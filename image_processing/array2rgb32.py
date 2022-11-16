#!/usr/bin/env python3

import sys
import numpy as np
from PIL import Image
import matplotlib.pyplot as plt

def get_base_image(image):
    image = Image.fromarray(np.uint8(image))
    image = image.convert(mode="RGBA", colors=256)

    if image.size != (640, 480): # width, height
        image = image.resize(size=(640, 480))
    
    return image

def show_image(image):
    plt.imshow(image)
    plt.show()

image = get_base_image(eval(input("")))
image_bytes = image.tobytes()

#show_image(image)

out_file, = sys.argv[1:]

with open(out_file, 'wb') as f:
    f.write(image_bytes)
