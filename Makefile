TARGET := iphone:clang:13.7:7.0

include $(THEOS)/makefiles/common.mk

FRAMEWORK_NAME = AltList

AltList_FILES = AltList.x $(wildcard *.m)
AltList_PUBLIC_HEADERS = ATLApplicationListControllerBase.h ATLApplicationListMultiSelectionController.h ATLApplicationListSelectionController.h ATLApplicationListSubcontroller.h ATLApplicationListSubcontrollerController.h ATLApplicationSection.h ATLApplicationSelectionCell.h ATLApplicationSubtitleCell.h ATLApplicationSubtitleSwitchCell.h LSApplicationProxy+AltList.h
AltList_INSTALL_PATH = /Library/Frameworks
AltList_CFLAGS = -fobjc-arc -Wno-tautological-pointer-compare
AltList_FRAMEWORKS = MobileCoreServices
AltList_PRIVATE_FRAMEWORKS = Preferences

after-AltList-stage::
	@ln -s $(THEOS_PACKAGE_INSTALL_PREFIX)/Library/Frameworks/AltList.framework $(THEOS_STAGING_DIR)/Library/PreferenceBundles/AltList.bundle

include $(THEOS_MAKE_PATH)/framework.mk
ifeq ($(PACKAGE_BUILDNAME),debug)
SUBPROJECTS += AltListTestPreferences
SUBPROJECTS += AltListTestBundlelessPreferences
endif
include $(THEOS_MAKE_PATH)/aggregate.mk
