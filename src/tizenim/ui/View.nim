import ../native
import ../templates
import ../types
import ../dlog
import strutils
import strformat
import events
import animationinfo
import classes
import typetraits

# Autoresize flags
type ViewAutoresizingFlags* = enum
    FlexibleTopMargin,
    FlexibleBottomMargin,
    FlexibleLeftMargin,
    FlexibleRightMargin,
    FlexibleWidth,
    FlexibleHeight

#
# View class
class View:

    ## Event emitter
    var events: EventEmitter = initEventEmitter()

    ## The Evas_Object used by this view
    var evasObject {.private.}: Evas_Object

    ## True if currently visible
    var visible = true

    ## Current visibility state
    var visibleState = false

    ## Parent object
    var parent: View

    ## List of children
    var children: seq[View]

    ## Position
    var frame: Rectangle = Rectangle(size: Size(width: 512, height: 512))

    ## Last size, for use in autolayout calculations
    var lastSize: Size = Size(width: 512, height: 512)

    ## Absolute position in the window
    var absolutePosition: Position

    ## Autoresizing mask
    var autoresizingFlags: set[ViewAutoresizingFlags]

    ## Background view
    var evasBackground {.private.}: Evas_Object

    ## Background color
    var backgroundColor: Color = Transparent


    ## Lifecycle events which can be overridden
    method onCreate() = discard
    method onShow() = discard
    method onHide() = discard
    method onDestroy() = discard


    ## Create the Evas_Object for this view. This should be overridden by subclasses that want to
    ## create theor own custom Evas_Object types.
    method initEvasObject(parent: Evas_Object) {. private .} =

        # Create a generic evas container object
        this.evasObject = elm_bg_add(parent)
        if this.visible:
            evas_object_show(this.evasObject)

        # Set background color
        this.evasBackground = elm_bg_add(this.evasObject)
        elm_bg_color_set(this.evasBackground, (this.backgroundColor.red * 255).toInt(), (this.backgroundColor.green * 255).toInt(), (this.backgroundColor.blue * 255).toInt())#, (this.backgroundColor.alpha * 255).toInt())
        if this.visible:
            if this.backgroundColor.alpha == 0:
                evas_object_hide(this.evasBackground)
            else:
                evas_object_show(this.evasBackground)

        # Call hooks
        this.onCreate()

        # Call hooks
        if this.visible and not this.visibleState:
            this.visibleState = true
            this.onShow()


    ## Destroy the Evas_Object for this view.
    method destroyEvasObject() {. private .} =

        # Call hooks
        if this.visibleState:
            this.visibleState = false
            this.onHide()

        # Call hooks
        this.onDestroy()

        # Destroy it
        evas_object_del(this.evasBackground)
        evas_object_del(this.evasObject)
        this.evasObject = nil
        this.evasBackground = nil


    ## Set background color
    method setBackground(color: Color) =

        # Set it
        this.backgroundColor = color
        if this.evasBackground != nil:
            evas_object_color_set(this.evasBackground, (this.backgroundColor.red * 255).toInt(), (this.backgroundColor.green * 255).toInt(), (this.backgroundColor.blue * 255).toInt(), (this.backgroundColor.alpha * 255).toInt())


    ## Set background color
    method setBackground(red: float, green: float, blue: float, alpha: float) =
        this.setBackground(Color(red: red, green: green, blue: blue, alpha: alpha))


    ## Set visible
    method setVisible(v: bool) =

        # Check for change
        if v == this.visible:
            return

        # Store it
        this.visible = v
        if this.evasObject != nil:
            if v:

                # Show objects
                evas_object_show(this.evasObject)
                evas_object_show(this.evasBackground)

                # Call hooks
                if not this.visibleState:
                    this.visibleState = true
                    this.onShow()

            else:

                # Show objects
                evas_object_hide(this.evasObject)
                evas_object_hide(this.evasBackground)

                # Call hooks
                if this.visibleState:
                    this.visibleState = false
                    this.onHide()


    ## Hide the view
    method hide() = this.setVisible(false)

    ## Show the view
    method show() = this.setVisible(true)

    # Perform layout. Subclasses can override this, but make sure to call super.
    method layoutSubviews() =

        # Calculate absolute position in the window
        if this.parent == nil:
            this.absolutePosition = this.frame.position
        else:
            this.absolutePosition = this.parent.frame.position + this.frame.position

        # Move evas views
        if this.evasObject != nil: evas_object_move(this.evasObject, this.absolutePosition.x.toInt(), this.absolutePosition.y.toInt())
        if this.evasBackground != nil: evas_object_move(this.evasBackground, this.absolutePosition.x.toInt(), this.absolutePosition.y.toInt())

        # Check if the size changed
        if this.frame.size.width == this.lastSize.width and this.frame.size.height == this.lastSize.height:

            # Only the position has changed, just call layoutSubviews on the children
            for child in this.children:
                child.layoutSubviews()

        else:

            # Size has changed, perform autolayout on children
            let diffWidth = this.frame.size.width - this.lastSize.width
            let diffHeight = this.frame.size.height - this.lastSize.height
            this.lastSize = this.frame.size
            for child in this.children:

                # Check what to do for the horizontal plane
                var newX = child.frame.position.x
                var newW = child.frame.size.width
                if child.autoresizingFlags.contains(FlexibleLeftMargin) and child.autoresizingFlags.contains(FlexibleWidth) and child.autoresizingFlags.contains(FlexibleRightMargin):
                    newX += diffWidth/3
                    newW += diffWidth/3
                elif child.autoresizingFlags.contains(FlexibleLeftMargin) and child.autoresizingFlags.contains(FlexibleWidth):
                    newX += diffWidth/2
                    newW += diffWidth/2
                elif child.autoresizingFlags.contains(FlexibleLeftMargin) and child.autoresizingFlags.contains(FlexibleRightMargin):
                    newX += diffWidth/2
                elif child.autoresizingFlags.contains(FlexibleRightMargin) and child.autoresizingFlags.contains(FlexibleWidth):
                    newW += diffWidth/2
                elif child.autoresizingFlags.contains(FlexibleLeftMargin):
                    newX += diffWidth
                elif child.autoresizingFlags.contains(FlexibleWidth):
                    newW += diffWidth
                elif child.autoresizingFlags.contains(FlexibleRightMargin):
                    discard

                # Check what to do for the vertical plane
                var newY = child.frame.position.y
                var newH = child.frame.size.height
                if child.autoresizingFlags.contains(FlexibleTopMargin) and child.autoresizingFlags.contains(FlexibleHeight) and child.autoresizingFlags.contains(FlexibleBottomMargin):
                    newY += diffHeight/3
                    newH += diffHeight/3
                elif child.autoresizingFlags.contains(FlexibleTopMargin) and child.autoresizingFlags.contains(FlexibleHeight):
                    newY += diffHeight/2
                    newH += diffHeight/2
                elif child.autoresizingFlags.contains(FlexibleTopMargin) and child.autoresizingFlags.contains(FlexibleBottomMargin):
                    newY += diffHeight/2
                elif child.autoresizingFlags.contains(FlexibleBottomMargin) and child.autoresizingFlags.contains(FlexibleHeight):
                    newH += diffHeight/2
                elif child.autoresizingFlags.contains(FlexibleTopMargin):
                    newY += diffHeight
                elif child.autoresizingFlags.contains(FlexibleHeight):
                    newH += diffHeight
                elif child.autoresizingFlags.contains(FlexibleBottomMargin):
                    discard

                # Apply the new values
                child.setPosition(newX, newY)
                child.setSize(newW, newH)



    # Set position
    method setPosition(x: float, y: float) =

        # Store new values
        this.frame.position.x = x
        this.frame.position.y = y

        # Send events
        this.layoutSubviews()


    # Set size
    method setSize(width: float, height: float) =

        # Store new values
        this.frame.size.width = width
        this.frame.size.height = height

        # Send events
        this.layoutSubviews()


    ## Check if the evas object should be created or destroyed
    method refreshEvas() =

        ## If we have a parent view, we should have an evas object
        if this.parent != nil and this.parent.evasObject != nil:
            
            # We should have an evas object
            if this.evasObject == nil:

                # Create it
                this.initEvasObject(this.parent.evasObject)

                # Refresh all Evas properties
                this.setPosition(this.frame.position.x, this.frame.position.y)
                this.setSize(this.frame.size.width, this.frame.size.height)
                this.setVisible(this.visible)

        else:

            # We should not have an evas object
            if this.evasObject != nil:

                # Remove it
                this.destroyEvasObject()

        # Update children as well
        for child in this.children:
            child.refreshEvas()


    ## Add a subview
    method add(child: View) =

        # Check if child has already got a parent
        if child.parent != nil:
            raiseAssert("The child view already has a parent.")

        # Check if in the children array already
        if this.children.contains(child):
            return

        # Add to children array
        this.children.add(child)
        child.parent = this

        # Construct it's evas object
        child.refreshEvas()
    

    ## Called when an animation starts. Subclasses should use this opportunity to register their evas objects.
    method onAnimationStart(animationInfo: AnimationInfo) =

        # Register evas objects
        animationInfo.evasObjects.add(this.evasObject)
        animationInfo.evasObjects.add(this.evasBackground)


    ## Debug: Prints out the view heirarchy starting at this element.
    method printViewHeirarchy(depth: int = 0) =

        # Output this entry
        let evasStr = if this.evasObject == nil: "none" else: "created"
        dlog fmt"""{"  ".repeat(depth)}- {this.className} (x={this.frame.position.x} y={this.frame.position.y} w={this.frame.size.width} h={this.frame.size.height} visible={this.visible} evas={evasStr})"""

        # output for children as well
        for child in this.children:
            child.printViewHeirarchy(depth + 1)