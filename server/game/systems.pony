use "collections"
use "time"

use "../ecs"

class Movement is System

  let _env: Env

  let _aspect: Aspect =  Aspect(where all = [PositionFlag; VelocityFlag])

  let _entities: SetIs[Entity] = SetIs[Entity]

  let _rate: F64 = F64.from[U64](Nanos.from_seconds(1))

  new create(env: Env) =>
    _env = env

  fun flag(): MovementFlag val =>
    MovementFlag

  fun ref aspect(): Aspect =>
    _aspect

  fun ref entities(): SetIs[Entity] =>
    _entities

  fun ref update(t: F64, dt: F64) =>
    for entity in _entities.values() do
      try
        let position = entity.as_component[Position](PositionFlag)?
        let velocity = entity.as_component[Velocity](VelocityFlag)?
        let rate = dt / _rate
        position.x = position.x + (rate * velocity.x)
        position.y = position.y + (rate * velocity.y)
      end
    end


primitive MovementFlag

  fun value(): U64 =>
    1 << 0
