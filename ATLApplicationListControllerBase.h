#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import "ATLApplicationSection.h"

@class LSApplicationProxy;

@interface PSListController()
- (BOOL)containsSpecifier:(PSSpecifier*)specifier;
@end

@protocol LSApplicationWorkspaceObserverProtocol <NSObject>
@optional
-(void)applicationsDidInstall:(id)arg1;
-(void)applicationsDidUninstall:(id)arg1;
@end

@interface ATLApplicationListControllerBase : PSListController <UISearchResultsUpdating, LSApplicationWorkspaceObserverProtocol>
{
	dispatch_queue_t _iconLoadQueue;
	NSMutableArray* _allSpecifiers;
	NSMutableDictionary* _specifiersByLetter;
	NSArray<ATLApplicationSection*>* _applicationSections;
	UISearchController* _searchController;
	NSString* _searchKey;
	BOOL _isPopulated;
	NSBundle* _altListBundle;
}

@property (nonatomic) BOOL useSearchBar;
@property (nonatomic) BOOL hideSearchBarWhileScrolling;
@property (nonatomic) BOOL showIdentifiersAsSubtitle;
@property (nonatomic) BOOL alphabeticIndexingEnabled;
@property (nonatomic) BOOL hideAlphabeticSectionHeaders;
@property (nonatomic) NSBundle* localizationBundle;

- (instancetype)initWithSections:(NSArray<ATLApplicationSection*>*)applicationSections;

- (void)_setUpSearchBar;
- (void)_loadSectionsFromSpecifier;
- (void)_populateSections;

- (void)loadPreferences;
- (void)prepareForPopulatingSections;
- (NSString*)localizedStringForString:(NSString*)string;
- (void)reloadApplications;

- (BOOL)shouldHideApplicationSpecifiers;
- (BOOL)shouldHideApplicationSpecifier:(PSSpecifier*)specifier;

- (PSSpecifier*)createSpecifierForApplicationProxy:(LSApplicationProxy*)applicationProxy;
- (NSArray*)createSpecifiersForApplicationSection:(ATLApplicationSection*)section;
- (PSSpecifier*)createGroupSpecifierForApplicationSection:(ATLApplicationSection*)section;

- (NSMutableArray*)specifiersGroupedByLetters;
- (void)populateSpecifiersByLetter;

- (PSSpecifier*)specifierForApplicationWithIdentifier:(NSString*)applicationID;
- (NSIndexPath*)indexPathForApplicationWithIdentifier:(NSString*)applicationID;

@end