## A position on screen
type Position* = object
    x*: float
    y*: float

## A size
type Size* = object
    width*: float
    height*: float

## A Rectangle represents a position and a size
type Rectangle* = object
    position*: Position
    size*: Size

## Represents a color
type Color* = object
    red*: float
    green*: float
    blue*: float
    alpha*: float

## Some predefined colors
const Black*        = Color(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
const White*        = Color(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
const Red*          = Color(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
const Green*        = Color(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
const Blue*         = Color(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
const Transparent*  = Color(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)