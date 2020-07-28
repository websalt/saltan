import system except getCommand, setCommand, switch, `--`,
  packageName, version, author, description, license, srcDir, binDir, backend,
  skipDirs, skipFiles, skipExt, installDirs, installFiles, installExt, bin, foreignDeps,
  requires, task, packageName
import nimscriptapi, strutils
# Package

version       = "0.1.0"
author        = "websalt"
description   = "A package for calculating salt anagrams"
license       = "GPL-2.0"
srcDir        = "src"
binDir        = "bin"
bin           = @["saltan"]



# Dependencies

requires "nim >= 1.0.6"
requires "ajax >= 0.1.0"

onExit()
