//
//  AppDelegate.m
//  herpin
//
//  Created by team6 on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "firstViewController.h"
#import "presetsViewController.h"
#import "createNewViewController.h"
#import "Preset.h"
#import "FloatHolder.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize firstViewController;
@synthesize presetsViewController;
@synthesize createNewViewController;
@synthesize editViewController;
@synthesize manualControlViewController;
@synthesize presets;
@synthesize currentIndex;
@synthesize manualControlSettings;
@synthesize defaultSettings;
@synthesize activeSettings;
@synthesize mostRecentView;
@synthesize manual;
@synthesize pDoc;
@synthesize userID;
@synthesize idMax;
@synthesize timerID;
@synthesize login;
@synthesize wakeSet;
@synthesize sleepSet;
@synthesize alertSet;
@synthesize sArray;
@synthesize wArray;
@synthesize aArray;
@synthesize start;
@synthesize hour, minute, second;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.presets = [[NSMutableArray alloc] init]; //set presets to an empty array
    self.currentIndex = nil;
    self.userID = nil;
    self.idMax = 0;
    self.timerID = 100; //this doesn't correspond to a timer id so there is no confusion
    self.wakeSet = FALSE;
    self.sleepSet = FALSE;
    self.alertSet = FALSE;
    self.start = [[NSDate alloc] init]; //set start to an empty date
    
    self.hour = 0;
    self.minute = 0;
    self.second = 0;
    
    //set the wake, sleep and alert time arrays to all zeros
    NSNumber *tempInt = [NSNumber numberWithInt:0];
    self.sArray = [[NSMutableArray alloc] initWithCapacity:4];
    self.wArray = [[NSMutableArray alloc] initWithCapacity:4];
    self.aArray = [[NSMutableArray alloc] initWithCapacity:4];
    
    [self.sArray addObject:tempInt];
    [self.sArray addObject:tempInt];
    [self.sArray addObject:tempInt];
    [self.sArray addObject:tempInt];
    
    [self.wArray addObject:tempInt];
    [self.wArray addObject:tempInt];
    [self.wArray addObject:tempInt];
    [self.wArray addObject:tempInt];
    
    [self.aArray addObject:tempInt];
    [self.aArray addObject:tempInt];
    [self.aArray addObject:tempInt];
    [self.aArray addObject:tempInt];
    
    self.login = [[loginInfo alloc] init]; //create an empty login object
    
    //create a FloatHolder object (allows you to store floats in an object array like NSArray or NSMutableArray) with all 125s
    float temp = 125.0f;
    FloatHolder *tempHolder = [[FloatHolder alloc] initWithCount:5];
    for (int i = 0; i < 4; i++)
    {
        [tempHolder setValue:temp atIndex:i];
    }
    
    //create the manual control and default settings objects with the new FloatHolders
    Preset *mc = [[Preset alloc] initWithName:@"ManualControl" s1:tempHolder s2:tempHolder s3:tempHolder s4:tempHolder ID:0 isSetToActive:FALSE];
    Preset *ds = [[Preset alloc] initWithName:@"DefaultSettings" s1:tempHolder s2:tempHolder s3:tempHolder s4:tempHolder ID:1 isSetToActive:FALSE];
    
    self.manualControlSettings = mc;
    self.defaultSettings = ds;
    self.activeSettings = ds;
    
    mostRecentView = @" ";
    
    manual = FALSE;
    
    self.pDoc = nil;
    
    return YES; //exit the method and continue with the application
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
