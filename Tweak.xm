#import <UIKit/UIKit.h>
#import "FRPreferences/FRPrefs.h"
#import <libcolorpicker.h>
#import "UIView-Position.h"
#import "UIView-Utility.h"





/*          Preferences Button          */

@interface RootSettingsViewController : UIViewController
- (void)showLPCForKey:(id)key withFallback:(id)fallback showAlpha:(bool)alpha;
@end

%hook RootSettingsViewController

-(void)viewDidLoad {
    %orig;
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"ColorifyXI" style:UIBarButtonItemStylePlain target:self action:@selector(loadNewSettings:)];
    [self.navigationItem setRightBarButtonItem:addButton];
}



/*          Preferences         */

%new
- (void)loadNewSettings:(id)sender {
    FRPSection *primaryColours = [FRPSection sectionWithTitle:@"Primary Colours" footer:nil];

    FRPLinkCell *navigationBarBackground = [FRPLinkCell cellWithTitle:@"Navigation Bar Background" selectedBlock:^(id sender) { [self showLPCForKey:@"navigationBarBackground" withFallback:@"1c1c1c" showAlpha:YES]; }]; [primaryColours addCell:navigationBarBackground];
    FRPLinkCell *primaryBackground = [FRPLinkCell cellWithTitle:@"Background" selectedBlock:^(id sender) { [self showLPCForKey:@"primaryBackground" withFallback:@"#121212" showAlpha:NO]; }]; [primaryColours addCell:primaryBackground];
    FRPLinkCell *tabBarTint = [FRPLinkCell cellWithTitle:@"Tab Bar Tint" selectedBlock:^(id sender) { [self showLPCForKey:@"tabBarTint" withFallback:@"#282828" showAlpha:YES]; }]; [primaryColours addCell:tabBarTint];

    FRPreferences *table = [FRPreferences tableWithSections:@[primaryColours] title:@"ColorifyXI" tintColor:nil];
    [self.navigationController pushViewController:table animated:YES];
}
%new
- (void)showLPCForKey:(id)key withFallback:(id)fallback showAlpha:(bool)alpha {
    UIColor *startColor = LCPParseColorString([[NSUserDefaults standardUserDefaults] objectForKey:key], fallback);
        PFColorAlert *alert = [PFColorAlert colorAlertWithStartColor:startColor showAlpha:alpha];

        [alert displayWithCompletion: ^void (UIColor *pickedColor) {
	        NSString *hexString = [UIColor hexFromColor:pickedColor];
            hexString = [hexString stringByAppendingFormat:@":%f", pickedColor.alpha];

            [[NSUserDefaults standardUserDefaults] setObject:hexString forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
	    }];
}
%end

%hook UITableViewHeaderFooterView
- (void)didMoveToWindow {
    %orig;
    if ([[self spt_viewController] isKindOfClass:[%c(FRPreferences) class]]) {
        self.textLabel.font = [UIFont fontWithName:@"CircularSpUI-Book" size:12];
    }
}
%end






/*        Set Colours        */

static UIView *tabNPEffectView;

@interface SPTTheme
+ (id)binaryThemeWithPlist:(id)arg1;
+ (id)hex9WithPlistKey:(id)plistKey forKey:(id)key withFallback:(id)fallback;
@end


%hook SPTTheme
+ (id)binaryThemeWithPlist:(id)arg1 {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Theme" ofType:@"plist"];
    NSMutableDictionary *plist = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];

    plist[@"colors"][@"glueGray7Color"][@""] = [self hex9WithPlistKey:plist[@"colors"][@"glueGray7Color"][@""] forKey:@"primaryBackground" withFallback:@"#121212"];
    plist[@"colors"][@"glueGray15Color"][@""] = [self hex9WithPlistKey:plist[@"colors"][@"glueGray15Color"][@""] forKey:@"tabBarTint" withFallback:@"#282828"];

    arg1 = plist;
    return %orig;
}

