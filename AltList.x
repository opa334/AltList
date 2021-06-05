#import <Foundation/Foundation.h>
#import "CoreServices.h"
#import "LSApplicationProxy+AltList.h"

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