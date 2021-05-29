#import <Foundation/Foundation.h>
@interface PSSpecifier : NSObject
{
@public
    id target;
    SEL getter;
    SEL setter;
}
- (BOOL)hasValidGetter;
- (id)performGetter;
- (BOOL)hasValidSetter;
- (void)performSetterWithValue:(id)value;
@end
#import "PSSpecifier+AltList.h"

@implementation PSSpecifier (AltList)

- (BOOL)atl_hasValidGetter
{
    if([self respondsToSelector:@selector(hasValidGetter)])
    {
        return [self hasValidGetter];
    }
    else
    {
        if(getter && target)
        {
            return [target respondsToSelector:getter];
        }
        else
        {
            return NO;
        }
    }
}

- (id)atl_performGetter
{
    if([self respondsToSelector:@selector(performGetter)])
    {
        return [self performGetter];
    }
    else
    {
        if([self atl_hasValidGetter])
        {
            return [((id (*)(id, SEL, id))[target methodForSelector:getter])(target, getter, self) mutableCopy];
        }
        return nil;
    }
}

- (BOOL)atl_hasValidSetter
{
    if([self respondsToSelector:@selector(hasValidSetter)])
    {
        return [self hasValidSetter];
    }
    else
    {
        if(setter && target)
        {
            return [target respondsToSelector:setter];
        }
        else
        {
            return NO;
        }
    }
}

- (void)atl_performSetterWithValue:(id)value
{
    if([self respondsToSelector:@selector(performSetterWithValue:)])
    {
        [self performSetterWithValue:value];
    }
    else
    {
        if([self atl_hasValidSetter])
        {
            ((void (*)(id, SEL, id, id))[target methodForSelector:setter])(target, setter, value, self);
        }
    }
}
@end