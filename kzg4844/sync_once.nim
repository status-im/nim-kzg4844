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

  template lockSection*(z: var SyncOnce, condition: static[bool], body: untyped): auto =
    withLock z.lock:
      if z.done.load == condition:
        body
        z.done.store(not condition)

  template syncOnce*(z: SyncOnce, condition: static[bool], body: untyped): auto =
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

  template lockSection*(z: var SyncOnce, condition: static[bool], body: untyped): auto =
    if z.done == condition:
      body
      z.done = not condition

  template syncOnce*(z: SyncOnce, condition: static[bool], body: untyped): auto =
    if z.done == condition:
      body

template lockSection*(z: var SyncOnce, body: untyped): auto =
  lockSection(z, false, body)

template syncOnce*(z: SyncOnce, body: untyped): auto =
  syncOnce(z, false, body)

proc `=copy`(
    dest: var SyncOnce, src: SyncOnce
) {.error: "Copying SyncOnce is forbidden".} =
  # https://pubs.opengroup.org/onlinepubs/9699919799/functions/V2_chap02.html#tag_15_09_09 states that
  # > The effect of referring to a copy of the object when locking, unlocking, or destroying it is undefined.
  # So we forbid copying a SyncOnce because it contains a `Lock` object derived from pthreads mutex on Linux cs.
  discard
  