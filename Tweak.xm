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
    FRPLinkCell *spotifyTint = [FRPLinkCell cellWithTitle:@"Spotify Tint" selectedBlock:^(id sender) { [self showLPCForKey:@"spotifyTint" withFallback:@"#1db954" showAlpha:NO]; }]; [primaryColours addCell:spotifyTint];
    FRPLinkCell *mainTint = [FRPLinkCell cellWithTitle:@"Main Tint" selectedBlock:^(id sender) { [self showLPCForKey:@"mainTint" withFallback:@"#ffffff" showAlpha:NO]; }]; [primaryColours addCell:mainTint];
    FRPLinkCell *secondaryTint = [FRPLinkCell cellWithTitle:@"Secondary Tint" selectedBlock:^(id sender) { [self showLPCForKey:@"secondaryTint" withFallback:@"#b3b3b3" showAlpha:NO]; }]; [primaryColours addCell:secondaryTint];

    FRPSection *geniusColours = [FRPSection sectionWithTitle:@"Genius Colours" footer:nil];
    FRPLinkCell *geniusCardHighlight = [FRPLinkCell cellWithTitle:@"Highlight Colour" selectedBlock:^(id sender) { [self showLPCForKey:@"geniusCardHighlight" withFallback:@"#ffff64" showAlpha:NO]; }]; [geniusColours addCell:geniusCardHighlight];

    FRPreferences *table = [FRPreferences tableWithSections:@[primaryColours, geniusColours] title:@"ColorifyXI" tintColor:nil];
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
+ (id)hexWithKey:(id)key withFallback:(id)fallback;
+ (id)hex9WithKey:(id)key withFallback:(id)fallback;
+ (id)hex9WithColor:(UIColor *)color;
+ (UIColor *)lighterColorForColor:(UIColor *)c;
+ (UIColor *)darkerColorForColor:(UIColor *)c;
@end


%hook SPTTheme
+ (id)binaryThemeWithPlist:(id)arg1 {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Theme" ofType:@"plist"];
    NSMutableDictionary *plist = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];

    plist[@"colors"][@"glueGray7Color"][@""] = [self hex9WithKey:@"primaryBackground" withFallback:@"#121212"];
    plist[@"colors"][@"glueGray15Color"][@""] = [self hex9WithKey:@"tabBarTint" withFallback:@"#282828"];
    plist[@"colors"][@"glueGreenColor"][@""] = [self hex9WithKey:@"spotifyTint" withFallback:@"#1db954"];
    plist[@"colors"][@"glueGreenDarkColor"][@""] = [self hex9WithColor:[self darkerColorForColor:LCPParseColorString([[NSUserDefaults standardUserDefaults] objectForKey:@"spotifyTint"], @"#1db954")]];
    plist[@"colors"][@"glueGreenLightColor"][@""] = [self hex9WithColor:[self lighterColorForColor:LCPParseColorString([[NSUserDefaults standardUserDefaults] objectForKey:@"spotifyTint"], @"#1db954")]];
    plist[@"colors"][@"glueWhiteColor"][@""] = [self hex9WithKey:@"mainTint" withFallback:@"#ffffff"];
    plist[@"colors"][@"glueGray70Color"][@""] = [self hex9WithKey:@"secondaryTint" withFallback:@"#b3b3b3"];
    
    plist[@"colors"][@"geniusCardContentsHighlightColor"][@""] = [self hex9WithKey:@"geniusCardHighlight" withFallback:@"#ffff64"];
    plist[@"colors"][@"geniusNowPlayingViewContentsHighlightColor"][@""] = [self hex9WithKey:@"geniusCardHighlight" withFallback:@"#ffff64"];
    plist[@"colors"][@"geniusNowPlayingViewVerifiedArtistNameColor"][@""] = [self hex9WithKey:@"geniusCardHighlight" withFallback:@"#ffff64"];

    arg1 = plist;
    return %orig;
}

%new
+ (id)hexWithKey:(id)key withFallback:(id)fallback {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:key]) {
        [[NSUserDefaults standardUserDefaults] setObject:fallback forKey:key];
    }
    UIColor *pickedColor = LCPParseColorString([[NSUserDefaults standardUserDefaults] objectForKey:key], fallback);
    NSString *hexString = [UIColor hexFromColor:pickedColor];
    return hexString;
}
%new
+ (id)hex9WithKey:(id)key withFallback:(id)fallback {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:key]) {
        [[NSUserDefaults standardUserDefaults] setObject:fallback forKey:key];
    }
    UIColor *pickedColor = LCPParseColorString([[NSUserDefaults standardUserDefaults] objectForKey:key], fallback);
    NSString *hexString = [UIColor hexFromColor:pickedColor];
    hexString = [hexString stringByAppendingString:[NSString stringWithFormat:@"%lX", (unsigned long)pickedColor.alpha * 255]];
    return hexString;
}
%new
+ (id)hex9WithColor:(UIColor *)color {
    NSString *hexString = [UIColor hexFromColor:color];
    hexString = [hexString stringByAppendingString:[NSString stringWithFormat:@"%lX", (unsigned long)color.alpha * 255]];
    return hexString;
}
%new
+ (UIColor *)lighterColorForColor:(UIColor *)c {
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a]) {
        return [UIColor colorWithRed:MIN(r + 0.2, 1.0) green:MIN(g + 0.2, 1.0) blue:MIN(b + 0.2, 1.0) alpha:a];
    }
    return nil;
}
%new
+ (UIColor *)darkerColorForColor:(UIColor *)c {
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a]) {
        return [UIColor colorWithRed:MAX(r - 0.2, 0.0) green:MAX(g - 0.2, 0.0) blue:MAX(b - 0.2, 0.0) alpha:a];
    }
    return nil;
}
%end





