//
//  createNewViewController.m
//  herpin
//
//  Created by team6 on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "createNewViewController.h"
#import "presetsViewController.h"
#import "AppDelegate.h"
#import "Preset.h"
#import "APXML.h"
#import "FloatHolder.h"
#import "GCDAsyncSocket.h"

@implementation createNewViewController
@synthesize createButton;
@synthesize RControl;
@synthesize GControl;
@synthesize BControl;
@synthesize YControl;
@synthesize nameField;
@synthesize lightSelector;
@synthesize applyButton;
@synthesize colorView;
@synthesize delegate;
@synthesize socket;

float r[4];
float g[4];
float b[4];
float y[4];

UIColor *myColor;

#define PRESET_SEND 1
#define GENERAL_RECEIVE 2

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)initNetworkCommunication
{

}

- (void)socket:(GCDAsyncSocket *)sender didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    NSLog(@"new connection");
    [newSocket readDataWithTimeout:-1 tag:GENERAL_RECEIVE];
}

- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"connected");
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    if (tag == PRESET_SEND)
    {
        NSLog(@"preset updated");
        [socket disconnect];
    }
}

- (void)socket:(GCDAsyncSocket *)sender didReadData:(NSData *)data withTag:(long)tag
{
    
}

- (void)sendDataToServer:(NSString *)value
{
    //NSString *host = @"168.122.13.199";
    //NSString *host = @"128.197.180.248";
    NSString *host = @"192.168.1.116";
    int port = 5000;
    
    NSError *err = nil;
    if (![socket connectToHost:host onPort:port error:&err]) // Asynchronous!
    {
        // If there was an error, it's likely something like "already connected" or "no delegate set"
        NSLog(@"I goofed: %@", err);
        return;
    }
    
    NSString *response = [NSString stringWithFormat:@"%@\n",value];
    NSData *daData = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
    
    [socket writeData:daData withTimeout:-1 tag:PRESET_SEND];
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [self.nameField setDelegate:self];

    [super viewDidLoad];
    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    //listener = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillShowNotification 
                                                  object:nil]; 
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                name:UIKeyboardWillHideNotification 
                                                  object:nil];
    
    //set default values for the sliders
    for (int i = 0; i < 4; i++)
    {
        r[i]  = 127.0f;
        g[i]  = 127.0f;
        b[i]  = 127.0f;
        y[i]  = 127.0f;
    }
    
    lightSelector.momentary = NO; 
    lightSelector.selectedSegmentIndex = 0; 
    
    myColor = [[UIColor alloc] initWithRed:r[0]/255 green:g[0]/255 blue:b[0]/255 alpha:1.0f];
    colorView.backgroundColor = myColor;
    
    //[self initNetworkCommunication];
    
    stepVal = 5.f;
}

