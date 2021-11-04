#import <Foundation/Foundation.h>
#import "ATLApplicationListMultiSelectionController.h"
#import "PSSpecifier+AltList.h"

@implementation ATLApplicationListMultiSelectionController

- (void)loadPreferences
{
	PSSpecifier* specifier = [self specifier];
	if([specifier atl_hasValidGetter])
	{
		_selectedApplications = [NSMutableSet setWithArray:[specifier atl_performGetter]];
	}

	if(!_selectedApplications)
	{
		NSArray* defaultValue = [specifier propertyForKey:@"default"];
		if(defaultValue && [defaultValue isKindOfClass:[NSArray class]])
		{
			_selectedApplications = [NSMutableSet setWithArray:defaultValue];
		}
		else
		{
			_selectedApplications = [NSMutableSet new];
		}
	}
}

- (void)savePreferences
{
	PSSpecifier* specifier = [self specifier];
	if([specifier atl_hasValidSetter])
	{
		[specifier atl_performSetterWithValue:[_selectedApplications allObjects]];
	}
}

- (void)prepareForPopulatingSections
{
	[super prepareForPopulatingSections];
	NSNumber* defaultApplicationValueNum = [[self specifier] propertyForKey:@"defaultApplicationSwitchValue"];
	_defaultApplicationSwitchValue = [defaultApplicationValueNum boolValue];
}

- (void)setApplicationEnabled:(NSNumber*)enabledNum specifier:(PSSpecifier*)specifier
{
	NSString* applicationID = [specifier propertyForKey:@"applicationIdentifier"];
	if([enabledNum boolValue] != _defaultApplicationSwitchValue)
	{
		[_selectedApplications addObject:applicationID];
	}
	else
	{
		[_selectedApplications removeObject:applicationID];
	}

	[self savePreferences];
}

- (id)readApplicationEnabled:(PSSpecifier*)specifier
{
	NSString* applicationID = [specifier propertyForKey:@"applicationIdentifier"];
	BOOL applicationSelected = [_selectedApplications containsObject:applicationID];

	if(applicationSelected)
	{
		return @(!_defaultApplicationSwitchValue);
	}
	
	return @(_defaultApplicationSwitchValue);
}

- (PSCellType)cellTypeForApplicationCells
{
	return PSSwitchCell;
}

- (SEL)getterForSpecifierOfApplicationProxy:(LSApplicationProxy*)applicationProxy
{
	return @selector(readApplicationEnabled:);
}

- (SEL)setterForSpecifierOfApplicationProxy:(LSApplicationProxy*)applicationProxy
{
	return @selector(setApplicationEnabled:specifier:);
}

@end