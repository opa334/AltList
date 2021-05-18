#import "ATLApplicationListMultiSelectionController.h"

#import <Preferences/PSSpecifier.h>
@interface PSSpecifier()
- (BOOL)hasValidGetter;
- (id)performGetter;
- (BOOL)hasValidSetter;
- (void)performSetterWithValue:(id)value;
@end

@implementation ATLApplicationListMultiSelectionController

- (void)loadPreferences
{
	PSSpecifier* specifier = [self specifier];
	if([specifier hasValidGetter])
	{
		_selectedApplications = [NSMutableSet setWithArray:[specifier performGetter]];
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

	PSSpecifier* mainSpecifier = [self specifier];
	if([mainSpecifier hasValidSetter])
	{
		[mainSpecifier performSetterWithValue:[_selectedApplications allObjects]];
	}
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

- (SEL)getterForSpecifierOfApplicationProxy:(LSApplicationProxy*)applicationProxy
{
	return @selector(readApplicationEnabled:);
}

- (SEL)setterForSpecifierOfApplicationProxy:(LSApplicationProxy*)applicationProxy
{
	return @selector(setApplicationEnabled:specifier:);
}

- (PSSpecifier*)createSpecifierForApplicationProxy:(LSApplicationProxy*)applicationProxy
{
	PSSpecifier* specifier = [super createSpecifierForApplicationProxy:applicationProxy];
	specifier.cellType = PSSwitchCell;
	if(self.showIdentifiersAsSubtitle)
	{
		[specifier setProperty:NSClassFromString(@"ATLApplicationSubtitleSwitchCell") forKey:@"cellClass"];
	}
	return specifier;
}

@end