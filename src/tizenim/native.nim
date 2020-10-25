#
# This class exposes the native API functions












############################## App lifecycle

type app_control_h* = pointer
type
  ui_app_lifecycle_callback_s* {.bycopy.} = object
    create*: proc (user_data: pointer): bool     ## *< This callback function is called at the start of the application.
    terminate*: proc (user_data: pointer) ## *< This callback function is called once after the main loop of the application exits.
    pause*: proc (user_data: pointer)       ## *< This callback function is called each time the application is completely obscured by another application and becomes invisible to the user.
    resume*: proc (user_data: pointer)     ## *< This callback function is called each time the application becomes visible to the user.
    control*: proc (app_control: app_control_h, user_data: pointer) ## *< This callback function is called when another application sends the launch request to the application.

## *
##  @brief Runs the application's main loop until ui_app_exit() is called.
##  @details This function is the main entry point of the Tizen application.
##           The app_create_cb() callback function is called to initialize the application before the main loop of application starts up.
##           After the app_create_cb() callback function returns true, the main loop starts up and the app_control_cb() callback function is subsequently called.
##           If the app_create_cb() callback function returns false, the main loop doesn't start up and app_terminate_cb() callback function is called.
##           This main loop supports event handling for the Ecore Main Loop.
##  @since_tizen @if MOBILE 2.3 @elseif WEARABLE 2.3.1 @endif
##  @param[in] argc The argument count
##  @param[in] argv The argument vector
##  @param[in] callback The set of callback functions to handle application lifecycle events
##  @param[in] user_data The user data to be passed to the callback functions
##  @return @c 0 on success,
## 			otherwise a negative error value
##  @retval #APP_ERROR_NONE Successful
##  @retval #APP_ERROR_INVALID_PARAMETER Invalid parameter
##  @retval #APP_ERROR_INVALID_CONTEXT The application is launched illegally, not launched by the launch system
##  @retval #APP_ERROR_ALREADY_RUNNING The main loop already started
##  @see app_create_cb()
##  @see app_terminate_cb()
##  @see app_pause_cb()
##  @see app_resume_cb()
##  @see app_control_cb()
##  @see ui_app_exit()
##  @see #ui_app_lifecycle_callback_s
##
proc ui_app_main*(argc: cint, argv: cstringArray, callback: ref ui_app_lifecycle_callback_s; user_data: pointer): cint {. header: "app.h" .}

type
  app_event_type_e* = enum
    APP_EVENT_LOW_MEMORY,     ## *< The low memory event
    APP_EVENT_LOW_BATTERY,    ## *< The low battery event
    APP_EVENT_LANGUAGE_CHANGED, ## *< The system language changed event
    APP_EVENT_DEVICE_ORIENTATION_CHANGED, ## *< The device orientation changed event
    APP_EVENT_REGION_FORMAT_CHANGED, ## *< The region format changed event
    APP_EVENT_SUSPENDED_STATE_CHANGED, ## *< The suspended state changed event of the application (since @if MOBILE 2.4 @elseif WEARABLE 3.0 @endif)
                                      ## 					     @see app_event_get_suspended_state
    APP_EVENT_UPDATE_REQUESTED ## *< The update requested event (Since 3.0)
                              ## 					This event can occur when an app needs to be updated.
                              ## 					It is dependent on target devices.

## *
##  @brief Adds the system event handler.
##  @since_tizen @if MOBILE 2.3 @elseif WEARABLE 2.3.1 @endif
##  @param[out] event_handler The event handler
##  @param[in] event_type The system event type
##  @param[in] callback The callback function
##  @param[in] user_data The user data to be passed to the callback functions
##  @return @c 0 on success,
## 			otherwise a negative error value
##  @retval #APP_ERROR_NONE Successful
##  @retval #APP_ERROR_INVALID_PARAMETER Invalid parameter
##  @retval #APP_ERROR_OUT_OF_MEMORY Out of memory
##  @see app_event_type_e
##  @see app_event_cb
##  @see ui_app_remove_event_handler
##
type app_event_handler_h* = pointer
type app_event_info_h* = pointer
type app_event_cb* = proc (event_info: app_event_info_h, user_data: pointer) {. cdecl .}
proc ui_app_add_event_handler*(event_handler: ref app_event_handler_h, event_type: app_event_type_e, callback: app_event_cb, user_data: pointer): cint {. header: "app.h" .}

