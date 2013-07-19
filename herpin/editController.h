//
//  editController.h
//  herpin
//
//  Created by team6 on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Preset.h"
#import "GCDAsyncSocket.h"

@interface editController : UIViewController <NSStreamDelegate, UITextFieldDelegate>
{
    UITextField *nameField;
    UISlider *RControl;
    UISlider *GControl;
    UISlider *BControl;
    UISlider *YControl;
    UIButton *saveButton;
    UISegmentedControl *lightSelector;
    Preset *selectedPreset;
    GCDAsyncSocket *socket;
    GCDAsyncSocket *listener;
    float stepVal;
    id delegate;
}

@property (retain, nonatomic) IBOutlet UITextField *nameField; //textfield to enter name
@property (retain, nonatomic) IBOutlet UISlider *RControl; //red slider
@property (retain, nonatomic) IBOutlet UISlider *GControl; //green slider
@property (retain, nonatomic) IBOutlet UISlider *BControl; //blue slider
@property (retain, nonatomic) IBOutlet UISlider *YControl; //yellow slider
@property (retain, nonatomic) IBOutlet UIButton *saveButton; //save button
@property (retain, nonatomic) IBOutlet UISegmentedControl *lightSelector; //segmented control to choose current light
@property (retain, nonatomic) IBOutlet UIButton *applyButton; //apply settings to all lights
@property (retain, nonatomic) NSMutableArray *se1; //settings 1
@property (retain, nonatomic) NSMutableArray *se2; //settings 2
@property (retain, nonatomic) NSMutableArray *se3; //settings 3
@property (retain, nonatomic) NSMutableArray *se4; //settings 4
@property (retain, nonatomic) Preset *selectedPreset; //the preset that is being changed
@property (retain, nonatomic) IBOutlet UIView *colorView; //shows a preview of the color the user has set the lights to
@property (retain, nonatomic) GCDAsyncSocket *socket; //socket to send
@property (retain, nonatomic) GCDAsyncSocket *listener; //socket to receive
@property (assign, nonatomic) id delegate;
- (IBAction)saveButtonIsPressed:(id)sender;
- (IBAction)lightSelectorValueChanged:(id)sender;
- (IBAction)controlValueChanged:(id)sender; //called when the sliders have changed
- (IBAction)applyButtonIsPressed:(id)sender;
- (IBAction)cancelButtonIsPressed:(id)sender;

@end
