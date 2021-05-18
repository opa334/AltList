#import "ATLApplicationListSubcontrollerController.h"
#import "CoreServices.h"

@implementation ATLApplicationListSubcontrollerController

- (NSString*)previewStringForApplicationWithIdentifier:(NSString*)applicationID
{
	return nil;
}

- (NSString*)_previewStringForSpecifier:(PSSpecifier*)specifier
{
	NSString* previewString = [self previewStringForApplicationWithIdentifier:[specifier propertyForKey:@"applicationIdentifier"]];
	return previewString;
}

- (void)prepareForPopulatingSections
{
	[super prepareForPopulatingSections];
	NSString* subcontrollerClassString = [[self specifier] propertyForKey:@"subcontrollerClass"];
	if(subcontrollerClassString)
	{
		self.subcontrollerClass = NSClassFromString(subcontrollerClassString);
	}
}

- (SEL)getterForSpecifierOfApplicationProxy:(LSApplicationProxy*)applicationProxy
{
	if(!self.showIdentifiersAsSubtitle)
	{
		return @selector(_previewStringForSpecifier:);
	}

	return nil;
}

- (PSSpecifier*)createSpecifierForApplicationProxy:(LSApplicationProxy*)applicationProxy
{
	PSSpecifier* specifier = [super createSpecifierForApplicationProxy:applicationProxy];

	specifier.detailControllerClass = self.subcontrollerClass;
	[specifier setProperty:applicationProxy.bundleIdentifier forKey:@"key"];
	if(self.showIdentifiersAsSubtitle)
	{
		specifier.cellType = PSLinkCell;
		[specifier setProperty:NSClassFromString(@"ATLApplicationSubtitleCell") forKey:@"cellClass"];
	}
	else
	{
		specifier.cellType = PSLinkListCell;
	}

	return specifier;
}

@end