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

#define kGrabBarThickness 6.0f
#define kGrabBarRounding kGrabBarThickness / 2.0f
#define kGrabBarOutlineThickness 1.0f
#define kColorBarRounding 4

@interface DKVerticalColorPicker ()

@property (nonatomic) CGFloat currentSelection;
@property (nonatomic) CGFloat lastHueSelection;
@property (nonatomic) CGFloat lastBrightnessSelection;
@property (nonatomic) CGFloat lastSaturationSelection;

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
    _verticalPicker = YES;
    _currentSelection = 0.0;
    _lastBrightnessSelection = 1.0;
    _lastSaturationSelection = 1.0;
    self.backgroundColor = [UIColor clearColor];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    [self drawGradient];
    [self drawGrabBar];
}

- (void)drawGradient {
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    //draw gradient
    CGFloat cbLocationBegin = self.verticalPicker ? self.frame.size.width : self.frame.size.height;
    CGFloat cbThickness = cbLocationBegin;
    cbLocationBegin *= 0.2;
    cbThickness *= 0.6;
    CGFloat cbTotalLength = self.verticalPicker ? self.frame.size.height : self.frame.size.width;
    for (int xy = 0; xy < cbTotalLength; xy ++) {
        [[self colorFromPosition:xy] setFill];
        CGRect temp;
        if (self.verticalPicker) {
            temp = CGRectMake(cbLocationBegin, xy, cbThickness, 1.0);
        } else {
            temp = CGRectMake(xy, cbLocationBegin, 1.0, cbThickness);
        }
        if (xy < kColorBarRounding || cbTotalLength - xy <= kColorBarRounding) {
            //To get a rounded gradient bar we draw rounded rects on the ends
            if (self.verticalPicker) {
                temp.size.height = kColorBarRounding * 2;
            } else {
                temp.size.width = kColorBarRounding * 2;
            }
            if (cbTotalLength - xy <= kColorBarRounding) {
                if (self.verticalPicker) {
                    temp.origin.y -= kColorBarRounding;
                } else {
                    temp.origin.x -= kColorBarRounding;
                }
                xy += kColorBarRounding;
            }
            CGMutablePathRef mutablePath = CGPathCreateMutable();
            CGPathAddRoundedRect(mutablePath, NULL, temp, kColorBarRounding, kColorBarRounding);
            CGContextAddPath(currentContext, mutablePath);
            CGContextFillPath(currentContext);
            CGPathRelease(mutablePath);
        } else {
            UIRectFill(temp);
        }
    }
}

- (void)drawGrabBar {
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGFloat tempPlace = self.currentSelection;
    if (tempPlace < 0.0) {
        tempPlace = kGrabBarOutlineThickness/2.0;
    } else if (self.verticalPicker && tempPlace >= self.frame.size.height - kGrabBarThickness) {
        tempPlace = self.frame.size.height - kGrabBarThickness - kGrabBarOutlineThickness/2.0;
    } else if (!self.verticalPicker && tempPlace >= self.frame.size.width - kGrabBarThickness) {
        tempPlace = self.frame.size.width - kGrabBarThickness - kGrabBarOutlineThickness/2.0;
    }
    CGRect temp;
    if (self.verticalPicker) {
        temp = CGRectMake(kGrabBarOutlineThickness/2.0, tempPlace, self.frame.size.width - kGrabBarOutlineThickness, kGrabBarThickness);
    } else {
        temp = CGRectMake(tempPlace, kGrabBarOutlineThickness/2.0, kGrabBarThickness, self.frame.size.height - kGrabBarOutlineThickness);
    }
    [[self colorFromPosition:self.currentSelection] setFill];
    [[UIColor whiteColor] setStroke];
    CGContextSetLineWidth(currentContext, kGrabBarOutlineThickness);
    CGMutablePathRef mutablePath = CGPathCreateMutable();
    CGPathAddRoundedRect(mutablePath, NULL, temp, kGrabBarRounding, kGrabBarRounding);
    CGContextAddPath(currentContext, mutablePath);
    CGContextFillPath(currentContext);
    CGContextAddPath(currentContext, mutablePath);
    CGContextStrokePath(currentContext);
    CGPathRelease(mutablePath);
}

/*!
 Changes the selected color, updates the UI, and notifies the delegate.
 */
- (void)setSelectedColor:(UIColor *)selectedColor {
    if (selectedColor == _selectedColor) {
        return;
    }
    [self setCurrentSelectionFromColor:selectedColor];
    [self setNeedsDisplay];
    _selectedColor = selectedColor;
    [self notifyDelegateOfColor:_selectedColor];
}

