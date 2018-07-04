/*
 Modified Version By: Leejay Schmidt (Skylite Labs Inc.)
 
 Copyright (c) 2018 Skylite Labs Inc.
 Based on the original: ISColorWheel from Justin Meiners : https://github.com/justinmeiners/ios-color-wheel
 Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
 */

#import "SLLViewController.h"
#import "SLLColorPicker.h"

@interface SLLViewController () <SLLColorPickerDelegate>

@property (nonatomic, readwrite, nonnull, strong) SLLColorPicker *colorPicker;
@property (nonatomic, readwrite, nonnull, strong) UISlider *brightnessSlider;
@property (nonatomic, readwrite, nonnull, strong) UIView *wellView;

@end

@implementation SLLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGSize size = self.view.bounds.size;
    
    CGSize pickerSize = CGSizeMake(size.width * .9, size.width * .9);
    
    self.colorPicker = [[SLLColorPicker alloc] initWithFrame:CGRectMake(size.width / 2 - pickerSize.width / 2,
                                                                        size.height * .1,
                                                                        pickerSize.width,
                                                                        pickerSize.height)];
    self.colorPicker.delegate = self;
    self.colorPicker.continuous = true;
    [self.view addSubview:self.colorPicker];
    
    self.brightnessSlider = [[UISlider alloc] initWithFrame:CGRectMake(size.width * .4,
                                                                       size.height * .8,
                                                                       size.width * .5,
                                                                       size.height * .1)];
    self.brightnessSlider.minimumValue = 0.0;
    self.brightnessSlider.maximumValue = 1.0;
    self.brightnessSlider.value = 1.0;
    self.brightnessSlider.continuous = true;
    [self.brightnessSlider addTarget:self
                              action:@selector(changeBrightness:)
                    forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.brightnessSlider];
    
    self.wellView = [[UIView alloc] initWithFrame:CGRectMake(size.width * .1,
                                                             size.height * .8,
                                                             size.width * .2,
                                                             size.height * .1)];
    
    self.wellView.layer.borderColor = [UIColor blackColor].CGColor;
    self.wellView.layer.borderWidth = 2.0;
    [self.view addSubview:self.wellView];
    self.colorPicker.currentColor = [UIColor colorWithRed:249.f / 255
                                                    green:150.f / 255
                                                     blue:45.f / 255
                                                    alpha:1.f];
    self.wellView.backgroundColor = self.colorPicker.currentColor;
}



- (void)changeBrightness:(UISlider*)sender
{
    self.colorPicker.brightness = self.brightnessSlider.value;
    self.wellView.backgroundColor = self.colorPicker.currentColor;
}

- (void)colorPickerDidChangeColor:(SLLColorPicker *)colorPicker
{
    self.wellView.backgroundColor =self.colorPicker.currentColor;
}

    // Do any additional setup after loading the view, typically from a nib.

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
