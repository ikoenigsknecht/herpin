//
//  firstViewController.m
//  herpin
//
//  Created by team6 on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "firstViewController.h"
#import "APXML.h"
#import "loginInfo.h"
#import "FloatHolder.h"
#import "AppDelegate.h"
#import "GCDAsyncSocket.h"

@implementation firstViewController

@synthesize username;
@synthesize password;
@synthesize activeField;
@synthesize submitButton;
@synthesize scroller;
@synthesize login;
@synthesize socket;
@synthesize listener;

//tags for the socket communcation
#define LOGIN_SEND_TAG 1
#define LOGIN_RECEIVE_TAG 2

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
    [newSocket readDataWithTimeout:-1 tag:LOGIN_RECEIVE_TAG]; //setup an asynchronous read on the new socket with no timeout
}

//called when socket connects to the server
- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"Connected on port %i",port); //output a message
}

//called when socket successfully completes a write
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    if (tag == LOGIN_SEND_TAG) //if the write tag corresponds to our write operation...
        NSLog(@"login sent"); //print a message if the login is sent
    
    [socket disconnect]; //disconnect the socket
}

//called when listener successfully reads data
- (void)socket:(GCDAsyncSocket *)sender didReadData:(NSData *)data withTag:(long)tag
{
    if (tag == LOGIN_RECEIVE_TAG) //if the tag corresponds to our read operation...
    {
        [listener disconnect]; //disconnect listener
        NSLog(@"Data received");
        
        
        //store the data received as a string and split it by '+=+'
        NSString *response = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSLog(response);
        NSArray *parts = [response componentsSeparatedByString:@"+=+"];
        NSString *trimmed = [[parts objectAtIndex:1] stringByTrimmingCharactersInSet: //remove all white spaces/newlines from the yes/no
                                   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        //check if the response is a no or a yes
        if ([trimmed isEqualToString:@"no"])
        {
            //if no, show a popup that informs the user that they entered incorrect information
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                            message:@"Your username or password is incorrect.  Please try again." 
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        else //if the response is a yes...
        {
            //store the last part of the message in an APDocument (since the string is an xml formatted string)
            APDocument *pDoc = [[APDocument alloc] initWithString:[parts objectAtIndex:2]];
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            appDelegate.userID = [parts objectAtIndex:1]; //store the userid
            appDelegate.pDoc = pDoc;
            appDelegate.presets = [[NSMutableArray alloc] init]; //initialize the presets array
            
            //The document that we stored contains an xml file populated by the entirety of the preset table found on server.  Using the APXML library we
            //can parse through the xml document and pull out all of the child elements (which correspond to each preset) and store the data in a more readily
            //usable form (ie the preset array "presets").
            APElement *root = pDoc.rootElement;
            int cCount = [root childCount];
            NSArray *children = [root childElements];
            int current = [[root valueForAttributeNamed:@"active"] intValue];
            
            for (int i = 0; i < cCount; i++)
            {
                //check if the current child element is the "default", which should be stored in its own object
                if (![[[children objectAtIndex:i] valueForAttributeNamed:@"name"] isEqualToString:@"default"])
                {
                    APElement *child = [children objectAtIndex:i];
                    NSString *name = [child valueForAttributeNamed:@"name"];
                    
                    if ([[child valueForAttributeNamed:@"id"] intValue] > appDelegate.idMax) { appDelegate.idMax = [[child valueForAttributeNamed:@"id"] intValue]; }
                
                    NSArray *cArray = [child childElements];
                    float rr[4], gg[4], bb[4], yy[4];
                
                    FloatHolder *h1 = [[FloatHolder alloc] initWithCount:4];
                    FloatHolder *h2 = [[FloatHolder alloc] initWithCount:4];
                    FloatHolder *h3 = [[FloatHolder alloc] initWithCount:4];
                    FloatHolder *h4 = [[FloatHolder alloc] initWithCount:4];
                    
                    for (int j = 0; j < [child childCount]; j++)
                    {
                        rr[j] = [[[cArray objectAtIndex:j] valueForAttributeNamed:@"red"] floatValue];
                        gg[j] = [[[cArray objectAtIndex:j] valueForAttributeNamed:@"green"] floatValue];
                        bb[j] = [[[cArray objectAtIndex:j] valueForAttributeNamed:@"blue"] floatValue];
                        yy[j] = [[[cArray objectAtIndex:j] valueForAttributeNamed:@"yellow"] floatValue];
                    }
                
                    [h1 setValue:rr[0] atIndex:0];
                    [h1 setValue:gg[0] atIndex:1];
                    [h1 setValue:bb[0] atIndex:2];
                    [h1 setValue:yy[0] atIndex:3];
                
                    [h2 setValue:rr[1] atIndex:0];
                    [h2 setValue:gg[1] atIndex:1];
                    [h2 setValue:bb[1] atIndex:2];
                    [h2 setValue:yy[1] atIndex:3];
                
                    [h3 setValue:rr[2] atIndex:0];
                    [h3 setValue:gg[2] atIndex:1];
                    [h3 setValue:bb[2] atIndex:2];
                    [h3 setValue:yy[2] atIndex:3];
                
                    [h4 setValue:rr[3] atIndex:0];
                    [h4 setValue:gg[3] atIndex:1];
                    [h4 setValue:bb[3] atIndex:2];
                    [h4 setValue:yy[3] atIndex:3];
                
                    Preset *temp = [[Preset alloc] initWithName:name s1:h1 s2:h2 s3:h3 s4:h4 ID:[[child valueForAttributeNamed:@"id"] intValue] isSetToActive:FALSE];
                
                    if (temp.ID == current) { temp.isSetToActive = TRUE; }
                    [appDelegate.presets addObject:temp];
                }
                else //store the defualt in the defaultSettings object
                {
                    APElement *child = [children objectAtIndex:i];
                    NSString *name = [child valueForAttributeNamed:@"name"];
                    
                    NSArray *cArray = [child childElements];
                    float rr[4], gg[4], bb[4], yy[4];
                    
                    FloatHolder *h1 = [[FloatHolder alloc] initWithCount:4];
                    FloatHolder *h2 = [[FloatHolder alloc] initWithCount:4];
                    FloatHolder *h3 = [[FloatHolder alloc] initWithCount:4];
                    FloatHolder *h4 = [[FloatHolder alloc] initWithCount:4];
                    
                    for (int j = 0; j < [child childCount]; j++)
                    {
                        rr[j] = [[[cArray objectAtIndex:j] valueForAttributeNamed:@"red"] floatValue];
                        gg[j] = [[[cArray objectAtIndex:j] valueForAttributeNamed:@"green"] floatValue];
                        bb[j] = [[[cArray objectAtIndex:j] valueForAttributeNamed:@"blue"] floatValue];
                        yy[j] = [[[cArray objectAtIndex:j] valueForAttributeNamed:@"yellow"] floatValue];
                    }
                    
                    [h1 setValue:rr[0] atIndex:0];
                    [h1 setValue:gg[0] atIndex:1];
                    [h1 setValue:bb[0] atIndex:2];
                    [h1 setValue:yy[0] atIndex:3];
                    
                    [h2 setValue:rr[1] atIndex:0];
                    [h2 setValue:gg[1] atIndex:1];
                    [h2 setValue:bb[1] atIndex:2];
                    [h2 setValue:yy[1] atIndex:3];
                    
                    [h3 setValue:rr[2] atIndex:0];
                    [h3 setValue:gg[2] atIndex:1];
                    [h3 setValue:bb[2] atIndex:2];
                    [h3 setValue:yy[2] atIndex:3];
                    
                    [h4 setValue:rr[3] atIndex:0];
                    [h4 setValue:gg[3] atIndex:1];
                    [h4 setValue:bb[3] atIndex:2];
                    [h4 setValue:yy[3] atIndex:3];
                    
                    Preset *temp = [[Preset alloc] initWithName:name s1:h1 s2:h2 s3:h3 s4:h4 ID:0 isSetToActive:FALSE];
                    
                    appDelegate.defaultSettings = temp;
                }
            }
            pDoc = nil; //set the aforementioned document to nil
            
            NSLog(@"done"); //print a message letting us know it completed
            
            appDelegate.login = self.login; //set the global login object to the new user's credentials
            
            [self performSegueWithIdentifier:@"loginSegue" sender:self]; //segue to the presets page
        }
    }
}

//called when data is to be sent to the server for login
- (void)sendLoginToServer:(NSString *)value
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
    
    [socket writeData:daData withTimeout:-1 tag:LOGIN_SEND_TAG]; //write to the host with no timeout
    
    NSLog(@"message = %@",value);
}

//// User Controls Functions
//called when the user presses the submit button
- (IBAction)pressSubmit:(id)sender
{
    [sender resignFirstResponder]; //resign the first responder

    //check if the user has entered both username and password.  If not, display a popup asking the user to enter both.
    if ([login.username isEqualToString:@""] || [login.password isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                        message:@"Please enter a username and password." 
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    //If they have entered both, then form the message to be sent to the server and send.
    else
    {
        //create the message with server (so the server knows its meant for it), login (so the server knows what form the message takes), username, password and
        //then the iPhone's IP 
        NSString *message = [NSString stringWithFormat:@"server+=+login+=+%@",username.text];
        message = [message stringByAppendingString:@"+=+"];
        message = [message stringByAppendingString:[NSString stringWithFormat:@"%@",password.text]];
        message = [message stringByAppendingString:[NSString stringWithFormat:@"+=+192.168.1.118"]];
        //[self sendLoginToServer:message]; //send the message
        
        [self performSegueWithIdentifier:@"loginSegue" sender:self];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.login = self.login;
    }
    
    
}

//// Textfield Functions
//called when the keyboard is shown
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField; //set the activefield to the editing textfield
    
    //create the toolbar with next, previous and done buttons on top of the keyboard
    [textField addTarget:self 
                  action:@selector(pressSubmit:) 
        forControlEvents:UIControlEventEditingDidEndOnExit];
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
    toolBar.barStyle = UIBarStyleBlackTranslucent;
    
    NSMutableArray* buttonArray = [[NSMutableArray alloc] initWithCapacity:4];

    UIBarButtonItem *previousButton = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Prev"
                                              style:UIBarButtonItemStyleBordered
                                              target:self 
                                       action:@selector(previousAction:)];
    
    [buttonArray addObject:previousButton];
    [previousButton release];
    
    UIBarButtonItem *nextButton =     [[UIBarButtonItem alloc]
                                              initWithTitle:@"Next"
                                              style:UIBarButtonItemStyleBordered
                                              target:self 
                                              action:@selector(nextAction:)];
    
    [buttonArray addObject:nextButton];
    [nextButton release];
    
    
    UIBarButtonItem *fixedSpace =            [[UIBarButtonItem alloc]   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace 
                                              target:nil 
                                              action:nil];
    fixedSpace.width = 137;
    
    [buttonArray addObject:fixedSpace];
    [fixedSpace release];
    
    UIBarButtonItem *doneButton =     [[UIBarButtonItem alloc]
                                              initWithTitle:@"Done"
                                              style:UIBarButtonItemStyleBordered
                                              target:self 
                                              action:@selector(doneAction:)];
    
    [buttonArray addObject:doneButton];
    [doneButton release];
    
    [toolBar setItems:buttonArray animated:NO];

    username.inputAccessoryView = toolBar;
    password.inputAccessoryView = toolBar;
}

//set username and password when texfields are done editing
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    login.username = username.text;
    login.password = password.text;
    activeField = nil;
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect bkgndRect = activeField.superview.frame;
    
    bkgndRect.size.height += kbSize.height;
    
    [activeField.superview setFrame:bkgndRect];
    
    [scroller setContentOffset:CGPointMake(0.0, activeField.frame.origin.y-(kbSize.height-150)) animated:YES];
}