## Get resource directory path
proc app_get_resource_path*(): cstring {. header: "app.h" .}

## Get shared resource directory path
proc app_get_shared_resource_path*(): cstring {. header: "app.h" .}











###################### Evas

type Evas* = pointer
type Evas_Object* = pointer

## Makes the object visible
proc evas_object_show*(obj: Evas_Object) {. header: "Evas.h" .}

## Makes the object hidden
proc evas_object_hide*(obj: Evas_Object) {. header: "Evas.h" .}

## Frees the given evas and any objects created on it.
##
## Any objects with 'free' callbacks will have those callbacks called
## in this function.
proc evas_free*(obj: Evas_Object) {. header: "Evas.h" .}

## Move the given Evas object to the given location inside its canvas' viewport.
proc evas_object_move*(obj: Evas_Object, x: int, y: int) {. header: "Evas.h" .}

## Changes the size of the given Evas object.
proc evas_object_resize*(obj: Evas_Object, width: int, height: int) {. header: "Evas.h" .}

const EVAS_HINT_EXPAND* = 1.0 # /**< Use with evas_object_size_hint_weight_set(), evas_object_size_hint_weight_get(), evas_object_size_hint_expand_set(), evas_object_size_hint_expand_get() */
const EVAS_HINT_FILL* = -1.0 # /**< Use with evas_object_size_hint_align_set(), evas_object_size_hint_align_get(), evas_object_size_hint_fill_set(), evas_object_size_hint_fill_get() */

## Sets the hints for an object's weight.
##
## This is not a size enforcement in any way, it's just a hint that should be
## used whenever appropriate.
##
## This is a hint on how a container object should resize a given child within
## its area. Containers may adhere to the simpler logic of just expanding the
## child object's dimensions to fit its own (see the #EVAS_HINT_EXPAND helper
## weight macro) or the complete one of taking each child's weight hint as real
## weights to how much of its size to allocate for them in each axis. A
## container is supposed to, after normalizing the weights of its children
## (with weight  hints), distribut the space it has to layout them by those
## factors -- most weighted children get larger in this process than the least
## ones.
##
## @note Default weight hint values are 0.0, for both axis.
proc evas_object_size_hint_weight_set*(obj: Evas_Object, x: float, y: float) {. header: "Evas.h" .}

## Adds a rectangle to the given evas.
proc evas_object_rectangle_add*(obj: Evas_Object): Evas_Object {. header: "Evas.h" .}

## Sets the general/main color of the given Evas object to the given one.
proc evas_object_color_set*(obj: Evas_Object, r: int, g: int, b: int, a: int) {. header: "Evas.h" .}

