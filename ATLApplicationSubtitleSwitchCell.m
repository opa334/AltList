#import <Foundation/Foundation.h>
#import "ATLApplicationSubtitleSwitchCell.h"

#import "ATLApplicationListControllerBase.h"

@implementation ATLApplicationSubtitleSwitchCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier specifier:(PSSpecifier*)specifier
{
	return [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier specifier:specifier];
}

- (void)refreshCellContentsWithSpecifier:(PSSpecifier*)specifier
{
	[super refreshCellContentsWithSpecifier:specifier];
	id target = specifier.target;
	if([target respondsToSelector:@selector(_subtitleForSpecifier:)])
	{
		self.detailTextLabel.text = [(ATLApplicationListControllerBase*)target _subtitleForSpecifier:specifier];
	}
}

@end