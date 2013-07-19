//
//  loginInfo.h
//  lightControlApp
//
//  Created by Ian Koenigsknecht on 4/16/12.
//  Copyright (c) 2012 BU. All rights reserved.
//

//This creates a loginInfo object.  Used to store the username and password of the current user.
#import <Foundation/Foundation.h>

@interface loginInfo : NSObject
{
    NSString *username;
    NSString *password;
}

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *password;
-(id)initWithUsername:(NSString *)user password:(NSString *)pass;

@end
