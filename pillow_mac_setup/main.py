import os

# the image will be in the same dir as main.py when packaged
script_dir = os.path.dirname(os.path.abspath(__file__))

from PIL import Image

# Image retrieved from: https://search.creativecommons.org/photos/35b0c879-492e-4fb6-a514-2e505fe0f5fe
print(Image)