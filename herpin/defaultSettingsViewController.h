//
//  defaultSettingsViewController.h
//  lightControlApp
//
//  Created by Ian Koenigsknecht on 3/30/12.
//  Copyright (c) 2012 BU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"

@interface defaultSettingsViewController : UIViewController
@property (retain, nonatomic) IBOutlet UISegmentedControl *lightSelector;
@property (retain, nonatomic) IBOutlet UISlider *RControl;
@property (retain, nonatomic) IBOutlet UISlider *GControl;
@property (retain, nonatomic) IBOutlet UISlider *BControl;
@property (retain, nonatomic) IBOutlet UISlider *YControl;
@property (retain, nonatomic) IBOutlet UIButton *applyButton;
@property (retain, nonatomic) IBOutlet UIButton *cancelButton;
@property (retain, nonatomic) IBOutlet UIButton *saveButton;
@property (retain, nonatomic) IBOutlet UIView *colorView;
@property (retain, nonatomic) GCDAsyncSocket *socket;
@property (retain, nonatomic) GCDAsyncSocket *listener;
@property float stepVal;
- (IBAction)lightSelectorValueChanged:(id)sender;
- (IBAction)controlValueChanged:(id)sender;
- (IBAction)applyButtonIsPressed:(id)sender;
- (IBAction)saveButtonIsPressed:(id)sender;



@end
