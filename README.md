SLLColorPicker
===============

(c) 2018 Skylite Labs Inc.
Based on ISColorWheel, (c) 2015 Justin Meiners.

### About ###

A fully scalable and dynamically rendered color picker for iOS.

Many other iOS color pickers work by sampling colors from a pre-rendered image of a color wheel. This approach limits the color picker to the size and quality of the static image.
This project contains a color wheel that computes color values mathematically, and renders dynamically, giving a completely scalable UIView and more accurate color selection.

### Technical ###

Color wheels visualize and define colors from hue, saturation, and brightness components (HSB color space). On the wheel, two of these components can be mapped to two-dimensional polar coordinates. Hue is defined by the angle on the wheel. Saturation is defined by the distance from the center. Brightness, the third component cannot also be mapped to the two dimensional surface so it must be controlled by a separate control such as a slider.

### Includes ###
  - Standalone SLLColorPicker class (UIView subclass)
  - Example project

![sample image](screenshots/main.png)
