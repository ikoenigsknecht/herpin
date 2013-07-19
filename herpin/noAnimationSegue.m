//
//  noAnimationSegue.m
//  lightControlApp
//
//  Created by Ian Koenigsknecht on 4/7/12.
//  Copyright (c) 2012 BU. All rights reserved.
//

#import "noAnimationSegue.h"

@implementation noAnimationSegue

- (void) perform 
{
    // Present the new view controller with no animation
    [self.sourceViewController presentModalViewController:self.destinationViewController animated:NO];
}

@end
