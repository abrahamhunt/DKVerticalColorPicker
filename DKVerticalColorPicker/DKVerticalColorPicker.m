//  DKVerticalColorPicker.m

/*
 DKVerticalColorPicker
 Copyright (c) 2015 David Kopec
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

#import "DKVerticalColorPicker.h"

@interface DKVerticalColorPicker ()

@property (nonatomic) CGFloat currentSelectionY;
@property (nonatomic) CGFloat lastHueSelection;

@end

@implementation DKVerticalColorPicker

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

// for when coming out of a nib
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _currentSelectionY = 0.0;
    self.backgroundColor = [UIColor clearColor];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    
    //draw wings
    [[UIColor blackColor] set];
    CGFloat tempYPlace = self.currentSelectionY;
    if (tempYPlace < 0.0) {
        tempYPlace = 0.0;
    } else if (tempYPlace >= self.frame.size.height) {
        tempYPlace = self.frame.size.height - 1.0;
    }
    CGRect temp = CGRectMake(0.0, tempYPlace, self.frame.size.width, 1.0);
    UIRectFill(temp);
    
    //draw central bar over it
    CGFloat cbxbegin = self.frame.size.width * 0.2;
    CGFloat cbwidth = self.frame.size.width * 0.6;
    for (int y = 0; y < self.frame.size.height; y++) {
        [[self colorFromY:y] set];
        CGRect temp = CGRectMake(cbxbegin, y, cbwidth, 1.0);
        UIRectFill(temp);
    }
}

/*!
 Changes the selected color, updates the UI, and notifies the delegate.
 */
- (void)setSelectedColor:(UIColor *)selectedColor
{
    if (selectedColor != _selectedColor) {
        [self setCurrentSelectionYFromColor:selectedColor];
        _selectedColor = selectedColor;
        [self notifyDelegateOfColor:_selectedColor];
    }
}

- (void)setCurrentSelectionYFromColor:selectedColor {
    CGFloat hue = 0.0, sat = 0.0, bright = 0.0, temp = 0.0;
    if (![selectedColor getHue:&hue saturation:&sat brightness:&bright alpha:&temp]) {
        return;
    }
    CGFloat forCalc;
    switch (self.pickerType) {
        case PickerTypeHue:
            forCalc = hue;
            break;
        case PickerTypeBrightness:
            forCalc = bright;
            break;
        case PickerTypeSaturation:
            forCalc = sat;
            break;
    }
    _currentSelectionY = floorf(forCalc * self.frame.size.height);
    [self adjustHueSelectionAsNeeded];
    [self setNeedsDisplay];
}

- (void)setCurrentSelectionY:(CGFloat)currentSelectionY {
    if (currentSelectionY == _currentSelectionY) {
        return;
    }
    _currentSelectionY = currentSelectionY;
    [self adjustHueSelectionAsNeeded];
    _selectedColor = [self colorFromY:currentSelectionY];
    [self notifyDelegateOfColor:self.selectedColor];
    [self setNeedsDisplay];
}

- (void)setPickerType:(PickerType)pickerType {
    if (pickerType == _pickerType) {
        return;
    }
    _pickerType = pickerType;
    _selectedColor = [self colorFromY:self.currentSelectionY];
    [self notifyDelegateOfColor:self.selectedColor];
    [self setNeedsDisplay];
}

- (void)adjustHueSelectionAsNeeded {
    if (self.pickerType == PickerTypeHue) {
        self.lastHueSelection = self.currentSelectionY / self.frame.size.height;
    }
}

#pragma mark - Touch Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.currentSelectionY = [((UITouch *)[touches anyObject]) locationInView:self].y;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.currentSelectionY = [((UITouch *)[touches anyObject]) locationInView:self].y;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.currentSelectionY = [((UITouch *)[touches anyObject]) locationInView:self].y;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

#pragma mark - Helpers

- (UIColor *)colorFromY:(CGFloat)y {
    return [self colorFromValue:y/self.frame.size.height andType:self.pickerType];
}

- (UIColor *)colorFromValue:(CGFloat)value andType:(PickerType)type {
    switch (type) {
        case PickerTypeBrightness:
            return [UIColor colorWithHue:1.0 saturation:0 brightness:value alpha:1.0];
        case PickerTypeHue:
            return [UIColor colorWithHue:value saturation:1.0 brightness:1.0 alpha:1.0];
        case PickerTypeSaturation:
            return [UIColor colorWithHue:self.lastHueSelection saturation:value brightness:1.0 alpha:1.0];
    }
}

- (void)notifyDelegateOfColor:(UIColor *)color {
    if([self.delegate respondsToSelector:@selector(colorPicked:)]) {
        [self.delegate colorPicked:color];
    }
}

@end
