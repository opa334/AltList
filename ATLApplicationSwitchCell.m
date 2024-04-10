#import <Foundation/Foundation.h>
#import "ATLApplicationSwitchCell.h"

#import "ATLApplicationListControllerBase.h"
#import "PSTableCell+AltList.h"

@implementation ATLApplicationSwitchCell

- (void)refreshCellContentsWithSpecifier:(PSSpecifier*)specifier
{
	[super refreshCellContentsWithSpecifier:specifier];
	[self addSearchHighlights];
}

@end