#!/usr/bin/env python

import sys

from PIL import Image, ImageDraw, ImageFont


basename = sys.argv[1]
fractions = sys.argv[2:]

if not fractions:
    raise SystemExit("Usage: comp.py BASENAME FRAC [FRAC ...]")

font = ImageFont.truetype("~/Library/Fonts/Inconsolata-Regular.ttf", 24)
swatch_width = 200
swatch_height = 400
content_crop = (0, 230, 200, 630)

images = [Image.open(f"{basename}-{frac}.png") for frac in fractions]
swatches = []

for image, fraction in zip(images, fractions):
    swatch = image.crop(content_crop)
    label = "orig" if fraction == "0.00" else fraction
    ImageDraw.Draw(swatch).text((90, 370), label, font=font)
    swatches.append(swatch)

composite = Image.new("RGB", (swatch_width * len(swatches), swatch_height))

for index, swatch in enumerate(swatches):
    composite.paste(swatch, (swatch_width * index, 0))

composite.save(f"{basename}-comp.png")