type Evas_Callback_Type* = enum
    EVAS_CALLBACK_MOUSE_IN,
    EVAS_CALLBACK_MOUSE_OUT,
    EVAS_CALLBACK_MOUSE_DOWN,
    EVAS_CALLBACK_MOUSE_UP,
    EVAS_CALLBACK_MOUSE_MOVE,
    EVAS_CALLBACK_MOUSE_WHEEL,
    EVAS_CALLBACK_MULTI_DOWN,
    EVAS_CALLBACK_MULTI_UP,
    EVAS_CALLBACK_MULTI_MOVE,
    EVAS_CALLBACK_FREE,
    EVAS_CALLBACK_KEY_DOWN,
    EVAS_CALLBACK_KEY_UP,
    EVAS_CALLBACK_FOCUS_IN,
    EVAS_CALLBACK_FOCUS_OUT,
    EVAS_CALLBACK_SHOW,
    EVAS_CALLBACK_HIDE,
    EVAS_CALLBACK_MOVE,
    EVAS_CALLBACK_RESIZE,
    EVAS_CALLBACK_RESTACK,
    EVAS_CALLBACK_DEL,
    EVAS_CALLBACK_HOLD,
    EVAS_CALLBACK_CHANGED_SIZE_HINTS,
    EVAS_CALLBACK_IMAGE_PRELOADED,
    EVAS_CALLBACK_CANVAS_FOCUS_IN,
    EVAS_CALLBACK_CANVAS_FOCUS_OUT,
    EVAS_CALLBACK_RENDER_FLUSH_PRE,
    EVAS_CALLBACK_RENDER_FLUSH_POST,
    EVAS_CALLBACK_CANVAS_OBJECT_FOCUS_IN,
    EVAS_CALLBACK_CANVAS_OBJECT_FOCUS_OUT,
    EVAS_CALLBACK_IMAGE_UNLOADED,
    EVAS_CALLBACK_RENDER_PRE,
    EVAS_CALLBACK_RENDER_POST,
    EVAS_CALLBACK_IMAGE_RESIZE,
    EVAS_CALLBACK_DEVICE_CHANGED,
    EVAS_CALLBACK_AXIS_UPDATE,
    EVAS_CALLBACK_CANVAS_VIEWPORT_RESIZE,
    EVAS_CALLBACK_LAST

type Evas_Object_Event_Cb* = proc (userData: pointer, e: Evas, sourceObject: Evas_Object, eventInfo: pointer) {. cdecl .}

## Add (register) a callback function to a given Evas object event.
proc evas_object_event_callback_add*(obj: Evas_Object, callbackType: Evas_Callback_Type, callback: Evas_Object_Event_Cb, userData: pointer) {. header: "Evas.h" .}



## Retrieves the position and (rectangular) size of the given Evas object.
proc evas_object_geometry_get*(obj: Evas_Object, x: var int, y: var int, w: var int, h: var int) {. header: "Evas.h" .}

## Delete an object
proc evas_object_del*(obj: Evas_Object) {. header: "Evas.h" .}

## Check if an image file type is supported
proc evas_object_image_extension_can_load_get*(file: cstring): bool {. header: "Evas.h" .}

## Create an image object
proc evas_object_image_add*(parent: Evas_Object): Evas_Object {. header: "Evas.h" .}

## Creates a new image object that automatically scales its bound image to the object's area, on both axis.
proc evas_object_image_filled_add*(parent: Evas_Object): Evas_Object {. header: "Evas.h" .}

## Set image object's file
proc evas_object_image_file_set*(obj: Evas_Object, file: cstring, key: cstring) {. header: "Evas.h" .}

type Emile_Image_Load_Error* = enum
    EMILE_IMAGE_LOAD_ERROR_NONE = 0,  #/**< No error on load */
    EMILE_IMAGE_LOAD_ERROR_GENERIC = 1,  #/**< A non-specific error occurred */
    EMILE_IMAGE_LOAD_ERROR_DOES_NOT_EXIST = 2,  #/**< File (or file path) does not exist */
    EMILE_IMAGE_LOAD_ERROR_PERMISSION_DENIED = 3,  #/**< Permission denied to an existing file (or path) */
    EMILE_IMAGE_LOAD_ERROR_RESOURCE_ALLOCATION_FAILED = 4,  #/**< Allocation of resources failure prevented load */
    EMILE_IMAGE_LOAD_ERROR_CORRUPT_FILE = 5,  #/**< File corrupt (but was detected as a known format) */
    EMILE_IMAGE_LOAD_ERROR_UNKNOWN_FORMAT = 6  #/**< File is not a known format */

## Get last image load error
proc evas_object_image_load_error_get*(obj: Evas_Object): Emile_Image_Load_Error {. header: "Evas.h" .}

## Appends a font path to the list of font paths used by the application.
proc evas_font_path_global_append*(path: cstring) {. header: "Evas.h" .}









