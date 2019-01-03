@import CoreMotion;
#import "BAFluidView/BAFluidView.h"
#include <math.h>
#include <CSColorPicker/CSColorPicker.h>

//preference values:
#define domainString @"com.muirey03.waves"
#define waveColor [UIColor colorFromHexString:PreferencesString(@"waveColor", @"9A6BB9F0")]
#define waveHeight PreferencesFloat(@"waveHeight", 0.5)
#define waveAmplitude PreferencesFloat(@"waveAmplitude", 45)

@interface UIView (Waves)
-(UIViewController*)_viewControllerForAncestor;
@end

@interface NSUserDefaults (Waves)
-(id)objectForKey:(id)arg1 inDomain:(id)arg2;
@end

@interface SBHomeScreenView : UIView
@end

static CGFloat PreferencesFloat(NSString* key, CGFloat fallback)
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key inDomain:domainString] ? [[[NSUserDefaults standardUserDefaults] objectForKey:key inDomain:domainString] floatValue] : fallback;
}

static NSString* PreferencesString(NSString* key, NSString* fallback)
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key inDomain:domainString] ? [[NSUserDefaults standardUserDefaults] objectForKey:key inDomain:domainString] : fallback;
}

//make it static to avoid autorelease
static CMMotionManager* motionManager;
static BAFluidView* fluidView;

//update fluid view to match prefs values
static void updateFluidView()
{
    fluidView.fillColor = waveColor;
    [fluidView fillTo:@(waveHeight)];
    fluidView.maxAmplitude = waveAmplitude;
}

static void StartNotifications()
{
    //broadcast the necessary motion notifications:
    if (motionManager.deviceMotionAvailable)
    {
        [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue new] withHandler:^(CMDeviceMotion* data, NSError* error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kBAFluidViewCMMotionUpdate object:nil userInfo:@{@"data" : data}];
        }];
    }
}

static void StopNotifications()
{
    [motionManager stopDeviceMotionUpdates];
}

%hook SBHomeScreenWindow
//start updates when view appears
-(void)becomeKeyWindow
{
    %orig;
    if (fluidView)
    {
        [fluidView startAnimation];
        StartNotifications();
    }
}

//stop updates when view disappears
-(void)resignKeyWindow
{
    %orig;
    if (fluidView)
    {
        [fluidView stopAnimation];
        StopNotifications();
    }
}
%end

%hook SBHomeScreenView
-(void)didMoveToWindow
{
    %orig;

    //only create fluid view once
    if (fluidView) [fluidView removeFromSuperview];

    //create the fluid view:
    CGFloat w = sqrt(self.frame.size.height * self.frame.size.height * 2);
    fluidView = [[BAFluidView alloc] initWithFrame:CGRectMake((self.frame.size.width - w) / 2, (self.frame.size.height - w) / 2, w, w) maxAmplitude:waveAmplitude minAmplitude:5 amplitudeIncrement:5];
    fluidView.fillColor = waveColor;
    fluidView.strokeColor = [UIColor clearColor];
    [fluidView keepStationary];
    [fluidView fillTo:@(waveHeight)];
    [fluidView startTiltAnimation];
    [self insertSubview:fluidView atIndex:0];
}

//ensure fluid view is always sent to back
-(void)addSubview:(UIView*)arg1
{
    %orig;
    [self sendSubviewToBack:fluidView];
}
%end

%ctor
{
    //initialise motion manager
    motionManager = [[CMMotionManager alloc] init];
    motionManager.deviceMotionUpdateInterval = 0.5;
    //add observer for preferences changed:
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)updateFluidView, CFSTR("com.muirey03.waves-prefsChanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}
