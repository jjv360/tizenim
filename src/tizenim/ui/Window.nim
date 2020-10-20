import View
import ../native
import ../templates
import ../dlog
import ../types
import strformat

#
# Window class
type Window* = ref object of View

    ## Evas_Object representing the window itself.
    evasWindow: Elm_Win

    ## Evas_Object representing the "conformant" view
    evasConformant: Evas_Object


# Lower the window in the view stack
method lowerIt*(this: Window) = elm_win_lower(this.evasWindow)

# Raise the window in the view stack
method raiseIt*(this: Window) = elm_win_raise(this.evasWindow)


# Override the evas object init, since windows have custom behaviour logic here
method initEvasObject*(this: Window, parent: Evas_Object) {. private .} = discard
method destroyEvasObject*(this: Window) {. private .} = discard
method setPosition*(this: Window, x: float, y: float) = discard
method setSize*(this: Window, width: float, height: float) = discard


## Called when the window is resized by the system
method onWindowResized(this: Window) {.base.} =

    # Match our in-memory size with the actual size
    var x = 0
    var y = 0
    var w = 0
    var h = 0
    evas_object_geometry_get(this.evasWindow, x, y, w, h)
    procCall this.View.setSize(w.toFloat(), h.toFloat())


## Called when the hardware back key is pressed. Override this if you want to perform different behaviour than just closing the window.
method onBackKey*(this: Window) {.base.} =

    # Hide window
    this.lowerIt()


## Called when the user twists the rotary dial
method onRotaryEvent*(this: Window, isClockwise: bool) {.base.} = discard


# Initialize the window
method init*(this: Window): Window {. base .} =
    discard procCall this.View.init()

    # Create the window
    this.evasWindow = elm_win_util_standard_add("org.example.tizen-project", "Window")
    evas_object_show(this.evasWindow)

    # Create conformant view, which handles resizing based on virtual keyboards etc
    # this.evasConformant = elm_conformant_add(this.evasWindow)
    # elm_win_resize_object_add(this.evasWindow, this.evasConformant)
    # evas_object_size_hint_weight_set(this.evasConformant, EVAS_HINT_EXPAND, EVAS_HINT_EXPAND)
    # evas_object_show(this.evasConformant)

    # Create the evas container now
    procCall this.View.initEvasObject(this.evasWindow)

    # Add a resize listener
    evas_object_event_callback_add(this.evasWindow, EVAS_CALLBACK_RESIZE, proc (this: pointer, e: Evas, sourceObject: Evas_Object, eventInfo: pointer) {.cdecl.} = cast[Window](this).onWindowResized(), cast[pointer](this))

    # Create hardware key listeners
    eext_object_event_callback_add(this.evasWindow, EEXT_CALLBACK_BACK, proc(this: pointer, src: Evas_Object, info: pointer) {.cdecl.} = cast[Window](this).onBackKey(), cast[pointer](this))
    discard eext_rotary_object_event_callback_add(this.evasWindow, proc(this: pointer, src: Evas_Object, info: ref Eext_Rotary_Event_Info): bool {.cdecl.} = cast[Window](this).onRotaryEvent(info.direction == EEXT_ROTARY_DIRECTION_CLOCKWISE), cast[pointer](this))
    eext_rotary_object_event_activated_set(this.evasWindow, true)

    # Call hooks
    this.onCreate()

    # Done
    return this