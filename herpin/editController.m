//
//  editController.m
//  herpin
//
//  Created by team6 on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "editController.h"
#import "presetsViewController.h"
#import "Preset.h"
#import "AppDelegate.h"
#import "APXML.h"
#import "GCDAsyncSocket.h"

@implementation editController
@synthesize nameField;
@synthesize RControl;
@synthesize GControl;
@synthesize BControl;
@synthesize YControl;
@synthesize saveButton;
@synthesize lightSelector;
@synthesize applyButton;
@synthesize se1;
@synthesize se2;
@synthesize se3;
@synthesize se4;
@synthesize selectedPreset;
@synthesize colorView;
@synthesize delegate;
@synthesize listener;
@synthesize socket;

float r[4];
float g[4];
float b[4];
float y[4];

BOOL activeStatus;

UIColor *myColor;

#define PRESET_EDIT_SEND 1
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

//called when the save button is pressed
- (IBAction)saveButtonIsPressed:(id)sender 
{
    if (nameField.text.length == 0) //give an error if the user didn't enter in a name for the preset
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                        message:@"You must enter a name for your preset." 
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];

    }
    else //otherwise...
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        BOOL taken = FALSE;
        for (int i = 0; i < appDelegate.presets.count; i++) //cycle through the presets and determine if the name the user chose is taken
        {
            if (i != appDelegate.currentIndex.row)
            {
                Preset *temp = [appDelegate.presets objectAtIndex:i];
                if ([nameField.text isEqualToString:temp.name]) { taken = TRUE; }
            }
        }
        
        if (taken == TRUE) //if the name is taken, show an error message
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                            message:@"That name is already taken.  Please choose a new one." 
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        
        else //otherwise...
        {
            //store all of the float values from the sliders
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
            
            //update the preset
            Preset *moreTemp = [appDelegate.presets objectAtIndex:appDelegate.currentIndex.row];
            Preset *temp = [[Preset alloc] initWithName:nameField.text s1:s1 s2:s2 s3:s3 s4:s4 ID:moreTemp.ID isSetToActive:false];
            [appDelegate.presets replaceObjectAtIndex:appDelegate.currentIndex.row withObject:temp]; //replace the older version of the preset with the new one
            
            //create an xml document to send the data in
            APElement *root = [[APElement alloc] initWithName:@"updatePreset"];
            APElement *preset = [[APElement alloc] initWithName:@"preset"];
            NSString *idNum = [NSString stringWithFormat:@"%i",temp.ID];
            [preset addAttributeNamed:@"id" withValue:idNum];
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
            
            //send the xml doc to the server
            NSString *message = [NSString stringWithFormat:@"serverX+=+%@",xml];
            //[self sendDataToServer:message];
            
            [self performSegueWithIdentifier: @"editPresets" sender: self]; //return to the presets page
        }
    }
}

- (void)initNetworkCommunication
{
//    NSError *err = nil;
//    NSLog(@"network initialization");
//    
//    int listenPort = 5000;
//    if (![listener acceptOnPort:listenPort error:&err])
//    {
//        NSLog(@"I dun goofed");
//        return;
//    }
}

//connection opened
- (void)socket:(GCDAsyncSocket *)sender didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    NSLog(@"new connection");
    [newSocket readDataWithTimeout:-1 tag:GENERAL_RECEIVE];
}

//connected to host
- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"connected");
}

//data has been sent
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    if (tag == PRESET_EDIT_SEND)
    {
        NSLog(@"preset updated");
        [socket disconnect];
    }
}

//data was received
- (void)socket:(GCDAsyncSocket *)sender didReadData:(NSData *)data withTag:(long)tag
{

}

//this function opens up a connection to the server and sends the preset data
- (void)sendDataToServer:(NSString *)value
{
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
    
    [socket writeData:daData withTimeout:-1 tag:PRESET_EDIT_SEND];
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void)viewDidLoad
{
    [nameField setDelegate:self];
    
    [super viewDidLoad];
    
    //create the socket and listener objects
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    listener = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //pull out the selected preset and populate the UI with the stored values
    selectedPreset = [appDelegate.presets objectAtIndex:appDelegate.currentIndex.row];
    activeStatus = selectedPreset.isSetToActive;
    
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
    
    //initialize the first page of sliders
    RControl.value  = r[0];
    GControl.value  = g[0];
    BControl.value  = b[0];
    YControl.value  = y[0];
    nameField.text = selectedPreset.name;
    
    //create the color view based on the current color values
    myColor = [[UIColor alloc] initWithRed:(r[0]/255) green:(g[0]/255) blue:(b[0]/255) alpha:1.0f];
    colorView.backgroundColor = myColor;
    
    stepVal = 5.f;
}

- (void)viewDidUnload
{
    [self setNameField:nil];
    [self setRControl:nil];
    [self setGControl:nil];
    [self setBControl:nil];
    [self setYControl:nil];
    [self setSaveButton:nil];
    [self setLightSelector:nil];
    [self setApplyButton:nil];
    [self setColorView:nil];
    [super viewDidUnload];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)dealloc {
    [nameField release];
    [RControl release];
    [GControl release];
    [BControl release];
    [YControl release];
    [saveButton release];
    [lightSelector release];
    [applyButton release];
    [colorView release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//update the stored slider values when the user changes them
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
    
    //update the color view
    myColor = [[UIColor alloc] initWithRed:(r[temp]/255) green:(g[temp]/255) blue:(b[temp]/255) alpha:1.0f];
    colorView.backgroundColor = myColor;
}

//apply the currently viewed settings to all 4 pages
- (IBAction)applyButtonIsPressed:(id)sender 
{
    int temp = lightSelector.selectedSegmentIndex; //which page are we on?
    
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
    
    myColor = [[UIColor alloc] initWithRed:(r[temp]/255) green:(g[temp]/255) blue:(b[temp]/255) alpha:1.0f];
    colorView.backgroundColor = myColor;
}

//return to the presets page and abandon the changes
- (IBAction)cancelButtonIsPressed:(id)sender 
{
    [self performSegueWithIdentifier: @"editPresets" sender: self];
}

//change pages based on the segmented button
- (IBAction)lightSelectorValueChanged:(id)sender 
{
    int temp = lightSelector.selectedSegmentIndex;
    
    RControl.value = r[temp];
    GControl.value = g[temp];
    BControl.value = b[temp];
    YControl.value = y[temp];
    
    myColor = [[UIColor alloc] initWithRed:(r[temp]/255) green:(g[temp]/255) blue:(b[temp]/255) alpha:1.0f];
    colorView.backgroundColor = myColor;
}

@end
