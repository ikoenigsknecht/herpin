//
//  settingsViewController.m
//  lightControlApp
//
//  Created by Ian Koenigsknecht on 3/28/12.
//  Copyright (c) 2012 BU. All rights reserved.
//

#import "settingsViewController.h"
#import "AppDelegate.h"
#import "GCDAsyncSocket.h"

@implementation settingsViewController
@synthesize presetsButton;
@synthesize energyButton;
@synthesize logoutButton;
@synthesize changePassButton;
@synthesize sleepTimerButton;
@synthesize wakeupTimerButton;
@synthesize alertTimerButton;
@synthesize white;
@synthesize myBlue;
@synthesize myRed;
@synthesize userLabel;
@synthesize socket;
@synthesize listener;

//tags for the socket communcation
#define TIMER_SEND_TAG 30
#define TIMER_RECEIVE_TAG 31

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
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *response = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSLog(response);
    NSArray *parts = [response componentsSeparatedByString:@"+=+"];
    NSString *sleep = [[parts objectAtIndex:1] stringByTrimmingCharactersInSet: //remove all white spaces/newlines from the yes/no
                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *wake = [[parts objectAtIndex:2] stringByTrimmingCharactersInSet: //remove all white spaces/newlines from the yes/no
                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];;
    NSString *alert = [[parts objectAtIndex:3] stringByTrimmingCharactersInSet: //remove all white spaces/newlines from the yes/no
                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSLog(@"%@ %@ %@",sleep,wake,alert);
    
    int sleepH;
    int sleepM;
    int wakeH;
    int wakeM;
    int alertH;
    int alertM;
    int wAP;
    int aAP;
    int sAP;
    
    if (![sleep isEqualToString:@"0"])
    {
        sleepM = [sleep intValue];
        appDelegate.sleepSet = TRUE;
        
        int seconds = sleepM * 60;
        NSDate *tempDate = [NSDate dateWithTimeIntervalSinceNow:seconds];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:tempDate];
        sleepH = [components hour];
        sleepM = [components minute];
        
        if (sleepH > 12) { sAP = 1; sleepH = sleepH - 12; }
        else { sAP = 0; }
        
        NSLog(@"%i:%i",sleepH,sleepM);
    }
    else { sleepH = 0; sleepM = 0; appDelegate.sleepSet = FALSE; }
    
    if (![wake isEqualToString:@"0"])
    {
        NSArray *wParts = [wake componentsSeparatedByString:@":"];
        wakeH = [[wParts objectAtIndex:0] intValue];
        wakeM = [[wParts objectAtIndex:1] intValue];
        
        if (wakeH > 12) { wAP = 1; wakeH = wakeH - 12;}
        else { wAP = 0; }
        
        NSLog(@"%i:%i",wakeH,wakeM);
        
        appDelegate.wakeSet = TRUE;
    }
    else { wakeH = 0; wakeM = 0; appDelegate.wakeSet = FALSE; }
    
    if (![alert isEqualToString:@"0"])
    {
        NSArray *aParts = [alert componentsSeparatedByString:@":"];
        alertH = [[aParts objectAtIndex:0] intValue];
        alertM = [[aParts objectAtIndex:1] intValue];
        
        if (alertH > 12) { aAP = 1; alertH = alertH - 12;}
        else { aAP = 0; }
        
        appDelegate.alertSet = TRUE;
    }
    else { alertH = 0; alertM = 0; appDelegate.alertSet = FALSE; }
    
    appDelegate.sArray = [[NSMutableArray alloc] init];
    [appDelegate.sArray addObject:[NSNumber numberWithInt:sleepH]];
    [appDelegate.sArray addObject:[NSNumber numberWithInt:sleepM]];
    [appDelegate.sArray addObject:[NSNumber numberWithInt:0]];
    [appDelegate.sArray addObject:[NSNumber numberWithInt:sAP]];
    
    appDelegate.wArray = [[NSMutableArray alloc] init];
    [appDelegate.wArray addObject:[NSNumber numberWithInt:wakeH]];
    [appDelegate.wArray addObject:[NSNumber numberWithInt:wakeM]];
    [appDelegate.wArray addObject:[NSNumber numberWithInt:0]];
    [appDelegate.wArray addObject:[NSNumber numberWithInt:wAP]];
    
    appDelegate.aArray = [[NSMutableArray alloc] init];
    [appDelegate.aArray addObject:[NSNumber numberWithInt:alertH]];
    [appDelegate.aArray addObject:[NSNumber numberWithInt:alertM]];
    [appDelegate.aArray addObject:[NSNumber numberWithInt:0]];
    [appDelegate.aArray addObject:[NSNumber numberWithInt:aAP]];
    
    [listener disconnect];
    [self performSegueWithIdentifier:@"settingsToTimer" sender:self];
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

//move to current settings view
- (void)swipeUp:(UISwipeGestureRecognizer *)recognizer
{
    [self performSegueWithIdentifier:@"settingsCurrent" sender:self];
}

- (void)swipeLeft:(UISwipeGestureRecognizer *)recognizer
{
}

//move to energy usage page
- (void)swipeRight:(UISwipeGestureRecognizer *)recognizer
{
    [self performSegueWithIdentifier:@"settingsEnergy" sender:self];
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
    appDelegate.mostRecentView = @"settings";
    
    //setup the sockets
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    listener = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    
    [self initNetworkCommunication]; //initialize the sockets
    
    UISwipeGestureRecognizer *swipeUp = 
    [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUp:)] autorelease];
    [swipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [[self view] addGestureRecognizer:swipeUp];
    
    UISwipeGestureRecognizer *swipeLeft = 
    [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)] autorelease];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [[self view] addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = 
    [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)] autorelease];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [[self view] addGestureRecognizer:swipeRight];
    
    self.logoutButton.titleLabel.textAlignment = UITextAlignmentCenter;
    self.changePassButton.titleLabel.textAlignment = UITextAlignmentCenter;
    self.alertTimerButton.titleLabel.textAlignment = UITextAlignmentCenter;
    self.wakeupTimerButton.titleLabel.textAlignment = UITextAlignmentCenter;
    self.sleepTimerButton.titleLabel.textAlignment = UITextAlignmentCenter;
    
    self.white = [UIColor whiteColor];
    self.myBlue = [[UIColor alloc] initWithRed:50.0f green:79.0f blue:133.0f alpha:1.0f];
    self.myRed = [[UIColor alloc] initWithRed:133.0f green:26.0f blue:18.0f alpha:1.0f];
    
    self.userLabel.text = appDelegate.login.username;
    
    appDelegate.timerID = 100;
}

