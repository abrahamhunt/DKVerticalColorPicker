//
//  ViewController.m
//  DKVerticalColorPicker
//
//  Created by David Kopec on 1/6/15.
//  Copyright (c) 2015 Oak Snow Consulting. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, weak) IBOutlet DKVerticalColorPicker *vertPicker;
@property (nonatomic, weak) IBOutlet UIView *sampleView;
@property (nonatomic, strong) NSArray *pickerTypes;
@property (weak, nonatomic) IBOutlet UIPickerView *typePicker;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pickerTypes = @[@"Hue Independent",@"Saturation Based on Hue",@"Brightness Independent", @"Hue Dependent", @"Saturation Dependent", @"Brightness Dependent"];
    //self.vertPicker.selectedColor = [UIColor blueColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)colorPicked:(UIColor *)color
{
    self.sampleView.backgroundColor = color;
}

#pragma mark - UIPickerView

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.pickerTypes[row];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.pickerTypes.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.vertPicker.pickerType = row;
}

@end
