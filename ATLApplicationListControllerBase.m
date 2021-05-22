#import "ATLApplicationListControllerBase.h"
#import "CoreServices.h"
#import "LSApplicationProxy+AltList.h"

@interface UIImage (Private)
+ (instancetype)_applicationIconImageForBundleIdentifier:(NSString*)bundleIdentifier format:(int)format scale:(CGFloat)scale;
@end

@implementation ATLApplicationListControllerBase

- (instancetype)init
{
	self = [super init];
	if (dispatch_queue_attr_make_with_qos_class != NULL)
	{
		dispatch_queue_attr_t qos = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, DISPATCH_QUEUE_PRIORITY_BACKGROUND, -1);
		_iconLoadQueue = dispatch_queue_create("com.opa334.AltList.IconLoadQueue", qos);
	}

	_altListBundle = [NSBundle bundleForClass:[ATLApplicationListControllerBase class]];
	[[LSApplicationWorkspace defaultWorkspace] addObserver:self];
	return self;
}

- (instancetype)initWithSections:(NSArray<ATLApplicationSection*>*)applicationSections
{
	self = [self init];
	_applicationSections = applicationSections;
	return self;
}

- (void)dealloc
{
	[[LSApplicationWorkspace defaultWorkspace] removeObserver:self];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	PSSpecifier* specifier = [self specifier];

	NSNumber* useSearchBarNum = [specifier propertyForKey:@"useSearchBar"];
	if(useSearchBarNum)
	{
		self.useSearchBar = [useSearchBarNum boolValue];
	}
	if(self.useSearchBar)
	{
		NSNumber* hideSearchBarWhileScrollingNum = [specifier propertyForKey:@"hideSearchBarWhileScrolling"]; // only on ios 11 and up
		if(hideSearchBarWhileScrollingNum)
		{
			self.hideSearchBarWhileScrolling = [hideSearchBarWhileScrollingNum boolValue];
		}

		NSNumber* includeIdentifiersInSearchNum = [specifier propertyForKey:@"includeIdentifiersInSearch"];
		if(includeIdentifiersInSearchNum)
		{
			self.includeIdentifiersInSearch = [includeIdentifiersInSearchNum boolValue];
		}
	}

	[self _setUpSearchBar];
}

// UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if(self.hideAlphabeticSectionHeaders)
	{
		PSSpecifier* specifier = [self specifierAtIndex:[self indexOfGroup:section]];
		if([[specifier propertyForKey:@"isLetterSection"] boolValue])
		{
			return 0.00000000001;
		}
	}

	return [super tableView:tableView heightForHeaderInSection:section];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if(self.hideAlphabeticSectionHeaders)
	{
		PSSpecifier* specifier = [self specifierAtIndex:[self indexOfGroup:section]];
		if([[specifier propertyForKey:@"isLetterSection"] boolValue])
		{
			return nil;
		}
	}

	return [super tableView:tableView titleForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	if(self.alphabeticIndexingEnabled)
	{
		PSSpecifier* specifier = [self specifierAtIndex:[self indexOfGroup:section]];
		if([[specifier propertyForKey:@"isLetterSection"] boolValue] || [[specifier propertyForKey:@"isFirstLetterSection"] boolValue])
		{
			return 0.00000000001;
		}
	}

	return [super tableView:tableView heightForFooterInSection:section];
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	if(self.hideAlphabeticSectionHeaders)
	{
		PSSpecifier* specifier = [self specifierAtIndex:[self indexOfGroup:section]];
		if([[specifier propertyForKey:@"isLetterSection"] boolValue])
		{
			return nil;
		}
	}

	return [super tableView:tableView titleForFooterInSection:section];
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	if(self.alphabeticIndexingEnabled)
	{
		return [[_specifiersByLetter allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	}
	return nil;
}

// UITableViewDelegate end

// LSApplicationWorkspaceObserverProtocol

- (void)applicationsDidInstall:(id)arg1
{
	[self reloadApplications];
}

- (void)applicationsDidUninstall:(id)arg1
{
	[self reloadApplications];
}

// LSApplicationWorkspaceObserverProtocol end

- (void)setAlphabeticIndexingEnabled:(BOOL)enabled
{
	if(_applicationSections.count == 1)
	{
		_alphabeticIndexingEnabled = enabled;
		return;
	}

	_alphabeticIndexingEnabled = NO;
}

- (void)_setUpSearchBar
{
	if(self.useSearchBar)
	{
		_searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
		_searchController.searchResultsUpdater = self;
		if (@available(iOS 9.1, *)) _searchController.obscuresBackgroundDuringPresentation = NO;
		if (@available(iOS 11.0, *))
		{
			self.navigationItem.searchController = _searchController;
			self.navigationItem.hidesSearchBarWhenScrolling = self.hideSearchBarWhileScrolling;
		}
		else
		{
			self.table.tableHeaderView = _searchController.searchBar;
			[self.table setContentOffset:CGPointMake(0,44) animated:NO];
		}
	}
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		_searchKey = searchController.searchBar.text;
		dispatch_async(dispatch_get_main_queue(), ^(void){
			[self reloadSpecifiers];
		});
	});
}

