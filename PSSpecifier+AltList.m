#import "PSSpecifier.h"
#import "PSSpecifier+AltList.h"
#import <version.h>

@implementation PSSpecifier (AltList)

- (BOOL)atl_hasValidGetter
{
    if(IS_IOS_OR_NEWER(iOS_9_0))
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
    if(IS_IOS_OR_NEWER(iOS_9_0))
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
    if(IS_IOS_OR_NEWER(iOS_9_0))
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
    if(IS_IOS_OR_NEWER(iOS_9_0))
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