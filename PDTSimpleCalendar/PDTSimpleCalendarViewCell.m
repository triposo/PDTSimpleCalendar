//
//  PDTSimpleCalendarViewCell.m
//  PDTSimpleCalendar
//
//  Created by Jerome Miglino on 10/7/13.
//  Copyright (c) 2013 Producteev. All rights reserved.
//

#import "PDTSimpleCalendarViewCell.h"

const CGFloat PDTSimpleCalendarCircleSize = 32.0f;

@interface PDTSimpleCalendarViewCell ()

@property (nonatomic) CALayer *stripe;
@property (nonatomic) CALayer *circle;
@property (nonatomic) UILabel *dayLabel;
@property (nonatomic) NSDate *date;
@property (nonatomic) DateRangeStatus dateRangeStatus;

@end

@implementation PDTSimpleCalendarViewCell

#pragma mark - Class Methods

+ (NSString *)formatDate:(NSDate *)date withCalendar:(NSCalendar *)calendar
{
    NSDateFormatter *dateFormatter = [self dateFormatter];
    return [PDTSimpleCalendarViewCell stringFromDate:date withDateFormatter:dateFormatter withCalendar:calendar];
}

+ (NSString *)formatAccessibilityDate:(NSDate *)date withCalendar:(NSCalendar *)calendar
{
    NSDateFormatter *dateFormatter = [self accessibilityDateFormatter];
    return [PDTSimpleCalendarViewCell stringFromDate:date withDateFormatter:dateFormatter withCalendar:calendar];
}


+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"d";
    });
    return dateFormatter;
}

+ (NSDateFormatter *)accessibilityDateFormatter {
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        
    });
    return dateFormatter;
}

+ (NSString *)stringFromDate:(NSDate *)date withDateFormatter:(NSDateFormatter *)dateFormatter withCalendar:(NSCalendar *)calendar {
    //Test if the calendar is different than the current dateFormatter calendar property
    if (![dateFormatter.calendar isEqual:calendar]) {
        dateFormatter.calendar = calendar;
    }
    return [dateFormatter stringFromDate:date];
}

#pragma mark - Instance Methods

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat length = PDTSimpleCalendarCircleSize;
        self.circle = [CALayer layer];
        self.circle.contentsScale = [UIScreen mainScreen].scale;
        self.circle.frame = CGRectMake(0, 0, length, length);
        self.circle.masksToBounds = TRUE;
        self.circle.cornerRadius = 0.5f * length;
        [self.contentView.layer addSublayer:self.circle];

        _date = nil;

        _dayLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _dayLabel.font = self.textDefaultFont;
        _dayLabel.textAlignment = NSTextAlignmentCenter;
        _dayLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.dayLabel];

        [self setCircleColorSelected:FALSE];
    }
    return self;
}

- (void)setDate:(NSDate *)date calendar:(NSCalendar *)calendar {
    NSString* day = @"";
    NSString* accessibilityDay = @"";
    if (date && calendar) {
        _date = date;
        day = [PDTSimpleCalendarViewCell formatDate:date withCalendar:calendar];
        accessibilityDay = [PDTSimpleCalendarViewCell formatAccessibilityDate:date withCalendar:calendar];
    }
    self.dayLabel.text = day;
    self.dayLabel.accessibilityLabel = accessibilityDay;

    [self.dayLabel sizeToFit];
    [self setNeedsLayout];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self setCircleColorSelected:selected];
}

- (void)setCircleColorSelected:(BOOL)selected {
    UIColor *circleColor;
    UIColor *labelColor = [self textDefaultColor];

    if (self.date && self.delegate) {
        if ([self.delegate respondsToSelector:@selector(simpleCalendarViewCell:shouldUseCustomColorsForDate:)] && [self.delegate simpleCalendarViewCell:self shouldUseCustomColorsForDate:self.date]) {

            if ([self.delegate respondsToSelector:@selector(simpleCalendarViewCell:textColorForDate:)] && [self.delegate simpleCalendarViewCell:self textColorForDate:self.date]) {
                labelColor = [self.delegate simpleCalendarViewCell:self textColorForDate:self.date];
            }

            if ([self.delegate respondsToSelector:@selector(simpleCalendarViewCell:circleColorForDate:)] && [self.delegate simpleCalendarViewCell:self circleColorForDate:self.date]) {
                circleColor = [self.delegate simpleCalendarViewCell:self circleColorForDate:self.date];
            }
        }


    }

    if (selected) {
        circleColor = [self circleSelectedColor];
        labelColor = [self textSelectedColor];
    }

    [CATransaction begin];
    [CATransaction setDisableActions:TRUE];

    if (circleColor) {
        self.circle.backgroundColor = circleColor.CGColor;
        self.circle.hidden = FALSE;
    } else {
        self.circle.hidden = TRUE;
    }

    self.dayLabel.textColor = labelColor;
    
    [CATransaction commit];
}

