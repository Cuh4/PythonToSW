cd src
py setup.py sdist
twine upload dist/*
cd ..