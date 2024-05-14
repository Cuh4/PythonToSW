from setuptools import setup, find_packages

setup(
    name= "PythonToSW",
    version = "1.0.0",
    author = "Cuh4",
    description = "A package that allows you to create addons in Stormworks with Python, handled through HTTP.",
    long_description = open("../README.md", encoding = "utf-8").read(),
    packages = find_packages(),
    
    classifiers = [
        "Programming Language :: Python :: 3",
        "License :: Apache License 2.0",
        "Operating System :: OS Independent",
    ],

    python_requires = ">=3.12",
)