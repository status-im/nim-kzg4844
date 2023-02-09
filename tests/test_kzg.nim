# nim-kzg4844
# Copyright (c) 2023 Status Research & Development GmbH
# Licensed under either of
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE))
#  * MIT license ([LICENSE-MIT](LICENSE-MIT))
# at your option.
# This file may not be copied, modified, or distributed except according to
# those terms.

{.used.}

import
  unittest2,
  ../kzg4844/kzg,
  ./types

proc createKateBlobs(ctx: KzgCtx, n: int): KateBlobs =
  var blob: KzgBlob
  for i in 0..<n:
    discard urandom(blob)
    for i in 0..<len(blob):
      # don't overflow modulus
      if blob[i] > MAX_TOP_BYTE and i %% BYTES_PER_FIELD_ELEMENT == 31:
        blob[i] = MAX_TOP_BYTE
    result.blobs.add(blob)

  for i in 0..<n:
    let res = ctx.toCommitment(result.blobs[i])
    doAssert res.isOk
    result.kates.add(res.get)

suite "verify proof (high-level)":
  var ctx: KzgCtx

  test "load trusted setup from string":
    let res = loadTrustedSetupFromString(trustedSetup)
    check res.isOk
    ctx = res.get

  test "verify proof success":
    let kb = ctx.createKateBlobs(nblobs)
    let pres = ctx.computeProof(kb.blobs)
    check pres.isOk
    let res = ctx.verifyProof(kb.blobs, kb.kates, pres.get)
    check res.isOk

  test "verify proof failure":
    let kb = ctx.createKateBlobs(nblobs)
    let pres = ctx.computeProof(kb.blobs)
    check pres.isOk

    let other = ctx.createKateBlobs(nblobs)
    let badProof = ctx.computeProof(other.blobs)
    check badProof.isOk

    let res = ctx.verifyProof(kb.blobs, kb.kates, badProof.get)
    check res.isErr

  test "verify proof":
    let kp = ctx.computeProof(blob, inputPoint)
    check kp.isOk
    check kp.get == proof

    let res = ctx.verifyProof(commitment, inputPoint, claimedValue, kp.get)
    check res.isOk
