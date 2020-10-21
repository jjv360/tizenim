import View
import ../native
import ../templates
import ../dlog
import strformat

## A label is a view which can draw text to the screen.
type Label* = ref object of View

    ## Label object
    labelObject: Evas_Object

    ## Current text
    text*: string


# Constructor
method init*(this: Label): Label {.base.} =
    discard procCall this.View.init()

    # Default values
    this.text = "Label"
    
    # Done
    return this


# Override the evas object init
method onCreate*(this: Label) {. private .} =
    procCall this.View.onCreate()

    # Create a generic evas container object
    this.labelObject = elm_label_add(this.evasObject)
    elm_object_part_text_set(this.labelObject, nil, this.text)


method onDestroy*(this: Label) {. private .} =
    procCall this.View.onDestroy()

    # Destroy it
    evas_object_del(this.labelObject)
    this.labelObject = nil


method layoutSubviews*(this: Label, oldWidth: float, oldHeight: float) {. private .} =

    # Set size of label view
    if this.labelObject != nil:
        evas_object_move(this.labelObject, this.frame.position.x.toInt(), this.frame.position.y.toInt())
        evas_object_resize(this.labelObject, this.frame.size.width.toInt(), this.frame.size.height.toInt())


## Set text
method setText*(this: Label, text: string) {. base .} =

    # Store text
    this.text = text
    if this.labelObject != nil:
        elm_object_part_text_set(this.labelObject, nil, this.text)


# Called on show
method onShow*(this: Label) =
    procCall this.View.onShow()

    # Show objects
    evas_object_show(this.labelObject)


# Called on hide
method onHide*(this: Label) =
    procCall this.View.onHide()

    # Show objects
    evas_object_hide(this.labelObject)