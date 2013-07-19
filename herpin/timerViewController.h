//
//  timerViewController.h
//  lightControlApp
//
//  Created by Ian Koenigsknecht on 4/23/12.
//  Copyright (c) 2012 BU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"

@interface timerViewController : UIViewController
@property (retain, nonatomic) IBOutlet UINavigationItem *titleBar;
@property (retain, nonatomic) IBOutlet UIButton *cancelButton;
@property (retain, nonatomic) IBOutlet UIButton *setTimerButton;
@property (retain, nonatomic) IBOutlet UIStepper *hourControl;
@property (retain, nonatomic) IBOutlet UIStepper *minuteControl;
@property (retain, nonatomic) IBOutlet UILabel *hourLabel;
@property (retain, nonatomic) IBOutlet UILabel *minuteLabel;
@property (retain, nonatomic) IBOutlet UILabel *secondLabel;
@property (retain, nonatomic) IBOutlet UISegmentedControl *amPmControl;
@property int amPM;
@property int ID;
@property int hour;
@property int minute;
@property int second;
@property (retain, nonatomic) GCDAsyncSocket *socket;
@property (retain, nonatomic) GCDAsyncSocket *listener;
@property (retain, nonatomic) IBOutlet UIButton *stopButton;
@property (retain, nonatomic) NSRunLoop *runner;

- (IBAction)setTimerButtonIsPressed:(id)sender;
- (IBAction)hourControlValueChanged:(id)sender;
- (IBAction)minuteControlValueChanged:(id)sender;
- (IBAction)amPmControlValueChanged:(id)sender;
- (IBAction)stopButtonIsPressed:(id)sender;
- (IBAction)cancelButtonIsPressed:(id)sender;


@end
