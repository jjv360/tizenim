import os
import osproc
import docopt
import strformat
import strutils
import nre
import streams
import parsecfg

# Help document
let helpDoc = """
TizenNim - build Tizen apps in Nim.

Usage:
    tizenim build
    tizenim clean
    tizenim launch
    tizenim logs
    tizenim --help

Options:
    -h --help               Show this screen.
"""


# Adds common executable extensions
proc resolveExeExtension(exe: string): string =
    if fileExists(exe): return exe
    elif fileExists(exe & ".exe"): return exe & ".exe"
    elif fileExists(exe & ".bat"): return exe & ".bat"
    elif fileExists(exe & ".cmd"): return exe & ".cmd"
    elif fileExists(exe & ".sh"): return exe & ".sh"
    raiseAssert("File not found: " & exe)


# Execute process and return the exit code
proc runCmd(exe: string, options: varargs[string]): int =

    # Create the process
    let p = startProcess(command = resolveExeExtension(exe), workingDir = getCurrentDir(), args = options, env = nil, options = { poParentStreams })
    return p.waitForExit()


# Execute a process and return the Process object
proc startCmd(exe: string, options: varargs[string]): Process =

    # Create the process
    return startProcess(command = resolveExeExtension(exe), workingDir = getCurrentDir(), args = options, env = nil, options = { poStdErrToStdOut })


# Copies and replaces a file only if it has changed
proc copyFileIfChanged(src: string, dest: string) =

    # Do it if the dest file doesn't exist
    if not fileExists(dest):
        copyFile(src, dest)
        return

    # Compare the two
    let strSrc = readFile(src)
    let strDest = readFile(dest)
    if strSrc != strDest:

        # Changed, copy the file
        removeFile(dest)
        copyFile(src, dest)


