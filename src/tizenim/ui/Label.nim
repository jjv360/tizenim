import view
import ../native
import ../templates
import ../dlog
import strformat
import classes
import os
import ../io/files

## A label is a view which can draw text to the screen.
class Label of View:

    ## Label object
    var labelObject: Evas_Object

    ## Current text
    var text: string


    # Constructor
    method init() =
        super.init()

        # Default values
        this.text = "Label"


    # Override the evas object init
    method onCreate() =
        super.onCreate()

        # On first ever init, check for the fonts directory
        var hasInitedFonts {.global .} = false
        if not hasInitedFonts:
            hasInitedFonts = true

            # Register font directory
            evas_font_path_global_append(resourcesFolder() / "fonts")

        # Create a generic evas container object
        this.labelObject = elm_label_add(this.evasObject)
        elm_object_part_text_set(this.labelObject, nil, this.text)


    method onDestroy() =
        super.onDestroy()

        # Destroy it
        evas_object_del(this.labelObject)
        this.labelObject = nil


    method layoutSubviews() =
        super.layoutSubviews()

        # Set size of label view
        if this.labelObject != nil:
            evas_object_move(this.labelObject, this.absolutePosition.x.toInt(), this.absolutePosition.y.toInt())
            evas_object_resize(this.labelObject, this.frame.size.width.toInt(), this.frame.size.height.toInt())


    ## Set text. This supports an odd kind of HTML. See here: https://developer.tizen.org/dev-guide/training/native-app/en/wearable/lesson_16/index.html
    ## <font> tag supports these attributes:
    ## - font : to be italic specify `:style=Italic` after the font name
    ## - font_size
    ## - align : `'left`, `center`, `right`
    ## - underline_color
    ## - underline2_color
    ## - underline : `on`, `off`, `single`, `double`
    ## - strikethrough_color
    ## - strikethrough : `on`, `off`
    ## 
    ## NOTE: To install custom fonts, add them to the res/fonts/ folder of your project. They must not have any spaces in the name. Eg. if you
    ## have a res/fonts/myfont.ttf file, you can set the text to "<font=myfont>My text</font>" to use that font.
    method setText(text: string) =

        # Store text
        this.text = text
        if this.labelObject != nil:
            elm_object_part_text_set(this.labelObject, nil, this.text)


    # Called on show
    method onShow() =
        super.onShow()

        # Show objects
        evas_object_show(this.labelObject)


    # Called on hide
    method onHide() =
        super.onHide()

        # Show objects
        evas_object_hide(this.labelObject)