- (void)_loadSectionsFromSpecifier
{
	NSArray* plistSections = [[self specifier] propertyForKey:@"sections"];
	if(plistSections)
	{
		NSMutableArray* applicationSectionsM = [NSMutableArray new];
		[plistSections enumerateObjectsUsingBlock:^(NSDictionary* dict, NSUInteger idx, BOOL *stop)
		{
			if(![dict isKindOfClass:[NSDictionary class]]) return;
			ATLApplicationSection* section = [ATLApplicationSection applicationSectionWithDictionary:dict];
			[applicationSectionsM addObject:section];
		}];
		_applicationSections = applicationSectionsM.copy;
	}
	else
	{
		_applicationSections = @[[[ATLApplicationSection alloc] initNonCustomSectionWithType:SECTION_TYPE_VISIBLE]];
	}
}

- (void)_populateSections
{
	NSArray<LSApplicationProxy*>* allInstalledApplications = [[LSApplicationWorkspace defaultWorkspace] allInstalledApplications];
	[_applicationSections enumerateObjectsUsingBlock:^(ATLApplicationSection* section, NSUInteger idx, BOOL *stop)
	{
		[section populateFromAllApplications:allInstalledApplications];
	}];
}

- (void)loadPreferences { }

- (void)prepareForPopulatingSections
{
	NSNumber* showIdentifiersAsSubtitleNum = [[self specifier] propertyForKey:@"showIdentifiersAsSubtitle"];
	if(showIdentifiersAsSubtitleNum)
	{
		self.showIdentifiersAsSubtitle = [showIdentifiersAsSubtitleNum boolValue];
	}

	NSNumber* alphabeticIndexingEnabledNum = [[self specifier] propertyForKey:@"alphabeticIndexingEnabled"];
	self.alphabeticIndexingEnabled = [alphabeticIndexingEnabledNum boolValue];
	if(self.alphabeticIndexingEnabled)
	{
		NSNumber* hideAlphabeticSectionHeadersNum = [[self specifier] propertyForKey:@"hideAlphabeticSectionHeaders"];
		self.hideAlphabeticSectionHeaders = [hideAlphabeticSectionHeadersNum boolValue];
	}

	NSString* localizationBundlePathString = [[self specifier] propertyForKey:@"localizationBundlePath"];
	if(localizationBundlePathString)
	{
		self.localizationBundle = [NSBundle bundleWithPath:localizationBundlePathString];
	}
}

- (NSString*)localizedStringForString:(NSString*)string
{
	if(self.localizationBundle)
	{
		NSString* localizedString = [self.localizationBundle localizedStringForKey:string value:nil table:nil];
		if(localizedString)
		{
			return localizedString;
		}
	}

	if(!_altListBundle)
	{
		return string;
	}

	return [_altListBundle localizedStringForKey:string value:string table:nil];
}

- (SEL)getterForSpecifierOfApplicationProxy:(LSApplicationProxy*)applicationProxy
{
	return nil;
}

- (SEL)setterForSpecifierOfApplicationProxy:(LSApplicationProxy*)applicationProxy
{
	return nil;
}

