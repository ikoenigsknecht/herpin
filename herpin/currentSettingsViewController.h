//
//  currentSettingsViewController.h
//  lightControlApp
//
//  Created by Ian Koenigsknecht on 4/5/12.
//  Copyright (c) 2012 BU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface currentSettingsViewController : UIViewController
@property (retain, nonatomic) IBOutlet UIView *cView;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UILabel *settingsNum;
@property (retain, nonatomic) IBOutlet UILabel *rLabel;
@property (retain, nonatomic) IBOutlet UILabel *gLabel;
@property (retain, nonatomic) IBOutlet UILabel *bLabel;
@property (retain, nonatomic) IBOutlet UILabel *yLabel;
@property (retain, nonatomic) IBOutlet UIPageControl *pageControl;
- (IBAction)pageControlValueChanged:(id)sender;

@end