- (void)setCurrentSelectionFromColor:(UIColor *)selectedColor {
    CGFloat hue = 0.0, sat = 0.0, bright = 0.0, temp = 0.0;
    if (![selectedColor getHue:&hue saturation:&sat brightness:&bright alpha:&temp]) {
        return;
    }
    CGFloat forCalc;
    switch (self.pickerType) {
        case PickerTypeHueIndependent:
        case PickerTypeHueInterdependent:
            forCalc = hue;
            self.lastHueSelection = forCalc;
            break;
        case PickerTypeBrightnessIndependent:
        case PickerTypeBrightnessInterdependent:
            forCalc = bright;
            self.lastBrightnessSelection = forCalc;
            break;
        case PickerTypeSaturationBasedOnHue:
        case PickerTypeSaturationInterdependent:
            forCalc = sat;
            self.lastSaturationSelection = forCalc;
            break;
    }
    if (self.verticalPicker) {
        _currentSelection = floorf(forCalc * self.frame.size.height);
    } else {
        _currentSelection = floorf(forCalc * self.frame.size.width);
    }
}

- (void)setCurrentSelection:(CGFloat)currentSelection {
    if (currentSelection == _currentSelection) {
        return;
    }
    _currentSelection = currentSelection;
    [self adjustValueSelection];
    _selectedColor = [self colorFromPosition:currentSelection];
    [self notifyDelegateOfColor:self.selectedColor];
    [self setNeedsDisplay];
}

- (void)setPickerType:(PickerType)pickerType {
    if (pickerType == _pickerType) {
        return;
    }
    PickerType previousType = _pickerType;
    _pickerType = pickerType;
    if (pickerType >= PickerTypeHueInterdependent && previousType >= PickerTypeHueInterdependent) {
        [self setCurrentSelectionFromColor:self.selectedColor];
    } else {
        //color shouldn't change, but we should adjust the current selection according to type...
        _selectedColor = [self colorFromPosition:self.currentSelection];
        [self adjustValueSelection];
    }
    [self notifyDelegateOfColor:self.selectedColor];
    [self setNeedsDisplay];
}

- (NSString *)keyForPickerType:(PickerType)type {
    switch (type) {
        case PickerTypeHueIndependent:
        case PickerTypeHueInterdependent:
            return @"lastHueSelection";
        case PickerTypeBrightnessIndependent:
        case PickerTypeBrightnessInterdependent:
            return @"lastBrightnessSelection";
        case PickerTypeSaturationBasedOnHue:
        case PickerTypeSaturationInterdependent:
            return @"lastSaturationSelection";
    }
}

- (void)adjustValueSelection {
    CGFloat value;
    if (self.verticalPicker) {
        value = self.currentSelection / self.frame.size.height;
    } else {
        value = self.currentSelection / self.frame.size.width;
    }
    [self setValue:@(value) forKey:[self keyForPickerType:self.pickerType]];
}

#pragma mark - Touch Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self setSelectionWithTouches:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self setSelectionWithTouches:touches];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self setSelectionWithTouches:touches];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

#pragma mark - Helpers

- (void)setSelectionWithTouches:(NSSet *)touches {
    if (self.verticalPicker) {
        self.currentSelection = [((UITouch *)[touches anyObject]) locationInView:self].y;
    } else {
        self.currentSelection = [((UITouch *)[touches anyObject]) locationInView:self].x;
    }
}

- (UIColor *)colorFromPosition:(CGFloat)position {
    if (self.verticalPicker) {
        return [self colorFromValue:position/self.frame.size.height andType:self.pickerType];
    }
    return [self colorFromValue:position/self.frame.size.width andType:self.pickerType];
}

- (UIColor *)colorFromValue:(CGFloat)value andType:(PickerType)type {
    switch (type) {
        case PickerTypeHueIndependent:
            return [UIColor colorWithHue:value saturation:1.0 brightness:1.0 alpha:1.0];
        case PickerTypeSaturationBasedOnHue:
            return [UIColor colorWithHue:self.lastHueSelection saturation:value brightness:1.0 alpha:1.0];
        case PickerTypeBrightnessIndependent:
            return [UIColor colorWithHue:1.0 saturation:0 brightness:value alpha:1.0];
        case PickerTypeHueInterdependent:
            return [UIColor colorWithHue:value saturation:self.lastSaturationSelection brightness:self.lastBrightnessSelection alpha:1.0];
        case PickerTypeSaturationInterdependent:
            return [UIColor colorWithHue:self.lastHueSelection saturation:value brightness:self.lastBrightnessSelection alpha:1.0];
        case PickerTypeBrightnessInterdependent:
            return [UIColor colorWithHue:self.lastHueSelection saturation:self.lastSaturationSelection brightness:value alpha:1.0];
    }
}

- (void)notifyDelegateOfColor:(UIColor *)color {
    if([self.delegate respondsToSelector:@selector(colorPicked:)]) {
        [self.delegate colorPicked:color];
    }
}

@end
