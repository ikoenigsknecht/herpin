//
//  energyViewController.m
//  lightControlApp
//
//  Created by Ian Koenigsknecht on 3/28/12.
//  Copyright (c) 2012 BU. All rights reserved.
//

#import "energyViewController.h"
#import "AppDelegate.h"
#import "GCDAsyncSocket.h"

@interface energyViewController ()

@end

@implementation energyViewController
@synthesize presetsButton;
@synthesize settingsButton;
@synthesize socket;
@synthesize listener;
@synthesize energyLabel;
@synthesize timeControl;
@synthesize day;
@synthesize month;
@synthesize total;
@synthesize dayS;
@synthesize monthS;
@synthesize totalS;

//tags for the socket communcation
#define ENERGY_SEND_TAG 50
#define ENERGY_RECEIVE_TAG 51

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
    [newSocket readDataWithTimeout:-1 tag:ENERGY_RECEIVE_TAG]; //setup an asynchronous read on the new socket with no timeout
    //[newSocket disconnectAfterReading];
}

//called when socket connects to the server
- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"Connected on port %i",port); //output a message
}

//called when socket successfully completes a write
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    if (tag == ENERGY_SEND_TAG) //if the write tag corresponds to our write operation...
        NSLog(@"energy"); //print a message if the login is sent
    
    [socket disconnect]; //disconnect the socket
}

//called when listener successfully reads data
- (void)socket:(GCDAsyncSocket *)sender didReadData:(NSData *)data withTag:(long)tag
{
    //AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSLog(@"derp");
    
    if (tag == ENERGY_RECEIVE_TAG)
    {
        NSString *response = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSLog(@"%@",response);
        //AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSArray *parts = [response componentsSeparatedByString:@"+=+"];
        
        self.dayS = [[parts objectAtIndex:1] stringByTrimmingCharactersInSet: //remove all white spaces/newlines from the yes/no
                           [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.monthS = [[parts objectAtIndex:2] stringByTrimmingCharactersInSet: //remove all white spaces/newlines from the yes/no
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]];;
        self.totalS = [[parts objectAtIndex:3] stringByTrimmingCharactersInSet: //remove all white spaces/newlines from the yes/no
                           [NSCharacterSet whitespaceAndNewlineCharacterSet]];
 
        //self.timeControl.selectedSegmentIndex = 0;
        self.energyLabel.text = [NSString stringWithFormat:@"%@ kWh",self.dayS];
        
        [listener disconnect];
    }
}

//called when data is to be sent to the server for login
- (void)sendRequestToServer:(NSString *)value
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
    
    [socket writeData:daData withTimeout:-1 tag:ENERGY_SEND_TAG]; //write to the host with no timeout
}

//show current settings
- (void)swipeUp:(UISwipeGestureRecognizer *)recognizer
{
    [self performSegueWithIdentifier:@"energyCurrent" sender:self];
}

//move to the app settings page
- (void)swipeLeft:(UISwipeGestureRecognizer *)recognizer
{
    [self performSegueWithIdentifier:@"energySettings" sender:self];
}

//move to the presets page
- (void)swipeRight:(UISwipeGestureRecognizer *)recognizer
{
    [self performSegueWithIdentifier:@"energyPresets" sender:self];
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
    
    //setup the sockets
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    listener = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    
    [self initNetworkCommunication];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.mostRecentView = @"energy";
    
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
    
    //[self sendRequestToServer:@"server+=+getEnergy"]; //retrieve energy usage stats from server
}

- (void)viewDidUnload
{
    [self setPresetsButton:nil];
    [self setSettingsButton:nil];
    [self setEnergyLabel:nil];
    [self setTimeControl:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [presetsButton release];
    [settingsButton release];
    [energyLabel release];
    [timeControl release];
    [super dealloc];
}
- (IBAction)presetsButtonIsPressed:(id)sender {
}

- (IBAction)settingsButtonIsPressed:(id)sender {
}

- (IBAction)timeControlValueIsChanged:(id)sender 
{
    int ind = timeControl.selectedSegmentIndex;
    
    if (ind == 0) { self.energyLabel.text = [NSString stringWithFormat:@"%@ kWh",self.dayS]; }
    else if (ind == 1) { self.energyLabel.text = [NSString stringWithFormat:@"%@ kWh",self.monthS]; }
    else if (ind == 2) { self.energyLabel.text = [NSString stringWithFormat:@"%@ kWh",self.totalS]; }
}
@end
