//
//  timerViewController.m
//  lightControlApp
//
//  Created by Ian Koenigsknecht on 4/23/12.
//  Copyright (c) 2012 BU. All rights reserved.
//

#import "timerViewController.h"
#import "GCDAsyncSocket.h"
#import "AppDelegate.h"

@implementation timerViewController
@synthesize stopButton;
@synthesize titleBar;
@synthesize cancelButton;
@synthesize setTimerButton;
@synthesize hourControl;
@synthesize minuteControl;
@synthesize hourLabel;
@synthesize minuteLabel;
@synthesize secondLabel;
@synthesize amPmControl;
@synthesize amPM;
@synthesize ID;
@synthesize hour, minute, second;
@synthesize runner;
@synthesize socket;
@synthesize listener;

NSTimer *timer;
NSDate *tempDate;

//tags for the socket communcation
#define TIMER_SEND_TAG 1
#define TIMER_RECEIVE_TAG 2

//// Network Functions
//setup the listener socket on port 5000
- (void)initNetworkCommunication
{
    NSError *err = nil; //set the error to nil
    
    int listenPort = 5000; //set the port to listen on
    if (![listener acceptOnPort:listenPort error:&err]) //open the socket and print a message if this fails 
    {
        NSLog(@"Error: could not open listener on port %i",listenPort);
        return;
    }
}

//called when listener accepts communication with a socket
- (void)socket:(GCDAsyncSocket *)sender didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    NSLog(@"New connection received"); //print a message
    [newSocket readDataWithTimeout:-1 tag:TIMER_RECEIVE_TAG]; //setup an asynchronous read on the new socket with no timeout
}

//called when socket connects to the server
- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"Connected on port %i",port); //output a message
}

//called when socket successfully completes a write
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    if (tag == TIMER_SEND_TAG) //if the write tag corresponds to our write operation...
        NSLog(@"timer set"); //print a message if the login is sent
    
    [socket disconnect]; //disconnect the socket
}

//called when listener successfully reads data
- (void)socket:(GCDAsyncSocket *)sender didReadData:(NSData *)data withTag:(long)tag
{
    
}