%new
+ (id)hex9WithPlistKey:(id)plistKey forKey:(id)key withFallback:(id)fallback {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:key]) {
        [[NSUserDefaults standardUserDefaults] setObject:fallback forKey:key];
    }
    UIColor *pickedColor = LCPParseColorString([[NSUserDefaults standardUserDefaults] objectForKey:key], fallback);
    NSString *hexString = [UIColor hexFromColor:pickedColor];
    plistKey = [hexString stringByAppendingString:[NSString stringWithFormat:@"%lX", (unsigned long)pickedColor.alpha * 255]];
    return plistKey;
}
%end





/*        Screen Height        */

@interface EXP_HUBCollectionView : UIView
@property (nonatomic, assign, readwrite) CGPoint contentOffset;
@end
@interface SPTAsyncLoadingView : UIView
@end
@interface SPTTableView : UITableView
@end
@interface SPTCollectionOverviewViewController : UIViewController
@end
@interface SPTLegacyHubViewController : UIViewController
@end
@interface SPTStationViewController : UIViewController
@end
@interface SPTPlaylistFolderViewController : UIViewController
@end
@interface SPTStationsListViewController : UIViewController
@end
@interface SPTCollectionSongsViewController : UIViewController
@end
@interface SPTCollectionAlbumsViewController : UIViewController
@end
@interface SPTCollectionAlbumViewController : UIViewController
@end
@interface SPTCollectionArtistsViewController : UIViewController
@end
@interface SPTCollectionArtistViewController : UIViewController
@end
@interface SPTCollectionPodcastOverviewViewController : UIViewController
@end
@interface SPTPodcastViewController : UIViewController
@end
@interface SPTCollectionVideoOverviewViewController : UIViewController
@end
@interface SPTProfileViewController : UIViewController
@end
@interface SPTProfileViewAllViewController : UIViewController
@end

%hook EXP_HUBCollectionView
- (void)setContentOffset:(CGPoint)arg1 {
    if (arg1.y - self.contentOffset.y  == 42) {
        arg1 = self.contentOffset;
    }
    %orig;
}
- (void)layoutSubviews {
    %orig;
    [self spt_setFrameHeight:[UIScreen mainScreen].bounds.size.height];
}
%end

%hook SPTAsyncLoadingView
- (void)layoutSubviews {
    %orig;
    [self spt_setFrameHeight:[UIScreen mainScreen].bounds.size.height];
}
%end

%hook SPTTableView
- (void)layoutSubviews {
    %orig;
    if ([[self spt_viewController] isKindOfClass:[%c(SPTPodcastViewController) class]]) {
        [self spt_setFrameHeight:[UIScreen mainScreen].bounds.size.height];
    }
}
%end

%hook SPTCollectionOverviewViewController
- (void)viewDidLayoutSubviews {
    %orig;
    [self.view spt_setFrameHeight:[UIScreen mainScreen].bounds.size.height];
}
%end

%hook SPTLegacyHubViewController
- (void)viewDidLayoutSubviews {
    %orig;
    [self.view spt_setFrameHeight:[UIScreen mainScreen].bounds.size.height];
}
%end

%hook RootSettingsViewController
- (void)viewDidLayoutSubviews {
    %orig;
    [self.view spt_setFrameHeight:[UIScreen mainScreen].bounds.size.height];
}
%end

%hook FRPreferences
- (void)viewDidLayoutSubviews {
    %orig;
    [self.view spt_setFrameHeight:[UIScreen mainScreen].bounds.size.height];
}
%end

%hook SPTStationViewController
- (void)viewDidLayoutSubviews {
    %orig;
    [self.view spt_setFrameHeight:[UIScreen mainScreen].bounds.size.height];
}
%end

%hook SPTPlaylistFolderViewController
- (void)viewDidLayoutSubviews {
    %orig;
    [self.view spt_setFrameHeight:[UIScreen mainScreen].bounds.size.height];
}
%end

