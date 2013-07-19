//
//  loginInfo.m
//  lightControlApp
//
//  Created by Ian Koenigsknecht on 4/16/12.
//  Copyright (c) 2012 BU. All rights reserved.
//

#import "loginInfo.h"

@implementation loginInfo

@synthesize username;
@synthesize password;

-(id)initWithUsername:(NSString *)user password:(NSString *)pass
{
    self.username = user;
    self.password = pass;
    
    return self;
}

@end
