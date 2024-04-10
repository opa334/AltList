# AltList
A modern AppList alternative

The main focus of this dependency is to be an easy to use and easy to customize framework to handle per app preferences.
Unlike AppLists `ALApplicationList` class, AltList does not have a way to get installed applications yourself, as stock iOS classes like [`LSApplicationWorkspace`](https://developer.limneos.net/?ios=13.1.3&framework=CoreServices.framework&header=LSApplicationWorkspace.h) and [`LSApplicationProxy`](https://developer.limneos.net/?ios=13.1.3&framework=CoreServices.framework&header=LSApplicationProxy.h) (MobileCoreService / CoreServices framework) can already do that. Communication to SpringBoard is not needed for this.

Example uses:
```objc
// get LSApplicationProxy of all installed applications
NSArray<LSApplicationProxy*>* allInstalledApplications = [[LSApplicationWorkspace defaultWorkspace] atl_allInstalledApplications];

// get LSApplicationProxy for one application
LSApplicationProxy* appProxy = [LSApplicationProxy applicationProxyForIdentifier:@"com.yourapp.yourapp"];
```

## Features
* Uses `LSApplicationWorkspace`, not dependent on RocketBootstrap / SpringBoard injection
* Supports search bars
* Supports application sections (similar to AppList)
* Supports alphabetic indexing if only one section is specified
* Doesn't reinvent the wheel
* Supports iOS 7 and up

## Installation
Run [install_to_theos.sh](install_to_theos.sh) and add it to the makefile of your project:
```
<YOUR_PROJECT>_EXTRA_FRAMEWORKS = AltList
```
Then you can import it using `#import <AltList/AltList.h>` or just use the classes below in your preferences plist.

## Documentation

AltList features three `PSListController` subclasses that can be used from your preference bundle or application.
Unlike AppList it is highly customizable, so if you want to adapt something you can just make a subclass and specify that instead.

All classes can be configured via values in your plist.

### Plist-Only approach

For very simple preferences, it is possible to use AltList straight from your entry.plist without implementing any class. For an example check out [AltListTestBundlelessPreferences](AltListTestBundlelessPreferences/layout/Library/PreferenceLoader/Preferences/AltListTestBundlelessPreferences.plist).

### ATLApplicationSection

Just like the original AppList, AltList allows you to specify the sections of applications it should display.

AltList ships with a few stock section types:
* All: All Applications, including hidden ones
* System: System Applications (e.g. App Store, Safari)
* User: User installed applications (e.g. Reddit, Instagram)
* Hidden: Hidden applications (e.g. InCallService, Carplay Settings)
* Visible: All applications that are not hidden (e.g. System and User applications)

The stock section types already have predicates and localized names.
Custom sections are also supported and allow you to specify your own section name and predicate.
If you want your custom section name to be localized: the value you set will be passed to the `localizedStringForString` of your ListController (see below).

| Key                | Type                                           | Fallback | Usage        |
| ------------------ | ------                                         | -------- | ------------ |
| `sectionType`      | String (All/System/User/Hidden/Visible/Custom) | Visible  | Type of the section, see above |
| `sectionName`      | String                                         | @""      | For custom sections, name of the section |
| `sectionPredicate` | String                                         | @""      | For custom sections, predicate to filter the applications, check out the [`LSApplicationProxy` headers](https://developer.limneos.net/?ios=14.4&framework=CoreServices.framework&header=LSApplicationProxy.h) for possible values to use |
| `customClass`      | String                                         | @""      | Custom subclass of `ATLApplicationSection` to use, in case you want to implement even more custom behaviour |

### ATLApplicationListControllerBase

ATLApplicationListControllerBase is the base class inherited by the other classes, it has several features that apply to all classes below.

#### Keys

| Key                            | Type    | Fallback            | Usage        |
| ------------------------------ | ------- | ------------------- | ------------ |
| `sections`                     | Array   | One Visible section | Array of dictionaries that represent the sections in which the applications are shown |
| `useSearchBar`                 | Boolean | false               | Whether there should be a search bar at the top that allows to search for applications [(Example)](.images/1.PNG?raw=true) |
| `hideSearchBarWhileScrolling`  | Boolean | false               | When `useSearchBar` is enabled, whether the search bar should be hidden while scrolling (Always true on iOS 10 and below) [(Example)](.images/2.PNG?raw=true) |
| `includeIdentifiersInSearch`   | Boolean | false               | When `useSearchBar` is enabled, whether it should be possible to search for apps by their identifier. When this is false, it is only possible to search for apps by their name. |
| `highlightSearchText`          | Boolean | false               | When `useSearchBar` is enabled, whether the search text should be highlighted in the application names or identifiers. |
| `showIdentifiersAsSubtitle`    | Boolean | false               | Whether the application identifiers should be shown in the subtitle [(Example)](.images/3.PNG?raw=true) |
| `alphabeticIndexingEnabled`    | Boolean | false               | When there is only one section, whether to section and index it by the starting letters [(Example)](.images/4.PNG?raw=true) |
| `hideAlphabeticSectionHeaders` | Boolean | false               | When `alphabeticIndexingEnabled` is true, whether to hide the sections that contain the first letters [(Example)](.images/5.PNG?raw=true) |
| `localizationBundlePath`       | String  | @""                 | Path to the bundle that should be used for localizing custom section titles |

#### Methods (Can be overwritten by subclasses for customization)

| Method                                                                                     | Purpose      |
| ------------------------------------------------------------------------------------------ | ------------ |
| `- (void)loadPreferences`                                                                  | Load the preference value that the list controller will display |
| `- (void)savePreferences`                                                                  | Save preferences when they have changed |
| `- (void)prepareForPopulatingSections`                                                     | Initialize stuff that needs to be done before the populating starts |
| `- (NSString*)localizedStringForString:(NSString*)string`                                  | Localize string if possible from internal AltList bundle or the localization bundle specified by localizationBundlePath |
| `- (void)reloadApplications`                                                               | Reload applications and specifiers |
| `- (BOOL)shouldHideApplicationSpecifiers`                                                  | Whether any specifier at all should be hidden (internally used for search bar) |
| `- (BOOL)shouldHideApplicationSpecifier:(PSSpecifier*)specifier`                           | Whether the specifier `specifier` should be hidden (internally used for search bar) |
| `- (BOOL)shouldShowSubtitles`                           | Whether subtitles should be shown on the application cells |
| `- (NSString*)subtitleForApplicationWithIdentifier:(NSString*)applicationID`                           | The subtitle that should be displayed in the cell for the specific application that's passed as `applicationID` |
| `- (PSCellType)cellTypeForApplicationCells`                           | Cell type for the application cells |
| `- (Class)customCellClassForCellType:(PSCellType)cellType`                           | Custom cell class for the application cells |
| `- (Class)detailControllerClassForSpecifierOfApplicationProxy:(LSApplicationProxy*)applicationProxy`                           | detailControllerClass to be used by the application specifiers |
| `- (SEL)getterForSpecifierOfApplicationProxy:(LSApplicationProxy*)applicationProxy`                           | getter to be used by the application specifiers |
| `- (SEL)setterForSpecifierOfApplicationProxy:(LSApplicationProxy*)applicationProxy`                           | setter to be used by the application specifiers |
| `- (PSSpecifier*)createSpecifierForApplicationProxy:(LSApplicationProxy*)applicationProxy` | Create a specifier for the application represented by `applicationProxy` |
| `- (NSArray*)createSpecifiersForApplicationSection:(ATLApplicationSection*)section`        | Create the specicifers for a whole application section represented by `section` (Calls the method above) |

### ATLApplicationListSelectionController

ATLApplicationListSelectionController can be used as the detail class of a PSLinkListCell to have a list of applications of which one can be selected.
The selected applications bundle identifier will be saved in the preference domain specified via `defaults` under the specified `key`.
It respects the `get` / `set` attributes so by default it will use the `readPreferenceValue:` and `setPreferenceValue:specifier:` methods of the PSListController that contains the cell for reading / writing the value.
Setting the cellClass to `ATLApplicationSelectionCell` is recommended so the value preview shows the application name instead of the application bundle identifier.

#### Example
```xml
<dict>
	<key>cell</key>
	<string>PSLinkListCell</string>
	<key>detail</key>
	<string>ATLApplicationListSelectionController</string>
	<key>cellClass</key>
	<string>ATLApplicationSelectionCell</string>
	<key>defaults</key>
	<string>com.yourcompany.yourtweakprefs</string>
	<key>key</key>
	<string>(...)</string>
	<key>label</key>
	<string>(...)</string>
	<key>sections</key>
	<array>
		<dict>
			<key>sectionType</key>
			<string>System</string>
		</dict>
		<dict>
			<key>sectionType</key>
			<string>User</string>
		</dict>
	</array>
	<key>useSearchBar</key>
	<true/>
	<key>hideSearchBarWhileScrolling</key>
	<false/>
</dict>
```

### ATLApplicationListMultiSelectionController

ATLApplicationListSelectionController can be used as the detail class of a PSLinkListCell to have a list of applications where each has a switch next to it.
The key `defaultApplicationSwitchValue` can be set to a boolean and will be used as the default value of the application switches.
An array with the application identifiers of the enabled (or disabled when `defaultApplicationSwitchValue` is true) applications will be saved in the preference domain specified via `defaults` under the specified `key`.
It respects the `get` / `set` attributes so by default it will use the `readPreferenceValue:` and `setPreferenceValue:specifier:` methods of the PSListController that contains the cell for reading / writing the value.

#### Keys

| Key                             | Type    | Fallback  | Usage                                     |
| ------------------------------  | ------- | --------- | ----------------------------------------- |
| `defaultApplicationSwitchValue` | Boolean | false     | Default value of the application switches |

#### Example

```xml
<dict>
	<key>cell</key>
	<string>PSLinkListCell</string>
	<key>detail</key>
	<string>ATLApplicationListMultiSelectionController</string>
	<key>defaults</key>
	<string>(...)</string>
	<key>key</key>
	<string>(...)</string>
	<key>label</key>
	<string>(...)</string>
	<key>sections</key>
	<array>
		<dict>
			<key>sectionType</key>
			<string>Visible</string>
		</dict>
		<dict>
			<key>sectionType</key>
			<string>Hidden</string>
		</dict>
	</array>
	<key>showIdentifiersAsSubtitle</key>
	<true/>
	<key>defaultApplicationSwitchValue</key>
	<false/>
	<key>useSearchBar</key>
	<true/>
</dict>
```

### ATLApplicationListSubcontrollerController

ATLApplicationListSubcontrollerController can be used as the detail class of a PSLinkListCell to have one PSListController per application.
The key `subcontrollerClass` is used to specify the PSListController subclass, although you can also subclass `ATLApplicationListSubcontroller` instead which has a convienience method to get the application identifier and also automatically reloads the preview string shown in the application list.
Preview strings are supported but require you to subclass ATLApplicationListSubcontrollerController and use your subclass instead. In your subclass you need to overwrite the `previewStringForApplicationWithIdentifier:` method and return the preview string there.
Preferences also need to be handled in your `PSListController`/`ATLApplicationListSubcontrollerController` subclass, if you want an example for this, check out the [Choicy preferences](https://github.com/opa334/Choicy/blob/master/Preferences/CHPApplicationDaemonConfigurationListController.m).

#### Keys

| Key                  | Type    | Fallback        | Usage                                                              |
| -------------------- | ------- | --------------- | ------------------------------------------------------------------ |
| `subcontrollerClass` | String  | None (Required) | Name of the class that should be used for the application subpages |

#### Example

```xml
<dict>
	<key>cell</key>
	<string>PSLinkListCell</string>
	<key>detail</key>
	<string>ATLApplicationListSubcontrollerController</string>
	<key>subcontrollerClass</key>
	<string>(...)</string>
	<key>label</key>
	<string>(...)</string>
	<key>sections</key>
	<array>
		<dict>
			<key>sectionType</key>
			<string>Visible</string>
		</dict>
		<dict>
			<key>sectionType</key>
			<string>Hidden</string>
		</dict>
	</array>
	<key>showIdentifiersAsSubtitle</key>
	<true/>
	<key>useSearchBar</key>
	<true/>
</dict>
```
