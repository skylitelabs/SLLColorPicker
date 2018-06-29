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
    _colorPicker.delegate = self;
    _colorPicker.continuous = true;
    [self.view addSubview:_colorPicker];
    
    _brightnessSlider = [[UISlider alloc] initWithFrame:CGRectMake(size.width * .4,
                                                                   size.height * .8,
                                                                   size.width * .5,
                                                                   size.height * .1)];
    _brightnessSlider.minimumValue = 0.0;
    _brightnessSlider.maximumValue = 1.0;
    _brightnessSlider.value = 1.0;
    _brightnessSlider.continuous = true;
    [_brightnessSlider addTarget:self action:@selector(changeBrightness:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_brightnessSlider];
    
    _wellView = [[UIView alloc] initWithFrame:CGRectMake(size.width * .1,
                                                         size.height * .8,
                                                         size.width * .2,
                                                         size.height * .1)];
    
    _wellView.layer.borderColor = [UIColor blackColor].CGColor;
    _wellView.layer.borderWidth = 2.0;
    [self.view addSubview:_wellView];
}



- (void)changeBrightness:(UISlider*)sender
{
    [_colorPicker setBrightness:_brightnessSlider.value];
    [_wellView setBackgroundColor:_colorPicker.currentColor];
}

- (void)colorPickerDidChangeColor:(SLLColorPicker *)colorPicker
{
    [_wellView setBackgroundColor:_colorPicker.currentColor];
}

    // Do any additional setup after loading the view, typically from a nib.

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