############################ Efl

type Eext_Callback_Type* = enum EEXT_CALLBACK_BACK, EEXT_CALLBACK_MORE, EEXT_CALLBACK_LAST
type Eext_Event_Cb = proc(userData: pointer, sourceObject: Evas_Object, eventInfo: pointer) {.cdecl.}

## Add (register) a callback function to a given evas object.
proc eext_object_event_callback_add*(obj: Evas_Object, callbackType: Eext_Callback_Type, callback: Eext_Event_Cb, userData: pointer) {. header: "efl_extension.h" .}

type Eext_Rotary_Event_Direction* = enum
    EEXT_ROTARY_DIRECTION_CLOCKWISE,
    EEXT_ROTARY_DIRECTION_COUNTER_CLOCKWISE

type Eext_Rotary_Event_Info* = object
    direction*: Eext_Rotary_Event_Direction
    timestamp*: uint

type Eext_Rotary_Handler_Cb* = proc(userData: pointer, eventInfo: ref Eext_Rotary_Event_Info): bool {.cdecl.}

## Add (register) a handler for rotary event.
proc eext_rotary_event_handler_add*(callback: Eext_Rotary_Handler_Cb, userData: pointer): bool {. header: "efl_extension.h" .}

type Eext_Rotary_Event_Cb* = proc(userData: pointer, src: Evas_Object, eventInfo: ref Eext_Rotary_Event_Info): bool {.cdecl.}

## Add (register) a rotary event callback for evas object @a obj.
proc eext_rotary_object_event_callback_add*(obj: Evas_Object, callback: Eext_Rotary_Event_Cb, userData: pointer): bool {. header: "efl_extension.h" .}

## Activate an object as the receiver for rotary events
proc eext_rotary_object_event_activated_set*(obj: Evas_Object, activated: bool) {. header: "efl_extension.h" .}










####################### Ecore

##
## @internal
##
## @brief Creates a new Ecore_Evas based on engine name and common parameters.
##
## @param engine_name Engine name as returned by
##        ecore_evas_engines_get() or @c NULL to use environment variable
##        ECORE_EVAS_ENGINE, that can be undefined and in this case
##        this call will try to find the first working engine.
## @param x Horizontal position of window (not supported in all engines)
## @param y Vertical position of window (not supported in all engines)
## @param w Width of window
## @param h Height of window
## @param extra_options String with extra parameter, dependent on engines
##        or @ NULL. String is usually in the form: 'key1=value1;key2=value2'.
##        Pay attention that when getting that from shell commands, most
##        consider ';' as the command terminator, so you need to escape
##        it or use quotes.
##
## @return Ecore_Evas instance or @c NULL if creation failed.
##
proc ecore_evas_new*(engine_name: cstring, x: int, y: int, w: int, h: int, extra_options: cstring): Evas_Object {. header: "Ecore_Evas.h" .}

## Init, returns how many times the lib has been initialized, 0 indicates failure.
proc ecore_evas_init*(): int {. header: "Ecore_Evas.h" .}

type Ecore_Timer* = pointer

## Creates a timer to call the given function in the given period of time.
proc ecore_timer_add*(interval: cdouble, cb: proc(userData: pointer): bool {.cdecl.}, userData: pointer): Ecore_Timer {. header: "Ecore.h" .}

## Deletes the specified timer from the timer list.
proc ecore_timer_del*(timer: Ecore_Timer): pointer {.discardable, header: "Ecore.h".}











############################ Edje

## Instantiates a new Edje object.
proc edje_object_add*(parent: Evas_Object): Evas_Object {. header: "Edje.h" .}











######################### Elementary

type Elm_Win* = Evas_Object
type Elm_Image* = Evas_Object
type Elm_Transit* = pointer
type Elm_Transit_Effect* = pointer

