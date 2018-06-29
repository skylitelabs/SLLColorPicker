/*
 Modified Version By: Leejay Schmidt (Skylite Labs Inc.)
 
 Copyright (c) 2018 Skylite Labs Inc.
 Based on the original: ISColorWheel from Justin Meiners : https://github.com/justinmeiners/ios-color-wheel
 Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
 */

#import <UIKit/UIKit.h>

typedef struct {
    unsigned char red;
    unsigned char green;
    unsigned char blue;
} SLLColorPickerPixelRGB;

static inline SLLColorPickerPixelRGB SLLColorPickerPixelRGBMake(unsigned char red,
                                                         unsigned char green,
                                                         unsigned char blue) {
    SLLColorPickerPixelRGB pixel;
    pixel.red = red;
    pixel.green = green;
    pixel.blue = blue;
    return pixel;
}

@class SLLColorPicker;


@protocol SLLColorPickerDelegate <NSObject>

- (void)colorPickerDidChangeColor:(SLLColorPicker*)colorPicker;

@end


@interface SLLColorPicker : UIControl

@property (nonatomic, readwrite, nullable, weak) id<SLLColorPickerDelegate> delegate;
@property (nonatomic, readwrite, assign) CGSize dropperSize;
@property (nonatomic, readwrite, nonnull, strong) UIView* dropperView;
@property (nonatomic, readwrite, assign) CGFloat brightness;
@property (nonatomic, readwrite, assign) BOOL continuous;
@property (nonatomic, readwrite, null_unspecified, strong) UIColor* borderColor;
@property (nonatomic, readwrite, assign) CGFloat borderWidth;
@property (nonatomic, readwrite, null_unspecified, strong) UIColor* currentColor;

- (void)updateImage;
- (void)setTouchPoint:(CGPoint)point;

@end
