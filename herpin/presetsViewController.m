//
//  presetsViewController.m
//  herpin
//
//  Created by team6 on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "presetsViewController.h"
#import "editController.h"
#import "AppDelegate.h"
#import "Preset.h"
#import "APXML.h"
#import "FloatHolder.h"
#import "currentSettingsViewController.h"
#import "GCDAsyncSocket.h"

@implementation presetsViewController
@synthesize energyButton;
@synthesize settingsButton;
@synthesize navTitle;
@synthesize editButton;
@synthesize createNewButton;
@synthesize setDefaultButton;
@synthesize manualControlSwitch;
@synthesize manualView;
@synthesize presetTable;
@synthesize refreshButton;
@synthesize delegate;
@synthesize lightSelector;
@synthesize rControl;
@synthesize gControl;
@synthesize bControl;
@synthesize yControl;
@synthesize applyButton;
@synthesize saveButton;
@synthesize colorView;
@synthesize colorContainer;
@synthesize p1;
@synthesize hasBeenSelected;
@synthesize manual;
@synthesize stepVal;
@synthesize socket;
@synthesize socket1;
@synthesize socket2;
@synthesize listener;

float r[5];
float g[5];
float b[5];
float y[5];

UIColor *myColor;
BOOL controlIsDown;

BOOL down[4];

UISwipeGestureRecognizer *swipeLeft;
UISwipeGestureRecognizer *swipeRight;



#define PRESET_FETCH_RECEIVE 0
#define PRESET_FETCH_SEND 1
#define MANUAL_SEND 2
#define MANUAL_SEND1 3
#define MANUAL_SEND2 4
#define FIRST_SEND 10
#define SECOND_SEND 11
#define THIRD_SEND 12
#define FOURTH_SEND 13

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////
//// UITable Functions

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    return appDelegate.presets.count;
}

//create the cell with the preset name, a detail button and the "active" label (if active)
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier] autorelease];
        
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        cell.detailTextLabel.textColor = [UIColor redColor];
        cell.detailTextLabel.text = @"  "; //initialize the "active" label as blank and then determine later if its active or not
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //pull the preset name from the preset array
    p1 = (Preset *)[appDelegate.presets objectAtIndex:indexPath.row];
    cell.textLabel.text = p1.name;
    cell.textLabel.font = [UIFont fontWithName:@"Heiti SC Medium" size:16];
    
    //set the active label accordingly
    if (p1.isSetToActive) { cell.detailTextLabel.text = @"Active"; }
    else { cell.detailTextLabel.text = @"  "; }
    
    cell.backgroundColor = [UIColor whiteColor];
    
    editButton.enabled = TRUE;
    
    return cell;
}

