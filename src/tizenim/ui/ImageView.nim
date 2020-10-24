import View
import AnimationInfo
import ../native
import ../templates
import ../dlog
import strformat
import os
import classes

## An Image view allows you to display an image on the screen.
class ImageView of View:

    ## Image object
    var imageObject: Evas_Object

    ## Image file path
    var imageFile: string


    # Set the image to the specified file URL
    method setImageFile(filename: string) =

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
            return

        # Failed!
        dlog "[ImageView] Unable to set image: " & filename


    # Called when the view is created
    method onCreate() =
        super.onCreate()

        # Create a generic evas container object
        this.imageObject = elm_image_add(this.evasObject)

        # Restore properties
        if this.imageFile != "": this.setImageFile(this.imageFile)

    # Called when the view is destroyed
    method onDestroy() =
        super.onDestroy()

        # Destroy it
        evas_object_del(this.imageObject)
        this.imageObject = nil


    method layoutSubviews(oldWidth: float, oldHeight: float) =

        # Set size of label view
        if this.imageObject != nil:
            evas_object_move(this.imageObject, this.frame.position.x.toInt(), this.frame.position.y.toInt())
            evas_object_resize(this.imageObject, this.frame.size.width.toInt(), this.frame.size.height.toInt())
            dlog fmt"[ImageView] Moving to {this.frame.position.x.toInt()} {this.frame.position.y.toInt()}"


    # Called on show
    method onShow() =
        super.onShow()

        # Show objects
        evas_object_show(this.imageObject)


    # Called on hide
    method onHide() =
        super.onHide()

        # Show objects
        evas_object_hide(this.imageObject)


    # Called on animation start
    method onAnimationStart(animationInfo: AnimationInfo) =
        super.onAnimationStart(animationInfo)

        # Add our evas object
        animationInfo.evasObjects.add(this.imageObject)