- (PSSpecifier*)createSpecifierForApplicationProxy:(LSApplicationProxy*)applicationProxy
{
	SEL setter = [self setterForSpecifierOfApplicationProxy:applicationProxy];
	SEL getter = [self getterForSpecifierOfApplicationProxy:applicationProxy];

	PSSpecifier* specifier = [PSSpecifier preferenceSpecifierNamed:[applicationProxy atl_nameToDisplay]
		target:self
		set:setter
		get:getter
		detail:nil
		cell:PSStaticTextCell
		edit:nil];

	[specifier setProperty:applicationProxy.bundleIdentifier forKey:@"applicationIdentifier"];

	if(_iconLoadQueue)
	{
		UITableView* tableView = [self valueForKey:@"_table"];
		dispatch_async(_iconLoadQueue, ^{
			UIImage* iconImage = [UIImage _applicationIconImageForBundleIdentifier:applicationProxy.bundleIdentifier format:0 scale:[UIScreen mainScreen].scale];
			dispatch_async(dispatch_get_main_queue(), ^{
				[specifier setProperty:iconImage forKey:@"iconImage"];
				if([self containsSpecifier:specifier])
				{
					NSIndexPath* specifierIndexPath = [self indexPathForIndex:[self indexOfSpecifier:specifier]];
					if([[tableView indexPathsForVisibleRows] containsObject:specifierIndexPath])
					{
						dispatch_async(dispatch_get_main_queue(), ^{
							[self reloadSpecifier:specifier];
						});
					}
				}
			});
		});
	}
	else
	{
		UIImage* iconImage = [UIImage _applicationIconImageForBundleIdentifier:applicationProxy.bundleIdentifier format:0 scale:[UIScreen mainScreen].scale];
		[specifier setProperty:iconImage forKey:@"iconImage"];
	}

	[specifier setProperty:@YES forKey:@"enabled"];

	return specifier;
}

- (BOOL)shouldHideApplicationSpecifiers
{
	if(_searchKey)
	{
		return ![_searchKey isEqualToString:@""];
	}
	return NO;
}

- (BOOL)shouldHideApplicationSpecifier:(PSSpecifier*)specifier
{
	BOOL nameMatch = [specifier.name rangeOfString:_searchKey options:NSCaseInsensitiveSearch range:NSMakeRange(0, [specifier.name length]) locale:[NSLocale currentLocale]].location != NSNotFound;

	BOOL identifierMatch = NO;
	if(self.includeIdentifiersInSearch)
	{
		NSString* applicationID = [specifier propertyForKey:@"applicationIdentifier"];
		identifierMatch = [applicationID rangeOfString:_searchKey options:NSCaseInsensitiveSearch].location != NSNotFound;
	}

	return !identifierMatch && !nameMatch;
}

- (NSArray*)createSpecifiersForApplicationSection:(ATLApplicationSection*)section
{
	NSMutableArray* sectionSpecifiers = [NSMutableArray new];
	[section.applicationsInSection enumerateObjectsUsingBlock:^(LSApplicationProxy* appProxy, NSUInteger idx, BOOL *stop)
	{
		PSSpecifier* appSpecifier = [self createSpecifierForApplicationProxy:appProxy];
		if(appSpecifier)
		{
			[sectionSpecifiers addObject:appSpecifier];
		}
	}];

	return sectionSpecifiers;
}

- (void)populateSpecifiersByLetter
{
	_specifiersByLetter = [NSMutableDictionary new];

	[_specifiers enumerateObjectsUsingBlock:^(PSSpecifier* specifier, NSUInteger idx, BOOL *stop)
	{
		NSString* firstLetter = [specifier.name substringToIndex:1].lowercaseString;
		NSMutableArray* letterSpecifiers = [_specifiersByLetter objectForKey:firstLetter];
		if(!letterSpecifiers)
		{
			letterSpecifiers = [NSMutableArray new];
			[_specifiersByLetter setObject:letterSpecifiers forKey:firstLetter];
		}
		[letterSpecifiers addObject:specifier];
	}];
}