//when selected, the cell shows the preset as active and changes the previously active cell to not active...it also sends this data to the server
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //change the old preset to not active
    if (hasBeenSelected == TRUE)
    {
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath: appDelegate.currentIndex];
        oldCell.detailTextLabel.text = @"  ";
        p1 = (Preset *)[appDelegate.presets objectAtIndex:appDelegate.currentIndex.row];
        p1.isSetToActive = FALSE;
    }
    
    //change all presets to not active if "hasBeenSelected" is not set to TRUE
    else 
    {
        NSArray *cells = [presetTable visibleCells];
        
        for (UITableViewCell *cell in cells)
        {
            if ([cell.detailTextLabel.text isEqualToString:@"Active"])
            {
                cell.detailTextLabel.text = @"  ";
                appDelegate.currentIndex = [presetTable indexPathForCell:cell];
            }
        }
        
        p1 = (Preset *)[appDelegate.presets objectAtIndex:appDelegate.currentIndex.row];
        p1.isSetToActive = FALSE;
    }
    
    //set the selected cell to active
    appDelegate.currentIndex = indexPath;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.detailTextLabel.text = @"Active";
    p1 = (Preset *)[appDelegate.presets objectAtIndex:indexPath.row];
    p1.isSetToActive = TRUE;
    appDelegate.activeSettings = p1;
    
    cell.selected = NO;
    
    //send the data to the server
    NSString *message = [NSString stringWithFormat:@"server+=+activePreset+=+%i\n",p1.ID];
    //[self sendDataToServer:message];
    
    FloatHolder *f1 = p1.s1;
    FloatHolder *f2 = p1.s2;
    
    r[0] = [f1 getValueAtIndex:0];
    g[0] = [f1 getValueAtIndex:1];
    b[0] = [f1 getValueAtIndex:2];
    y[0] = [f1 getValueAtIndex:3];
    
    r[1] = [f2 getValueAtIndex:0];
    g[1] = [f2 getValueAtIndex:1];
    b[1] = [f2 getValueAtIndex:2];
    y[1] = [f2 getValueAtIndex:3];

    r[0] = floorf(r[0]);
    g[0] = floorf(g[0]);
    b[0] = floorf(b[0]);
    y[0] = floorf(y[0]);
    
    NSString *sr1  = [NSString stringWithFormat:@"%03.f",r[0]];
    NSString *sg1  = [NSString stringWithFormat:@"%03.f",g[0]];
    NSString *sb1  = [NSString stringWithFormat:@"%03.f",b[0]];
    NSString *sy1  = [NSString stringWithFormat:@"%03.f",y[0]];

    r[1] = floorf(r[1]);
    g[1] = floorf(g[1]);
    b[1] = floorf(b[1]);
    y[1] = floorf(y[1]);
    
    NSString *sr2  = [NSString stringWithFormat:@"%03.f",r[1]];
    NSString *sg2  = [NSString stringWithFormat:@"%03.f",g[1]];
    NSString *sb2  = [NSString stringWithFormat:@"%03.f",b[1]];
    NSString *sy2  = [NSString stringWithFormat:@"%03.f",y[1]];
    
    NSString *herp = [NSString stringWithFormat:@"r%@\ng%@\nb%@\ny%@\n",sr1,sg1,sb1,sy1];
    NSString *herp1 = [NSString stringWithFormat:@"r%@\ng%@\nb%@\ny%@\n",sr2,sg2,sb2,sy2];
    //[self sendDataToLights:herp :herp1]; //send the color values to the lights
}

//if the user presses the detail button, go to the edit page
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath: (NSIndexPath *) indexPath
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.currentIndex = indexPath;
    
    NSLog(@"The current index is: %d",appDelegate.currentIndex.row);
    
    [self performSegueWithIdentifier:@"pushToEdit" sender:self];
}

//use this to delete cells from the table
- (void) tableView: (UITableView *) tableView commitEditingStyle: (UITableViewCellEditingStyle) editingStyle forRowAtIndexPath: (NSIndexPath *) indexPath 
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    Preset *temp = [appDelegate.presets objectAtIndex:indexPath.row];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) 
    {
        [appDelegate.presets removeObjectAtIndex: indexPath.row];  // manipulate your data structure.
        [tableView deleteRowsAtIndexPaths: [NSArray arrayWithObject: indexPath]
                         withRowAnimation: UITableViewRowAnimationFade];
        
        NSString *message = [NSString stringWithFormat:@"server+=+deletePreset+=+%i\n",temp.ID];
        //[self sendDataToServer:message];
    }
    
    if (appDelegate.presets.count == 0) 
    { 
        [self.presetTable setEditing:NO animated:NO];
        editButton.title = @"Edit";
        editButton.tintColor = [UIColor blackColor];
        editButton.enabled = FALSE; 
    }
}

- (void)reloadTable
{
    [presetTable reloadData];
}

//////////////////////////////////////////////////
//// User Controls Functions

//when the view is set to manual, set the stored values based on user changes
- (IBAction)controlValuesChanged:(id)sender 
{
    int temp = lightSelector.selectedSegmentIndex;
    
    float newR = roundf((rControl.value) / stepVal);
    float newG = roundf((gControl.value) / stepVal);
    float newB = roundf((bControl.value) / stepVal);
    float newY = roundf((yControl.value) / stepVal);
    
    rControl.value = newR * stepVal;
    gControl.value = newG * stepVal;
    bControl.value = newB * stepVal;
    yControl.value = newY * stepVal;
    
    r[temp]  = rControl.value;
    g[temp]  = gControl.value;
    b[temp]  = bControl.value;
    y[temp]  = yControl.value;
    
    myColor = [[UIColor alloc] initWithRed:(r[temp]/255) green:(g[temp]/255) blue:(b[temp]/255) alpha:1.0f];
    colorView.backgroundColor = myColor;
    
    NSLog(@"r:%02f\ng:%02f\nb:%02f\ny:%02f\n",r[temp],g[temp],b[temp],y[temp]);
}

