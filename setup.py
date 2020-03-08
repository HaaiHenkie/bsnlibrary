from setuptools import setup

with open("README.md", "r") as fh:
    long_description = fh.read()


setup(
    name='robotframework-bsnlibrary',
    version='0.1',
    packages=['BSNLibrary'],
    url='https://github.com/HaaiHenkie/bsnlibrary',
    license='GNU General Public License version 3',
    author='Henk van den Akker',
    description='Robot Framework library for generating BSNs (Dutch citizen service number)',
    long_description=long_description,
    long_description_content_type="text/markdown",
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: GNU General Public License, version 3",
        "Operating System :: OS Independent",
    ],
    install_requires=['robotframework']
)
