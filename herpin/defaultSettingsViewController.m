//
//  defaultSettingsViewController.m
//  lightControlApp
//
//  Created by Ian Koenigsknecht on 3/30/12.
//  Copyright (c) 2012 BU. All rights reserved.
//

#import "defaultSettingsViewController.h"
#import "FloatHolder.h"
#import "AppDelegate.h"
#import "Preset.h"

@implementation defaultSettingsViewController
@synthesize lightSelector;
@synthesize RControl;
@synthesize GControl;
@synthesize BControl;
@synthesize YControl;
@synthesize applyButton;
@synthesize cancelButton;
@synthesize saveButton;
@synthesize colorView;
@synthesize stepVal;
@synthesize socket;
@synthesize listener;

float r[4];
float g[4];
float b[4];
float y[4];

UIColor *myColor;

#define PRESET_SEND 1
#define PRESET_RECEIVE 2

- (void)initNetworkCommunication
{
    
}

- (void)socket:(GCDAsyncSocket *)sender didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    NSLog(@"new connection");
    [newSocket readDataWithTimeout:-1 tag:PRESET_RECEIVE];
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
//    if (tag == PRESET_RECEIVE)
//    {
//        NSLog(@"herp receive");
//        NSString *response = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//        NSLog(@"%@",response);
//        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//        NSArray *parts = [response componentsSeparatedByString:@"+=+"];
//        
//        if ([appDelegate.userID isEqualToString:[parts objectAtIndex:1]])
//        {
//            APDocument *pDoc = [[APDocument alloc] initWithString:[parts objectAtIndex:2]];
//            
//            //appDelegate.pDoc = pDoc;
//            //appDelegate.presets = [[NSMutableArray alloc] init];
//            APElement *root = pDoc.rootElement;
//            
//            //int cCount = [root childCount];
//            NSArray *children = [root childElements];
//            
//
//            APElement *child = [children objectAtIndex:0];
//            NSString *name = [child valueForAttributeNamed:@"name"];
//                
//            NSArray *cArray = [child childElements];
//            float rr[4], gg[4], bb[4], yy[4];
//                
//            FloatHolder *h1 = [[FloatHolder alloc] initWithCount:4];
//            FloatHolder *h2 = [[FloatHolder alloc] initWithCount:4];
//            FloatHolder *h3 = [[FloatHolder alloc] initWithCount:4];
//            FloatHolder *h4 = [[FloatHolder alloc] initWithCount:4];
//                
//            for (int j = 0; j < [child childCount]; j++)
//            {
//                rr[j] = [[[cArray objectAtIndex:j] valueForAttributeNamed:@"red"] floatValue];
//                gg[j] = [[[cArray objectAtIndex:j] valueForAttributeNamed:@"green"] floatValue];
//                bb[j] = [[[cArray objectAtIndex:j] valueForAttributeNamed:@"blue"] floatValue];
//                yy[j] = [[[cArray objectAtIndex:j] valueForAttributeNamed:@"yellow"] floatValue];
//            }
//                
//            [h1 setValue:rr[0] atIndex:0];
//            [h1 setValue:gg[0] atIndex:1];
//            [h1 setValue:bb[0] atIndex:2];
//            [h1 setValue:yy[0] atIndex:3];
//                
//            [h2 setValue:rr[1] atIndex:0];
//            [h2 setValue:gg[1] atIndex:1];
//            [h2 setValue:bb[1] atIndex:2];
//            [h2 setValue:yy[1] atIndex:3];
//                
//            [h3 setValue:rr[2] atIndex:0];
//            [h3 setValue:gg[2] atIndex:1];
//            [h3 setValue:bb[2] atIndex:2];
//            [h3 setValue:yy[2] atIndex:3];
//        
//            [h4 setValue:rr[3] atIndex:0];
//            [h4 setValue:gg[3] atIndex:1];
//            [h4 setValue:bb[3] atIndex:2];
//            [h4 setValue:yy[3] atIndex:3];
//                
//            Preset *temp = [[Preset alloc] initWithName:name s1:h1 s2:h2 s3:h3 s4:h4 ID:[[child valueForAttributeNamed:@"id"] intValue] isSetToActive:FALSE];
//            appDelegate.defaultSettings = temp;
//            pDoc = nil; 
//            NSLog(@"done");
//        }
//    }
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
	// Do any additional setup after loading the view.
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    Preset *selectedPreset = appDelegate.defaultSettings;
    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    listener = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    
    [self initNetworkCommunication];
    
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
    
    RControl.value  = r[0];
    GControl.value  = g[0];
    BControl.value  = b[0];
    YControl.value  = y[0];
    
    myColor = [[UIColor alloc] initWithRed:(r[0]/255) green:(g[0]/255) blue:(b[0]/255) alpha:1.0f];
    colorView.backgroundColor = myColor;
    
    stepVal = 5.f;
}

- (void)viewDidUnload
{
    [self setLightSelector:nil];
    [self setRControl:nil];
    [self setGControl:nil];
    [self setBControl:nil];
    [self setYControl:nil];
    [self setApplyButton:nil];
    [self setCancelButton:nil];
    [self setSaveButton:nil];
    [self setColorView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [lightSelector release];
    [RControl release];
    [GControl release];
    [BControl release];
    [YControl release];
    [applyButton release];
    [cancelButton release];
    [saveButton release];
    [colorView release];
    [super dealloc];
}

- (IBAction)lightSelectorValueChanged:(id)sender 
{
    int temp = lightSelector.selectedSegmentIndex;
    
    RControl.value  = r[temp];
    GControl.value  = g[temp];
    BControl.value  = b[temp];
    YControl.value  = y[temp];
    
    myColor = [[UIColor alloc] initWithRed:(r[temp]/255) green:(g[temp]/255) blue:(b[temp]/255) alpha:1.0f];
    colorView.backgroundColor = myColor;
}

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
    
    r[temp]  = RControl.value;
    g[temp]  = GControl.value;
    b[temp]  = BControl.value;
    y[temp]  = YControl.value;
    
    myColor = [[UIColor alloc] initWithRed:(r[temp]/255) green:(g[temp]/255) blue:(b[temp]/255) alpha:1.0f];
    colorView.backgroundColor = myColor;
}

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
    
    myColor = [[UIColor alloc] initWithRed:(r[temp]/255) green:(g[temp]/255) blue:(b[temp]/255) alpha:1.0f];
    colorView.backgroundColor = myColor;
}

- (IBAction)saveButtonIsPressed:(id)sender 
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
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
    
    Preset *temp = [[Preset alloc] initWithName:@"DefaultSettings" s1:s1 s2:s2 s3:s3 s4:s4 ID:1 isSetToActive:false];
    appDelegate.defaultSettings = temp;
    
    APElement *root = [[APElement alloc] initWithName:@"updatePreset"];
    APElement *preset = [[APElement alloc] initWithName:@"preset"];
    //NSString *idNum = [NSString stringWithFormat:@"%i",temp.ID];
    [preset addAttributeNamed:@"id" withValue:@"1"];
    [preset addAttributeNamed:@"name" withValue:@"default"];
    
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
    //[self sendDataToServer:message];
    
    [self performSegueWithIdentifier: @"defaultPresets" sender: self];
}

@end