//called when the keyboard is about to hide
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    
    scroller.contentInset = contentInsets;
    
    scroller.scrollIndicatorInsets = contentInsets;
    
    [scroller setContentOffset:CGPointZero animated:YES];
}

//called when the textfield returns
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    login.username = username.text;
    login.password = password.text;
    [textField resignFirstResponder];
    return YES;
}

//called when the previous button is pressed.  moves to the previous text field
- (void)previousAction:(id)previousButton
{
    if (activeField == username)
    {
    }
    else if (activeField == password)
    {
        [username becomeFirstResponder];
        activeField = username;
    }
}

//called when the next button is pressed.  moves to the next text field.
- (void)nextAction:(id)sender
{
    if (activeField == username)
    {
        [password becomeFirstResponder];
        activeField = password;
    }
    else if (activeField == password)
    {
    }
}

//called when the done butotn is pressed.  closes the keyboard.
- (void)doneAction:(id)sender
{
    if (activeField == username) { [username resignFirstResponder]; }
    else if (activeField == password) { [password resignFirstResponder]; }
    
    login.username = username.text;
    login.password = password.text;
}

//// Other Functions
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

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //setup the sockets
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    listener = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    
    [self initNetworkCommunication]; //initialize the sockets
    username.delegate = self;
    password.delegate = self;
    
    //setup keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWasShown:)
     
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWillBeHidden:)
     
                                                 name:UIKeyboardWillHideNotification object:nil];

    login = [[loginInfo alloc] initWithUsername:@"" password:@""];
    
    //UINavigationBar *navBar = [[UINavigationBar alloc] init];
    //UIBarItem *title = [[UIBarItem alloc] init];
    //title.title = @"Welcome to PILSner";
    self.navigationItem.title = @"Welcome to PILSner";
}

- (void)viewDidUnload
{
    [self setUsername:nil];
    [self setPassword:nil];
    [self setScroller:nil];
    [self setScroller:nil];
    
    [self setSubmitButton:nil];
    [super viewDidUnload];
    
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillShowNotification 
                                                  object:nil]; 
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillHideNotification 
                                                  object:nil];  
    
    [listener disconnect];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:(BOOL)animated];
    
    [listener disconnect];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [scroller release];
    [scroller release];
    [submitButton release];
    [super dealloc];
}

@end
