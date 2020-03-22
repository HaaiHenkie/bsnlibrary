from setuptools import setup

with open("README.md", "r") as fh:
    long_description = fh.read()


setup(
    name='robotframework-bsnlibrary',
    version='0.3',
    packages=['BSNLibrary'],
    url='https://github.com/HaaiHenkie/bsnlibrary',
    project_urls={
        'Documentation': 'https://haaihenkie.github.io/bsnlibrary/',
        'Source': 'https://github.com/HaaiHenkie/bsnlibrary',
        'Tracker': 'https://github.com/HaaiHenkie/bsnlibrary/issues',
    },
    license='GNU General Public License v3 (GPLv3)',
    author='Henk van den Akker',
    author_email='haaihenkie@users.noreply.github.com',
    description='Robot Framework library for generating BSNs (Dutch citizen service number)',
    long_description=long_description,
    long_description_content_type="text/markdown",
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Developers",
        "Topic :: Software Development :: Testing",
        "Framework :: Robot Framework :: Library",
        "License :: OSI Approved :: GNU General Public License v3 (GPLv3)",
        "Programming Language :: Python :: 2.7",
        "Programming Language :: Python :: 3",
        "Operating System :: OS Independent",
    ],
    install_requires=['robotframework'],
    python_requires='>=2.7'
)
