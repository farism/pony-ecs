use "collections"

use "../ecs"

class Player is Component

  var name: String

  new create(name': String) =>
    name = name'

  fun flag(): PlayerFlag val =>
    PlayerFlag


primitive PlayerFlag

  fun value(): ComponentId =>
    1 << 0


class Position is Component

  var x: F64
  var y: F64
  var z: F64

  new create(x': F64 = 0, y': F64 = 0, z': F64 = 0) =>
    x = x'
    y = y'
    z = z'

  fun flag(): PositionFlag val =>
    PositionFlag

  fun value(): ComponentId val =>
    1 << 1


primitive PositionFlag

  fun value(): ComponentId =>
    1 << 1


class Velocity is Component

  var x: F64
  var y: F64
  var z: F64

  new create(x': F64 = 0, y': F64 = 0, z': F64 = 0) =>
    x = x'
    y = y'
    z = z'

  fun flag(): VelocityFlag val =>
    VelocityFlag


primitive VelocityFlag

  fun value(): ComponentId =>
    1 << 2
