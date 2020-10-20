# Package

version       = "0.1.0"
author        = "jjv360"
description   = "Create apps for Tizen using the Nim language."
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["tizenim"]


# Dependencies

requires "nim >= 1.4.0"
requires "docopt"