//called when data is to be sent to the server for login
- (void)sendTimerToServer:(NSString *)value
{
    NSString *host = @"192.168.1.116"; //set the host's IP
    int port = 5000; //set the port to communicate on
    
    NSError *err = nil; //set the error to nil
    if (![socket connectToHost:host onPort:port error:&err]) //try to open an asynchronous connection to the host
    {
        NSLog(@"Error: falied to connect to %@ on port %i",host,port); //print an error message if connection fails
        return;
    }
    NSString *response = [NSString stringWithFormat:@"%@\n",value]; //set the string to send
    NSData *daData = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]]; //encode it as ASCII string
    
    [socket writeData:daData withTimeout:-1 tag:TIMER_SEND_TAG]; //write to the host with no timeout
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //setup the sockets
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    listener = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    
    [self initNetworkCommunication]; //initialize the sockets

    self.ID = appDelegate.timerID;
    
    NSLog(@"%i",ID);
	
    if (ID == 0) 
    { 
        self.titleBar.title = @"Set Sleep Timer";
        [self.setTimerButton setTitle:@"Set Sleep Timer" forState:UIControlStateNormal];
        self.amPmControl.hidden = FALSE;
        
        if (appDelegate.sleepSet == FALSE)
        {
//            self.hour = 0;
//            self.minute = 0;
//            self.second = 0;
//            self.amPM = 0;
            self.stopButton.hidden = TRUE;
            self.amPmControl.enabled = TRUE;
            self.minuteControl.enabled = TRUE;
            self.hourControl.enabled = TRUE;
        }
        
        else 
        {
            self.hour = [[appDelegate.sArray objectAtIndex:0] intValue];
            self.minute = [[appDelegate.sArray objectAtIndex:1] intValue];
            self.second = [[appDelegate.sArray objectAtIndex:2] intValue];
            self.amPM = [[appDelegate.sArray objectAtIndex:3] intValue];
            self.stopButton.hidden = FALSE;
            self.amPmControl.enabled = FALSE;
            self.minuteControl.enabled = FALSE;
            self.hourControl.enabled = FALSE;
        }
    }
    else if (ID == 1) 
    { 
        self.titleBar.title = @"Set Wake-Up Timer";
        [self.setTimerButton setTitle:@"Set Wake-Up Timer" forState:UIControlStateNormal];
        self.amPmControl.hidden = FALSE;
        
        if (appDelegate.wakeSet == FALSE)
        {
//            self.hour = 0;
//            self.minute = 0;
//            self.second = 0;
//            self.amPM = 0;
            self.stopButton.hidden = TRUE;
            self.amPmControl.enabled = TRUE;
            self.minuteControl.enabled = TRUE;
            self.hourControl.enabled = TRUE;
        }
        
        else 
        {
            self.hour = [[appDelegate.wArray objectAtIndex:0] intValue];
            self.minute = [[appDelegate.wArray objectAtIndex:1] intValue];
            self.second = [[appDelegate.wArray objectAtIndex:2] intValue];
            self.amPM = [[appDelegate.wArray objectAtIndex:3] intValue];
            self.stopButton.hidden = FALSE;
            self.amPmControl.enabled = FALSE;
            self.amPmControl.enabled = FALSE;
            self.minuteControl.enabled = FALSE;
            self.hourControl.enabled = FALSE;
        }
    }
    else if (ID == 2) 
    { 
        self.titleBar.title = @"Set Alert Timer"; 
        [self.setTimerButton setTitle:@"Set Alert Timer" forState:UIControlStateNormal];
        self.amPmControl.hidden = TRUE;
        
        if (appDelegate.alertSet == FALSE)
        {
//            self.hour = 0;
//            self.minute = 0;
//            self.second = 0;
//            self.amPM = 0;
            self.stopButton.hidden = TRUE;
            self.minuteControl.enabled = TRUE;
            self.hourControl.enabled = TRUE;
            self.cancelButton.titleLabel.text = @"Cancel";
        }
        
        else 
        {
            self.hour = [[appDelegate.aArray objectAtIndex:0] intValue];
            self.minute = [[appDelegate.aArray objectAtIndex:1] intValue];
            self.second = [[appDelegate.aArray objectAtIndex:2] intValue];
            self.amPM = [[appDelegate.aArray objectAtIndex:3] intValue];
            self.stopButton.hidden = FALSE;
            self.amPmControl.enabled = FALSE;
            self.minuteControl.enabled = FALSE;
            self.hourControl.enabled = FALSE;
            self.cancelButton.titleLabel.text = @"Back";
        }
    }
    
    hourLabel.text = [NSString stringWithFormat:@"%02i",self.hour];
    minuteLabel.text = [NSString stringWithFormat:@"%02i",self.minute];
    secondLabel.text = [NSString stringWithFormat:@"%02i",self.second];
    amPmControl.selectedSegmentIndex = amPM;
}

- (void)viewDidUnload
{
    [self setTitleBar:nil];
    [self setCancelButton:nil];
    [self setSetTimerButton:nil];
    [self setHourControl:nil];
    [self setMinuteControl:nil];
    [self setHourLabel:nil];
    [self setMinuteLabel:nil];
    [self setSecondLabel:nil];
    [self setAmPmControl:nil];
    [self setStopButton:nil];
    [super viewDidUnload];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [titleBar release];
    [cancelButton release];
    [setTimerButton release];
    [hourControl release];
    [minuteControl release];
    [hourLabel release];
    [minuteLabel release];
    [secondLabel release];
    [amPmControl release];
    [stopButton release];
    [super dealloc];
}
- (IBAction)setTimerButtonIsPressed:(id)sender 
{
    NSString *message;
    if (ID == 0)
    {
        if (amPM == 0) {  message = [NSString stringWithFormat:@"server+=sleepTimer+=+%02i:%02i",hour,minute]; }
        else { message = [NSString stringWithFormat:@"server+=+sleepTimer+=+%02i:%02i",hour+12,minute]; }
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.sleepSet = TRUE;
        appDelegate.sArray = [[NSMutableArray alloc] initWithCapacity:4];
        [appDelegate.sArray addObject:[NSNumber numberWithInt:hour]];
        [appDelegate.sArray addObject:[NSNumber numberWithInt:minute]];
        [appDelegate.sArray addObject:[NSNumber numberWithInt:second]];
        [appDelegate.sArray addObject:[NSNumber numberWithInt:amPM]];
        
    }
    else if (ID == 1)
    {
        if (amPM == 0) {  message = [NSString stringWithFormat:@"server+=wakeTimer+=+%02i:%02i",hour,minute]; }
        else { message = [NSString stringWithFormat:@"server+=+wakeTimer+=+%02i:%02i",hour+12,minute]; }
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.wakeSet = TRUE;
        appDelegate.wArray = [[NSMutableArray alloc] initWithCapacity:4];
        [appDelegate.wArray addObject:[NSNumber numberWithInt:hour]];
        [appDelegate.wArray addObject:[NSNumber numberWithInt:minute]];
        [appDelegate.wArray addObject:[NSNumber numberWithInt:second]];
        [appDelegate.wArray addObject:[NSNumber numberWithInt:amPM]];
    }
    else if (ID == 2)
    {
        if (amPM == 0) {  message = [NSString stringWithFormat:@"server+=alertTimer+=+%02i:%02i",hour,minute]; }
        else { message = [NSString stringWithFormat:@"server+=+alertTimer+=+%02i:%02i",hour+12,minute]; }
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.hour = self.hour;
        appDelegate.minute = self.minute;
        appDelegate.second = self.second;
        appDelegate.alertSet = TRUE;
        appDelegate.aArray = [[NSMutableArray alloc] initWithCapacity:4];
        [appDelegate.aArray addObject:[NSNumber numberWithInt:hour]];
        [appDelegate.aArray addObject:[NSNumber numberWithInt:minute]];
        [appDelegate.aArray addObject:[NSNumber numberWithInt:second]];
        [appDelegate.aArray addObject:[NSNumber numberWithInt:0]];
    }
    
    [cancelButton.titleLabel setText:@"Back"];
    self.stopButton.hidden = FALSE;
    self.amPmControl.enabled = FALSE;
    self.minuteControl.enabled = FALSE;
    self.hourControl.enabled = FALSE;
    
    [self sendTimerToServer:message];
}