//change pages
- (IBAction)lightSelectorValueChanged:(id)sender 
{
    int temp = lightSelector.selectedSegmentIndex;
    
    rControl.value  = r[temp];
    gControl.value  = g[temp];
    bControl.value  = b[temp];
    yControl.value  = y[temp];
    
    myColor = [[UIColor alloc] initWithRed:(r[temp]/255) green:(g[temp]/255) blue:(b[temp]/255) alpha:1.0f];
    colorView.backgroundColor = myColor;
}

//apply current values to all lights
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

//if the user saves the values, store everything and send the data to the lights
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
        
    Preset *temp = [[Preset alloc] initWithName:@"ManualControl" s1:s1 s2:s2 s3:s3 s4:s4 ID:0 isSetToActive:false];
    
    appDelegate.manualControlSettings = temp;
    
    NSString *herp = [NSString stringWithFormat:@"r%@\ng%@\nb%@\ny%@\n",sr1,sg1,sb1,sy1];
    NSString *herp1 = [NSString stringWithFormat:@"r%@\ng%@\nb%@\ny%@\n",sr2,sg2,sb2,sy2];
    //[self sendDataToLights:herp :herp1];
}

//change the edit button between 'edit' and 'done'
-(IBAction)editButtonIsPressed:(id)sender
{
    if (self.presetTable.isEditing == NO)
    {
        [self.presetTable setEditing:YES animated:YES];
        editButton.title = @"Done";
        editButton.tintColor = [UIColor redColor];
    }
    else
    {
        [self.presetTable setEditing:NO animated:NO];
        editButton.title = @"Edit";
        editButton.tintColor = [UIColor blackColor]; 
    }
    
}

//the user can switch to manual mode which bypasses the presets
- (IBAction)manualControlSwitchIsPressed:(id)sender 
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //hide the table and bring up the manual control view
    if (presetTable.hidden == FALSE)
    {
        presetTable.hidden = TRUE;
        createNewButton.hidden = TRUE;
        setDefaultButton.hidden = TRUE;
        manualView.hidden = FALSE;
        editButton.enabled = FALSE;
        colorContainer.hidden = FALSE;
        navTitle.title = @"Manual Control";
        
        //load the manual settings
        Preset *tempPre = appDelegate.manualControlSettings;
        
        FloatHolder *holder = tempPre.s1;
        r[0]  = [holder getValueAtIndex:0];
        g[0]  = [holder getValueAtIndex:1];
        b[0]  = [holder getValueAtIndex:2];
        y[0]  = [holder getValueAtIndex:3];
        
        holder = tempPre.s2;
        r[1]  = [holder getValueAtIndex:0];
        g[1]  = [holder getValueAtIndex:1];
        b[1]  = [holder getValueAtIndex:2];
        y[1]  = [holder getValueAtIndex:3];
        
        holder = tempPre.s3;
        r[2]  = [holder getValueAtIndex:0];
        g[2]  = [holder getValueAtIndex:1];
        b[2]  = [holder getValueAtIndex:2];
        y[2]  = [holder getValueAtIndex:3];
        
        holder = tempPre.s4;
        r[3]  = [holder getValueAtIndex:0];
        g[3]  = [holder getValueAtIndex:1];
        b[3]  = [holder getValueAtIndex:2];
        y[3]  = [holder getValueAtIndex:3];
        
        rControl.value  = r[0];
        gControl.value  = g[0];
        bControl.value  = b[0];
        yControl.value  = y[0];
        
        myColor = [[UIColor alloc] initWithRed:r[0]/255 green:g[0]/255 blue:b[0]/255 alpha:1.0f];
        colorView.backgroundColor = myColor;
        
        appDelegate.manual = TRUE;
        //[self sendDataToServer:@"server+=+dynamicTrue"];  //tell the server whats going on
    }
    else //if its already in manual mode, return to the presets view and tell the server
    {
        presetTable.hidden = FALSE;
        createNewButton.hidden = FALSE;
        setDefaultButton.hidden = FALSE;
        manualView.hidden = TRUE;
        editButton.enabled = TRUE;
        colorContainer.hidden = TRUE;
        navTitle.title = @"Presets";
        
        appDelegate.manual = FALSE;
        //[self sendDataToServer:@"server+=+dynamicFalse"]; //tell the server whats going on
    }
}

//request the most up to date version of the server data
- (IBAction)refreshButtonIsPressed:(id)sender 
{
    [self requestPresetData];
}