## *
##  Adds a window object with standard setup
##
##  @param name The name of the window
##  @param title The title for the window
##
##  This creates a window like elm_win_add() but also puts in a standard
##  background with elm_bg_add(), as well as setting the window title to
##  @p title. The window type created is of type ELM_WIN_BASIC, with @c NULL
##  as the parent widget.
##
##  @return The created object, or @c NULL on failure
##
##  @see elm_win_add()
##
##  @ingroup Elm_Win
##
##  @if MOBILE @since_tizen 2.3
##  @elseif WEARABLE @since_tizen 2.3.1
##  @endif
##
proc elm_win_util_standard_add*(name: cstring, title: cstring): Elm_Win {. header: "Elementary.h" .}

## Places the window pointed by @c obj at the top of the stack, so that it's not covered by any other window.
proc elm_win_raise*(window: Elm_Win) {. header: "Elementary.h" .}

## Places the window pointed by @c obj at the bottom of the stack, so that no other window is covered by it.
proc elm_win_lower*(window: Elm_Win) {. header: "Elementary.h" .}

## Add a new label to the parent.
proc elm_label_add*(parent: Evas_Object): Evas_Object {. header: "Elementary.h" .}

## Set object text. NULL part is the default part.
proc elm_object_part_text_set*(obj: Evas_Object, part: cstring, text: cstring) {. header: "Elementary.h" .}

## Add a new conformant widget to the given parent Elementary (container) object.
proc elm_conformant_add*(window: Evas_Object): Evas_Object {. header: "Elementary.h" .}

## @brief Add @c subobj as a resize object of window @c obj.
##
## Setting an object as a resize object of the window means that the @c subobj
## child's size and position will be controlled by the window directly. That
## is, the object will be resized to match the window size and should never be
## moved or resized manually by the developer.
##
## In addition, resize objects of the window control what the minimum size of
## it will be, as well as whether it can or not be resized by the user.
##
## For the end user to be able to resize a window by dragging the handles or
## borders provided by the Window Manager, or using any other similar
## mechanism, all of the resize objects in the window should have their @ref
## evas_object_size_hint_weight_set set to EVAS_HINT_EXPAND.
##
## Also notice that the window can get resized to the current size of the
## object if the EVAS_HINT_EXPAND is set after the call to this. So if the
## object should get resized to the size of the window, set this hint before
## adding it as a resize object (this happens because the size of the window
## and the object are evaluated as soon as the object is added to the window).
##
## @if MOBILE @since_tizen 2.3 @elseif WEARABLE @since_tizen 2.3.1 @endif
##
## @param[in] obj The object.
## @param[in] subobj The resize object to add.
##
## @ingroup Elm_Win
##
proc elm_win_resize_object_add*(window: Elm_Win, subobj: Evas_Object) {. header: "Elementary.h" .}

## Set the content on part of a given container widget
proc elm_object_part_content_set*(obj: Evas_Object, part: cstring, content: Evas_Object) {. header: "Elementary.h" .}

## Add a layout element
proc elm_layout_add*(parent: Evas_Object): Evas_Object {. header: "Elementary.h" .}

## Add a background
proc elm_bg_add*(parent: Evas_Object): Evas_Object {. header: "Elementary.h" .}

## Set background element color
proc elm_bg_color_set*(obj: Evas_Object, r: int, g: int, b: int) {. header: "Elementary.h" .}

## Create image
proc elm_image_add*(parent: Evas_Object): Elm_Image {. header: "Elementary.h" .}

## Get the underlying Evas_Object for an image object
proc elm_image_object_get*(obj: Elm_Image): Evas_Object {. header: "Elementary.h" .}

## Set the image file's source
proc elm_image_file_set*(obj: Elm_Image, file: cstring, group: cstring): bool {. header: "Elementary.h" .}

## Get resources directory
proc elm_app_data_dir_get*(): cstring {. header: "Elementary.h" .}

## Enable or disable preloading of the image
proc elm_image_preload_disabled_set*(imgView: Elm_Image, disabled: bool) {. header: "Elementary.h" .}

## Set the background image file's source
proc elm_bg_file_set*(obj: Evas_Object, file: cstring, group: cstring): bool {. header: "Elementary.h" .}

