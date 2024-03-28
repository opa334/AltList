ifeq ($(THEOS_PACKAGE_SCHEME),rootless)
TARGET := iphone:clang:16.5:15.0
else
TARGET := iphone:clang:14.5:7.0
endif

include $(THEOS)/makefiles/common.mk

FRAMEWORK_NAME = AltList

AltList_FILES = AltList.x $(wildcard *.m)
AltList_PUBLIC_HEADERS = ATLApplicationListControllerBase.h ATLApplicationListMultiSelectionController.h ATLApplicationListSelectionController.h ATLApplicationListSubcontroller.h ATLApplicationListSubcontrollerController.h ATLApplicationSection.h ATLApplicationSelectionCell.h ATLApplicationSubtitleCell.h ATLApplicationSubtitleSwitchCell.h LSApplicationProxy+AltList.h
AltList_INSTALL_PATH = /Library/Frameworks
AltList_CFLAGS = -fobjc-arc -Wno-tautological-pointer-compare
ifeq ($(THEOS_PACKAGE_SCHEME),rootless)
AltList_LDFLAGS += -install_name @rpath/AltList.framework/AltList
endif
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
