import View
import ../native
import ../templates
import ../dlog
import strformat
import os

## An Image view allows you to display an image on the screen.
type ImageView* = ref object of View

    ## Image object
    imageObject: Evas_Object

    ## Image file path
    imageFile: string


# Constructor
method init*(this: ImageView): ImageView {.base.} =
    discard procCall this.View.init()

    # Default values
    
    # Done
    return this


# Set the image to the specified file URL
method setImageFile*(this: ImageView, filename: string) {. base .} =

    # Check if file exists
    if not fileExists(filename):
        dlog "[ImageView] File not found: " & filename
        return

    # Stop if not loaded yet
    this.imageFile = filename
    if this.imageObject == nil:
        return

    # Set it
    let success = elm_image_file_set(this.imageObject, filename, nil)
    if success:
        dlog "[ImageView] Successfully set image: " & filename

    # Failed!
    dlog "[ImageView] Unable to set image: " & filename


# Called when the view is created
method onCreate*(this: ImageView) {. private .} =
    procCall this.View.onCreate()

    # Create a generic evas container object
    this.imageObject = elm_image_add(this.evasObject)

    # Restore properties
    if this.imageFile != "": this.setImageFile(this.imageFile)


method layoutSubviews*(this: ImageView, oldWidth: float, oldHeight: float) {. private .} =

    # Set size of label view
    if this.imageObject != nil:
        evas_object_move(this.imageObject, this.frame.position.x.toInt(), this.frame.position.y.toInt())
        evas_object_resize(this.imageObject, this.frame.size.width.toInt(), this.frame.size.height.toInt())
        dlog fmt"[ImageView] Moving to {this.frame.position.x.toInt()} {this.frame.position.y.toInt()}"


# Called on show
method onShow*(this: ImageView) =
    procCall this.View.onShow()

    # Show objects
    evas_object_show(this.imageObject)


# Called on hide
method onHide*(this: ImageView) =
    procCall this.View.onHide()

    # Show objects
    evas_object_hide(this.imageObject)