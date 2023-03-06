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
  ../kzg4844/kzg_ex,
  ./types

proc createKateBlobs(n: int): KateBlobs =
  var blob: KzgBlob
  for i in 0..<n:
    discard urandom(blob)
    for i in 0..<len(blob):
      # don't overflow modulus
      if blob[i] > MAX_TOP_BYTE and i %% BYTES_PER_FIELD_ELEMENT == 31:
        blob[i] = MAX_TOP_BYTE
    result.blobs.add(blob)

  for i in 0..<n:
    let res = toCommitment(result.blobs[i])
    doAssert res.isOk
    result.kates.add(res.get)

suite "verify proof (extended version)":
  test "load trusted setup from string":
    let res = Kzg.loadTrustedSetupFromString(trustedSetup)
    check res.isOk

  test "verify batch proof success":
    let kb = createKateBlobs(nblobs)
    var kp: array[nblobs, KzgProof]
    for i in 0..<nblobs:
      let pres = computeProof(kb.blobs[i])
      check pres.isOk
      kp[i] = pres.get

    let res = verifyProofs(kb.blobs, kb.kates, kp)
    check res.isOk

  test "verify batch proof failure":
    let kb = createKateBlobs(nblobs)
    var kp: array[nblobs, KzgProof]
    for i in 0..<nblobs:
      let pres = computeProof(kb.blobs[i])
      check pres.isOk
      kp[i] = pres.get

    let other = createKateBlobs(nblobs)
    var badProofs: array[nblobs, KzgProof]
    for i in 0..<nblobs:
      let pres = computeProof(other.blobs[i])
      check pres.isOk
      badProofs[i] = pres.get

    let res = verifyProofs(kb.blobs, kb.kates, badProofs)
    check res.isErr

  test "verify blob proof":
    let kp = computeProof(blob)
    check kp.isOk

    let res = verifyProof(blob, commitment, kp.get)
    check res.isOk

  test "verify proof":
    let kp = computeProof(blob, inputPoint)
    check kp.isOk
    check kp.get == proof

    let res = verifyProof(commitment, inputPoint, claimedValue, kp.get)
    check res.isOk
