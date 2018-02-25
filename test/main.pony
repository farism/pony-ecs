use "ponytest"

use "../core/core"

actor Main is TestList
  new create(env: Env) =>
    PonyTest(env, this)

  new make() =>
    None

  fun tag tests(test: PonyTest) =>
    test(_TestAdd)
    test(_TestMultiply)

class iso _TestAdd is UnitTest
  fun name(): String => "addition"

  fun apply(h: TestHelper) =>
    h.assert_eq[U32](4, Core.add(2, 2))

class iso _TestMultiply is UnitTest
  fun name(): String => "multiplication"

  fun apply(h: TestHelper) =>
    h.assert_eq[U32](4, Core.mult(2, 2))
