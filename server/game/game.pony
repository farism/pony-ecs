use "collections"
use "time"

use "../ecs"

class Game

  let _world: World

  new create(env: Env) =>
    _world = World(env)

    let s = Movement(env)
    _world.add_system(s)

    let e = _world.create_entity()
    e.add_component(Player("joe"))
    e.add_component(Position())
    e.add_component(Velocity(0, 1))
    _world.add_entity(consume e)

    let e2 = _world.create_entity()
    e2.add_component(Player("bob"))
    e2.add_component(Position())
    e2.add_component(Velocity(1))
    _world.add_entity(consume e2)

    env.out.print("starting game loop")

    let loop = Loop(F64.from[U64](Nanos.from_millis(16)))

    loop.start({(t: F64, dt: F64) => _world.update(t, dt)})

    env.out.print("finished game loop")
