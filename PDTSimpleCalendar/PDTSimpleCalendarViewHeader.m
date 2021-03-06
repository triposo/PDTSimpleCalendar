//
//  PDTSimpleCalendarViewHeader.m
//  PDTSimpleCalendar
//
//  Created by Jerome Miglino on 10/8/13.
//  Copyright (c) 2013 Producteev. All rights reserved.
//

#import "PDTSimpleCalendarViewHeader.h"

const CGFloat PDTSimpleCalendarHeaderTextSize = 13.0f;

@interface PDTSimpleCalendarViewHeader ()

@property (nonatomic) NSArray *weekdayLabels;
@property (nonatomic, weak) CALayer *bottomBorder;

@end

@implementation PDTSimpleCalendarViewHeader

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = self.textFont;
        _titleLabel.textColor = self.textColor;
        _titleLabel.backgroundColor = [UIColor whiteColor];
        [self addSubview:_titleLabel];

        CALayer *border = [CALayer layer];
        border.contentsScale = [UIScreen mainScreen].scale;
        border.backgroundColor = self.separatorColor.CGColor;
        [self.layer addSublayer:border];
        self.bottomBorder = border;
    }
    return self;
}

- (void)bindWeekdaySymbols:(NSArray *)weekdaySymbols firstWeekday:(NSUInteger)firstWeekday {
    if (![self.weekdayLabels count]) {
        NSMutableArray *labels = [NSMutableArray array];
        NSUInteger daysPerWeek = [weekdaySymbols count];

        for (NSUInteger i = 0; i < daysPerWeek; i++) {
            // As documented in NSDateComponents are numbers 1 through n, e.g.
            // Sunday is represented by 1 in Gregorian calendar.
            NSUInteger idx = (i + firstWeekday - 1) % daysPerWeek;

            UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.font = self.textFont;
            label.textColor = self.textColor;
            label.backgroundColor = [UIColor whiteColor];
            label.text = weekdaySymbols[idx];
            label.numberOfLines = 1;
            [label sizeToFit];

            [labels addObject:label];
            [self addSubview:label];
        }

        self.weekdayLabels = labels;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [CATransaction begin];
    [CATransaction setDisableActions:TRUE];

    const UIEdgeInsets contentInset = UIEdgeInsetsMake(0, 10, 0, 10);
    const CGFloat weekdayLabelsTopMargin = 6;

    CGFloat contentHeight = 0;
    contentHeight += CGRectGetHeight(self.titleLabel.bounds);

    if ([self.weekdayLabels count]) {
        contentHeight += weekdayLabelsTopMargin;
        contentHeight += CGRectGetHeight([[self.weekdayLabels firstObject] bounds]);
    }

    CGFloat offsetY = roundf(CGRectGetMidY(self.bounds) - 0.5 * contentHeight);
    CGSize size = self.titleLabel.bounds.size;

    self.titleLabel.center = (CGPoint) {
        .x = contentInset.left + 0.5 * size.width,
        .y = offsetY + 0.5 * size.height
    };

    if ([self.weekdayLabels count]) {
        offsetY = ceilf(CGRectGetMaxY(self.titleLabel.frame) + weekdayLabelsTopMargin);
        CGFloat blockWidth = CGRectGetWidth(self.bounds) / [self.weekdayLabels count];
        CGFloat offsetX = 0;

        for (UIView *label in self.weekdayLabels) {
            size = label.bounds.size;

            label.center = (CGPoint) {
                .x = roundf(offsetX + 0.5 * (blockWidth - size.width)) + 0.5 * size.width,
                .y = offsetY + 0.5 * size.height
            };

            offsetX = offsetX + blockWidth;
        }

        size = self.titleLabel.bounds.size;

        offsetX = roundf(CGRectGetMidX(self.bounds) - 0.5f * size.width);
        offsetY = roundf(CGRectGetMidY(self.bounds) - 0.5f * contentHeight);

        self.titleLabel.center = (CGPoint) {
            .x = offsetX + 0.5f * size.width,
            .y = offsetY + 0.5f * size.height
        };
    }

    if (self.bottomBorder.superlayer && !self.bottomBorder.isHidden) {
        self.bottomBorder.frame = (CGRect) {
            .origin = {.y = CGRectGetMaxY(self.bounds)},
            .size = {.width = self.bounds.size.width, .height = 1.f}
        };
    }

    [CATransaction commit];
}

#pragma mark - Colors

- (UIColor *)textColor
{
    if(_textColor == nil) {
        _textColor = [[[self class] appearance] textColor];
    }

    if(_textColor != nil) {
        return _textColor;
    }

    return [UIColor grayColor];
}

- (UIFont *)textFont
{
    if(_textFont == nil) {
        _textFont = [[[self class] appearance] textFont];
    }

    if(_textFont != nil) {
        return _textFont;
    }

    return [UIFont systemFontOfSize:PDTSimpleCalendarHeaderTextSize];
}

- (UIColor *)separatorColor
{
    if(_separatorColor == nil) {
        _separatorColor = [[[self class] appearance] separatorColor];
    }

    if(_separatorColor != nil) {
        return _separatorColor;
    }

    return [UIColor colorWithWhite:0.925f alpha:1.f];
}


@end
