# TizeNim

![](https://img.shields.io/badge/status-pre--alpha-red)

This tool allows you to write Tizen watch apps for the Samsung Galaxy watches using Nim.

> Make sure the Samsung Certificate Extension and Samsung Wearable Extension are installed, and that you've created a **Samsung** certificate in the Certificate Manager! It must be a **Samsung** certificate.

## Installation

To install, clone this repo and then run `nimble install`.

## Example app

```ini
# Create file: tizen.config
main = "src/App.nim"
```

```nim
# Create file: src/App.nim
import tizenim/TizenApp
import tizenim/ui/Window
import tizenim/ui/Label
import tizenim/ui/View


# Create a window subclass
type MyWindow* = ref object of Window

## Called on create
method onCreate(this: MyWindow) =
    procCall this.Window.onCreate()

    # Create center label
    let centerLabel = Label().init()
    centerLabel.autoresizingFlags = { FlexibleTopMargin, FlexibleBottomMargin, FlexibleWidth }
    centerLabel.setPosition(20, this.frame.size.height/2)
    centerLabel.setSize(this.frame.size.width-40, 100)
    centerLabel.setText("<align=center>Hello world</align>")
    this.add(centerLabel)


# Create an app subclass
type MyApp* = ref object of TizenApp

# On create
method onCreate(this: MyApp) =
    procCall this.TizenApp.onCreate()
    
    # Create and show my window
    discard MyWindow().init()
```

```sh
# Now make sure your watch is connected in the Device Manager, and then run the app:
$ tizenim launch
```

## Config options

```ini
# Default values for the tizen.config file:
name = "Tizenim App"                    # Your app's name, appears in the app list
version = "1.0.0"                       # Your app's version
main = "src/App.nim"                    # Your app's entry point
packageID = "com.example.TizenimApp"    # Your app's unique package ID
resources = "res/"                      # All files in this folder will be installed with the app

# Advanced fields:
tizenSDK = "C:/tizen-studio"            # Path to your Tizen Studio installation
nimSDK = <auto>                         # Path to your Nim installation, with /bin/nim and /lib/system.nim files.
```