- (void)viewDidUnload
{
    [self setCreateButton:nil];
    [self setNameField:nil];
    [self setRControl:nil];
    [self setGControl:nil];
    [self setBControl:nil];
    [self setYControl:nil];
    [self setLightSelector:nil];
    [self setApplyButton:nil];
    [self setColorView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    //[self createButtonIsPressed:self];
    return YES;
}

- (void)dealloc {
    [createButton release];
    [nameField release];
    [RControl release];
    [GControl release];
    [BControl release];
    [YControl release];
    [lightSelector release];
    [applyButton release];
    [colorView release];
    [super dealloc];
}

//if the user presses create, populate the preset object and store it/send to server
- (IBAction)createButtonIsPressed:(id)sender 
{
    if (nameField.text.length == 0) //check if the user entered a name for the preset
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                        message:@"You must enter a name for your preset." 
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    else //if a name was entered, create a new preset entry
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        BOOL taken =FALSE;
        for (int i = 0; i < appDelegate.presets.count; i++)
        {
            Preset *temp = [appDelegate.presets objectAtIndex:i];
            if ([nameField.text isEqualToString:temp.name]) { taken = TRUE; }
        }
        
        if (taken == TRUE) //if the name is taken, give an error
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                            message:@"That name is already taken.  Please choose a new one." 
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        
        else //else, populate the object and send to the server
        {
            FloatHolder *s1 = [[FloatHolder alloc] initWithCount:4];
            FloatHolder *s2 = [[FloatHolder alloc] initWithCount:4];
            FloatHolder *s3 = [[FloatHolder alloc] initWithCount:4];
            FloatHolder *s4 = [[FloatHolder alloc] initWithCount:4];
            
            int j = 0;
            [s1 setValue:r[j] atIndex:0];
            [s1 setValue:g[j] atIndex:1];
            [s1 setValue:b[j] atIndex:2];
            [s1 setValue:y[j] atIndex:3];
            
            r[j] = floorf(r[j]);
            g[j] = floorf(g[j]);
            b[j] = floorf(b[j]);
            y[j] = floorf(y[j]);
            
            NSString *sr1  = [NSString stringWithFormat:@"%03.f",r[j]];
            NSString *sg1  = [NSString stringWithFormat:@"%03.f",g[j]];
            NSString *sb1  = [NSString stringWithFormat:@"%03.f",b[j]];
            NSString *sy1  = [NSString stringWithFormat:@"%03.f",y[j]];
            
            j = 1;
            [s2 setValue:r[j] atIndex:0];
            [s2 setValue:g[j] atIndex:1];
            [s2 setValue:b[j] atIndex:2];
            [s2 setValue:y[j] atIndex:3];
            
            r[j] = floorf(r[j]);
            g[j] = floorf(g[j]);
            b[j] = floorf(b[j]);
            y[j] = floorf(y[j]);
            
            NSString *sr2  = [NSString stringWithFormat:@"%03.f",r[j]];
            NSString *sg2  = [NSString stringWithFormat:@"%03.f",g[j]];
            NSString *sb2  = [NSString stringWithFormat:@"%03.f",b[j]];
            NSString *sy2  = [NSString stringWithFormat:@"%03.f",y[j]];
            
            j = 2;
            [s3 setValue:r[j] atIndex:0];
            [s3 setValue:g[j] atIndex:1];
            [s3 setValue:b[j] atIndex:2];
            [s3 setValue:y[j] atIndex:3];
            
            r[j] = floorf(r[j]);
            g[j] = floorf(g[j]);
            b[j] = floorf(b[j]);
            y[j] = floorf(y[j]);
            
            NSString *sr3  = [NSString stringWithFormat:@"%03.f",r[j]];
            NSString *sg3  = [NSString stringWithFormat:@"%03.f",g[j]];
            NSString *sb3  = [NSString stringWithFormat:@"%03.f",b[j]];
            NSString *sy3  = [NSString stringWithFormat:@"%03.f",y[j]];
            
            j = 3;
            [s4 setValue:r[j] atIndex:0];
            [s4 setValue:g[j] atIndex:1];
            [s4 setValue:b[j] atIndex:2];
            [s4 setValue:y[j] atIndex:3];
            
            r[j] = floorf(r[j]);
            g[j] = floorf(g[j]);
            b[j] = floorf(b[j]);
            y[j] = floorf(y[j]);
            
            NSString *sr4  = [NSString stringWithFormat:@"%03.f",r[j]];
            NSString *sg4  = [NSString stringWithFormat:@"%03.f",g[j]];
            NSString *sb4  = [NSString stringWithFormat:@"%03.f",b[j]];
            NSString *sy4  = [NSString stringWithFormat:@"%03.f",y[j]];
            
            //create the preset object
            Preset *temp = [[Preset alloc] initWithName:nameField.text s1:s1 s2:s2 s3:s3 s4:s4 ID:appDelegate.idMax+1 isSetToActive:false];
            appDelegate.idMax = appDelegate.idMax+1;
            
            //if this is the first preset, set it to active
            if (appDelegate.presets.count == 0) 
            { 
                temp.isSetToActive = TRUE; 
                appDelegate.activeSettings = temp;
            }
            
            [appDelegate.presets addObject:temp];
            
            //create the xml doc to send
            APElement *root = [[APElement alloc] initWithName:@"createPreset"];
            APElement *preset = [[APElement alloc] initWithName:@"preset"];
            //NSString *idNum = [NSString stringWithFormat:@"%i",temp.ID];
            //[preset addAttributeNamed:@"id" withValue:idNum];
            [preset addAttributeNamed:@"name" withValue:nameField.text];
            
            APElement *light1 = [[APElement alloc] initWithName:@"light"];
            APElement *light2 = [[APElement alloc] initWithName:@"light"];
            APElement *light3 = [[APElement alloc] initWithName:@"light"];
            APElement *light4 = [[APElement alloc] initWithName:@"light"];
            
            [light1 addAttributeNamed:@"red" withValue:sr1];
            [light1 addAttributeNamed:@"green" withValue:sg1];
            [light1 addAttributeNamed:@"blue" withValue:sb1];
            [light1 addAttributeNamed:@"yellow" withValue:sy1];
            [light1 addAttributeNamed:@"id" withValue:@"1"];
            
            [light2 addAttributeNamed:@"red" withValue:sr2];
            [light2 addAttributeNamed:@"green" withValue:sg2];
            [light2 addAttributeNamed:@"blue" withValue:sb2];
            [light2 addAttributeNamed:@"yellow" withValue:sy2];
            [light2 addAttributeNamed:@"id" withValue:@"2"];
            
            [light3 addAttributeNamed:@"red" withValue:sr3];
            [light3 addAttributeNamed:@"green" withValue:sg3];
            [light3 addAttributeNamed:@"blue" withValue:sb3];
            [light3 addAttributeNamed:@"yellow" withValue:sy3];
            [light3 addAttributeNamed:@"id" withValue:@"3"];
            
            [light4 addAttributeNamed:@"red" withValue:sr4];
            [light4 addAttributeNamed:@"green" withValue:sg4];
            [light4 addAttributeNamed:@"blue" withValue:sb4];
            [light4 addAttributeNamed:@"yellow" withValue:sy4];
            [light4 addAttributeNamed:@"id" withValue:@"4"];
            
            [preset addChild:light1];
            [preset addChild:light2];
            [preset addChild:light3];
            [preset addChild:light4];
            
            [root addChild:preset];
            
            APDocument *pDoc = [[APDocument alloc] initWithRootElement:root];
            
            NSString *xml = [pDoc xml];
            NSLog(@"%@",xml);
            
            NSString *message = [NSString stringWithFormat:@"serverX+=+%@",xml];
            //[self sendDataToServer:message]; //send the data to the server
            
            [self performSegueWithIdentifier: @"createPresets" sender: self];
        }
    }
}

