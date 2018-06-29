/*
 Modified Version By: Leejay Schmidt (Skylite Labs Inc.)
 
 Copyright (c) 2018 Skylite Labs Inc.
 Based on the original: ISColorWheel from Justin Meiners : https://github.com/justinmeiners/ios-color-wheel
 Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
 */

#import "SLLColorPicker.h"

static inline CGFloat SLLColorPicker_PointDistance(CGPoint p1,
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

@interface SLLDropperView : UIView

@property (nonatomic, readwrite, null_unspecified, strong) UIColor* fillColor;

@end

@implementation SLLDropperView

- (id)initWithFrame:(CGRect)frame {
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

@interface SLLColorPicker ()

@property (nonatomic, readwrite, assign) CGImageRef radialImage;
@property (nonatomic, readwrite, assign) SLLColorPickerPixelRGB *imageData;
@property (nonatomic, readwrite, assign) NSInteger imageDataLength;
@property (nonatomic, readwrite, assign) CGFloat radius;
@property (nonatomic, readwrite, assign) CGPoint touchPoint;

- (SLLColorPickerPixelRGB)colorAtPoint:(CGPoint)point;
- (CGPoint)viewToImageSpace:(CGPoint)point;
- (void)updateDropper;

@end

@implementation SLLColorPicker

- (void)doInit
{
    _radialImage = nil;
    _imageData = nil;
    
    _imageDataLength = 0;
    
    _brightness = 1.0;
    _dropperSize = CGSizeMake(28, 28);
    
    _touchPoint = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
    
    
    self.borderColor = [UIColor blackColor];
    self.borderWidth = 3.0;
    
    self.backgroundColor = [UIColor clearColor];
    self.dropperView = [[SLLDropperView alloc] init];
    
    _continuous = false;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self doInit];
    }
    return self;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    [self doInit];
}

- (void)dealloc
{
    if (_radialImage)
    {
        CGImageRelease(_radialImage);
        _radialImage = nil;
    }
    
    if (_imageData)
    {
        free(_imageData);
    }
    
    self.dropperView = nil;
}


- (SLLColorPickerPixelRGB)colorAtPoint:(CGPoint)point
{
    CGPoint center = CGPointMake(_radius, _radius);
    
    CGFloat angle = atan2(point.x - center.x, point.y - center.y) + M_PI;
    CGFloat dist = SLLColorPicker_PointDistance(point, CGPointMake(center.x, center.y));
    
    CGFloat hue = angle / (M_PI * 2.0f);
    
    hue = MIN(hue, 1.0f - .0000001f);
    hue = MAX(hue, 0.0f);
    
    CGFloat sat = dist / (_radius);
    
    sat = MIN(sat, 1.0f);
    sat = MAX(sat, 0.0f);
    
    return SLLColorPickerHSBToRGB(hue, sat, _brightness);
}

- (CGPoint)viewToImageSpace:(CGPoint)point
{
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    point.y = height - point.y;
    
    CGPoint min = CGPointMake(width / 2.0 - _radius, height / 2.0 - _radius);
    
    point.x = point.x - min.x;
    point.y = point.y - min.y;
    
    return point;
}

- (void)updateDropper
{
    if (!_dropperView)
    {
        return;
    }
    
    _dropperView.bounds = CGRectMake(0, 0, _dropperSize.width, _dropperSize.height);
    _dropperView.center = _touchPoint;
}

