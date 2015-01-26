//
//  PDTSimpleCalendarViewHeader.m
//  PDTSimpleCalendar
//
//  Created by Jerome Miglino on 10/8/13.
//  Copyright (c) 2013 Producteev. All rights reserved.
//

#import "PDTSimpleCalendarViewHeader.h"

const CGFloat PDTSimpleCalendarHeaderTextSize = 12.0f;

@interface PDTSimpleCalendarViewHeader ()

@property (nonatomic) NSArray *weekdayLabels;

@end

@implementation PDTSimpleCalendarViewHeader

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setFont:self.textFont];
        [_titleLabel setTextColor:self.textColor];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];

        [self addSubview:_titleLabel];
        [_titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];

        UIView *separatorView = [[UIView alloc] init];
        [separatorView setBackgroundColor:self.separatorColor];
        [self addSubview:separatorView];
        [separatorView setTranslatesAutoresizingMaskIntoConstraints:NO];

        CGFloat onePixel = 1.0f / [UIScreen mainScreen].scale;
        NSDictionary *metricsDictionary = @{@"onePixel" : [NSNumber numberWithFloat:onePixel]};
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(separatorView);

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[separatorView]|" options:0 metrics:nil views:viewsDictionary]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[separatorView(==onePixel)]|" options:0 metrics:metricsDictionary views:viewsDictionary]];
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
            label.backgroundColor = [UIColor clearColor];
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
    const CGFloat weekdayLabelsTopMargin = 4;

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

        CGFloat offsetX = contentInset.left;

        for (UIView *label in self.weekdayLabels) {
            size = label.bounds.size;

            label.center = (CGPoint) {
                .x = offsetX + 0.5 * roundf(blockWidth),
                .y = offsetY + 0.5 * size.height
            };

            offsetX = roundf(offsetX + blockWidth);
        }
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

    return [UIColor lightGrayColor];
}


@end
