import classes
import ../native

## A timer class executes code at a specified interval
class Timer:

    ## Intenal timer object
    var ecoreTimer: Ecore_Timer

    ## Interval to execute at, in seconds
    var interval = 1.0

    ## If true, will remove the timer after the first run
    var onceOnly = false

    ## Function to execute
    var callback: proc()

    ## Start the timer
    method start() =

        # Stop if already started
        if this.ecoreTimer != nil:
            this.stop()

        # Reference this object permanently, so it's never garbage collected
        GC_ref(this)

        # Create ecore timer
        this.ecoreTimer = ecore_timer_add(this.interval, proc(userData: pointer): bool {.cdecl.} =
            return cast[Timer](userData).onTimerTick()    
        , cast[pointer](this))


    ## Stop a timer
    method stop() =

        # Stop if already stopped
        if this.ecoreTimer == nil:
            return

        # Remove GC reference
        GC_unref(this)

        # Stop timer
        ecore_timer_del(this.ecoreTimer)
        this.ecoreTimer = nil


    ## Alias for .stop()
    method cancel() = this.stop()


    ## Internal. Called on timer execute.
    method onTimerTick(): bool =

        # Call user function if set
        if this.callback != nil:
            this.callback()

        # Stop if this is a recurring timer
        if not this.onceOnly:
            return true

        # Don't renew the timer
        this.ecoreTimer = nil
        GC_unref(this)
        return false


## Shorthand timer creation, execute the specified code after the specified number of seconds
proc delay*(duration: float, body: proc()): Timer {.discardable.} =
    let t = Timer.init()
    t.interval = duration
    t.onceOnly = true
    t.callback = body
    t.start()


## Shorthand timer creation, execute the specified code continuously
proc createTimer*(duration: float, body: proc()): Timer {.discardable.} =
    let t = Timer.init()
    t.interval = duration
    t.onceOnly = false
    t.callback = body
    t.start()