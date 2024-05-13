# // ---------------------------------------------------------------------
# // ------- [cuhHub] Tools - Combiner
# // ---------------------------------------------------------------------

# -----------------------------------------
# // ---- Imports
# -----------------------------------------
import os
import argparse

# -----------------------------------------
# // ---- Variables
# -----------------------------------------
parser = argparse.ArgumentParser(
    description = "Combines all files in a directory into one.",
)

# -----------------------------------------
# // ---- Functions
# -----------------------------------------
# // Read a file
def quickRead(path: str, mode: str = "r"):
    with open(path, mode) as f:
        return f.read()
    
# // Write to a file
def quickWrite(path: str, content: str, mode: str = "w"):
    directory = os.path.dirname(path)
    
    if not os.path.exists(directory):
        os.makedirs(directory, exist_ok = True)
    
    with open(path, mode) as f:
        return f.write(content)
    
# // Check if path is in list
def pathInList(path: str, paths: list):
    for currentPath in paths:
        if os.path.exists(currentPath) and os.path.samefile(path, currentPath):
            return True
        
    return False

# // Get contents of all files in a path
def recursiveRead(targetDir: str, allowedFileExtensions: list[str], pathExceptions: list[str]) -> dict[str, str]:
    # list files
    files = os.listdir(targetDir)
    contents = {}
    
    # iterate through them
    for file in files:
        # get file-related variables
        _, extension = os.path.splitext(file)
        path = os.path.join(targetDir, file)

        # file is folder, but is an exception
        if pathInList(path, pathExceptions):
            continue
        
        # file extension check
        if extension == "":
            # file is folder, so read it too
            contents = {**contents, **recursiveRead(path, allowedFileExtensions, pathExceptions)}
            
        # file extension check
        if extension not in allowedFileExtensions and len(allowedFileExtensions) > 0:
            continue
        
        # get file content
        content = quickRead(path, "r")
        
        # append file content to contents
        contents[path] = content
        
    return contents

# -----------------------------------------
# // ---- Main
# -----------------------------------------
# // Setup
# setup parser args
parser.add_argument("-d", "-p", "--directory", "--path", type = str, help = "The directory containing files to combine.", required = True)
parser.add_argument("-de", "--destination", type = str, help = "The file which should have the content of all files combined. Created automatically if it doesn't exist.", required = True)
parser.add_argument("-afe", "--allow_file_extension", type = str, nargs = "*", help = "The file extensions to allow.", default = [])
parser.add_argument("-ip", "--ignore_path", type = str, nargs = "*", help = "The paths to ignore when combining.", default = [])

args = parser.parse_args()

# // Main
# get content of all files
result = recursiveRead(
    args.directory,
    args.allow_file_extension,
    [*args.ignore_path, *[args.destination, os.path.relpath(__file__)]]
)

# print message
print("Combined the following files:\n- " + "\n- ".join([path.replace("\\", "/") for path in result.keys()]))

# format result
for path, content in result.items():
    newContent = [
        "----------------------------------------------",
        f"-- // [File] {path}",
        "----------------------------------------------",
        content
    ]
    
    result[path] = "\n".join(newContent)

# dump it into output file
try:
    quickWrite(args.destination, "\n\n".join(result.values()), "w")
except:
    print("Failed to output.")