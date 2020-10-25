import ../native
import classes

## Get resources directory
proc resourcesFolder*(): string = return $app_get_shared_resource_path()