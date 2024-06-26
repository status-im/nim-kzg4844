# nim-kzg4844
# Copyright (c) 2023-2024 Status Research & Development GmbH
# Licensed under either of
#  * Apache License, version 2.0, ([LICENSE-APACHE](LICENSE-APACHE))
#  * MIT license ([LICENSE-MIT](LICENSE-MIT))
# at your option.
# This file may not be copied, modified, or distributed except according to
# those terms.

mode = ScriptMode.Verbose

packageName   = "kzg4844"
version       = "0.1.0"
author        = "Status Research & Development GmbH"
description   = "c-kzg-4844 wrapper in Nim"
license       = "Apache License 2.0"
skipDirs      = @["tests"]

requires "nim >= 1.6.0"
requires "stew >= 0.1.0"
requires "unittest2"

let cfg =
  " --outdir:build -f -c --hints:off --warnings:off" &
  " --styleCheck:usages --styleCheck:error --skipParentCfg" &
  " -d:release -d:kzgExternalBlstNoSha256 -d:kzgExternalBlst"

# Helper functions
proc test(args, path: string) =
  if not dirExists "build":
    mkDir "build"
  exec "nim " & getEnv("TEST_LANG", "c") & " " & getEnv("NIMFLAGS") & " " &
    cfg & " " & args & " " & path

task test, "Run all tests":
  test "--mm:refc", "tests/test_all"
  if (NimMajor, NimMinor) > (1, 6):
    test "--mm:orc", "tests/test_all"
