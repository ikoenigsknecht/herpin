//
//  FloatHolder.m
//  lightControlApp
//
//  Thanks to Daniel on stackoverflow.com
//

#import "FloatHolder.h"


@implementation FloatHolder

@synthesize count = _count;
@synthesize values = _values;

- (id) initWithCount:(int)count {
    self = [super init];
    if (self != nil) {
        _count = count;
        _values = malloc(sizeof(float)*count);
    }
    return self;
}

- (void) dealloc
{
    free(_values);
    
    [super dealloc];
}

- (float)getValueAtIndex:(int)index {
    if(index<0 || index>=_count) {
        @throw [NSException exceptionWithName: @"Exception" reason: @"Index out of bounds" userInfo: nil];
    }
    
    return _values[index];
}

- (void)setValue:(float)value atIndex:(int)index {
    if(index<0 || index>=_count) {
        @throw [NSException exceptionWithName: @"Exception" reason: @"Index out of bounds" userInfo: nil];
    }
    
    _values[index] = value;
}

@end