- (void)viewDidUnload
{
    [self setPresetsButton:nil];
    [self setEnergyButton:nil];
    [self setLogoutButton:nil];
    [self setChangePassButton:nil];
    [self setSleepTimerButton:nil];
    [self setWakeupTimerButton:nil];
    [self setAlertTimerButton:nil];
    [self setUserLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [presetsButton release];
    [energyButton release];
    [logoutButton release];
    [changePassButton release];
    [sleepTimerButton release];
    [wakeupTimerButton release];
    [alertTimerButton release];
    [userLabel release];
    [super dealloc];
}

//// Button Press Methods
- (IBAction)presetsButtonIsPressed:(id)sender 
{
    [listener disconnect];
}

- (IBAction)energyButtonIsPressed:(id)sender 
{
    [listener disconnect];
}

- (IBAction)logoutButtonIsPressed:(id)sender 
{
    //if no, show a popup that informs the user that they entered incorrect information
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" 
                                                    message:@"Are you sure you would like to be logged out?" 
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes",nil];
    
    [alert show];
    [alert release];
    //[alert dismissWithClickedButtonIndex:1 animated:NO];
    
    [listener disconnect];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonID = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([buttonID isEqualToString:@"No"])
    {
        
    }
    else if ([buttonID isEqualToString:@"Yes"])
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.login = nil;
        appDelegate.presets = nil;
        appDelegate.manualControlSettings = nil;
        appDelegate.defaultSettings = nil;
        appDelegate.userID = nil;
        appDelegate.activeSettings = nil;
        [alertView resignFirstResponder];
        [self performSegueWithIdentifier:@"logoutSegue" sender:self];
    }
}

- (IBAction)changePassButtonIsPressed:(id)sender 
{
    //if no, show a popup that informs the user that they entered incorrect information
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry, bro" 
                                                    message:@"You gotta use the web app to change your password." 
                                                   delegate:self
                                          cancelButtonTitle:@"Aight."
                                          otherButtonTitles:nil];
    
    [alert show];
    [alert release];
}

- (IBAction)sleepTimerButtonIsPressed:(id)sender 
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    appDelegate.timerID = 0;
    
    [self sendTimerToServer:@"server+=+getTimers+=+192.168.1.118"];
}

- (IBAction)wakeupTimerButtonIsPressed:(id)sender 
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    appDelegate.timerID = 1;
    
    [self sendTimerToServer:@"server+=+getTimers+=+192.168.1.118"];
}

- (IBAction)alertTimerButtonIsPressed:(id)sender 
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    appDelegate.timerID = 2;
    
    [self sendTimerToServer:@"server+=+getTimers+=+192.168.1.118"];
}

- (IBAction)sleepDown:(id)sender 
{
}

- (IBAction)wakeDown:(id)sender 
{
}

- (IBAction)alertDown:(id)sender 
{
}
@end
