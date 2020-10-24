#
# Define the Tizen app interface

import os
import native
import dlog
import strformat
import classes

# Class description
class TizenApp:

    # Event functions subclasses can override
    method onCreate() = discard
    method onPause() = discard
    method onResume() = discard
    method onTerminate() = discard
    method onLowMemory() = discard
    method onAppControl(event: app_control_h) = discard

    # Execute the project
    method run() {. noReturn .} =

        # Initialize Ecore_Evas
        # if ecore_evas_init() == 0:
        #     dlog "[TizenApp] Unable to init ecore_evas"

        # Add callbacks
        let callbacks = new(ui_app_lifecycle_callback_s)
        callbacks.pause = proc(this: pointer) = cast[TizenApp](this).onPause()
        callbacks.resume = proc(this: pointer) = cast[TizenApp](this).onResume()
        callbacks.terminate = proc(this: pointer) = cast[TizenApp](this).onTerminate()
        callbacks.control = proc(app_control: pointer, this: pointer) = cast[TizenApp](this).onAppControl(app_control)
        callbacks.create = proc(this: pointer) : bool = 
            cast[TizenApp](this).onCreate()
            return true

        # Add low memory warning event listener
        let funct: app_event_cb = proc(info: app_event_info_h, this: pointer) {. cdecl .} = cast[TizenApp](this).onLowMemory()
        var handler = new(app_event_handler_h)
        discard ui_app_add_event_handler(handler, APP_EVENT_LOW_MEMORY, funct, cast[pointer](this))

        # Get params
        var nargv = newSeq[string](paramCount())
        var x = 0
        while x < paramCount():
            nargv[x] = paramStr(x)
            x += 1

        # Run the app's event loop
        var argv: cStringArray = nargv.allocCStringArray()
        let code = ui_app_main(cast[cint](paramCount()), argv, callbacks, cast[pointer](this))
        argv.deallocCStringArray()

        # Closed
        discard dlog_print(DLOG_INFO, "TizenApp", fmt"UI app exited with code: {code}")


# Immediately log, first thing. This is used by the log tracer to find our PID.
discard dlog_print(DLOG_DEBUG, "TizenApp", "=== START NIM LOG ===")