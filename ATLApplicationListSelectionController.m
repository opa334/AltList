#import "ATLApplicationListSelectionController.h"

@interface PSSpecifier()
- (BOOL)hasValidGetter;
- (id)performGetter;
- (BOOL)hasValidSetter;
- (void)performSetterWithValue:(id)value;
@end

@implementation ATLApplicationListSelectionController

- (void)loadPreferences
{
	[super loadPreferences];

	PSSpecifier* specifier = [self specifier];
	if([specifier hasValidGetter])
	{
		_selectedApplicationID = [specifier performGetter];
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

- (PSSpecifier*)createSpecifierForApplicationProxy:(LSApplicationProxy*)applicationProxy
{
	PSSpecifier* specifier = [super createSpecifierForApplicationProxy:applicationProxy];

	if(self.showIdentifiersAsSubtitle)
	{
		[specifier setProperty:NSClassFromString(@"ATLApplicationSubtitleCell") forKey:@"cellClass"];
	}

	return specifier;
}

- (PSTableCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	PSTableCell* tableCell = (PSTableCell*)[super tableView:tableView cellForRowAtIndexPath:indexPath];

	PSSpecifier* specifier = [tableCell specifier];
	NSString* applicationID = [specifier propertyForKey:@"applicationIdentifier"];
	if([_selectedApplicationID isEqualToString:applicationID])
	{
		tableCell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	else
	{
		tableCell.accessoryType = UITableViewCellAccessoryNone;
	}

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

	PSSpecifier* specifier = [self specifier];
	if([specifier hasValidSetter])
	{
		[specifier performSetterWithValue:_selectedApplicationID];
	}
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