# Entry point
proc run2() =

    # Echo header
    echo ("")
    echo (" +-----------------------+")
    echo (" |     Tizen for Nim     |")
    echo (" +-----------------------+")
    echo ("")

    # Parse opts
    let args = docopt(helpDoc)
    
    # Get package root
    var projectRoot = absolutePath(getCurrentDir())
    while not fileExists(projectRoot / "tizen.config"):
        projectRoot = parentDir(projectRoot)
        if projectRoot.len() <= 3:
            raiseAssert("Unable to find 'tizen.config' file. Please make sure this file exists in your project's folder.")

    # Parse the config file
    let config = loadConfig(projectRoot / "tizen.config")

    # Get absolute path to nim entry point
    echo ""
    echo " === Details ==="
    let nimFile = absolutePath(projectRoot / config.getSectionValue("", "main", "src/App.nim"))
    if not fileExists(nimFile): raiseAssert("The file at path " & nimFile & " does not exist.")
    echo("App entry point: " & nimFile)

    # Create temporary output directory, deleting if it exists already
    let tmpFolder = absolutePath(projectRoot / "build")
    echo ("Working directory: " & tmpFolder)

    # Create output folder
    let distFolder = absolutePath(projectRoot / "dist")
    echo ("Output directory: " & distFolder)

    # Find path to the Tizen SDK
    let tizenSdkPath = config.getSectionValue("", "tizenSDK", "C:/tizen-studio")
    let tizenExe = tizenSdkPath / "tools/ide/bin/tizen"
    let sdbExe = tizenSdkPath / "tools/sdb"
    if not dirExists(tizenSdkPath): raiseAssert("Unable to find Tizen SDK at " & tizenSdkPath)
    echo "Tizen SDK: " & tizenSdkPath

    # Find path to Nim std library
    # TODO: Find this dynamically!
    let nimSdkPath = config.getSectionValue("", "nimSDK", absolutePath(getHomeDir() & "/.choosenim/toolchains/nim-1.4.0"))
    let nimExe = nimSdkPath / "bin/nim"
    if not dirExists(nimSdkPath): raiseAssert("Could not find the Nim toolchain folder! You may have to add nimSDK to your tizen.config file.")
    echo "Nim path: " & nimSdkPath

    # Clean the build folder if necessary
    if args["clean"]:

        # Remove working directories
        if dirExists(tmpFolder): removeDir(tmpFolder)

    
    # Build if necessary
    if args["build"] or args["launch"]:

        # Get configuration name, use Release if doing a "build", or Debug for "launch"
        var configuration = "Debug"
        if args["build"]:
            configuration = "Release"

        # Clean output directory
        if dirExists(distFolder): removeDir(distFolder)
        createDir(distFolder)
        
        # Compile to C
        echo ""
        echo " === Compiling Nim to C ==="
        var code = runCmd(
            nimExe, 
            "compileToC", 
            "--compileOnly", 
            "--os:linux", 
            "--cpu:arm", 
            "--nimcache=" & (tmpFolder / "nimcache"), 
            "--cincludes=" & (tizenSdkPath / "platforms/tizen-4.0/wearable/rootstraps/wearable-4.0-device.core/usr/include"), 
            "--define:TIZEN:1", 
            "--out=" & (tmpFolder / "appbinary"), 
            if configuration == "Release": "-d:release" else: "-d:debug",
            nimFile
        )
        if code != 0:
            raiseAssert("Failed to compile the app.")

        # Fetch all C output files
        var cFiles: seq[string]
        for kind, path in walkDir(tmpFolder / "nimcache"):
            if path.endsWith(".c"):
                cFiles.add(path)

        echo fmt"""Output contains {cFiles.len} C files"""


        # Create temporary Tizen project if necessary
        if not dirExists(tmpFolder / "tizen-project"):
            echo ""
            echo " === Creating Tizen project ==="
            code = runCmd(tizenExe, "create", "native-project", "--name=tizen-project", "--profile=wearable-4.0", "--template=basic-ui", "--", tmpFolder)
            if code != 0:
                raiseAssert("Failed to create a Tizen project.")

        # Copy all C files to the src folder
        if fileExists(tmpFolder / "tizen-project/src/tizen-project.c"): removeFile(tmpFolder / "tizen-project/src/tizen-project.c")
        for file in cFiles:
            copyFileIfChanged(file, tmpFolder / "tizen-project/src" / lastPathPart(file))

        # Update the tizen project's file reference
        writeFile(tmpFolder / "tizen-project/project_def.prop", fmt"""
            APPNAME = tizen-project

            type = app
            profile = wearable-4.0

            USER_SRCS = src/*.c
            USER_DEFS =
            USER_INC_DIRS = inc "{nimSdkPath}/lib"
            USER_OBJS =
            USER_LIBS =
            USER_EDCS =
        """)

        # Copy resource files
        let resourcesDir = absolutePath(config.getSectionValue("", "resources", "res"), projectRoot)
        if dirExists(resourcesDir):
            echo "Copying resources..."
            let resDestFolder = tmpFolder / "tizen-project/shared/res"
            for kind, path in walkDir(resourcesDir):
                if (kind == pcDir) or (kind == pcLinkToDir):
                    copyDir(path, resDestFolder / lastPathPart(path))
                else:
                    copyFile(path, resDestFolder / lastPathPart(path))

        # Add privileges
        writeFile(tmpFolder / "tizen-project/tizen-manifest.xml", fmt"""
        
            <?xml version="1.0" encoding="utf-8"?>
            <manifest xmlns="http://tizen.org/ns/packages" api-version="4.0" package="org.example.tizen-project" version="1.0.0">
                <profile name="wearable" />
                <ui-application appid="org.example.tizen-project" exec="tizen-project" type="capp" multiple="false" taskmanage="true" nodisplay="false">
                    <icon>tizen-project.png</icon>
                    <label>tizen-project</label>
                </ui-application>
                <privileges>
                    <privilege>http://tizen.org/privilege/externalstorage.appdata</privilege>
                    <privilege>http://tizen.org/privilege/externalstorage</privilege>
                </privileges>
            </manifest>

        
        """.strip())

        # Compile Tizen app
        echo ""
        echo " === Compiling Tizen project ==="
        code = runCmd(tizenExe, "build-native", "--arch=arm", "--compiler=gcc", "--configuration=" & configuration, "--", tmpFolder / "tizen-project")
        if code != 0:
            raiseAssert("Failed to compile the app.")

        # Package Tizen app
        echo ""
        echo " === Packaging Tizen project ==="
        code = runCmd(tizenExe, "package", "--type=tpk", "--", tmpFolder / "tizen-project" / configuration)
        if code != 0:
            raiseAssert("Failed to package the app.")

        # Copy final output file
        copyFile(tmpFolder / "tizen-project" / configuration / "org.example.tizen-project-1.0.0-arm.tpk", distFolder / "App.tpk")

        # Done
        echo ""
        echo " === Success ==="
        echo "Your app is in the /dist folder."

    # Now install
    if args["launch"]:
        
        # Start installing
        echo ""
        echo " === Installing to device ==="
        var code = runCmd(sdbExe, "install", distFolder / "App.tpk")
        if code != 0:
            raiseAssert("Failed to install the app.")

    # Now debug
    if args["logs"] or args["launch"]:

        # Clear log
        var code = runCmd(sdbExe, "dlog", "-c")
        if code != 0:
            raiseAssert("Failed to clear the old logs.")

        # Run the app
        echo ""
        echo " === Running the app ==="
        code = runCmd(sdbExe, "shell", "launch_app", "org.example.tizen-project")
        if code != 0:
            raiseAssert("Failed to run the app.")

        # Get log msgs
        echo ""
        echo " === Log messages ==="
        echo "Waiting for app to start..."
        var processID = ""
        let process = startCmd(sdbExe, "dlog", "-v", "brief")
        let stream = process.outputStream()
        let lineRegex = re"^(.)\/(.*?)\(\s*([0-9]*)\):(.*)$"
        while true:

            # Read next line
            let line = stream.readLine()

            # Parse text
            let match = line.match(lineRegex)
            if match.isNone:
                continue

             # Extract fields
            let entryType = match.get.captures[0]
            let tag = match.get.captures[1]
            let pid = match.get.captures[2]
            let txt = match.get.captures[3]

            # Check if this is our special PID check entry
            if processID == "" and txt.contains("=== START NIM LOG ==="):
                echo "App started with PID " & pid
                processID = pid
                continue

            # Check if process ended
            if pid != processID and processID != "" and txt.contains(fmt"APP_DEAD_SIGNAL : {processID}"):
                echo "App has exited."
                break

            # Stop if not our PID
            if pid != processID:
                continue

            # Log it
            echo fmt"{entryType} {tag}: {txt}"

        # End the monitoring process
        process.close()
    

# Entry point with error handling
proc run*() =

    # Run and catch errors
    try:
        run2()
    except Exception as ex:
        echo("Error: " & ex.msg)