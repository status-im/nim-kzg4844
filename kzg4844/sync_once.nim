# kzg-4844
# Copyright (c) 2026 Status Research & Development GmbH
# Licensed under either of
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE))
#  * MIT license ([LICENSE-MIT](LICENSE-MIT))
# at your option.
# This file may not be copied, modified, or distributed except according to
# those terms

{.push gcsafe, raises: [].}

when compileOption("threads"):
  import
    std/[atomics, locks]

  type
    SyncOnce* = object
      done: Atomic[bool]
      lock: Lock

  func init*(_: type SyncOnce): SyncOnce =
    result.done.store(false)
    result.lock.initLock()

  template lockSectionImpl(z: var SyncOnce, condition: static[bool], body: untyped): auto =
    withLock z.lock:
      if z.done.load == condition:
        body
        z.done.store(not condition)

  template syncOnceImpl(z: SyncOnce, condition: static[bool], body: untyped): auto =
    if z.done.load == condition:
      body

else:
  type
    SyncOnce* = object
      done: bool

  func init*(_: type SyncOnce): SyncOnce =
    SyncOnce(
      done: false,
    )

  template lockSectionImpl(z: var SyncOnce, condition: static[bool], body: untyped): auto =
    body

  template syncOnceImpl(z: SyncOnce, condition: static[bool], body: untyped): auto =
    if z.done == condition:
      body

# lockSectionImpl and syncOnceImpl is used as a workaround for
# Nim 2.0 vmgen ICE
template lockSection*(z: var SyncOnce, body: untyped): auto =
  lockSectionImpl(z, false, body)

template syncOnce*(z: SyncOnce, body: untyped): auto =
  syncOnceImpl(z, false, body)

template lockSection*(z: var SyncOnce, condition: static[bool], body: untyped): auto =
  lockSectionImpl(z, condition, body)

template syncOnce*(z: SyncOnce, condition: static[bool], body: untyped): auto =
  syncOnceImpl(z, condition, body)
