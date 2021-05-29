#import <Foundation/Foundation.h>
#import "ATLApplicationListSubcontroller.h"
#import <Preferences/PSSpecifier.h>

@implementation ATLApplicationListSubcontroller

- (void)setSpecifier:(PSSpecifier*)specifier
{
	[super setSpecifier:specifier];
	self.applicationID = [specifier propertyForKey:@"applicationIdentifier"];
	[self setTitle:specifier.name];
}

- (NSMutableArray*)loadSpecifiersFromPlistName:(NSString*)plistName target:(id)target
{
	NSMutableArray* specifiers = [super loadSpecifiersFromPlistName:plistName target:target];
	if([self.title isEqualToString:@""] || !self.title)
	{
		[self setTitle:[self specifier].name];
	}
	return specifiers;
}

- (void)viewWillDisappear:(BOOL)animated
{
	// auto reload preview string in previous page
	PSListController* topVC = (PSListController*)self.navigationController.topViewController;
	if([topVC respondsToSelector:@selector(reloadSpecifier:)])
	{
		[topVC reloadSpecifier:[self specifier]];
	}
}

@end