## Create transition animation
proc elm_transit_add*(): Elm_Transit {. header: "Elementary.h" .}

## Add an object to the transit
proc elm_transit_object_add*(transit: Elm_Transit, obj: Evas_Object) {. header: "Elementary.h" .}

## Execute the transition
proc elm_transit_go*(transit: Elm_Transit) {. header: "Elementary.h" .}

## Execute the transition after some time
proc elm_transit_go_in*(transit: Elm_Transit, delay: float) {. header: "Elementary.h" .}

## Set the duration
proc elm_transit_duration_set*(transit: Elm_Transit, duration: cdouble) {. header: "Elementary.h" .}

## Transition effect
proc elm_transit_effect_translation_add*(transit: Elm_Transit, from_dx: int, from_dy: int, to_dx: int, to_dy: int): Elm_Transit_Effect {. header: "Elementary.h" .}

type Elm_Transit_Del_Cb* = proc(userData: pointer, transit: Elm_Transit) {.cdecl.}

## Add a callback which is called when the transit is deleted
proc elm_transit_del_cb_set*(transit: Elm_Transit, callback: Elm_Transit_Del_Cb, userData: pointer) {. header: "Elementary.h" .}

## Enable/disable keeping up the objects states. If it is not kept, the objects states will be reset when transition ends.
proc elm_transit_objects_final_state_keep_set*(transit: Elm_Transit, on: bool) {. header: "Elementary.h" .}

## Delete a running transit before it completes. This is effectively a "cancel". The delete callback will still be called.
proc elm_transit_del*(transit: Elm_Transit) {. header: "Elementary.h" .}

type Elm_Transit_Tween_Mode* = enum
    AnimationTweenModeLinear,          # /**< Constant speed */
    AnimationTweenModeSinusoidal,      #  /**< Starts slow, increase speed
                                            #    over time, then decrease again
                                            #     and stop slowly, v1 being a power factor */
    AnimationTweenModeDecelerate,      #  /**< Starts fast and decrease
                                            #     speed over time, v1 being a power factor */
    AnimationTweenModeAccelerate,      #  /**< Starts slow and increase speed
                                            #     over time, v1 being a power factor */
    AnimationTweenModeDivisorInterp,  #  /**< Start at gradient v1,
                                            #             interpolated via power of v2 curve */
    AnimationTweenModeBounce,          #  /**< Start at 0.0 then "drop" like a ball
                                            #    bouncing to the ground at 1.0, and
                                            #     bounce v2 times, with decay factor of v1 */
    AnimationTweenModeSpring,          #  /**< Start at 0.0 then "wobble" like a spring
                                            #    rest position 1.0, and wobble v2 times,
                                            #    with decay factor of v1 */
    AnimationTweenModeBezierCurve     #  /**< @since 1.13
                                            #      Follow the cubic-bezier curve
                                            #      calculated with the control points
                                            #      (x1, y1), (x2, y2) */

## Set tween mode
proc elm_transit_tween_mode_set*(transit: Elm_Transit, tween_mode: Elm_Transit_Tween_Mode) {. header: "Elementary.h" .}














########################### Hardware

type haptic_device_h* = pointer
type haptic_effect_h* = pointer

## Opens a haptic-vibration device.
proc device_haptic_open*(device_index: int, device_handle: haptic_device_h): int {. header: "<device/haptic.h>" .}

## Closes a haptic-vibration device.
proc device_haptic_close*(device_handle: haptic_device_h): int {. header: "<device/haptic.h>" .}

## Vibrates during the specified time with a constant intensity.
proc device_haptic_vibrate*(device_handle: haptic_device_h, duration: int, feedback: int, effect_handle: haptic_effect_h): int {. header: "<device/haptic.h>" .}

## Stops all vibration effects which are being played.
proc device_haptic_stop*(device_handle: haptic_device_h, effect_handle: haptic_effect_h): int {. header: "<device/haptic.h>" .}