//
//  firstViewController.h
//  herpin
//
//  Created by team6 on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "loginInfo.h"
#import "GCDAsyncSocket.h"

@interface firstViewController : UIViewController <NSStreamDelegate,UITextFieldDelegate,UINavigationControllerDelegate,UINavigationBarDelegate>
{
    UITextField *username; //username entered by user
    UITextField *password; //password entered by user
    UITextField *activeField; //the current textfield
    UIScrollView *scroller; //used to move between textfields when entering username and password
    UIButton *submitButton; //submit button
    loginInfo *login; //the new login object
    GCDAsyncSocket *socket; //used to communicate with the server
    GCDAsyncSocket *listener; //listens for a response from the server on a different port from socket
}

@property (retain, nonatomic) IBOutlet UITextField *username;
@property (retain, nonatomic) IBOutlet UITextField *password;
@property (retain, nonatomic) UITextField *activeField;
@property (retain, nonatomic) IBOutlet UIButton *submitButton;
@property (retain, nonatomic) IBOutlet UIScrollView *scroller;
@property (retain, nonatomic) loginInfo *login;
@property (retain, nonatomic) GCDAsyncSocket *socket;
@property (retain, nonatomic) GCDAsyncSocket *listener;
- (IBAction)pressSubmit:(id)sender; //method for pressing the submit button


@end