%hook SPTStationsListViewController
- (void)viewDidLayoutSubviews {
    %orig;
    [self.view spt_setFrameHeight:[UIScreen mainScreen].bounds.size.height];
}
%end

%hook SPTCollectionSongsViewController
- (void)viewDidLayoutSubviews {
    %orig;
    [self.view spt_setFrameHeight:[UIScreen mainScreen].bounds.size.height];
}
%end

%hook SPTCollectionAlbumsViewController
- (void)viewDidLayoutSubviews {
    %orig;
    [self.view spt_setFrameHeight:[UIScreen mainScreen].bounds.size.height];
}
%end

%hook SPTCollectionAlbumViewController
- (void)viewDidLayoutSubviews {
    %orig;
    [self.view spt_setFrameHeight:[UIScreen mainScreen].bounds.size.height];
}
%end

%hook SPTCollectionArtistsViewController
- (void)viewDidLayoutSubviews {
    %orig;
    [self.view spt_setFrameHeight:[UIScreen mainScreen].bounds.size.height];
}
%end

%hook SPTCollectionArtistViewController
- (void)viewDidLayoutSubviews {
    %orig;
    [self.view spt_setFrameHeight:[UIScreen mainScreen].bounds.size.height];
}
%end

%hook SPTCollectionPodcastOverviewViewController
- (void)viewDidLayoutSubviews {
    %orig;
    [self.view spt_setFrameHeight:[UIScreen mainScreen].bounds.size.height];
}
%end

%hook SPTPodcastViewController
- (void)viewDidLayoutSubviews {
    %orig;
    [self.view spt_setFrameHeight:[UIScreen mainScreen].bounds.size.height];
}
%end

%hook SPTCollectionVideoOverviewViewController
- (void)viewDidLayoutSubviews {
    %orig;
    [self.view spt_setFrameHeight:[UIScreen mainScreen].bounds.size.height];
}
%end

%hook SPTProfileViewController
- (void)viewDidLayoutSubviews {
    %orig;
    [self.view spt_setFrameHeight:[UIScreen mainScreen].bounds.size.height];
}
%end

%hook SPTProfileViewAllViewController
- (void)viewDidLayoutSubviews {
    %orig;
    [self.view spt_setFrameHeight:[UIScreen mainScreen].bounds.size.height];
}
%end




/*        Navigation Bar        */

@interface SPNavigationController : UIViewController
@property (retain, nonatomic) UIView *backgroundContainerView;
@property (retain, nonatomic) UIView *navigationBarBackgroundView;
@end

%hook SPNavigationController
- (void)viewDidLoad {
    %orig;
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"navigationBarBackground"] isEqual:@"1c1c1c"] || ![[[NSUserDefaults standardUserDefaults] objectForKey:@"navigationBarBackground"] isEqual:@"1C1C1C"]) {
        UIView *colouredView = [[UIView alloc] initWithFrame:self.navigationBarBackgroundView.frame];
        colouredView.backgroundColor = LCPParseColorString([[NSUserDefaults standardUserDefaults] objectForKey:@"navigationBarBackground"], @"#1c1c1c");
        [self.backgroundContainerView insertSubview:colouredView atIndex:0];

        colouredView.translatesAutoresizingMaskIntoConstraints = false;

        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:colouredView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.backgroundContainerView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:colouredView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.backgroundContainerView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];

        [self.backgroundContainerView addConstraint:widthConstraint];
        [self.backgroundContainerView addConstraint:heightConstraint];
        self.navigationBarBackgroundView.subviews[1].backgroundColor = [UIColor clearColor];
    } else {
        self.navigationBarBackgroundView.subviews[1].backgroundColor = [UIColor colorWithRed:0.000 green:0.000 blue:0.000 alpha:0.702];
    }
}
%end


@interface SPTHomeHubsRendererViewController : UIViewController
@property (retain, nonatomic) UIView *statusBarBackgroundView;
@end

