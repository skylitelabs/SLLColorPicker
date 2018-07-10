/*
 Modified Version By: Leejay Schmidt (Skylite Labs Inc.)
 
 Copyright (c) 2018 Skylite Labs Inc.
 Based on the original: ISColorWheel from Justin Meiners : https://github.com/justinmeiners/ios-color-wheel
 Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
 */

#import "SLLColorPicker.h"

#pragma mark - Supporting Functions
static inline CGFloat SLLColorPickerPointDistance(CGPoint p1,
                                                  CGPoint p2) {
    return sqrtf((p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y));
}

static inline SLLColorPickerPixelRGB SLLColorPickerHSBToRGB(CGFloat hue,
                                                            CGFloat saturation,
                                                            CGFloat brightness) {
    hue *= 6.0f;
    
    NSInteger i = (NSInteger)floorf(hue);
    CGFloat f = hue - (CGFloat)i;
    CGFloat p = brightness * (1.0f - saturation);
    CGFloat q = brightness * (1.0f - saturation * f);
    CGFloat t = brightness * (1.0f - saturation * (1.0f - f));
    
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    
    switch (i) {
        case 0:
            red = brightness;
            green = t;
            blue = p;
            break;
        case 1:
            red = q;
            green = brightness;
            blue = p;
            break;
        case 2:
            red = p;
            green = brightness;
            blue = t;
            break;
        case 3:
            red = p;
            green = q;
            blue = brightness;
            break;
        case 4:
            red = t;
            green = p;
            blue = brightness;
            break;
        default:        // case 5:
            red = brightness;
            green = p;
            blue = q;
            break;
    }
    
    return SLLColorPickerPixelRGBMake(red * 255.f,
                                      green * 255.f,
                                      blue * 255.f);
}

#pragma mark - Dropper

@interface SLLDropperView : UIView

@property (nonatomic, readwrite, null_unspecified, strong) UIColor* fillColor;

@end

@implementation SLLDropperView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.fillColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat borderWidth = 2.0f;
    CGRect borderFrame = CGRectInset(self.bounds, borderWidth / 2.0, borderWidth / 2.0);
    
    CGContextSetFillColorWithColor(ctx, [self.fillColor CGColor]);
    CGContextAddEllipseInRect(ctx, borderFrame);
    CGContextFillPath(ctx);

    
    CGContextSetLineWidth(ctx, borderWidth);
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextAddEllipseInRect(ctx, borderFrame);
    CGContextStrokePath(ctx);
}

@end

#pragma mark - Color Picker

@interface SLLColorPicker ()

@property (nonatomic, readwrite, assign) CGImageRef radialImage;
@property (nonatomic, readwrite, assign) SLLColorPickerPixelRGB *imageData;
@property (nonatomic, readwrite, assign) NSInteger imageDataLength;
@property (nonatomic, readwrite, assign) CGFloat radius;
@property (nonatomic, readwrite, assign) CGPoint touchPoint;

- (SLLColorPickerPixelRGB)colorAtPoint:(CGPoint)point;
- (CGPoint)viewToImageSpace:(CGPoint)point;
- (void)updateDropper;
- (CGPoint)pointForColor:(UIColor *)color;

@end

@implementation SLLColorPicker

- (void)commonInit {
    self.radialImage = nil;
    self.imageData = nil;
    
    self.imageDataLength = 0;
    
    _brightness = 1.0;
    self.dropperSize = CGSizeMake(28, 28);
    
    _radius = (MIN(self.bounds.size.width, self.bounds.size.height) / 2.f) - MAX(0.f, self.borderWidth);
    _touchPoint = CGPointMake(self.bounds.size.width / 2.0,
                              self.bounds.size.height / 2.0);
    
    
    self.borderColor = [UIColor blackColor];
    self.borderWidth = 3.0;
    
    self.backgroundColor = [UIColor clearColor];
    self.dropperView = [[SLLDropperView alloc] init];
    
    _continuous = false;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self commonInit];
}

- (void)dealloc {
    [self clearRadialImage];
    
    [self clearImageData];
    
    self.dropperView = nil;
}


- (SLLColorPickerPixelRGB)colorAtPoint:(CGPoint)point {
    CGPoint center = CGPointMake(self.radius,
                                 self.radius);
    
    CGFloat angle = atan2(point.x - center.x,
                          point.y - center.y) + M_PI;
    CGFloat dist = SLLColorPickerPointDistance(point,
                                               CGPointMake(center.x,
                                                           center.y));
    
    CGFloat hue = angle / (M_PI * 2.f);
    
    hue = MIN(hue, 1.f - .0000001f);
    hue = MAX(hue, 0.f);
    
    CGFloat sat = dist / (_radius);
    
    sat = MIN(sat, 1.f);
    sat = MAX(sat, 0.f);
    
    return SLLColorPickerHSBToRGB(hue, sat, self.brightness);
}

