# nim-kzg4844
# Copyright (c) 2023 Status Research & Development GmbH
# Licensed under either of
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE))
#  * MIT license ([LICENSE-MIT](LICENSE-MIT))
# at your option.
# This file may not be copied, modified, or distributed except according to
# those terms.

{.warning[UnusedImport]:off.}

import
  unittest2,
  ../kzg4844/kzg,
  ../kzg4844/kzg_abi

# do nothing else, all tests are done in c-kzg-4844.
# we only need to make sure our imports are compileable

test "Check that trusted setup can be loaded":
  check:
    loadTrustedSetupFromString(trustedSetup, 0) == Result[void, string].ok()
