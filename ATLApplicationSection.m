#import <Foundation/Foundation.h>
#import "ATLApplicationSection.h"

@implementation ATLApplicationSection

+ (ApplicationSectionType)sectionTypeFromString:(NSString*)typeString
{
	if([typeString isEqualToString:kApplicationSectionTypeAll])
	{
		return SECTION_TYPE_ALL;
	}
	else if([typeString isEqualToString:kApplicationSectionTypeSystem])
	{
		return SECTION_TYPE_SYSTEM;
	}
	else if([typeString isEqualToString:kApplicationSectionTypeUser])
	{
		return SECTION_TYPE_USER;
	}
	else if([typeString isEqualToString:kApplicationSectionTypeHidden])
	{
		return SECTION_TYPE_HIDDEN;
	}
	else if([typeString isEqualToString:kApplicationSectionTypeVisible])
	{
		return SECTION_TYPE_VISIBLE;
	}

	return SECTION_TYPE_CUSTOM;
}

+ (NSString*)stringFromSectionType:(ApplicationSectionType)sectionType
{
	switch(sectionType)
	{
		case SECTION_TYPE_ALL:
		return kApplicationSectionTypeAll;
		case SECTION_TYPE_SYSTEM:
		return kApplicationSectionTypeSystem;
		case SECTION_TYPE_USER:
		return kApplicationSectionTypeUser;
		case SECTION_TYPE_HIDDEN:
		return kApplicationSectionTypeHidden;
		case SECTION_TYPE_VISIBLE:
		return kApplicationSectionTypeVisible;
		default:
		return kApplicationSectionTypeCustom;
	}
}

+ (NSString*)sectionTitleForNonCustomSectionType:(ApplicationSectionType)sectionType
{
	switch(sectionType)
	{
		case SECTION_TYPE_ALL:
		case SECTION_TYPE_VISIBLE:
		return @"Applications";
		case SECTION_TYPE_SYSTEM:
		return @"System Applications";
		case SECTION_TYPE_USER:
		return @"User Applications";
		case SECTION_TYPE_HIDDEN:
		return @"Hidden Applications";
		default:
		return nil;
	}
}

+ (__kindof ATLApplicationSection*)applicationSectionWithDictionary:(NSDictionary*)sectionDictionary
{
	NSString* customClassString = sectionDictionary[@"customClass"];
	if(customClassString)
	{
		Class customClass = NSClassFromString(customClassString);
		return [[customClass alloc] _initWithDictionary:sectionDictionary];
	}
	else
	{
		return [[ATLApplicationSection alloc] _initWithDictionary:sectionDictionary];
	}
}

- (instancetype)_initWithDictionary:(NSDictionary*)sectionDictionary
{
	NSString* sectionTypeString = sectionDictionary[@"sectionType"];
	if(!sectionTypeString) return nil;

	ApplicationSectionType sectionType = [[self class] sectionTypeFromString:sectionTypeString];

	if(sectionType == SECTION_TYPE_CUSTOM)
	{
		NSString* predicateString = sectionDictionary[@"sectionPredicate"];
		NSPredicate* predicate = [NSPredicate predicateWithFormat:predicateString];
		NSString* sectionName = sectionDictionary[@"sectionName"];
		self = [self initCustomSectionWithPredicate:predicate sectionName:sectionName];
	}
	else
	{
		self = [self initNonCustomSectionWithType:sectionType];
	}

	return self;
}

- (instancetype)initNonCustomSectionWithType:(ApplicationSectionType)sectionType
{
	self = [super init];

	self.sectionType = sectionType;

	return self;
}

- (instancetype)initCustomSectionWithPredicate:(NSPredicate*)predicate sectionName:(NSString*)sectionName
{
	self = [super init];

	self.sectionType = SECTION_TYPE_CUSTOM;
	_customPredicate = predicate;
	_sectionName = sectionName;

	return self;
}

- (void)setSectionType:(ApplicationSectionType)sectionType
{
	_sectionType = sectionType;
	if(_sectionType != SECTION_TYPE_CUSTOM)
	{
		_sectionName = [[self class] sectionTitleForNonCustomSectionType:sectionType];
	}
}

- (NSArray<NSSortDescriptor*>*)sortDescriptorsForApplications
{
	return @[[NSSortDescriptor sortDescriptorWithKey:@"atl_fastDisplayName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
}

- (void)populateFromAllApplications:(NSArray*)allApplications
{
	NSPredicate* predicateToUse;

	switch(_sectionType)
	{
		case SECTION_TYPE_ALL:
		break;

		case SECTION_TYPE_SYSTEM:
		predicateToUse = [NSPredicate predicateWithFormat:@"atl_isSystemApplication == YES"];
		break;

		case SECTION_TYPE_USER:
		predicateToUse = [NSPredicate predicateWithFormat:@"atl_isUserApplication == YES"];
		break;

		case SECTION_TYPE_HIDDEN:
		predicateToUse = [NSPredicate predicateWithFormat:@"atl_isHidden == YES"];
		break;

		case SECTION_TYPE_VISIBLE:
		predicateToUse = [NSPredicate predicateWithFormat:@"atl_isHidden == NO"];
		break;

		default:
		predicateToUse = _customPredicate;
		break;
	}

	NSArray* filteredApplications;
	if(predicateToUse)
	{
		filteredApplications = [allApplications filteredArrayUsingPredicate:predicateToUse];
	}
	else
	{
		filteredApplications = allApplications;
	}

	NSArray* filteredAndSortedApplications = [filteredApplications sortedArrayUsingDescriptors:[self sortDescriptorsForApplications]];
	_applicationsInSection = filteredAndSortedApplications;
}

@end