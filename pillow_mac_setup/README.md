This is an example app showing the error when trying to bundle
an app using pillow using py2app. To see the error, install the
dependencies in `requirements.txt` then run the following command
in the project root directory:

`python setup.py py2app`

Expected result is a packaged app, but instead you should get
a ValueError about the header being too large to relocate.

If you set the LDFLAGS for brew to the following value 

LDFLAGS="-Wl,-headerpad_max_install_names"

before running the brew commands specified here

https://pillow.readthedocs.io/en/stable/installation.html#building-on-macos

and rebuild and install pillow using

`pip install pillow --global-option="build_ext"`

the error should disappear and you will now get a running
application that opens the incldued image in your default
image viewer.