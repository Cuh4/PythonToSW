rmdir dist /S /Q
py setup.py sdist
twine upload dist/*