- (void)refreshCellColors {
    [self setCircleColorSelected:self.isSelected];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [CATransaction begin];
    [CATransaction setDisableActions:TRUE];

    CGPoint center = {
        .x = CGRectGetMidX(self.contentView.bounds),
        .y = CGRectGetMidY(self.contentView.bounds)
    };

    CGSize size = self.dayLabel.bounds.size;

    self.dayLabel.center = (CGPoint) {
        .x = roundf(center.x - 0.5f * size.width) + 0.5f * size.width,
        .y = roundf(center.y - 0.5f * size.height) + 0.5f * size.height
    };

    self.circle.position = self.dayLabel.center;

    [CATransaction commit];
}

#pragma mark - Prepare for Reuse

- (void)prepareForReuse {
    [super prepareForReuse];

    self.date = nil;
    self.dateRangeStatus = DateRangeStatusNone;

    [CATransaction begin];
    [CATransaction setDisableActions:TRUE];

    self.dayLabel.text = @"";
    self.dayLabel.textColor = [self textDefaultColor];
    self.circle.hidden = TRUE;

    [CATransaction commit];
}

- (UIColor *)cellRangeColor {
    if (!_cellRangeColor) {
        _cellRangeColor = [[[self class] appearance] cellRangeColor];
    }

    if (_cellRangeColor) {
        return _cellRangeColor;
    }

    return [UIColor colorWithWhite:0.925f alpha:1.f];
}

#pragma mark - Circle Color Customization Methods

- (UIColor *)circleDefaultColor
{
    if(_circleDefaultColor == nil) {
        _circleDefaultColor = [[[self class] appearance] circleDefaultColor];
    }

    if(_circleDefaultColor != nil) {
        return _circleDefaultColor;
    }

    return [UIColor whiteColor];
}

- (UIColor *)circleSelectedColor {
    if(_circleSelectedColor == nil) {
        _circleSelectedColor = [[[self class] appearance] circleSelectedColor];
    }

    if(_circleSelectedColor != nil) {
        return _circleSelectedColor;
    }

    return [UIColor colorWithRed:0.318 green:0.659 blue:0.808 alpha:1];
}

- (UIColor *)circleRangeEndColor {
    if (!_circleRangeEndColor) {
        _circleRangeEndColor = [[[self class] appearance] circleRangeEndColor];
    }

    if (_circleRangeEndColor) {
        return _circleRangeEndColor;
    }

    return [UIColor grayColor];
}

#pragma mark - Text Label Customizations Color

- (UIColor *)textDefaultColor
{
    if(_textDefaultColor == nil) {
        _textDefaultColor = [[[self class] appearance] textDefaultColor];
    }

    if(_textDefaultColor != nil) {
        return _textDefaultColor;
    }

    return [UIColor blackColor];
}

- (UIColor *)textSelectedColor
{
    if(_textSelectedColor == nil) {
        _textSelectedColor = [[[self class] appearance] textSelectedColor];
    }

    if(_textSelectedColor != nil) {
        return _textSelectedColor;
    }

    return [UIColor whiteColor];
}

- (UIColor *)textDisabledColor
{
    if(_textDisabledColor == nil) {
        _textDisabledColor = [[[self class] appearance] textDisabledColor];
    }

    if(_textDisabledColor != nil) {
        return _textDisabledColor;
    }

    return [UIColor lightGrayColor];
}

#pragma mark - Text Label Customizations Font

- (UIFont *)textDefaultFont
{
    if(_textDefaultFont == nil) {
        _textDefaultFont = [[[self class] appearance] textDefaultFont];
    }

    if (_textDefaultFont != nil) {
        return _textDefaultFont;
    }

    // default system font
    return [UIFont systemFontOfSize:17.0];
}

@end