- (IBAction)hourControlValueChanged:(id)sender 
{
    hour = hourControl.value;
    hourLabel.text = [NSString stringWithFormat:@"%02i",hour];
}

- (IBAction)minuteControlValueChanged:(id)sender 
{
    minute = minuteControl.value;
    minuteLabel.text = [NSString stringWithFormat:@"%02i",minute];
}

- (IBAction)amPmControlValueChanged:(id)sender 
{
    amPM = amPmControl.selectedSegmentIndex;
}

- (IBAction)stopButtonIsPressed:(id)sender 
{
    self.hour = 0;
    self.minute = 0;
    self.second = 0;
    self.amPM = 0;
    
    if (ID == 0)
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.sleepSet = FALSE;
        appDelegate.sArray = [[NSMutableArray alloc] initWithCapacity:4];
        [appDelegate.sArray addObject:[NSNumber numberWithInt:hour]];
        [appDelegate.sArray addObject:[NSNumber numberWithInt:minute]];
        [appDelegate.sArray addObject:[NSNumber numberWithInt:second]];
        [appDelegate.sArray addObject:[NSNumber numberWithInt:amPM]];
    }
    else if (ID == 1)
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.wakeSet = FALSE;
        appDelegate.wArray = [[NSMutableArray alloc] initWithCapacity:4];
        [appDelegate.wArray addObject:[NSNumber numberWithInt:hour]];
        [appDelegate.wArray addObject:[NSNumber numberWithInt:minute]];
        [appDelegate.wArray addObject:[NSNumber numberWithInt:second]];
        [appDelegate.wArray addObject:[NSNumber numberWithInt:amPM]];   
    }
    else if (ID == 2)
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.alertSet = FALSE;
        appDelegate.aArray = [[NSMutableArray alloc] initWithCapacity:4];
        [appDelegate.aArray addObject:[NSNumber numberWithInt:hour]];
        [appDelegate.aArray addObject:[NSNumber numberWithInt:minute]];
        [appDelegate.aArray addObject:[NSNumber numberWithInt:second]];
        [appDelegate.aArray addObject:[NSNumber numberWithInt:0]];
    }
    
    self.stopButton.hidden = TRUE;
    self.amPmControl.enabled = TRUE;
    self.minuteControl.enabled = TRUE;
    self.hourControl.enabled = TRUE;
    [cancelButton.titleLabel setText:@"Cancel"];
    hourLabel.text = [NSString stringWithFormat:@"%02i",hour];
    minuteLabel.text = [NSString stringWithFormat:@"%02i",minute];
    secondLabel.text = [NSString stringWithFormat:@"%02i",second];
}

- (IBAction)cancelButtonIsPressed:(id)sender 
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (ID == 0)
    {
        if (appDelegate.sleepSet)
        {
            
        }
    }
    else if (ID == 1)
    {  
        if (appDelegate.wakeSet)
        {
            
        }
    }
    else if (ID == 2)
    {
        if (appDelegate.alertSet)
        {
            
        }
    }
    
    [self performSegueWithIdentifier:@"setTimer" sender:self];
}

@end
