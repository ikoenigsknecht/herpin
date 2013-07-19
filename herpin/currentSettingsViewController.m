//
//  currentSettingsViewController.m
//  lightControlApp
//
//  Created by Ian Koenigsknecht on 4/5/12.
//  Copyright (c) 2012 BU. All rights reserved.
//

#import "currentSettingsViewController.h"
#import "AppDelegate.h"
#import "FloatHolder.h"
#import "Preset.h"

@implementation currentSettingsViewController
@synthesize cView;
@synthesize nameLabel;
@synthesize settingsNum;
@synthesize rLabel;
@synthesize gLabel;
@synthesize bLabel;
@synthesize yLabel;
@synthesize pageControl;

float r[4];
float g[4];
float b[4];
float y[4];

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//return to the last view if the user swipes down
- (void)swipeDown:(UISwipeGestureRecognizer *)recognizer
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ([appDelegate.mostRecentView isEqualToString:@"presets"])
    {
        [self performSegueWithIdentifier:@"currentPresets" sender:self];
    }
    else if ([appDelegate.mostRecentView isEqualToString:@"energy"])
    {
        [self performSegueWithIdentifier:@"currentEnergy" sender:self];
    }
    else if ([appDelegate.mostRecentView isEqualToString:@"settings"])
    {
        [self performSegueWithIdentifier:@"currentSettings" sender:self];
    }
}

//change to the previous light view
- (void)swipeLeft:(UISwipeGestureRecognizer *)recognizer
{
    if (pageControl.currentPage < pageControl.numberOfPages-1)
    {
        pageControl.currentPage = pageControl.currentPage + 1;
        [self pageControlValueChanger];
    }
}

//change to the next light view
- (void)swipeRight:(UISwipeGestureRecognizer *)recognizer
{
    if (pageControl.currentPage > 0)
    {
        pageControl.currentPage = pageControl.currentPage - 1;
        [self pageControlValueChanger];
    }
}

//user used the page control object to change pages instead of swiping
- (void)pageControlValueChanger
{
    settingsNum.text = [NSString stringWithFormat:@"%i",(pageControl.currentPage+1)];
    
    rLabel.text = [NSString stringWithFormat:@"%.f",r[pageControl.currentPage]];
    gLabel.text = [NSString stringWithFormat:@"%.f",g[pageControl.currentPage]];
    bLabel.text = [NSString stringWithFormat:@"%.f",b[pageControl.currentPage]];
    yLabel.text = [NSString stringWithFormat:@"%.f",y[pageControl.currentPage]];
}

- (IBAction)pageControlValueChanged:(id)sender 
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UISwipeGestureRecognizer *swipeDown = 
    [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDown:)] autorelease];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [[self view] addGestureRecognizer:swipeDown];
    
    UISwipeGestureRecognizer *swipeLeft = 
    [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)] autorelease];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [[self view] addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = 
    [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)] autorelease];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [[self view] addGestureRecognizer:swipeRight];
    
    Preset *selectedPreset = appDelegate.activeSettings;
    
    FloatHolder *holder = selectedPreset.s1;
    r[0]  = [holder getValueAtIndex:0];
    g[0]  = [holder getValueAtIndex:1];
    b[0]  = [holder getValueAtIndex:2];
    y[0]  = [holder getValueAtIndex:3];
    
    holder = selectedPreset.s2;
    r[1]  = [holder getValueAtIndex:0];
    g[1]  = [holder getValueAtIndex:1];
    b[1]  = [holder getValueAtIndex:2];
    y[1]  = [holder getValueAtIndex:3];
    
    holder = selectedPreset.s3;
    r[2]  = [holder getValueAtIndex:0];
    g[2]  = [holder getValueAtIndex:1];
    b[2]  = [holder getValueAtIndex:2];
    y[2]  = [holder getValueAtIndex:3];
    
    holder = selectedPreset.s4;
    r[3]  = [holder getValueAtIndex:0];
    g[3]  = [holder getValueAtIndex:1];
    b[3]  = [holder getValueAtIndex:2];
    y[3]  = [holder getValueAtIndex:3];
    
    rLabel.text = [NSString stringWithFormat:@"%.f",r[0]];
    gLabel.text = [NSString stringWithFormat:@"%.f",g[0]];
    bLabel.text = [NSString stringWithFormat:@"%.f",b[0]];
    yLabel.text = [NSString stringWithFormat:@"%.f",y[0]];
    nameLabel.text = selectedPreset.name;
}

- (void)viewDidUnload
{
    [self setCView:nil];
    [self setNameLabel:nil];
    [self setSettingsNum:nil];
    [self setRLabel:nil];
    [self setGLabel:nil];
    [self setBLabel:nil];
    [self setYLabel:nil];
    [self setPageControl:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [cView release];
    [nameLabel release];
    [settingsNum release];
    [rLabel release];
    [gLabel release];
    [bLabel release];
    [yLabel release];
    [pageControl release];
    [super dealloc];
}

@end
