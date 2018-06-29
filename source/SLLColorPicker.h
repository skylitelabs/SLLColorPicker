/*
 Modified Version By: Leejay Schmidt (Skylite Labs Inc.)
 
 Copyright (c) 2018 Skylite Labs Inc.
 Based on the original: ISColorWheel from Justin Meiners : https://github.com/justinmeiners/ios-color-wheel
 Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
 */

#import <UIKit/UIKit.h>

typedef struct
{
    unsigned char r;
    unsigned char g;
    unsigned char b;
} SLLColorPickerPixelRGB;

@class SLLColorPicker;


@protocol SLLColorPickerDelegate <NSObject>
@required
- (void)colorPickerDidChangeColor:(SLLColorPicker*)colorPicker;
@end


@interface SLLColorPicker : UIControl


@property(nonatomic, weak) IBOutlet id <SLLColorPickerDelegate> delegate;
@property(nonatomic, assign)CGSize dropperSize;
@property(nonatomic, strong)UIView* dropperView;
@property(nonatomic, assign)CGFloat brightness;
@property(nonatomic, assign)BOOL continuous;
@property(nonatomic, strong)UIColor* borderColor;
@property(nonatomic, assign)CGFloat borderWidth;
@property(nonatomic, strong)UIColor* currentColor;

- (void)updateImage;
- (void)setTouchPoint:(CGPoint)point;



@end
