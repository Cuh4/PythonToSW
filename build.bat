@ECHO OFF
py combine.py --directory "src/SWToPython" --destination "src/PythonToSW/addon/script.lua" --allow_file_extension ".lua"
poetry build