- (CGPoint)pointForColor:(UIColor *)color {
    CGFloat hue = 0.f;
    CGFloat saturation = 0.f;
    CGFloat brightness = 1.f;
    CGFloat alpha = 1.f;
    
    [color getHue:&hue
       saturation:&saturation
       brightness:&brightness
            alpha:&alpha];
    
    self.brightness = brightness;
    
    CGPoint center = CGPointMake(self.radius,
                                 self.radius);
    
    CGFloat angle = (hue * (M_PI * 2.f)) + M_PI / 2;
    CGFloat dist = saturation * self.radius;
    
    CGPoint point;
    point.x = center.x + (cosf(angle) * dist);
    point.y = center.y + (sinf(angle) * dist);
    return point;
}

- (CGPoint)viewToImageSpace:(CGPoint)point {
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    point.y = height - point.y;
    
    CGPoint min = CGPointMake((width / 2.f) - self.radius,
                              (height / 2.f) - self.radius);
    
    point.x = point.x - min.x;
    point.y = point.y - min.y;
    
    return point;
}

- (void)updateDropper {
    if (!self.dropperView) {
        return;
    }
    
    self.dropperView.bounds = CGRectMake(0,
                                         0,
                                         self.dropperSize.width,
                                         self.dropperSize.height);
    self.dropperView.center = self.touchPoint;
}

- (void)updateImage {
    if (self.bounds.size.width == 0 || self.bounds.size.height == 0) {
        return;
    }
    
    [self clearRadialImage];
    
    int width = self.radius * 2.f;
    int height = width;
    
    int dataLength = sizeof(SLLColorPickerPixelRGB) * width * height;
    
    if (dataLength != self.imageDataLength) {
        [self clearImageData];
        self.imageData = malloc(dataLength);
        self.imageDataLength = dataLength;
    }
    
    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            self.imageData[x + y * width] = [self colorAtPoint:CGPointMake(x, y)];
        }
    }
    
    CGBitmapInfo bitInfo = kCGBitmapByteOrderDefault;
    
	CGDataProviderRef ref = CGDataProviderCreateWithData(NULL,
                                                         self.imageData,
                                                         dataLength,
                                                         NULL);
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
	self.radialImage = CGImageCreate(width,
                                     height,
                                     8,
                                     24,
                                     width * 3,
                                     colorspace,
                                     bitInfo,
                                     ref,
                                     NULL,
                                     true,
                                     kCGRenderingIntentDefault);
    
    CGColorSpaceRelease(colorspace);
    CGDataProviderRelease(ref);
    
    [self setNeedsDisplay];
}

- (UIColor*)currentColor {
    SLLColorPickerPixelRGB pixel = [self colorAtPoint:[self viewToImageSpace:self.touchPoint]];
    return [UIColor colorWithRed:pixel.red / 255.f
                           green:pixel.green / 255.f
                            blue:pixel.blue / 255.f
                           alpha:1.0];
}

- (void)setCurrentColor:(UIColor*)color {
    CGFloat hue = 0.f;
    CGFloat saturation = 0.f;
    CGFloat brightness = 1.f;
    CGFloat alpha = 1.f;
    
    [color getHue:&hue
       saturation:&saturation
       brightness:&brightness
            alpha:&alpha];
    
    self.brightness = brightness;
    
    CGPoint center = CGPointMake(self.radius,
                                 self.radius);
    
    CGFloat angle = (hue * (M_PI * 2.f)) + M_PI / 2;
    CGFloat dist = saturation * self.radius;
    
    CGPoint point;
    point.x = center.x + (cosf(angle) * dist);
    point.y = center.y + (sinf(angle) * dist);
    [self setTouchPoint:point];
    [self updateImage];
}

- (void)setBrightness:(CGFloat)brightness {
    _brightness = brightness;
    
    [self updateImage];
    [self updateDropperView];
    [self notifyDelegateOfChange];
}

- (void)setDropperView:(UIView *)dropperView {
    if (self.dropperView) {
        [self.dropperView removeFromSuperview];
    }
    
    _dropperView = dropperView;
    
    if (self.dropperView) {
        [self addSubview:self.dropperView];
    }
    
    [self updateDropper];
}

