#import "ATLApplicationSubtitleCell.h"

@implementation ATLApplicationSubtitleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier specifier:(PSSpecifier*)specifier
{
	self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier specifier:specifier];
	if(self)
	{
		self.detailTextLabel.text = [specifier propertyForKey:@"applicationIdentifier"];
	}
	return self;
}

@end