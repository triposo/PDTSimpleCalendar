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

@property (nonatomic) CAShapeLayer *circleLayer;
@property (nonatomic) UILabel *dayLabel;
@property (nonatomic) UILabel *markerLabel;
@property (nonatomic) NSDate *date;

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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.circleLayer = [CAShapeLayer layer];
        self.circleLayer.frame = CGRectMake(0, 0, PDTSimpleCalendarCircleSize, PDTSimpleCalendarCircleSize);
        self.circleLayer.contentsScale = [UIScreen mainScreen].scale;
        self.circleLayer.path = [UIBezierPath bezierPathWithOvalInRect:self.circleLayer.bounds].CGPath;
        [self.contentView.layer addSublayer:self.circleLayer];

        _date = nil;
        _isToday = NO;
        _dayLabel = [[UILabel alloc] initWithFrame:self.circleLayer.frame];
        _dayLabel.font = [self textDefaultFont];
        _dayLabel.textAlignment = NSTextAlignmentCenter;
        _dayLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.dayLabel];

        [self setCircleColor:NO selected:NO];
    }

    return self;
}

- (void)setDate:(NSDate *)date calendar:(NSCalendar *)calendar
{
    NSString* day = @"";
    NSString* accessibilityDay = @"";
    if (date && calendar) {
        _date = date;
        day = [PDTSimpleCalendarViewCell formatDate:date withCalendar:calendar];
        accessibilityDay = [PDTSimpleCalendarViewCell formatAccessibilityDate:date withCalendar:calendar];
    }
    self.dayLabel.text = day;
    self.dayLabel.accessibilityLabel = accessibilityDay;
}

- (void)setIsToday:(BOOL)isToday
{
    _isToday = isToday;
    [self setCircleColor:isToday selected:self.selected];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self setCircleColor:self.isToday selected:selected];
}

- (void)setMarker:(NSString *)text {
    if (!self.markerLabel.superview) {
        self.markerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 32.0f, 8.0f)];
        self.markerLabel.font = [UIFont systemFontOfSize:8];
        self.markerLabel.adjustsFontSizeToFitWidth = TRUE;
        self.markerLabel.backgroundColor = [UIColor clearColor];
        self.markerLabel.numberOfLines = 1;
        self.markerLabel.textAlignment = NSTextAlignmentCenter;

        [self.contentView addSubview:self.markerLabel];
        [self setNeedsLayout];
    }

    if ([text length]) {
        self.markerLabel.text = text;
        self.markerLabel.hidden = FALSE;
    } else {
        self.markerLabel.hidden = TRUE;
    }
}

- (void)setCircleColor:(BOOL)today selected:(BOOL)selected
{
    UIColor *circleColor = (today) ? [self circleTodayColor] : [self circleDefaultColor];
    UIColor *labelColor = (today) ? [self textTodayColor] : [self textDefaultColor];

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
        self.circleLayer.fillColor = circleColor.CGColor;
        self.circleLayer.hidden = FALSE;
    } else {
        self.circleLayer.hidden = TRUE;
    }

    self.dayLabel.textColor = labelColor;
    self.markerLabel.textColor = labelColor;

    [CATransaction commit];
}


- (void)refreshCellColors
{
    [self setCircleColor:self.isToday selected:self.isSelected];
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

    self.circleLayer.position = self.dayLabel.center;

    if (self.markerLabel) {
        size = self.markerLabel.bounds.size;

        self.markerLabel.center = (CGPoint) {
            .x = roundf(CGRectGetMidX(self.circleLayer.frame) - 0.5f * size.width) + 0.5f * size.width,
            .y = roundf(CGRectGetMaxY(self.circleLayer.frame) - 0.5f * size.height) + 0.5f * size.height
        };
    }

    [CATransaction commit];
}

#pragma mark - Prepare for Reuse

- (void)prepareForReuse
{
    [super prepareForReuse];
    _date = nil;
    _isToday = NO;

    [CATransaction begin];
    [CATransaction setDisableActions:TRUE];

    self.dayLabel.text = @"";
    self.dayLabel.textColor = [self textDefaultColor];
    self.markerLabel.text = nil;
    self.markerLabel.textColor = [self textDefaultColor];
    self.circleLayer.hidden = TRUE;

    [CATransaction commit];
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

- (UIColor *)circleTodayColor
{
    if(_circleTodayColor == nil) {
        _circleTodayColor = [[[self class] appearance] circleTodayColor];
    }

    if(_circleTodayColor != nil) {
        return _circleTodayColor;
    }

    return [UIColor grayColor];
}

- (UIColor *)circleSelectedColor
{
    if(_circleSelectedColor == nil) {
        _circleSelectedColor = [[[self class] appearance] circleSelectedColor];
    }

    if(_circleSelectedColor != nil) {
        return _circleSelectedColor;
    }

    return [UIColor redColor];
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

- (UIColor *)textTodayColor
{
    if(_textTodayColor == nil) {
        _textTodayColor = [[[self class] appearance] textTodayColor];
    }

    if(_textTodayColor != nil) {
        return _textTodayColor;
    }

    return [UIColor whiteColor];
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
