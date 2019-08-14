import py2app

from setuptools import setup

setup(
    app=["main.py"],
    options={
        # without this, py2app will ignore the PIL lib dependencies
        # and we'll get a runtime error trying to import Image when
        # running the app instead.
    },
    data_files=[('',['19250492498_163805e22a.jpg',]),]
)
