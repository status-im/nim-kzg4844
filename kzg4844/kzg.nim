# nim-kzg4844
# Copyright (c) 2023 Status Research & Development GmbH
# Licensed under either of
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE))
#  * MIT license ([LICENSE-MIT](LICENSE-MIT))
# at your option.
# This file may not be copied, modified, or distributed except according to
# those terms.

{. warning[UnusedImport]:off .}

import
  ./csources/bindings/nim/kzg,
  ./kzg_abi # compile sha256.c

export
  kzg
