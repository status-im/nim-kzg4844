# nim-kzg4844
# Copyright (c) 2023 Status Research & Development GmbH
# Licensed under either of
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE))
#  * MIT license ([LICENSE-MIT](LICENSE-MIT))
# at your option.
# This file may not be copied, modified, or distributed except according to
# those terms.

import
  test_abi,
  test_kzg,
  test_kzg_ex

when (NimMajor, NimMinor) >= (1, 4) and 
     (NimMajor, NimMinor) <= (1, 6):
  # nim devel causes shallowCopy error
  # on yaml
  import
    test_yaml
