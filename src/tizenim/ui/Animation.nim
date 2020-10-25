import view
import animationinfo
import ../types
import ../native
import ../dlog
import ../templates
import sequtils
import ../CInterop
import classes
export Elm_Transit_Tween_Mode

## Function call after animation completes
type OnAnimationComplete* = proc()

## list of currently running animations
var runningAnimations: seq[AnimationInfo]

## Animation context, maintains multiple animations that can be run at once
class AnimationContext:
    var cinterop: CInterop = CInterop()

    # All animations to execute
    var all: seq[AnimationInfo]

    # Called when the first animation completes
    var onCompleteHandlers: seq[OnAnimationComplete]

    ## Duration of the animation in seconds
    var duration: float

    ## Delay of the animation in seconds
    var delay: float

    ## Animation function
    var tweenFunction: Elm_Transit_Tween_Mode

    ## Constructor
    method init() =

        # Set defaults
        this.cinterop = CInterop()
        this.duration = 0.3
        this.delay = 0
        this.tweenFunction = AnimationTweenModeSinusoidal

    # Called when the animation completes
    method didComplete() =

        # Call callbacks
        dlog "[Animation] Complete"
        for cb in this.onCompleteHandlers:
            cb()

    # Add a listener for when the animation is complete
    method addCompleteHandler(cb: OnAnimationComplete) {.private.} =
        this.onCompleteHandlers.add(cb)

    ## Called to insert the effects into the transit
    method setupTransit(anim: AnimationInfo, evasObject: Evas_Object, transit: Elm_Transit) =

        # Check animation type
        if anim.action == AnimatePosition:

            # Get initial position
            var x = 0
            var y = 0
            var w = 0
            var h = 0
            evas_object_geometry_get(evasObject, x, y, w, h)

            # Animate to target position
            discard elm_transit_effect_translation_add(transit, 0, 0, anim.frame2.position.x.toInt() - x, anim.frame2.position.y.toInt() - y)

            # Update view coords
            let view = cast[View](anim.targetView)
            view.frame.position = anim.frame1.position

    ## Called to finalize the effects after the transit completes
    method finalizeTransit(anim: AnimationInfo, evasObject: Evas_Object, transit: Elm_Transit) =

        # Stop if cancelled
        if anim.cancelled:
            return

        # Check animation type
        if anim.action == AnimatePosition:

            # Set final position
            evas_object_move(evasObject, anim.frame2.position.x.toInt(), anim.frame2.position.y.toInt())

    # Execute all animations
    method execute() =

        # Attach completion handler to first transit, since they all have the same length and duration
        dlog "[Animation] Started..."

        # Run all transitions
        for anim in this.all:

            # Check if this animation is already running
            for runningAnim in runningAnimations.filterIt(it.targetView == anim.targetView and it.action == anim.action):

                # Ours should replace this one. Cancel it.
                dlog "[Animation] Cancelling animation..."
                runningAnim.cancelled = true
                runningAnimations.keepItIf(it != runningAnim)
                for t in runningAnim.transits:
                    dlog "[Animation] Cancelling transit"
                    elm_transit_del(t)


            # Inform view of animation start
            cast[View](anim.targetView).onAnimationStart(anim)

            # Add to active animations
            runningAnimations.add(anim)

            # Go through all evas objects
            for evasObject in anim.evasObjects:
            
                # Create transit
                let transit = elm_transit_add()
                elm_transit_object_add(transit, evasObject)
                elm_transit_duration_set(transit, this.duration)
                elm_transit_objects_final_state_keep_set(transit, true)
                elm_transit_tween_mode_set(transit, this.tweenFunction)
                
                anim.transits.add(transit)

                # Add animation effects
                this.setupTransit(anim, evasObject, transit)

                # Add completion listener
                let thisAnim = anim
                let thisEvasObject = evasObject
                let deleteProc = proc() =
                        
                    # Remove from active animations
                    runningAnimations.keepItIf(it != thisAnim)

                    # Finalize animation
                    this.finalizeTransit(thisAnim, thisEvasObject, transit)

                    # Notify listeners once
                    if this.all[0] == thisAnim and thisAnim.transits[0] == transit:

                        # This code gets run only once, even if there are ultiple animations and multple transits
                        dlog "[Animation] Complete"
                        for cb in this.onCompleteHandlers:
                            cb()
                        
                # Attach completion listener
                elm_transit_del_cb_set(transit, proc(userData: pointer, transit: Elm_Transit) {.cdecl.} =
                    callClosureForUserData(userData)
                , this.cinterop.userDataForClosure(deleteProc))

                # Execute transit
                elm_transit_go_in(transit, this.delay)

            # end for loop

    ## Add a translate animation
    method move(view: View, newPos: Position) =

        # Stop if not in a view
        if view.parent == nil:
            return

        # Create animation
        let anim = AnimationInfo()
        anim.context = this
        anim.targetView = view
        anim.action = AnimatePosition
        anim.frame1.position = newPos                                   # <-- Frame1 is the new relative position
        anim.frame2.position = view.parent.absolutePosition + newPos    # <-- Frame2 is the new absolute position
        this.all.add(anim)




## Current animation context, if any. This only exists while an "animate" block is being run to configure the animation
var currentAnimationContext*: AnimationContext = nil





## Helper utility, runs an animation that executes all changes in the code block. A variable `animation` contains the animation options if you want to change them.
template animate*(body: untyped) =

    # If we're in the context of an animation already, just run the code block
    if currentAnimationContext != nil:
        body
        return

    # Run code block, with the current animation context set
    currentAnimationContext = AnimationContext().init()
    body
    currentAnimationContext.execute()
    currentAnimationContext = nil








# Run some code after the animation completes
template onComplete*(this: AnimationContext, body: untyped) =
    
    let cb: proc() = proc() =
        body
    
    this.addCompleteHandler(cb)

























## Add a translate animation
proc move*(view: View, x: float, y: float) = currentAnimationContext.move(view, Position(x: x, y: y))