import ../native
import classes

## Files class
class Files:

    ## Get path to app's resources folder
    method resourcesFolder(): string {.static.} = return $app_get_shared_resource_path()