//////////////////////////////////////////////////
//// Network Functions
- (void)initNetworkCommunication
{
    NSError *err = nil;
    NSLog(@"network initialization");
    
    int listenPort = 5000;
    if (![listener acceptOnPort:listenPort error:&err])
    {
        NSLog(@"I dun goofed");
        return;
    }
}

- (void)socket:(GCDAsyncSocket *)sender didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    NSLog(@"new connection");
    [newSocket readDataWithTimeout:-1 tag:PRESET_FETCH_RECEIVE];
    [newSocket disconnectAfterReading];
}

- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"connected");
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    if (tag == MANUAL_SEND)
    {
        [socket disconnect];
    }
    else if (tag == MANUAL_SEND1)
    {
        [socket1 disconnect];
    }
    else if (tag == MANUAL_SEND2)
    {
        [socket2 disconnect];
    }
    else if (tag == PRESET_FETCH_SEND)
    {
        NSLog(@"preset fetch request sent");
        [socket disconnect];
    }
    else if (tag == FIRST_SEND)
    {
        [socket disconnect];
        NSString *host = @"192.168.1.116";
        int port = 5000;
        
        NSError *err = nil;
        if (![socket connectToHost:host onPort:port error:&err]) // Asynchronous!
        {
            // If there was an error, it's likely something like "already connected" or "no delegate set"
            NSLog(@"I goofed: %@", err);
            return;
        }
        
        NSLog(@"first");
    }
    else if (tag == SECOND_SEND)
    {
        [socket disconnect];
        NSString *host = @"192.168.1.116";
        int port = 5000;
        
        NSError *err = nil;
        if (![socket connectToHost:host onPort:port error:&err]) // Asynchronous!
        {
            // If there was an error, it's likely something like "already connected" or "no delegate set"
            NSLog(@"I goofed: %@", err);
            return;
        }
        
        NSLog(@"second");
    }
    else if (tag == THIRD_SEND)
    {
        [socket disconnect];
        NSString *host = @"192.168.1.116";
        int port = 5000;
        
        NSError *err = nil;
        if (![socket connectToHost:host onPort:port error:&err]) // Asynchronous!
        {
            // If there was an error, it's likely something like "already connected" or "no delegate set"
            NSLog(@"I goofed: %@", err);
            return;
        }
        
        NSLog(@"third");
    }
    else if (tag == FOURTH_SEND)
    {
        [socket disconnect];
        NSLog(@"fourth");
    }
}

//this pulls data in from the server and populates the table
- (void)socket:(GCDAsyncSocket *)sender didReadData:(NSData *)data withTag:(long)tag
{
    [listener disconnect];
    if (tag == PRESET_FETCH_RECEIVE)
    {
        NSLog(@"herp receive");
        NSString *response = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSLog(@"%@",response);
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSArray *parts = [response componentsSeparatedByString:@"+=+"];
        
        if ([appDelegate.userID isEqualToString:[parts objectAtIndex:1]])
        {
            APDocument *pDoc = [[APDocument alloc] initWithString:[parts objectAtIndex:2]];
        
            appDelegate.pDoc = pDoc;
            appDelegate.presets = [[NSMutableArray alloc] init];
            APElement *root = pDoc.rootElement;
        
            int cCount = [root childCount];
            NSArray *children = [root childElements];
        
            int current = [[root valueForAttributeNamed:@"active"] intValue];
            for (int i = 0; i < cCount; i++)
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
                
                Preset *temp = [[Preset alloc] initWithName:name s1:h1 s2:h2 s3:h3 s4:h4 ID:[[child valueForAttributeNamed:@"id"] intValue] isSetToActive:FALSE];
                    
                if (temp.ID == current) { temp.isSetToActive = TRUE; }
                [appDelegate.presets addObject:temp];
            }
            pDoc = nil; 
            
            NSLog(@"done");
        }
        [presetTable reloadData];
    }
}

//send data to the server
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
    
    NSString *response = [NSString stringWithFormat:@"%@",value];
    NSData *daData = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
    
    [socket writeData:daData withTimeout:-1 tag:MANUAL_SEND];
    [self initNetworkCommunication];
}

- (void)sendDataToServerTag:(NSString *)value :(int) tag
{
    NSString *response = [NSString stringWithFormat:@"%@",value];
    NSData *daData = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
    
    [socket writeData:daData withTimeout:-1 tag:tag];
    [self initNetworkCommunication];
}

