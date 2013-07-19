//
//  AppDelegate.h
//  herpin
//
//  Created by team6 on 2/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Preset.h"
#import "APXML.h"
#import "loginInfo.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    UIWindow *window;
    NSMutableArray *presets; //array of presets
    UIViewController *firstViewController; //first page
    UIViewController *presetsViewController; //main presets page
    UIViewController *createNewViewController; //preset creation page
    UIViewController *editViewController; //preset edit page
    UIViewController *manualControlViewController; //manual control page
    NSIndexPath *currentIndex; //current index in the preset table (used in selection of specific preset cells)
    Preset *manualControlSettings; //manual settings object
    Preset *defaultSettings; //default settings object
    Preset *activeSettings; //the current preset
    NSString *mostRecentView; //the last page the user was on (used when showing the current settings page)
    APDocument *pDoc; //stores the xml of the preset table
    NSString *userID; //user id
    BOOL manual; //sets the manual control on or off
    int idMax; //the highest possible value of a preset id
    int timerID; //shows which timer is being shown
    loginInfo *login; //login info object
    BOOL wakeSet, sleepSet, alertSet; //these are set when either the wake-up, sleep or alert timers are set/turned off
    NSMutableArray *sArray,*wArray,*aArray; //holds the hour, minute and second values for each timer
    NSDate *start; //when the alert timer was started
    int hour,minute,second; //used for alert timer decrementing
}

//create the above as properties
@property (retain, nonatomic) UIWindow *window;
@property (retain, nonatomic) NSMutableArray *presets;
@property (retain, nonatomic) UIViewController *firstViewController;
@property (retain, nonatomic) UIViewController *presetsViewController;
@property (retain, nonatomic) UIViewController *createNewViewController;
@property (retain, nonatomic) UIViewController *editViewController;
@property (retain, nonatomic) UIViewController *manualControlViewController;
@property (retain, nonatomic) NSIndexPath *currentIndex;
@property (retain, nonatomic) Preset *manualControlSettings;
@property (retain, nonatomic) Preset *defaultSettings;
@property (retain, nonatomic) Preset *activeSettings;
@property (retain, nonatomic) NSString *mostRecentView;
@property (retain, nonatomic) APDocument *pDoc;
@property (retain, nonatomic) NSString *userID;
@property (retain, nonatomic) loginInfo *login;
@property (retain, nonatomic) NSMutableArray *sArray;
@property (retain, nonatomic) NSMutableArray *wArray;
@property (retain, nonatomic) NSMutableArray *aArray;
@property (retain, nonatomic) NSDate *start;
@property BOOL manual;
@property int idMax;
@property int timerID;
@property BOOL wakeSet;
@property BOOL alertSet;
@property BOOL sleepSet;
@property int hour,minute,second;

@end
