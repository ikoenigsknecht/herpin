//
//  createNewViewController.h
//  herpin
//
//  Created by team6 on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Preset.h"
#import "GCDAsyncSocket.h"

@interface createNewViewController : UIViewController <NSStreamDelegate, UITextFieldDelegate>
{
    UIButton *createButton;
    UISlider *RControl;
    UISlider *GControl;
    UISlider *BControl;
    UISlider *YControl;
    UITextField *nameField;
    UISegmentedControl *lightSelector;
    GCDAsyncSocket *socket;
    float stepVal;
    id *delegate;
}
@property (retain, nonatomic) IBOutlet UIButton *createButton;
@property (retain, nonatomic) IBOutlet UISlider *RControl;
@property (retain, nonatomic) IBOutlet UISlider *GControl;
@property (retain, nonatomic) IBOutlet UISlider *BControl;
@property (retain, nonatomic) IBOutlet UISlider *YControl;
@property (retain, nonatomic) IBOutlet UITextField *nameField;
@property (retain, nonatomic) IBOutlet UISegmentedControl *lightSelector;
@property (retain, nonatomic) IBOutlet UIButton *applyButton;
@property (retain, nonatomic) IBOutlet UIView *colorView;
@property (retain, nonatomic) GCDAsyncSocket *socket;
@property (assign, nonatomic) id *delegate;
- (IBAction)createButtonIsPressed:(id)sender;
- (IBAction)lightSelectorValueChanged:(id)sender;
- (IBAction)controlValueChanged:(id)sender;
- (IBAction)applyButtonIsPressed:(id)sender;

@end
