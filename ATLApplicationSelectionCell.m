#import <Foundation/Foundation.h>
#import "ATLApplicationSelectionCell.h"
#import "CoreServices.h"
#import "LSApplicationProxy+AltList.h"

@interface PSTableCell()
- (void)setValue:(id)value;
@end

@implementation ATLApplicationSelectionCell

- (void)setValue:(id)value
{
	if([value isKindOfClass:[NSString class]])
	{
		NSString* strValue = value;
		LSApplicationProxy* appProxy = [LSApplicationProxy applicationProxyForIdentifier:strValue];
		if(appProxy)
		{
			[super setValue:[appProxy atl_nameToDisplay]];
			return;
		}
	}

	[super setValue:value];
}

@end