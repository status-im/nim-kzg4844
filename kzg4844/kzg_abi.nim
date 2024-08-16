# nim-kzg4844
# Copyright (c) 2023-2024 Status Research & Development GmbH
# Licensed under either of
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE))
#  * MIT license ([LICENSE-MIT](LICENSE-MIT))
# at your option.
# This file may not be copied, modified, or distributed except according to
# those terms.

# Ensure "c_kzg_4844.h" in this directory takes precedence
import std/[os, strutils]
{.passc: "-I" & quoteShell(currentSourcePath.rsplit({DirSep, AltSep}, 1)[0]).}

import
  ./csources/bindings/nim/kzg_abi

export
  kzg_abi

when defined(kzgExternalBlstNoSha256):
  import std/strutils
  from os import DirSep
  const
    kzgPath  = currentSourcePath.rsplit(DirSep, 1)[0] & "/"
  {.compile: kzgPath & "sha256.c"}
