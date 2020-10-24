import ../native
import classes

## Files class
class Files:

    ## Get path to app's resources folder
    method resourcesFolder(): string = return $app_get_shared_resource_path()


## Singleton
let files* = Files().init()
# proc files*(): Files =
#     let db {.global.} = Files().init()
#     return db