/*        Screen Height        */

static CGFloat tabFrameHeight; // Set by [UITabBar didMoveToWindow]

@interface EXP_HUBCollectionView : UIView
@property (nonatomic, assign, readwrite) CGPoint contentOffset;
@end
@interface EXP_HUBContainerView : UIView
@end
@interface SPTAsyncLoadingView : UIView
@end
@interface SPTTableView : UIView
@end
@interface PlaylistViewController : UIViewController
@end
@interface SPTCeramicVerticalCollectionView : UIView
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
@interface SettingsViewController: UIViewController
@end
@interface SPTAccountSettingsViewController: UIViewController
@end
@interface SPTNotificationPreferencesViewController : UIViewController
@end
@interface SPTCampaignViewController : UIViewController
@end
@interface SPTAccountUpsellViewController : UIViewController
@end
@interface SPTFreeTierCollectionYourLibraryViewController : UIViewController
@end
@interface SPTFreeTierFindContainerViewController : UIViewController
@end
@interface SPTAlbumViewController : UIViewController
@end
@interface SPTProfileSocialRelationsViewController : UIViewController
@end 
@interface SPTArtistAboutViewController : UIViewController
@end
@interface SPTConcertsEntityViewController : UIViewController
@end
@interface SPTConcertsLocationSearchViewController : UIViewController
- (id)tableView;
@end
@interface SPTFindFriendsVC : UIViewController
@end

%hook EXP_HUBCollectionView
- (void)setContentOffset:(CGPoint)arg1 {
    if (arg1.y - self.contentOffset.y  == 42) {
        arg1 = self.contentOffset;
    }
    %orig;
}
- (void)setContentInset:(UIEdgeInsets)arg1 {
    arg1.bottom = tabFrameHeight + tabNPEffectView.frame.size.height;
    %orig;
}
%end

%hook EXP_HUBContainerView
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
- (void)setContentInset:(UIEdgeInsets)arg1 {
    if ([[self spt_viewController] isKindOfClass:[%c(PlaylistViewController) class]]) {
        arg1.bottom += tabFrameHeight;
    } else {
        arg1.bottom = tabFrameHeight + tabNPEffectView.frame.size.height;
    }
    %orig;
}
%end

