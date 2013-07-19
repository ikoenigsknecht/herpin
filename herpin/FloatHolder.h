//
//  FloatHolder.h
//  lightControlApp
//
//  Thanks to Daniel on stackoverflow.com.
//

#import <Foundation/Foundation.h>

@interface FloatHolder : NSObject {
    int _count;
    float* _values;
}

- (id) initWithCount:(int)count;
- (float)getValueAtIndex:(int)index;
- (void)setValue:(float)value atIndex:(int)index;

@property(readonly) int count;
@property(readonly) float* values; // allows direct unsafe access to the values

@end

