#import <Foundation/Foundation.h>
#import "ATLApplicationListSelectionController.h"
#import "PSSpecifier+AltList.h"

@interface PSTableCell()
- (void)setChecked:(BOOL)checked;
@end

@implementation ATLApplicationListSelectionController

- (void)loadPreferences
{
	PSSpecifier* specifier = [self specifier];
	if([specifier atl_hasValidGetter])
	{
		_selectedApplicationID = [specifier atl_performGetter];
	}
	if(!_selectedApplicationID)
	{
		NSString* defaultValue = [specifier propertyForKey:@"default"];
		if(defaultValue && [defaultValue isKindOfClass:[NSString class]])
		{
			_selectedApplicationID = defaultValue;
		}
	}
}

- (void)savePreferences
{
	PSSpecifier* specifier = [self specifier];
	if([specifier atl_hasValidSetter])
	{
		[specifier atl_performSetterWithValue:_selectedApplicationID];
	}
}

- (PSTableCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	PSTableCell* tableCell = (PSTableCell*)[super tableView:tableView cellForRowAtIndexPath:indexPath];

	PSSpecifier* specifier = [tableCell specifier];
	NSString* applicationID = [specifier propertyForKey:@"applicationIdentifier"];

	[tableCell setChecked:[_selectedApplicationID isEqualToString:applicationID]];

	return tableCell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	if(_selectedApplicationID)
	{
		//deselect previously selected application if visible
		NSIndexPath* previousIndexPath = [self indexPathForApplicationWithIdentifier:_selectedApplicationID];
		if([[tableView indexPathsForVisibleRows] containsObject:previousIndexPath])
		{
			[tableView cellForRowAtIndexPath:previousIndexPath].accessoryType = UITableViewCellAccessoryNone;
		}
	}

	PSSpecifier* specifierOfCell = [self specifierAtIndex:[self indexForIndexPath:indexPath]];
	_selectedApplicationID = [specifierOfCell propertyForKey:@"applicationIdentifier"];

	[tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;

	[self savePreferences];
}

- (void)viewWillDisappear:(BOOL)animated
{
	PSListController* topVC = (PSListController*)self.navigationController.topViewController;
	if([topVC respondsToSelector:@selector(reloadSpecifier:)])
	{
		[topVC reloadSpecifier:[self specifier]];
	}
}

@end