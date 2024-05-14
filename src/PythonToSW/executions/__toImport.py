import os
import pyperclip

contents = []

for file in os.listdir("."):
    # ignore folders
    if os.path.isdir(file):
        continue
    
    # ignore non .py files
    if not file.endswith(".py"):
        continue
    
    # ignore init
    if file == "__init__.py":
        continue
    
    # ignore this script
    if os.path.samefile(file, __file__):
        continue
    
    # read
    content = open(file, "r").read()
    
    # get the class name
    pos = content.find("class ") + 6
    className = ""

    while content[pos]:
        if content[pos] == "(":
            break
        
        className += content[pos]
        pos += 1
    
    # format into import statement
    contents.append(f"from .{os.path.splitext(file)[0]} import {className}")
    
# convert contents to string
contents = "\n".join(contents)

# print and copy
print(contents)
pyperclip.copy(contents)