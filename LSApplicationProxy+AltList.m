#import "CoreServices.h"
#import "LSApplicationProxy+AltList.h"

@implementation LSApplicationProxy (AltList)

- (BOOL)atl_isSystemApplication
{
	return [self.applicationType isEqualToString:@"System"] && ![self atl_isHidden];
}

- (BOOL)atl_isUserApplication
{
	return [self.applicationType isEqualToString:@"User"] && ![self atl_isHidden];
}

- (BOOL)atl_isHidden
{
	NSArray* appTags;
	if([self respondsToSelector:@selector(correspondingApplicationRecord)])
	{
		// On iOS 14, self.appTags is always empty but the application record still has the correct ones
		LSApplicationRecord* record = [self correspondingApplicationRecord];
		appTags = record.appTags;
	}
	else
	{
		appTags = self.appTags;
	}
	return [appTags containsObject:@"hidden"] || [self.bundleIdentifier containsString:@"com.apple.webapp"];
}

- (NSString*)atl_nameToDisplay
{
	NSString* localizedName = self.localizedName;

	if([self.bundleIdentifier.lowercaseString containsString:@"carplay"])
	{
		if(![localizedName localizedCaseInsensitiveContainsString:@"carplay"])
		{
			return [localizedName stringByAppendingString:@" (CarPlay)"];
		}
	}

	return localizedName;
}

@end