//send data to the lights
- (void)sendDataToLights:(NSString *)value :(NSString *)otherValue
{
    //NSString *host = @"168.122.13.199";
    //NSString *host = @"128.197.180.248";
    NSString *host = @"192.168.1.101";
    int port = 1200;
    
    NSError *err = nil;
    if (![socket2 connectToHost:host onPort:port error:&err]) // Asynchronou
    {
        // If there was an error, it's likely something like "already connected" or "no delegate set"
        NSLog(@"I goofed: %@", err);
        return;
    }
    
    host = @"192.168.1.134";
    
    if (![socket1 connectToHost:host onPort:port error:&err]) // Asynchronou
    {
        // If there was an error, it's likely something like "already connected" or "no delegate set"
        NSLog(@"I goofed: %@", err);
        return;
    }
    
    NSString *response = [NSString stringWithFormat:@"%@\n",value];
    NSData *daData = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
    
    [socket2 writeData:daData withTimeout:-1 tag:MANUAL_SEND2];
    
    response = [NSString stringWithFormat:@"%@\n",otherValue];
    daData = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
    
    [socket1 writeData:daData withTimeout:-1 tag:MANUAL_SEND1];
}

//send a request to the server for the current preset data
- (void)requestPresetData
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
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *request = [NSString stringWithFormat:@"server+=+presetFetch+=+%@\n",appDelegate.userID];
    NSData *myData = [[NSData alloc] initWithData:[request dataUsingEncoding:NSASCIIStringEncoding]];
    
    [socket writeData:myData withTimeout:-1 tag:PRESET_FETCH_SEND];
}

//////////////////////////////////////////////////
//// Gesture Functions

- (IBAction)sliderDown1:(id)sender 
{
    down[0] = TRUE;
    if (down[0] && !down[1] && !down[2] && !down[3])
    {
        [[self view] removeGestureRecognizer:swipeLeft];
        [[self view] removeGestureRecognizer:swipeRight];
    }
}

- (IBAction)sliderUp1:(id)sender 
{
    if (down[0] && !down[1] && !down[2] && !down[3])
    {
        [[self view] addGestureRecognizer:swipeLeft];
        [[self view] addGestureRecognizer:swipeRight];
    }
    down[0] = FALSE;
}

- (IBAction)sliderDown2:(id)sender 
{
    down[1] = TRUE;
    if (!down[0] && down[1] && !down[2] && !down[3])
    {
        [[self view] removeGestureRecognizer:swipeLeft];
        [[self view] removeGestureRecognizer:swipeRight];
    }
}

- (IBAction)sliderUp2:(id)sender 
{
    if (!down[0] && down[1] && !down[2] && !down[3])
    {
        [[self view] addGestureRecognizer:swipeLeft];
        [[self view] addGestureRecognizer:swipeRight];
    }
    down[1] = FALSE;
    NSLog(@"herp");
}

- (IBAction)sliderDown3:(id)sender 
{
    down[2] = TRUE;
    if (!down[0] && !down[1] && down[2] && !down[3])
    {
        [[self view] removeGestureRecognizer:swipeLeft];
        [[self view] removeGestureRecognizer:swipeRight];
    }
}

- (IBAction)sliderUp3:(id)sender 
{
    if (!down[0] && !down[1] && down[2] && !down[3])
    {
        [[self view] addGestureRecognizer:swipeLeft];
        [[self view] addGestureRecognizer:swipeRight];
    }
    down[2] = FALSE;
}

- (IBAction)sliderDown4:(id)sender 
{
    down[3] = TRUE;
    if (!down[0] && !down[1] && !down[2] && down[3])
    {
        [[self view] removeGestureRecognizer:swipeLeft];
        [[self view] removeGestureRecognizer:swipeRight];
    }
}

- (IBAction)sliderUp4:(id)sender 
{
    if (!down[0] && !down[1] && !down[2] && down[3])
    {
        [[self view] addGestureRecognizer:swipeLeft];
        [[self view] addGestureRecognizer:swipeRight];
    }
    down[3] = FALSE;
}

//display the values for the current preset
- (void)swipeUp:(UISwipeGestureRecognizer *)recognizer
{
    [self performSegueWithIdentifier:@"presetsCurrent" sender:self];
}

