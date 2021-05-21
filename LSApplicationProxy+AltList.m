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
	else if([self respondsToSelector:@selector(appTags)])
	{
		appTags = self.appTags;
	}
	return [appTags containsObject:@"hidden"] || [self.bundleIdentifier containsString:@"com.apple.webapp"];
}

// Getting the display name is slow (up to 2ms) because it uses an IPC call
// this stacks up if you do it for every single application
// This method provides a faster way (around 0.5ms) to get the display name
// This reduces the overall time needed to sort the applications from ~230 to ~120ms on my test device
- (NSString*)atl_fastDisplayName
{
	NSString* cachedDisplayName = [self valueForKey:@"_localizedName"];
	if(cachedDisplayName && ![cachedDisplayName isEqualToString:@""])
	{
		return cachedDisplayName;
	}

	NSBundle* bundle = [NSBundle bundleWithURL:[self valueForKey:@"_bundleURL"]];
	NSString* localizedName;

	localizedName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
	if(!localizedName || [localizedName isEqualToString:@""])
	{ 
		localizedName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
		if(!localizedName || [localizedName isEqualToString:@""])
		{
			localizedName = [bundle objectForInfoDictionaryKey:@"CFBundleExecutable"];
			if(!localizedName || [localizedName isEqualToString:@""])
			{
				//last possible fallback: use slow IPC call
				localizedName = self.localizedName;
			}
		}
	}

	[self setValue:localizedName forKey:@"_localizedName"];
	return localizedName;
}

- (NSString*)atl_nameToDisplay
{
	NSString* localizedName = [self atl_fastDisplayName];//self.localizedName;

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