%hook SPTHomeHubsRendererViewController
- (void)viewDidLoad {
    %orig;
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"navigationBarBackground"] isEqual:@"1c1c1c"] || ![[[NSUserDefaults standardUserDefaults] objectForKey:@"navigationBarBackground"] isEqual:@"1C1C1C"]) {
        self.statusBarBackgroundView.backgroundColor = LCPParseColorString([[NSUserDefaults standardUserDefaults] objectForKey:@"navigationBarBackground"], @"#000000");

        UIView *effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        effectView.subviews[1].backgroundColor = [UIColor clearColor];
        effectView.frame = self.statusBarBackgroundView.frame;
        [self.statusBarBackgroundView addSubview:effectView];

        effectView.translatesAutoresizingMaskIntoConstraints = false;

        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:effectView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.statusBarBackgroundView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:effectView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.statusBarBackgroundView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];

        [self.statusBarBackgroundView addConstraint:widthConstraint];
        [self.statusBarBackgroundView addConstraint:heightConstraint];
    } else {
        self.statusBarBackgroundView.subviews[1].backgroundColor = [UIColor colorWithRed:0.000 green:0.000 blue:0.000 alpha:0.702];
    }
}
%end





/*        Tab Bar        */

@interface SPTNowPlayingBarContainerViewController : UIViewController
@property (retain, nonatomic) UIView *backgroundView;
@end

%hook SPTNowPlayingBarContainerViewController
- (void)viewDidLoad {
    %orig;
    tabNPEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    tabNPEffectView.subviews[1].backgroundColor = [UIColor clearColor];
    [self.backgroundView addSubview:tabNPEffectView];
    self.backgroundView.backgroundColor = LCPParseColorString([[NSUserDefaults standardUserDefaults] objectForKey:@"tabBarTint"], @"#282828");
}
%end

@interface SPTNowPlayingBarContentView
@end

%hook SPTNowPlayingBarContentView
- (void)setFrame:(CGRect)arg1 {
    %orig;
    tabNPEffectView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, arg1.size.height);
}
%end

%hook UITabBar
- (void)didMoveToWindow {
    bool alreadyEnabled = false;
    for (int i = 0; i < self.subviews.count; i++) {
        if ([self.subviews[i] isKindOfClass:[UIVisualEffectView class]]) {
            alreadyEnabled = true;
        }
    }
    if (!alreadyEnabled) {
        UIView *effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        effectView.subviews[1].backgroundColor = [UIColor clearColor];
        [self addSubview:effectView];
        effectView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    }
    %orig;
}
%end

@interface _UIBarBackground : UIView
@end

%hook _UIBarBackground
- (void)setBackgroundColor:(id)arg1 {
    if ([self.superview isKindOfClass:[UITabBar class]]) {
        arg1 = LCPParseColorString([[NSUserDefaults standardUserDefaults] objectForKey:@"tabBarTint"], @"#282828");
    }
    %orig;
}
%end





/*        Selected Colours        */

@interface UIView ()
+ (UIColor *)readableForegroundColorForBackgroundColor:(UIColor *)backgroundColor;
@end