%hook SPTCeramicVerticalCollectionView
- (void)setContentInset:(UIEdgeInsets)arg1 {
    arg1.bottom = tabFrameHeight + tabNPEffectView.frame.size.height;
    %orig;
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

%hook SettingsViewController
- (void)viewDidLayoutSubviews {
    %orig;
    [self.view spt_setFrameHeight:[UIScreen mainScreen].bounds.size.height];
}
%end

%hook SPTAccountSettingsViewController
- (void)viewDidLayoutSubviews {
    %orig;
    [self.view spt_setFrameHeight:[UIScreen mainScreen].bounds.size.height];
}
%end

%hook SPTNotificationPreferencesViewController
- (void)viewDidLayoutSubviews {
    %orig;
    [self.view spt_setFrameHeight:[UIScreen mainScreen].bounds.size.height];
}
%end

%hook SPTCampaignViewController
- (void)viewDidLayoutSubviews {
    %orig;
    [self.view spt_setFrameHeight:[UIScreen mainScreen].bounds.size.height];
}
%end

%hook SPTAccountUpsellViewController
- (void)viewDidLayoutSubviews {
    %orig;
    [self.view spt_setFrameHeight:[UIScreen mainScreen].bounds.size.height];
}
%end

%hook SPTFreeTierCollectionYourLibraryViewController
- (void)viewDidLayoutSubviews {
    %orig;
    [self.view spt_setFrameHeight:[UIScreen mainScreen].bounds.size.height];
}
%end

%hook SPTFreeTierFindContainerViewController
- (void)viewDidLayoutSubviews {
    %orig;
    [self.view spt_setFrameHeight:[UIScreen mainScreen].bounds.size.height];
}
%end

%hook SPTAlbumViewController
- (void)viewDidLayoutSubviews {
    %orig;
    [self.view spt_setFrameHeight:[UIScreen mainScreen].bounds.size.height];
}
%end

%hook SPTProfileSocialRelationsViewController
- (void)viewDidLayoutSubviews {
    %orig;
    [self.view spt_setFrameHeight:[UIScreen mainScreen].bounds.size.height];
}
%end

%hook SPTArtistAboutViewController
- (void)viewDidLayoutSubviews {
    %orig;
    [self.view spt_setFrameHeight:[UIScreen mainScreen].bounds.size.height];
}
%end

%hook SPTConcertsEntityViewController
- (void)viewDidLayoutSubviews {
    %orig;
    [self.view spt_setFrameHeight:[UIScreen mainScreen].bounds.size.height];
}
%end

%hook SPTConcertsLocationSearchViewController
- (void)viewDidLayoutSubviews {
    %orig;
    [self.view spt_setFrameHeight:[UIScreen mainScreen].bounds.size.height];
    [[self tableView] spt_setFrameHeight:[UIScreen mainScreen].bounds.size.height];
}
%end

%hook SPTFindFriendsVC
- (void)viewDidLayoutSubviews {
    %orig;
    [self.view spt_setFrameHeight:[UIScreen mainScreen].bounds.size.height];
}
%end





/*        Launchscreen Background        */

@interface SPTLaunchViewController : UIViewController
@end

%hook SPTLaunchViewController
- (void)viewDidLoad {
    %orig;
    self.view.backgroundColor = LCPParseColorString([[NSUserDefaults standardUserDefaults] objectForKey:@"primaryBackground"], @"#191414");
    ((UIImageView *)self.view.subviews[0]).image = [((UIImageView *)self.view.subviews[0]).image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [((UIImageView *)self.view.subviews[0]) setTintColor:LCPParseColorString([[NSUserDefaults standardUserDefaults] objectForKey:@"spotifyTint"], @"#1db954")];
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
    }
}
%end


@interface SPTStatusBarBackgroundAutoResizeView : UIView
@end

%hook SPTStatusBarBackgroundAutoResizeView
- (void)didMoveToWindow {
    %orig;
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"navigationBarBackground"] isEqual:@"1c1c1c"] || ![[[NSUserDefaults standardUserDefaults] objectForKey:@"navigationBarBackground"] isEqual:@"1C1C1C"]) {
        self.backgroundColor = LCPParseColorString([[NSUserDefaults standardUserDefaults] objectForKey:@"navigationBarBackground"], @"#000000");

        UIView *effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        effectView.subviews[1].backgroundColor = [UIColor clearColor];
        effectView.frame = self.frame;
        [self addSubview:effectView];

        effectView.translatesAutoresizingMaskIntoConstraints = false;

        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:effectView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:effectView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];

        [self addConstraint:widthConstraint];
        [self addConstraint:heightConstraint];
    }
}
- (void)setBackgroundColor:(id)arg1 {
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"navigationBarBackground"] isEqual:@"1c1c1c"] || ![[[NSUserDefaults standardUserDefaults] objectForKey:@"navigationBarBackground"] isEqual:@"1C1C1C"]) {
        arg1 = LCPParseColorString([[NSUserDefaults standardUserDefaults] objectForKey:@"navigationBarBackground"], @"#000000");
    }
}
%end


@interface SPTEntityHeaderBackgroundImageView : UIView
@property (retain, nonatomic) UIImageView *blurImageView;
@end

%hook SPTEntityHeaderBackgroundImageView
- (void)didMoveToWindow {
    %orig;
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"navigationBarBackground"] isEqual:@"1c1c1c"] || ![[[NSUserDefaults standardUserDefaults] objectForKey:@"navigationBarBackground"] isEqual:@"1C1C1C"]) {
        self.blurImageView.subviews[2].backgroundColor = LCPParseColorString([[NSUserDefaults standardUserDefaults] objectForKey:@"navigationBarBackground"], @"#000000");
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
    tabFrameHeight = self.frame.size.height;
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





/*        Search Bar Button Background        */

@interface SPTFreeTierFindHeaderView : UIView
@end

%hook UIButton
- (void)layoutSubviews {
    %orig;
    if ([self.superview isKindOfClass:[%c(SPTFreeTierFindHeaderView) class]]) {
        self.backgroundColor = [UIColor whiteColor];
    }
}
%end





/*        Category Label Text Colour Fix        */

@interface GLUELabel : UILabel
@end
@interface SPTBrowseUICategoryCardComponentView : UIView
@end

%hook GLUELabel
- (void)layoutSubviews {
    %orig;
    if ([self.superview isKindOfClass:[%c(SPTBrowseUICategoryCardComponentView) class]]) {
        self.textColor = [UIColor whiteColor];
    }
}
%end