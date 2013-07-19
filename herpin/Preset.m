//
//  Preset.m
//  herpin
//
//  Created by team6 on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Preset.h"
#import "FloatHolder.h"

@implementation Preset

@synthesize name;
@synthesize isSetToActive;
@synthesize s1;
@synthesize s2;
@synthesize s3;
@synthesize s4;
@synthesize ID;

-(id)initWithName:(NSString*)n s1:(FloatHolder *)se1 s2:(FloatHolder *)se2 s3:(FloatHolder *)se3 s4:(FloatHolder *)se4 ID:(int)idNum isSetToActive:(BOOL)activeStatus;
{
    self.name = n;
    self.isSetToActive = activeStatus;
    self.s1 = se1;
    self.s2 = se2;
    self.s3 = se3;
    self.s4 = se4;
    self.ID = idNum;
    return self;
}

@end
