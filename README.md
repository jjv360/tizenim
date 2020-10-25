# TizeNim

![](https://img.shields.io/badge/status-pre--alpha-red)

This tool allows you to write Tizen watch apps for the Samsung Galaxy watches using Nim.

> Make sure your Tizen environment is set up correctly for building native applications. There are some guides [here](https://developer.tizen.org/dev-guide/training/native-app/en/wearable_native/index.html).

## Installation

To install, clone this repo and then run `nimble install`. It works well with [nim-classes](https://github.com/jjv360/nim-classes), though you don't have to use it.

## Example app

```ini
# Create file: tizen.config
main = "src/App.nim"
```

```nim
# Create file: src/app.nim
import tizenim/tizenapp
import tizenim/ui/window
import tizenim/ui/label
import tizenim/ui/view
import classes


# Create a window subclass
class MyWindow of Window:

    ## Called on create
    method onCreate() =
        super.onCreate()

        # Create center label
        let centerLabel = Label().init()
        centerLabel.autoresizingFlags = { FlexibleTopMargin, FlexibleBottomMargin, FlexibleWidth }
        centerLabel.setPosition(20, this.frame.size.height/2)
        centerLabel.setSize(this.frame.size.width-40, 100)
        centerLabel.setText("<align=center>Hello world</align>")
        this.add(centerLabel)


# Create an app subclass
class MyApp of TizenApp:

    # On create
    method onCreate() =
        super.onCreate()
        
        # Create and show my window
        discard MyWindow.new()
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
main = "src/app.nim"                    # Your app's entry point
packageID = "com.example.TizenimApp"    # Your app's unique package ID
resources = "res/"                      # All files in this folder will be installed with the app

# Advanced fields:
tizenSDK = "C:/tizen-studio"            # Path to your Tizen Studio installation
nimSDK = <auto>                         # Path to your Nim installation, with /bin/nim and /lib/system.nim files.
```
