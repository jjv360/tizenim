import ../native
import ../types

## Possible animation actions
type AnimationAction* = enum
    AnimatePosition

## Context for a single object animation
type SingleAnimationContext* = ref object of RootObj
    evasObject*: Evas_Object
    transit*: Elm_Transit
    animation*: RootRef

## Animation information
type AnimationInfo* = ref object of RootObj
    context*: RootRef
    targetView*: RootRef
    evasObjects*: seq[Evas_Object]
    action*: AnimationAction
    frame1*: Rectangle
    frame2*: Rectangle
    transits*: seq[Elm_Transit]
    singleAnimationContexts*: seq[SingleAnimationContext]
    cancelled*: bool
