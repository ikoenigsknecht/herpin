//
//  settingsViewController.h
//  lightControlApp
//
//  Created by Ian Koenigsknecht on 3/28/12.
//  Copyright (c) 2012 BU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "defaultSettingsViewController.h"
#import "GCDAsyncSocket.h"

@interface settingsViewController : UIViewController <UIAlertViewDelegate>
@property (retain, nonatomic) IBOutlet UIButton *presetsButton;
@property (retain, nonatomic) IBOutlet UIButton *energyButton;
@property (retain, nonatomic) IBOutlet UIButton *logoutButton;
@property (retain, nonatomic) IBOutlet UIButton *changePassButton;
@property (retain, nonatomic) IBOutlet UIButton *sleepTimerButton;
@property (retain, nonatomic) IBOutlet UIButton *wakeupTimerButton;
@property (retain, nonatomic) IBOutlet UIButton *alertTimerButton;
@property (retain, nonatomic) IBOutlet UILabel *userLabel;
@property (retain, nonatomic) UIColor *white;
@property (retain, nonatomic) UIColor *myBlue;
@property (retain, nonatomic) UIColor *myRed;
@property (retain, nonatomic) GCDAsyncSocket *socket;
@property (retain, nonatomic) GCDAsyncSocket *listener;


// Button Presses
- (IBAction)presetsButtonIsPressed:(id)sender;
- (IBAction)energyButtonIsPressed:(id)sender;
- (IBAction)logoutButtonIsPressed:(id)sender;
- (IBAction)changePassButtonIsPressed:(id)sender;
- (IBAction)sleepTimerButtonIsPressed:(id)sender;
- (IBAction)wakeupTimerButtonIsPressed:(id)sender;
- (IBAction)alertTimerButtonIsPressed:(id)sender;

- (IBAction)sleepDown:(id)sender;
- (IBAction)wakeDown:(id)sender;
- (IBAction)alertDown:(id)sender;

@end