- (void)drawRect:(CGRect)rect {
    UIColor *currentColor = self.currentColor;
    self.radius = (MIN(self.bounds.size.width, self.bounds.size.height) / 2.f) - MAX(0.f, self.borderWidth);
    [self updateImage];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState (ctx);
    
    NSInteger width = self.bounds.size.width;
    NSInteger height = self.bounds.size.height;
    CGPoint center = CGPointMake(width / 2.f,
                                 height / 2.f);

    
    CGRect wheelFrame = CGRectMake(center.x - self.radius,
                                   center.y - self.radius,
                                   self.radius * 2.f,
                                   self.radius * 2.f);
    CGRect borderFrame = CGRectInset(wheelFrame,
                                     -self.borderWidth / 2.f,
                                     -self.borderWidth / 2.f);

    if (self.borderWidth > 0.f) {
        CGContextSetLineWidth(ctx, self.borderWidth);
        CGContextSetStrokeColorWithColor(ctx, [self.borderColor CGColor]);
        CGContextAddEllipseInRect(ctx, borderFrame);
        CGContextStrokePath(ctx);
    }
    
    CGContextAddEllipseInRect(ctx, wheelFrame);
    CGContextClip(ctx);
    
    if (self.radialImage) {
        CGContextDrawImage(ctx, wheelFrame, self.radialImage);
    }
    
    CGContextRestoreGState (ctx);
    CGPoint colorPoint = [self pointForColor:currentColor];
    self.touchPoint = colorPoint;
}

- (void)layoutSubviews {
    // catch the current color before we layout the subviews to prevent the math being incorrect
    UIColor *currentColor = self.currentColor;
    [super layoutSubviews];
    // redraw the circular color picker portion
    self.radius = (MIN(self.bounds.size.width, self.bounds.size.height) / 2.f) - MAX(0.f, self.borderWidth);
    [self updateImage];
    // reset the touch point
    CGPoint colorPoint = [self pointForColor:currentColor];
    self.touchPoint = colorPoint;
}

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event {
    [self willChangeValueForKey:@"currentColor"];
    
    self.touchPoint = [[touches anyObject] locationInView:self];
    
    [self updateDropperView];
    
    [self didChangeValueForKey:@"currentColor"];
    
    [self notifyDelegateOfChange];
}

- (void)touchesMoved:(NSSet *)touches
           withEvent:(UIEvent *)event {
    [self willChangeValueForKey:@"currentColor"];
    
    self.touchPoint = [[touches anyObject] locationInView:self];
    
    [self updateDropperView];
    
    [self didChangeValueForKey:@"currentColor"];
    
    if (self.continuous) {
        [self notifyDelegateOfChange];
    }
}

- (void)touchesEnded:(NSSet *)touches
           withEvent:(UIEvent *)event {
    [self notifyDelegateOfChange];
}


- (void)setTouchPoint:(CGPoint)point {
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    CGPoint center = CGPointMake(width / 2.f,
                                 height / 2.f);
    
    // Check if the touch is outside the wheel
    if (SLLColorPickerPointDistance(center, point) < self.radius) {
        _touchPoint = point;
    } else {
        // If so we need to create a drection vector and calculate the constrained point
        CGPoint vec = CGPointMake(point.x - center.x,
                                  point.y - center.y);
        
        CGFloat extents = sqrtf((vec.x * vec.x) + (vec.y * vec.y));
        
        vec.x /= extents;
        vec.y /= extents;
        
        _touchPoint = CGPointMake(center.x + vec.x * self.radius,
                                  center.y + vec.y * self.radius);
    }
    
    [self updateDropper];
}

#pragma mark - Helper Methods

- (void)notifyDelegateOfChange {
    if ([self.delegate respondsToSelector:@selector(colorPickerDidChangeColor:)]) {
        [self.delegate colorPickerDidChangeColor:self];
    }
}

- (void)updateDropperView {
    if ([self.dropperView respondsToSelector:@selector(setFillColor:)]) {
        [self.dropperView performSelector:@selector(setFillColor:) withObject:self.currentColor afterDelay:0.0f];
        [self.dropperView setNeedsDisplay];
    }
}

- (void)clearImageData {
    if (self.imageData) {
        free(self.imageData);
    }
}

- (void)clearRadialImage {
    if (self.radialImage) {
        CGImageRelease(self.radialImage);
        self.radialImage = nil;
    }
}

@end