- (void)updateImage
{
    if (self.bounds.size.width == 0 || self.bounds.size.height == 0)
    {
        return;
    }
    
    if (_radialImage)
    {
        CGImageRelease(_radialImage);
        _radialImage = nil;
    }
    
    int width = _radius * 2.0;
    int height = width;
    
    int dataLength = sizeof(SLLColorPickerPixelRGB) * width * height;
    
    if (dataLength != _imageDataLength)
    {
        if (_imageData)
        {
            free(_imageData);
        }
        _imageData = malloc(dataLength);
        _imageDataLength = dataLength;
    }
    
    for (int y = 0; y < height; ++y)
    {
        for (int x = 0; x < width; ++x)
        {
            _imageData[x + y * width] = [self colorAtPoint:CGPointMake(x, y)];
        }
    }
    
    CGBitmapInfo bitInfo = kCGBitmapByteOrderDefault;
    
	CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, _imageData, dataLength, NULL);
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
	_radialImage = CGImageCreate(width,
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

- (UIColor*)currentColor
{
    SLLColorPickerPixelRGB pixel = [self colorAtPoint:[self viewToImageSpace:_touchPoint]];
    return [UIColor colorWithRed:pixel.red / 255.f
                           green:pixel.green / 255.f
                            blue:pixel.blue / 255.f
                           alpha:1.0];
}

- (void)setCurrentColor:(UIColor*)color
{
    CGFloat h = 0.0;
    CGFloat s = 0.0;
    CGFloat b = 1.0;
    CGFloat a = 1.0;
    
    [color getHue:&h saturation:&s brightness:&b alpha:&a];
    
    self.brightness = b;
    
    CGPoint center = CGPointMake(_radius, _radius);
    
    CGFloat angle = (h * (M_PI * 2.0)) + M_PI / 2;
    CGFloat dist = s * _radius;
    
    CGPoint point;
    point.x = center.x + (cosf(angle) * dist);
    point.y = center.y + (sinf(angle) * dist);
    
    [self setTouchPoint: point];
    [self updateImage];
}

- (void)setBrightness:(CGFloat)brightness
{
    _brightness = brightness;
    
    [self updateImage];
    
    if ([_dropperView respondsToSelector:@selector(setFillColor:)])
    {
        [_dropperView performSelector:@selector(setFillColor:) withObject:self.currentColor afterDelay:0.0f];
        [_dropperView setNeedsDisplay];
    }
    
    [_delegate colorPickerDidChangeColor:self];
}

- (void)setDropperView:(UIView *)dropperView
{
    if (_dropperView)
    {
        [_dropperView removeFromSuperview];
    }
    
    _dropperView = dropperView;
    
    if (_dropperView)
    {
        [self addSubview:_dropperView];
    }
    
    [self updateDropper];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState (ctx);
    
    NSInteger width = self.bounds.size.width;
    NSInteger height = self.bounds.size.height;
    CGPoint center = CGPointMake(width / 2.0, height / 2.0);

    
    CGRect wheelFrame = CGRectMake(center.x - _radius, center.y - _radius, _radius * 2.0, _radius * 2.0);
    CGRect borderFrame = CGRectInset(wheelFrame, -_borderWidth / 2.0, -_borderWidth / 2.0);

    if (_borderWidth > 0.0f)
    {
        CGContextSetLineWidth(ctx, _borderWidth);
        CGContextSetStrokeColorWithColor(ctx, [_borderColor CGColor]);
        CGContextAddEllipseInRect(ctx, borderFrame);
        CGContextStrokePath(ctx);
    }
    
    CGContextAddEllipseInRect(ctx, wheelFrame);
    CGContextClip(ctx);
    
    if (_radialImage)
    {
        CGContextDrawImage(ctx, wheelFrame, _radialImage);
    }
    
    CGContextRestoreGState (ctx);
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _radius = (MIN(self.bounds.size.width, self.bounds.size.height) / 2.0) - MAX(0.0f, _borderWidth);
    
    [self updateImage];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self willChangeValueForKey:@"currentColor"];
    
    [self setTouchPoint:[[touches anyObject] locationInView:self]];
    
    if ([_dropperView respondsToSelector:@selector(setFillColor:)])
    {
        [_dropperView performSelector:@selector(setFillColor:) withObject:self.currentColor afterDelay:0.0f];
        [_dropperView setNeedsDisplay];
    }
    
    [self didChangeValueForKey:@"currentColor"];
    
    [_delegate colorPickerDidChangeColor:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self willChangeValueForKey:@"currentColor"];
    
    [self setTouchPoint:[[touches anyObject] locationInView:self]];
    
    if ([_dropperView respondsToSelector:@selector(setFillColor:)])
    {
        [_dropperView performSelector:@selector(setFillColor:) withObject:self.currentColor afterDelay:0.0f];
        [_dropperView setNeedsDisplay];
    }
    
    [self didChangeValueForKey:@"currentColor"];
    
    if (_continuous)
    {
        [_delegate colorPickerDidChangeColor:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_delegate colorPickerDidChangeColor:self];
}


- (void)setTouchPoint:(CGPoint)point
{
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    CGPoint center = CGPointMake(width / 2.0, height / 2.0);
    
    // Check if the touch is outside the wheel
    if (SLLColorPicker_PointDistance(center, point) < _radius)
    {
        _touchPoint = point;
    }
    else
    {
        // If so we need to create a drection vector and calculate the constrained point
        CGPoint vec = CGPointMake(point.x - center.x, point.y - center.y);
        
        CGFloat extents = sqrtf((vec.x * vec.x) + (vec.y * vec.y));
        
        vec.x /= extents;
        vec.y /= extents;
        
        _touchPoint = CGPointMake(center.x + vec.x * _radius, center.y + vec.y * _radius);
    }
    
    [self updateDropper];
}

@end
