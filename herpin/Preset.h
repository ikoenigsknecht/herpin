//
//  Preset.h
//  herpin
//
//  Created by team6 on 2/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//Used to create a Preset object.  Stores all relavent info for a lighting preset.
#import <Foundation/Foundation.h>
#import "FloatHolder.h"

@interface Preset : NSObject
{
    NSString *name;
    BOOL isSetToActive;
    FloatHolder *s1;
    FloatHolder *s2;
    FloatHolder *s3;
    FloatHolder *s4;
    int ID;
}

@property (nonatomic, copy) NSString *name; //name
@property (nonatomic, assign) BOOL isSetToActive; //is the preset in use?
@property (nonatomic, assign) FloatHolder *s1; //settings 1
@property (nonatomic, assign) FloatHolder *s2; //settings 2
@property (nonatomic, assign) FloatHolder *s3; //settings 3
@property (nonatomic, assign) FloatHolder *s4; //settings 4
@property (nonatomic, assign) int ID; //preset id #
-(id)initWithName:(NSString*)n s1:(FloatHolder *)se1 s2:(FloatHolder *)se2 s3:(FloatHolder *)se3 s4:(FloatHolder *)se4 ID:(int)idNum isSetToActive:(BOOL)activeStatus; //initialize the preset with the given data
@end