#import <Foundation/Foundation.h>
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

// always returns NO on iOS 7
- (BOOL)atl_isHidden
{
	NSArray* appTags;
	NSArray* recordAppTags;

	BOOL launchProhibited = NO;

	if([self respondsToSelector:@selector(correspondingApplicationRecord)])
	{
		// On iOS 14, self.appTags is always empty but the application record still has the correct ones
		LSApplicationRecord* record = [self correspondingApplicationRecord];
		recordAppTags = record.appTags;
		launchProhibited = record.launchProhibited;
	}
	if([self respondsToSelector:@selector(appTags)])
	{
		appTags = self.appTags;
	}
	if(!launchProhibited && [self respondsToSelector:@selector(isLaunchProhibited)])
	{
		launchProhibited = self.launchProhibited;
	}

	BOOL isWebApplication = ([self.atl_bundleIdentifier rangeOfString:@"com.apple.webapp" options:NSCaseInsensitiveSearch].location != NSNotFound);
	return [appTags containsObject:@"hidden"] || [recordAppTags containsObject:@"hidden"] || isWebApplication || launchProhibited;
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

	NSString* localizedName;

	NSURL* bundleURL = [self valueForKey:@"_bundleURL"];
	if(!bundleURL || ![bundleURL checkResourceIsReachableAndReturnError:nil])
	{
		localizedName = self.localizedName;
	}
	else
	{
		NSBundle* bundle = [NSBundle bundleWithURL:bundleURL];

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
	}

	[self setValue:localizedName forKey:@"_localizedName"];
	return localizedName;
}

- (NSString*)atl_nameToDisplay
{
	NSString* localizedName = [self atl_fastDisplayName];

	if([self.atl_bundleIdentifier rangeOfString:@"carplay" options:NSCaseInsensitiveSearch].location != NSNotFound)
	{
		if([localizedName rangeOfString:@"carplay" options:NSCaseInsensitiveSearch range:NSMakeRange(0, localizedName.length) locale:[NSLocale currentLocale]].location == NSNotFound)
		{
			return [localizedName stringByAppendingString:@" (CarPlay)"];
		}
	}

	return localizedName;
}

-(id)atl_bundleIdentifier
{
	// iOS 8-14
	if([self respondsToSelector:@selector(bundleIdentifier)])
	{
		return [self bundleIdentifier];
	}
	// iOS 7
	else
	{
		return [self applicationIdentifier];
	}
}

@end

@implementation LSApplicationWorkspace (AltList)

- (NSArray*)atl_allInstalledApplications
{
	if(![self respondsToSelector:@selector(enumerateApplicationsOfType:block:)])
	{
		return [self allInstalledApplications];
	}

	NSMutableArray* installedApplications = [NSMutableArray new];
	[self enumerateApplicationsOfType:0 block:^(LSApplicationProxy* appProxy)
	{
		[installedApplications addObject:appProxy];
	}];
	[self enumerateApplicationsOfType:1 block:^(LSApplicationProxy* appProxy)
	{
		[installedApplications addObject:appProxy];
	}];
	return installedApplications;
}

@end