- (NSMutableArray*)specifiersGroupedByLetters
{
	BOOL firstSpecifier = YES;
	NSMutableArray* letterGroupedSpecifiers = [NSMutableArray new];
	for(char c = 'a'; c <= 'z'; c++)
	{
		NSString* cString = [NSString stringWithFormat:@"%c", c];
		NSMutableArray* letterSpecifiers = [_specifiersByLetter objectForKey:cString];
		if(letterSpecifiers)
		{
			PSSpecifier* groupSpecifier = [PSSpecifier emptyGroupSpecifier];
			if(firstSpecifier && self.hideAlphabeticSectionHeaders)
			{
				groupSpecifier.name = [self localizedStringForString:@"Applications"];
				[groupSpecifier setProperty:@YES forKey:@"isFirstLetterSection"];
			}
			else
			{
				groupSpecifier.name = cString;
				[groupSpecifier setProperty:@YES forKey:@"isLetterSection"];
			}
			[letterGroupedSpecifiers addObject:groupSpecifier];
			[letterGroupedSpecifiers addObjectsFromArray:letterSpecifiers];
			firstSpecifier = NO;
		}
	}

	return letterGroupedSpecifiers;
}

- (PSSpecifier*)createGroupSpecifierForApplicationSection:(ATLApplicationSection*)section
{
	PSSpecifier* groupSpecifier = [PSSpecifier emptyGroupSpecifier];
	groupSpecifier.name = [self localizedStringForString:section.sectionName];
	return groupSpecifier;
}

- (void)reloadApplications
{
	_allSpecifiers = nil;
	[self reloadSpecifiers];
}

- (NSMutableArray*)specifiers
{
	if(!_specifiers)
	{
		[self loadPreferences];

		if(!_applicationSections)
		{
			[self _loadSectionsFromSpecifier];
		}

		if(!_allSpecifiers)
		{
			[self prepareForPopulatingSections];
			[self _populateSections];

			_allSpecifiers = [NSMutableArray new];

			[_applicationSections enumerateObjectsUsingBlock:^(ATLApplicationSection* section, NSUInteger idx, BOOL *stop)
			{
				PSSpecifier* groupSpecifier = [self createGroupSpecifierForApplicationSection:section];
				NSArray* specifiersForSection = [self createSpecifiersForApplicationSection:section];
				if(specifiersForSection && specifiersForSection.count > 0)
				{
					if(!self.alphabeticIndexingEnabled)
					{
						[_allSpecifiers addObject:groupSpecifier];
					}
					[_allSpecifiers addObjectsFromArray:specifiersForSection];
				}
			}];
		}

		if(![self shouldHideApplicationSpecifiers])
		{
			_specifiers = _allSpecifiers;
		}
		else
		{
			_specifiers = [NSMutableArray new];
			[_allSpecifiers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PSSpecifier* specifier, NSUInteger idx, BOOL *stop)
			{
				if(specifier.cellType != PSGroupCell)
				{
					// hide specifiers that should be hidden
					if([self shouldHideApplicationSpecifier:specifier])
					{
						return;
					}
				}
				else
				{
					// hide empty sections
					if(_specifiers.count == 0)
					{
						return;
					}
					PSSpecifier* firstSpecifier = _specifiers.firstObject;
					if(firstSpecifier.cellType == PSGroupCell)
					{
						return;
					}
				}

				[_specifiers insertObject:specifier atIndex:0];
			}];
		}

		if(self.alphabeticIndexingEnabled)
		{
			[self populateSpecifiersByLetter];
			_specifiers = [self specifiersGroupedByLetters];
		}
	}

	return _specifiers;
}

- (PSSpecifier*)specifierForApplicationWithIdentifier:(NSString*)applicationID
{
	__block PSSpecifier* specifierToReturn;
	[_specifiers enumerateObjectsUsingBlock:^(PSSpecifier* specifier, NSUInteger idx, BOOL *stop)
	{
		NSString* specifierApplicationID = [specifier propertyForKey:@"applicationIdentifier"];
		if([applicationID isEqualToString:specifierApplicationID])
		{
			specifierToReturn = specifier;
			*stop = YES;
		}
	}];
	return specifierToReturn;
}

- (NSIndexPath*)indexPathForApplicationWithIdentifier:(NSString*)applicationID
{
	PSSpecifier* specifier = [self specifierForApplicationWithIdentifier:applicationID];
	return [self indexPathForIndex:[self indexOfSpecifier:specifier]];
}

@end
