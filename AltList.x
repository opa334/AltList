#import <Foundation/Foundation.h>
#import "CoreServices.h"
#import "LSApplicationProxy+AltList.h"
#import <mach-o/dyld.h>

NSString *safe_getExecutablePath(void)
{
	char executablePathC[PATH_MAX];
	uint32_t executablePathCSize = sizeof(executablePathC);
	_NSGetExecutablePath(&executablePathC[0], &executablePathCSize);
	return [NSString stringWithUTF8String:executablePathC];
}

//Pre heat display names
%ctor
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[[[LSApplicationWorkspace defaultWorkspace] atl_allInstalledApplications] enumerateObjectsUsingBlock:^(LSApplicationProxy* proxy, NSUInteger idx, BOOL *stop)
		{
			[proxy atl_fastDisplayName];
		}];
	});
}