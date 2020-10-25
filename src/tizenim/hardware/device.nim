import classes
import ../native

## Represents the current device
class Device:

    ## Vibrate the device for the specified amount of time
    method vibrate(durationMilliseconds: int, strength: int = 100) {.static.} =

        discard