import ../native

## Files class
type FilesClass* = ref object of RootObj
    

## Get path to app's resources folder
proc resourcesFolder*(_: FilesClass): string = return $app_get_shared_resource_path()

## Get path to app's shared resources folder
# proc sharedResourcesFolder*(_: FilesClass): string = return $app_get_shared_resource_path()


# Best I can do to get a "static" function
let files* = FilesClass()