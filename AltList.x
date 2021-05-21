#import "CoreServices.h"
#import "LSApplicationProxy+AltList.h"
#import <version.h>

@interface PSSpecifier
{
@public
    id target;
    SEL getter;
    SEL setter;
}
@end

%group iOSlt9
%hook NSString
%new
- (BOOL)localizedStandardContainsString:(NSString *)str
{
    return [self rangeOfString:str options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch range:NSMakeRange(0, [self length]) locale:[NSLocale currentLocale]].location != NSNotFound;
}
%end //NSString

%hook PSSpecifier
%new
- (BOOL)hasValidGetter
{
    return self->getter != NULL;
}
%new
- (id)performGetter
{
    SEL getter = self->getter;
    if(getter)
    {
        id target = self->target;
        if([target respondsToSelector:getter])
        {
            return [((id (*)(id, SEL, id))[target methodForSelector:getter])(target, getter, self) mutableCopy];
        }
    }
    return nil;
}
%new
- (BOOL)hasValidSetter
{
    return self->setter != NULL;
}
%new
- (void)performSetterWithValue:(id)value
{
    SEL setter = self->setter;
    if(setter)
    {
        id target = self->target;
        if([target respondsToSelector:setter])
        {
            ((void (*)(id, SEL, id, id))[target methodForSelector:setter])(target, setter, value, self);
        }
    }
}
%end //PSSpecifier
%end //iOSlt9

%group iOSlt8
%hook LSApplicationProxy
%new
-(id)bundleIdentifier
{
    return [self applicationIdentifier];
}
%end //LSApplicationProxy

%hook NSString
%new
- (BOOL)localizedCaseInsensitiveContainsString:(NSString *)str
{
    return [self rangeOfString:str options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self length]) locale:[NSLocale currentLocale]].location != NSNotFound;
}
%new
- (BOOL)containsString:(NSString *)str
{
    return [self rangeOfString:str options:0 range:NSMakeRange(0, [self length]) locale:nil].location != NSNotFound;
}
%end //NSString
%end //iOSlt8

//Pre heat display names
%ctor
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
		[[[LSApplicationWorkspace defaultWorkspace] allInstalledApplications] enumerateObjectsUsingBlock:^(LSApplicationProxy* proxy, NSUInteger idx, BOOL *stop)
		{
			[proxy atl_fastDisplayName];
		}];
	});
    if(kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_9_0)
    {
        %init(iOSlt9)
    }
    if(kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_8_0)
    {
        %init(iOSlt8);
    }
}