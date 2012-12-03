//
//  AppDelegate.m
//  Paula
//
//  Created by Grant Damron on 9/27/12.
//  Copyright (c) 2012 Grant Damron. All rights reserved.
//

#import "AppDelegate.h"
#import "TempMainViewController.h"
#import "ScoreViewController.h"
#import "SharetoFBViewController.h"

@interface AppDelegate ()

@property (strong, nonatomic) SharetoFBViewController *sharetoFBViewController;

@end

@implementation AppDelegate
@synthesize window = _window;
@synthesize sharetoFBViewController = _sharetoFBViewController;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    TempMainViewController *tempMainViewController = [[TempMainViewController alloc] init];
    self.window.rootViewController = tempMainViewController;
    self.window.backgroundColor = [UIColor whiteColor];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
