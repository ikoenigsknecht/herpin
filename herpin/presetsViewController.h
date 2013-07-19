//
//  presetsViewController.h
//  herpin
//
//  Created by team6 on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Preset.h"
#import "GCDAsyncSocket.h"

@interface presetsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSStreamDelegate>
{
    GCDAsyncSocket *socket;
    GCDAsyncSocket *listener;
}

//Main Preset View Stuff
@property (retain, nonatomic) IBOutlet UINavigationItem *navTitle;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (retain, nonatomic) IBOutlet UIButton *createNewButton;
@property (retain, nonatomic) IBOutlet UIButton *setDefaultButton;
@property (retain, nonatomic) IBOutlet UISwitch *manualControlSwitch;
@property (assign, nonatomic) IBOutlet UITableView *presetTable;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (retain, nonatomic) Preset *p1;
@property (retain, nonatomic) GCDAsyncSocket *socket;
@property (retain, nonatomic) GCDAsyncSocket *socket1;
@property (retain, nonatomic) GCDAsyncSocket *socket2;
@property (retain, nonatomic) GCDAsyncSocket *listener;
@property BOOL hasBeenSelected;
@property (assign, nonatomic) id *delegate;
- (IBAction)editButtonIsPressed:(id)sender;
- (IBAction)manualControlSwitchIsPressed:(id)sender;
- (IBAction)refreshButtonIsPressed:(id)sender;

//Manual View Stuff
@property (retain, nonatomic) IBOutlet UIView *manualView;
@property (retain, nonatomic) IBOutlet UISegmentedControl *lightSelector;
@property (retain, nonatomic) IBOutlet UISlider *rControl;
@property (retain, nonatomic) IBOutlet UISlider *gControl;
@property (retain, nonatomic) IBOutlet UISlider *bControl;
@property (retain, nonatomic) IBOutlet UISlider *yControl;
@property (retain, nonatomic) IBOutlet UIButton *applyButton;
@property (retain, nonatomic) IBOutlet UIButton *saveButton;
@property (retain, nonatomic) IBOutlet UIView *colorView;
@property (retain, nonatomic) IBOutlet UIView *colorContainer;
@property BOOL manual;
@property float stepVal;
- (IBAction)controlValuesChanged:(id)sender;
- (IBAction)lightSelectorValueChanged:(id)sender;
- (IBAction)saveButtonIsPressed:(id)sender;
- (IBAction)applyButtonIsPressed:(id)sender;
- (IBAction)sliderDown1:(id)sender;
- (IBAction)sliderUp1:(id)sender;
- (IBAction)sliderDown2:(id)sender;
- (IBAction)sliderUp2:(id)sender;
- (IBAction)sliderDown3:(id)sender;
- (IBAction)sliderUp3:(id)sender;
- (IBAction)sliderDown4:(id)sender;
- (IBAction)sliderUp4:(id)sender;

//Custom Tab Bar
@property (retain, nonatomic) IBOutlet UIButton *energyButton;
@property (retain, nonatomic) IBOutlet UIButton *settingsButton;

@end
