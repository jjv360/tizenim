
# Stores the RAW UNSAFE pointers to a Nim closure, so it can be reconstructed
type TotallyUnsafeClosure {.union.} = object
    ptrs: (pointer, pointer)
    closure: proc()

## Stores the context for a "user data" C callback
type UnsafeClosureContext = ref object
    unsafeClosure: TotallyUnsafeClosure

## This class allows you to use Nim closures from "C callback + userData" type callback functions
type CInterop* = ref object of RootObj

    ## User data contexts. They will be freed when the object is deallocated.
    contexts: seq[UnsafeClosureContext]


## Get userData for a closure
proc userDataForClosure*(this: CInterop, cb : proc()): pointer =

    # Create context data
    let ctx = UnsafeClosureContext()
    ctx.unsafeClosure.ptrs = (rawProc(cb), rawEnv(cb))
    this.contexts.add(ctx)

    # Return it
    return cast[pointer](ctx)


## Call closure for user data
proc callClosureForUserData*(userData: pointer) =

    # Get context back
    let ctx = cast[UnsafeClosureContext](userData)

    # Call it
    ctx.unsafeClosure.closure()