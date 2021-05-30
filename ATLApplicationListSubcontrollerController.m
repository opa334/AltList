#import <Foundation/Foundation.h>
#import "ATLApplicationListSubcontrollerController.h"
#import "CoreServices.h"
#import "LSApplicationProxy+AltList.h"

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
	return @selector(_previewStringForSpecifier:);
}

- (PSCellType)cellTypeForApplicationCells
{
	return PSLinkListCell;
}

- (Class)detailControllerClassForSpecifierOfApplicationProxy:(LSApplicationProxy*)applicationProxy
{
	return self.subcontrollerClass;
}

@end