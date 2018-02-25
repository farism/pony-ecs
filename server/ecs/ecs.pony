use "collections"
use "time"

type EntityId is U64


type ComponentId is U64


type SystemId is U64


type ComponentMap is MapIs[ComponentId, Component]


interface ComponentFlag is Flag[ComponentId val]

  fun value(): ComponentId


interface Component

  fun flag(): ComponentFlag val


interface SystemFlag is Flag[SystemId val]

  fun value(): SystemId


interface System

  fun flag(): SystemFlag val

  fun ref update(t: F64, dt: F64)

  fun ref entities(): SetIs[Entity]

  fun ref aspect(): Aspect

  fun ref check_aspect(entity: Entity): Bool =>
    aspect().check(entity.component_flags())

  fun ref add_entity(entity: Entity) =>
    entities().set(entity)

  fun ref remove_entity(entity: Entity) =>
    entities().unset(entity)


primitive NotFoundComponent

  fun flag(): NotFoundFlag val =>
    NotFoundFlag


primitive NotFoundFlag

  fun value(): ComponentId =>
    0


class Aspect[A: Flag[ComponentId] val = ComponentFlag val]

    let _all: Flags[A] = Flags[A]

    let _none: Flags[A] = Flags[A]

    let _one: Flags[A] = Flags[A]

    new create(all: Array[A] = [], none: Array[A] = [], one: Array[A] = []) =>
      set_flags(all, _all)
      set_flags(none, _none)
      set_flags(one, _one)

    fun set_flags(flags: Array[A], target: Flags[A]) =>
      for flag in flags.values() do target.set(flag) end

    fun ref check_all(flags: Flags[A] box): Bool =>
      (_all.value() == 0) or (_all.op_or(flags).value() == flags.value())

    fun ref check_none(flags: Flags[A] box): Bool =>
      (_none.value() == 0) or (_none.op_and(flags).value() == 0)

    fun ref check_one(flags: Flags[A] box): Bool =>
      (_one.value() == 0) or (_one.op_and(flags).value() != 0)

    fun ref check(flags: Flags[A] box): Bool =>
      check_all(flags) and check_none(flags) and check_one(flags)


class Entity

  let _component_flags: Flags[ComponentFlag val] = Flags[ComponentFlag val]

  let _system_flags: Flags[ComponentFlag val] = Flags[ComponentFlag val]

  let _world: World

  let _id: EntityId

  new create(world': World ref, id': EntityId) =>
    _world = world'
    _id = id'

  fun world(): this->World =>
    _world

  fun id(): this->EntityId =>
    _id

  fun ref as_component[T: Component](flag: ComponentFlag val): T ? =>
    _world.get_component[T](flag, this)?

  fun ref add_component(component: Component) =>
    _component_flags.set(component.flag())
    _world.add_component(component, this)

  fun ref remove_component(component: Component) =>
    _component_flags.unset(component.flag())
    _world.remove_component(component, this)

  fun ref add_system(system: System) =>
    _system_flags.set(system.flag())

  fun ref remove_system(system: System) =>
    _system_flags.unset(system.flag())

  fun component_flags(): Flags[ComponentFlag val] box =>
    _component_flags

  fun system_flags(): Flags[SystemFlag val] box =>
    _system_flags


class World

  let _env: Env

  var _next_id: EntityId = 0

  let _entities: SetIs[Entity] = SetIs[Entity]

  let _components: MapIs[EntityId, ComponentMap] = MapIs[EntityId, ComponentMap]

  let _systems: SetIs[System] = SetIs[System]

  new create(env: Env) =>
    _env = env

  fun ref create_entity(): Entity =>
    _next_id = _next_id + 1
    Entity(this, _next_id)

  fun ref add_entity(entity: Entity) =>
    _entities.set(entity)

  fun ref remove_entity(entity: Entity) =>
    _entities.unset(entity)

  fun ref get_component[T: Component](
    flag: ComponentFlag val,
    entity: Entity
  ): T ? =>
    let entity_components = _components.get_or_else(entity.id(), ComponentMap)

    try
      entity_components(flag.value())? as T
    else
      error
    end

  fun ref add_component(component: Component, entity: Entity) =>
    let entity_components = _components.get_or_else(entity.id(), ComponentMap)

    try
      entity_components.insert(component.flag().value(), component)?
      _components.insert(entity.id(), entity_components)?
    end

    check_system_aspects(entity)

  fun ref remove_component(component: Component, entity: Entity) =>
    let entity_components = _components.get_or_else(entity.id(), ComponentMap)

    try
      entity_components.remove(component.flag().value())?
      _components.insert(entity.id(), entity_components)?
    end

    check_system_aspects(entity)

  fun ref check_system_aspects(entity: Entity) =>
    for system in _systems.values() do
      if system.check_aspect(entity) then
        system.add_entity(entity)
      else
        system.remove_entity(entity)
      end
    end

  fun ref add_system(system: System) =>
    _systems.set(system)

  fun ref remove_system(system: System) =>
    _systems.unset(system)

  fun ref update(t: F64, dt: F64) =>
    for system in _systems.values() do
      system.update(t, dt)
    end


class Loop

  let _dt: F64

  var _acc: F64 = 0

  new create(dt: F64) =>
    _dt = dt

  fun ref start(fn: {ref(F64, F64)}) =>
    var lag: F64 = 0
    var elapsed: F64 = 0
    var current: F64 = 0
    var previous: F64 = 0

    previous = F64.from[U64](Time.nanos())

    while (_acc < F64.from[U64](Nanos.from_seconds(3))) do
      current = F64.from[U64](Time.nanos())
      elapsed = current - previous
      previous = current
      lag = lag + elapsed
      _acc = _acc + elapsed

      while(lag >= _dt) do
        fn(_acc, _dt)
        lag = lag - _dt
      end
    end
