#import "ATLApplicationListControllerBase.h"

@interface ATLApplicationListMultiSelectionController : ATLApplicationListControllerBase
{
	NSMutableSet* _selectedApplications;
	BOOL _defaultApplicationSwitchValue;
}
@end