# nim-kzg4844
# Copyright (c) 2023 Status Research & Development GmbH
# Licensed under either of
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE))
#  * MIT license ([LICENSE-MIT](LICENSE-MIT))
# at your option.
# This file may not be copied, modified, or distributed except according to
# those terms.

import
  std/[streams, strutils],
  kzg_abi,
  stew/[results, byteutils]

export
  results,
  kzg_abi

type
  KzgCtx* = ref object
    val: KzgSettings

  G1Data* = array[48, byte]
  G2Data* = array[96, byte]

  Bytes32 = array[32, byte]

when (NimMajor, NimMinor) < (1, 4):
  {.push raises: [Defect].}
else:
  {.push raises: [].}

##############################################################
# Private helpers
##############################################################

proc destroy*(x: KzgCtx) =
  free_trusted_setup(x.val)

proc newKzgCtx(): KzgCtx =
  # Nim finalizer is still broken(v1.6)
  # consider to call destroy directly
  new(result, destroy)

template getPtr(x: untyped): auto =
  when (NimMajor, NimMinor) <= (1,6):
    unsafeAddr(x)
  else:
    addr(x)

template verify(res: KZG_RET) =
  if res != KZG_OK:
    return err($res)

##############################################################
# Public functions
##############################################################

proc loadTrustedSetup*(input: File): Result[KzgCtx, string] =
  let
    ctx = newKzgCtx()
    res = load_trusted_setup_file(ctx.val, input)

  verify(res)
  ok(ctx)

proc loadTrustedSetup*(fileName: string): Result[KzgCtx, string] =
  try:
    let file = open(fileName)
    result = file.loadTrustedSetup()
    file.close()
  except IOError as ex:
    return err(ex.msg)

proc loadTrustedSetup*(g1: openArray[G1Data],
                       g2: openArray[G2Data]):
                         Result[KzgCtx, string] =
  if g1.len == 0 or g2.len == 0:
    return err($KZG_BADARGS)

  let
    ctx = newKzgCtx()
    res = load_trusted_setup(ctx.val,
      g1[0][0].getPtr,
      g1.len.csize_t,
      g2[0][0].getPtr,
      g2.len.csize_t)

  verify(res)
  ok(ctx)

proc loadTrustedSetupFromString*(input: string): Result[KzgCtx, string] =
  var
    s = newStringStream(input)
    g1: array[FIELD_ELEMENTS_PER_BLOB, G1Data]
    g2: array[65, G2Data]

  try:
    let fieldElems = s.readLine().parseInt()
    doAssert fieldElems == FIELD_ELEMENTS_PER_BLOB
    let numG2 = s.readLine().parseInt()
    doAssert numG2 == 65

    for i in 0 ..< FIELD_ELEMENTS_PER_BLOB:
      g1[i] = hexToByteArray[48](s.readLine())

    for i in 0 ..< 65:
      g2[i] = hexToByteArray[96](s.readLine())
  except ValueError as ex:
    return err(ex.msg)
  except OSError as ex:
    return err(ex.msg)
  except IOError as ex:
    return err(ex.msg)

  loadTrustedSetup(g1, g2)

proc toCommitment*(ctx: KzgCtx,
                   blob: KzgBlob):
                     Result[KzgCommitment, string] {.gcsafe.} =
  var kate: KzgCommitment
  let res = blob_to_kzg_commitment(kate, blob, ctx.val)
  verify(res)
  ok(kate)

proc computeProof*(ctx: KzgCtx,
                   blob: KzgBlob,
                   z: Bytes32): Result[KzgProof, string] {.gcsafe.} =
  var proof: KzgProof
  let res = compute_kzg_proof(
    proof,
    blob,
    z,
    ctx.val)
  verify(res)
  ok(proof)

proc computeProof*(ctx: KzgCtx,
                   blob: KzgBlob): Result[KzgProof, string] {.gcsafe.} =
  var proof: KzgProof
  let res = compute_blob_kzg_proof(
    proof,
    blob,
    ctx.val)
  verify(res)
  ok(proof)

proc verifyProof*(ctx: KzgCtx,
                  commitment: KzgCommitment,
                  z: Bytes32, # Input Point
                  y: Bytes32, # Claimed Value
                  proof: KzgProof): Result[void, string] {.gcsafe.} =
  var ok: bool
  let res = verify_kzg_proof(
    ok,
    commitment,
    z,
    y,
    proof,
    ctx.val)
  verify(res)
  if not ok:
    return err($KZG_ERROR)
  ok()

proc verifyProof*(ctx: KzgCtx,
                  blob: KzgBlob,
                  commitment: KzgCommitment,
                  proof: KzgProof): Result[void, string] {.gcsafe.} =
  var ok: bool
  let res = verify_blob_kzg_proof(
    ok,
    blob,
    commitment,
    proof,
    ctx.val)
  verify(res)
  if not ok:
    return err($KZG_ERROR)
  ok()

proc verifyProofs*(ctx: KzgCtx,
                  blobs: openArray[KzgBlob],
                  commitments: openArray[KzgCommitment],
                  proofs: openArray[KzgProof]): Result[void, string] {.gcsafe.} =
  if blobs.len == 0 or
      commitments.len == 0 or
      proofs.len == 0:
    return err($KZG_BADARGS)

  if blobs.len != commitments.len:
    return err($KZG_BADARGS)

  if blobs.len != proofs.len:
    return err($KZG_BADARGS)

  var ok: bool
  let res = verify_blob_kzg_proof_batch(
    ok,
    blobs[0].getPtr,
    commitments[0].getPtr,
    proofs[0].getPtr,
    blobs.len.csize_t,
    ctx.val)
  verify(res)
  if not ok:
    return err($KZG_ERROR)
  ok()

{. pop .}