//slider values changed
- (IBAction)controlValueChanged:(id)sender
{
    int temp = lightSelector.selectedSegmentIndex;
    
    float newR = roundf((RControl.value) / stepVal);
    float newG = roundf((GControl.value) / stepVal);
    float newB = roundf((BControl.value) / stepVal);
    float newY = roundf((YControl.value) / stepVal);
    
    RControl.value = newR * stepVal;
    GControl.value = newG * stepVal;
    BControl.value = newB * stepVal;
    YControl.value = newY * stepVal;
    
    r[temp] = RControl.value;
    g[temp] = GControl.value;
    b[temp] = BControl.value;
    y[temp] = YControl.value;
    
    myColor = [[UIColor alloc] initWithRed:(r[temp]/255) green:(g[temp]/255) blue:(b[temp]/255) alpha:1.0f];
    colorView.backgroundColor = myColor;
}

//apply the current settings to all lights
- (IBAction)applyButtonIsPressed:(id)sender 
{
    int temp = lightSelector.selectedSegmentIndex;
    
    if (temp == 0)
    {
        r[1] = r[0];
        r[2] = r[0];
        r[3] = r[0];
        
        g[1] = g[0];
        g[2] = g[0];
        g[3] = g[0];
        
        b[1] = b[0];
        b[2] = b[0];
        b[3] = b[0];
        
        y[1] = y[0];
        y[2] = y[0];
        y[3] = y[0];
    }
    
    else if (temp == 1)
    {
        r[0] = r[1];
        r[2] = r[1];
        r[3] = r[1];
        
        g[0] = g[1];
        g[2] = g[1];
        g[3] = g[1];
        
        b[0] = b[1];
        b[2] = b[1];
        b[3] = b[1];
        
        y[0] = y[1];
        y[2] = y[1];
        y[3] = y[1];
    }
    
    else if (temp == 2)
    {
        r[0] = r[2];
        r[1] = r[2];
        r[3] = r[2];
        
        g[0] = g[2];
        g[1] = g[2];
        g[3] = g[2];
        
        b[0] = b[2];
        b[1] = b[2];
        b[3] = b[2];
        
        y[0] = y[2];
        y[1] = y[2];
        y[3] = y[2];
    }
    
    else if (temp == 3)
    {
        r[0] = r[3];
        r[1] = r[3];
        r[2] = r[3];
        
        g[0] = g[3];
        g[1] = g[3];
        g[2] = g[3];
        
        b[0] = b[3];
        b[1] = b[3];
        b[2] = b[3];
        
        y[0] = y[3];
        y[1] = y[3];
        y[2] = y[3];
    }
    
    myColor = [[UIColor alloc] initWithRed:r[temp]/255 green:g[temp]/255 blue:b[temp]/255 alpha:1.0f];
    colorView.backgroundColor = myColor;
}

//change light 
- (IBAction)lightSelectorValueChanged:(id)sender 
{
    int temp = lightSelector.selectedSegmentIndex;
    
    RControl.value = r[temp];
    GControl.value = g[temp];
    BControl.value = b[temp];
    YControl.value = y[temp];
    
    myColor = [[UIColor alloc] initWithRed:r[temp]/255 green:g[temp]/255 blue:b[temp]/255 alpha:1.0f];
    colorView.backgroundColor = myColor;
}
                                    
@end
