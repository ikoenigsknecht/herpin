//
//  energyViewController.h
//  lightControlApp
//
//  Created by Ian Koenigsknecht on 3/28/12.
//  Copyright (c) 2012 BU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"

@interface energyViewController : UIViewController
@property (retain, nonatomic) IBOutlet UIButton *presetsButton;
@property (retain, nonatomic) IBOutlet UIButton *settingsButton;
@property (retain, nonatomic) GCDAsyncSocket *socket;
@property (retain, nonatomic) GCDAsyncSocket *listener;
@property (retain, nonatomic) IBOutlet UILabel *energyLabel;
@property (retain, nonatomic) IBOutlet UISegmentedControl *timeControl;
@property int day;
@property int month;
@property int total;
@property (retain, nonatomic) NSString *dayS;
@property (retain, nonatomic) NSString *monthS;
@property (retain, nonatomic) NSString *totalS;
- (IBAction)presetsButtonIsPressed:(id)sender;
- (IBAction)settingsButtonIsPressed:(id)sender;
- (IBAction)timeControlValueIsChanged:(id)sender;

@end
