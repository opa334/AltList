#import <Foundation/Foundation.h>
#import "ATLApplicationCell.h"

#import "ATLApplicationListControllerBase.h"
#import "PSTableCell+AltList.h"

@implementation ATLApplicationCell

- (void)refreshCellContentsWithSpecifier:(PSSpecifier*)specifier
{
	[super refreshCellContentsWithSpecifier:specifier];
	[self addSearchHighlights];
}

@end