//move to the energy page
- (void)swipeLeft:(UISwipeGestureRecognizer *)recognizer
{
    [self performSegueWithIdentifier:@"presetsEnergy" sender:self];
}

- (void)swipeRight:(UISwipeGestureRecognizer *)recognizer
{
}

//////////////////////////////////////////////////
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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for (int i = 0; i < 4; i++) { down[i] = FALSE; }
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.mostRecentView = @"presets";
    
    [presetTable setDelegate:self];
    [presetTable setDataSource:self];
    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    socket1 = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    socket2 = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    listener = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    
    //[self initNetworkCommunication];
    
    UISwipeGestureRecognizer *swipeUp = 
    [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUp:)] autorelease];
    [swipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [[self view] addGestureRecognizer:swipeUp];
    
    swipeLeft = 
    [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)] autorelease];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [[self view] addGestureRecognizer:swipeLeft];
    
    swipeRight = 
    [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)] autorelease];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [[self view] addGestureRecognizer:swipeRight];
    
    if (appDelegate.presets.count == 0) { editButton.enabled = FALSE; }
    else { editButton.enabled = TRUE; }
    
    if (appDelegate.manual == TRUE)
    {
        presetTable.hidden = TRUE;
        createNewButton.hidden = TRUE;
        setDefaultButton.hidden = TRUE;
        manualView.hidden = FALSE;
        editButton.enabled = FALSE;
        colorContainer.hidden = FALSE;
        navTitle.title = @"Manual Control";
        manualControlSwitch.on = TRUE;

        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        Preset *tempPre = appDelegate.manualControlSettings;
        
        FloatHolder *holder = tempPre.s1;
        r[0]  = [holder getValueAtIndex:0];
        g[0]  = [holder getValueAtIndex:1];
        b[0]  = [holder getValueAtIndex:2];
        y[0]  = [holder getValueAtIndex:3];
        
        holder = tempPre.s2;
        r[1]  = [holder getValueAtIndex:0];
        g[1]  = [holder getValueAtIndex:1];
        b[1]  = [holder getValueAtIndex:2];
        y[1]  = [holder getValueAtIndex:3];
        
        holder = tempPre.s3;
        r[2]  = [holder getValueAtIndex:0];
        g[2]  = [holder getValueAtIndex:1];
        b[2]  = [holder getValueAtIndex:2];
        y[2]  = [holder getValueAtIndex:3];
        
        holder = tempPre.s4;
        r[3]  = [holder getValueAtIndex:0];
        g[3]  = [holder getValueAtIndex:1];
        b[3]  = [holder getValueAtIndex:2];
        y[3]  = [holder getValueAtIndex:3];
        
        rControl.value  = r[0];
        gControl.value  = g[0];
        bControl.value  = b[0];
        yControl.value  = y[0];
        
        myColor = [[UIColor alloc] initWithRed:r[0]/255 green:g[0]/255 blue:b[0]/255 alpha:1.0f];
        colorView.backgroundColor = myColor;
    }
    else 
    {
        presetTable.hidden = FALSE;
        createNewButton.hidden = FALSE;
        setDefaultButton.hidden = FALSE;
        manualView.hidden = TRUE;
        editButton.enabled = TRUE;
        colorContainer.hidden = TRUE;
        navTitle.title = @"Presets";
    }
    
    stepVal = 5.f;
}


- (void)viewDidUnload
{
    [self setEditButton:nil];
    [self setCreateNewButton:nil];
    [self setPresetTable:nil];
    [self setManualView:nil];
    [self setLightSelector:nil];
    [self setApplyButton:nil];
    [self setSaveButton:nil];
    [self setNavTitle:nil];
    [self setRefreshButton:nil];
    [self setEnergyButton:nil];
    [self setSettingsButton:nil];
    [self setSetDefaultButton:nil];
    [self setColorView:nil];
    [self setColorContainer:nil];
    
    [super viewDidUnload];
    
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
    [editButton release];
    [createNewButton release];
    [presetTable release];
    [manualView release];
    [lightSelector release];
    [rControl release];
    [gControl release];
    [bControl release];
    [yControl release];
    [applyButton release];
    [saveButton release];
    [navTitle release];
    [refreshButton release];
    [energyButton release];
    [settingsButton release];
    [setDefaultButton release];
    [colorView release];
    [colorContainer release];
    [super dealloc];
}
@end