%hook UIView
%new
+ (UIColor *)readableForegroundColorForBackgroundColor:(UIColor *)backgroundColor {
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
%end


@interface GLUENavigationRowView : UIView
@end

%hook GLUENavigationRowView
- (void)setAlpha:(CGFloat)arg1 {
    if (arg1 != (CGFloat) 1) {
        if ([[UIView readableForegroundColorForBackgroundColor:(UIColor *)LCPParseColorString([[NSUserDefaults standardUserDefaults] objectForKey:@"primaryBackground"], @"#121212")] isEqual:[UIColor blackColor]]) {
            self.backgroundColor = [UIColor colorWithRed:0.000 green:0.000 blue:0.000 alpha:0.100];
        } else {
            self.backgroundColor = [UIColor colorWithRed:1.000 green:1.000 blue:1.000 alpha:0.100];
        }
    }
    %orig;
}
%end


@interface GLUEEntityRowView : UIView
@end

%hook GLUEEntityRowView
- (void)setBackgroundColor:(id)arg1 {
    if ([arg1 isEqual:[UIColor colorWithRed:0.000 green:0.000 blue:0.000 alpha:1.000]]) {
        if ([[UIView readableForegroundColorForBackgroundColor:(UIColor *)LCPParseColorString([[NSUserDefaults standardUserDefaults] objectForKey:@"primaryBackground"], @"#121212")] isEqual:[UIColor blackColor]]) {
              arg1 = [UIColor colorWithRed:0.000 green:0.000 blue:0.000 alpha:0.100];
           } else {
               arg1 = [UIColor colorWithRed:1.000 green:1.000 blue:1.000 alpha:0.100];
           }
    }
    %orig;
}
%end


@interface SPTTableBasedCollectionViewCell : UIView
@end

%hook SPTTableBasedCollectionViewCell
- (void)setBackgroundColor:(id)arg1 {
    if ([arg1 isEqual:[UIColor colorWithRed:0.000 green:0.000 blue:0.000 alpha:1.000]]) {
        if ([[UIView readableForegroundColorForBackgroundColor:(UIColor *)LCPParseColorString([[NSUserDefaults standardUserDefaults] objectForKey:@"primaryBackground"], @"#121212")] isEqual:[UIColor blackColor]]) {
            arg1 = [UIColor colorWithRed:0.000 green:0.000 blue:0.000 alpha:0.100];
        } else {
            arg1 = [UIColor colorWithRed:1.000 green:1.000 blue:1.000 alpha:0.100];
        }
    }
    %orig;
}
%end


@interface SPTSettingsTableViewCell : UIView
@end

%hook SPTSettingsTableViewCell
- (void)insertSubview:arg1 atIndex:arg2 {
    if ([arg1 isKindOfClass:[UIView class]]) {
        if ([[UIView readableForegroundColorForBackgroundColor:(UIColor *)LCPParseColorString([[NSUserDefaults standardUserDefaults] objectForKey:@"primaryBackground"], @"#121212")] isEqual:[UIColor blackColor]]) {
            ((UIView *)arg1).backgroundColor = [UIColor colorWithRed:0.000 green:0.000 blue:0.000 alpha:0.100];
        } else {
            ((UIView *)arg1).backgroundColor = [UIColor colorWithRed:1.000 green:1.000 blue:1.000 alpha:0.100];
        }
    }
    %orig;
}
%end





/*        Now Playing Transition Animation        */

@interface UITransitionView : UIView
@end
@interface SPTMainWindow : UIView
@end
@interface _UIReplicantView : UIView
@end
@interface SPTNowPlayingToggleViewController : UIViewController
@end

%hook UITransitionView
- (void)addSubview:arg1 {
    if ([self.superview isKindOfClass:[%c(SPTMainWindow) class]]) {
        if (((UIView *)arg1).subviews.count == 0) {
            return;
        } else if ([[arg1 spt_viewController] isKindOfClass:[%c(SPTNowPlayingToggleViewController) class]]) {
            ((UIView *)arg1).alpha = 1;
        }
    }
    %orig;
}
%end


static CGFloat npViewY;

%hook UIView
- (void)setFrame:(CGRect)arg1 {
    %orig;
    if ([[self spt_viewController] isKindOfClass:[%c(SPTNowPlayingToggleViewController) class]]) {
        if (!npViewY) {
                npViewY = self.frame.origin.y;
        } else if (self.frame.origin.y != 0) {
            self.alpha = 4 * (1 - self.frame.origin.y / npViewY);
        }
    }
}
%end





/*        SPTActionButton Background        */

@interface SPTActionButton : UIView
@end

%hook SPTActionButton
- (void)setBackgroundColor:(UIColor *)arg1 {
    arg1 = LCPParseColorString([[NSUserDefaults standardUserDefaults] objectForKey:@"tabBarTint"], @"#282828");
    %orig;
}
%end


/*

Todo:

- Add extra space to bottom of scroll views

*/