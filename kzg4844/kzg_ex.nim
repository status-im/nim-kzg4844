# nim-kzg4844
# Copyright (c) 2023 Status Research & Development GmbH
# Licensed under either of
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE))
#  * MIT license ([LICENSE-MIT](LICENSE-MIT))
# at your option.
# This file may not be copied, modified, or distributed except according to
# those terms.

import
  stew/results,
  ./kzg

export
  results,
  kzg

type
  Kzg* = object
  Bytes32 = array[32, byte]

when (NimMajor, NimMinor) < (1, 4):
  {.push raises: [Defect].}
else:
  {.push raises: [].}

##############################################################
# Private helpers
##############################################################

var gCtx: KzgCtx

const
  GlobalCtxErr = "kzg global context not loaded"

template setupCtx(body: untyped): untyped =
  let res = body
  if res.isErr:
    return err(res.error)
  gCtx = res.get
  ok()

template verifyCtx(body: untyped): untyped =
  {.gcsafe.}:
    if gCtx.isNil:
      return err(GlobalCtxErr)
    body

##############################################################
# Public functions
##############################################################

proc loadTrustedSetup*(_: type Kzg,
                       input: File): Result[void, string] =
  setupCtx:
    kzg.loadTrustedSetup(input)

proc loadTrustedSetup*(_: type Kzg,
                       fileName: string): Result[void, string] =
  setupCtx:
    kzg.loadTrustedSetup(fileName)

proc loadTrustedSetup*(_: type Kzg, g1: openArray[G1Data],
                       g2: openArray[G2Data]):
                           Result[void, string] =
  setupCtx:
    kzg.loadTrustedSetup(g1, g2)

proc loadTrustedSetupFromString*(_: type Kzg,
                                 input: string): Result[void, string] =
  setupCtx:
    kzg.loadTrustedSetupFromString(input)

proc toCommitment*(blob: KzgBlob):
                    Result[KzgCommitment, string] {.gcsafe.} =
  verifyCtx:
    gCtx.toCommitment(blob)

proc computeProof*(blob: KzgBlob,
                   z: Bytes32): Result[KzgProof, string] {.gcsafe.} =
  verifyCtx:
    gCtx.computeProof(blob, z)

proc computeProof*(blob: KzgBlob):
                     Result[KzgProof, string] {.gcsafe.} =
  verifyCtx:
    gCtx.computeProof(blob)

proc verifyProof*(commitment: KzgCommitment,
                  z: Bytes32, # Input Point
                  y: Bytes32, # Claimed Value
                  proof: KzgProof): Result[void, string] {.gcsafe.} =
  verifyCtx:
    gCtx.verifyProof(commitment, z, y, proof)

proc verifyProof*(blob: KzgBlob,
                  commitment: KzgCommitment,
                  proof: KzgProof): Result[void, string] {.gcsafe.} =
  verifyCtx:
    gCtx.verifyProof(blob, commitment, proof)

proc verifyProofs*(blobs: openArray[KzgBlob],
                  commitments: openArray[KzgCommitment],
                  proofs: openArray[KzgProof]): Result[void, string] {.gcsafe.} =
  verifyCtx:
    gCtx.verifyProofs(blobs, commitments, proofs)

{. pop .}
