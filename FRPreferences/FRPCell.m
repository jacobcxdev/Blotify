//
//  FRPCell.m
//  FRPreferences
//
//  Created by Fouad Raheb on 7/2/15.
//  Copyright (c) 2015 F0u4d. All rights reserved.
//

#import "FRPCell.h"
#import <libcolorpicker.h>

@implementation FRPCell

- (UIColor *)readableForegroundColorForBackgroundColor:(UIColor *)backgroundColor {
    size_t count = CGColorGetNumberOfComponents(backgroundColor.CGColor);
    const CGFloat *componentColors = CGColorGetComponents(backgroundColor.CGColor);

    CGFloat darknessScore = 0;
    if (count == 2) {
        darknessScore = (((componentColors[0]*255) * 299) + ((componentColors[0]*255) * 587) + ((componentColors[0]*255) * 114)) / 1000;
    } else if (count == 4) {
        darknessScore = (((componentColors[0]*255) * 299) + ((componentColors[1]*255) * 587) + ((componentColors[2]*255) * 114)) / 1000;
    }

    if (darknessScore >= 125) {
        return [UIColor blackColor];
    }

    return [UIColor whiteColor];
}

+ (instancetype)cellWithTitle:(NSString *)title setting:(FRPSettings *)setting {
    return [[self alloc] initWithTitle:title setting:setting];
}

- (instancetype)initWithTitle:(NSString *)title setting:(FRPSettings *)setting {
    if (self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil]) {
        self.clipsToBounds = YES;
        self.textLabel.text = title;
        self.textLabel.font = [UIFont fontWithName:@"CircularSpUI-Book" size:13];
        self.textLabel.textColor = LCPParseColorString([[NSUserDefaults standardUserDefaults] objectForKey:@"mainTint"], @"#ffffff");
        self.backgroundColor = [UIColor clearColor];
        self.setting = setting;

        UIView *bgColorView = [[UIView alloc] init];

        if ([[self readableForegroundColorForBackgroundColor:(UIColor *)LCPParseColorString([[NSUserDefaults standardUserDefaults] objectForKey:@"primaryBackground"], @"#121212")] isEqual:[UIColor blackColor]]) {
            bgColorView.backgroundColor = [UIColor colorWithRed:0.000 green:0.000 blue:0.000 alpha:0.100];
        } else {
            bgColorView.backgroundColor = [UIColor colorWithRed:1.000 green:1.000 blue:1.000 alpha:0.100];
        }

        [self setSelectedBackgroundView:bgColorView];
    }
    return self;
}

- (void)didSelectFromTable:(FRPreferences *)viewController {
//    NSIndexPath *indexPath = [viewController.tableView indexPathForCell:self];
//    NSLog(@"Did Select Cell At Index: %@",indexPath);
}

@end
