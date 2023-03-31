ifeq ($(THEOS_PACKAGE_SCHEME),rootless)
TARGET := iphone:clang:16.2:15.0
else
TARGET := iphone:clang:14.5:7.0
endif

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = AltListTestPreferences

AltListTestPreferences_FILES = APPRootListController.m
AltListTestPreferences_FRAMEWORKS = UIKit
AltListTestPreferences_PRIVATE_FRAMEWORKS = Preferences
AltListTestPreferences_EXTRA_FRAMEWORKS = AltList
AltListTestPreferences_INSTALL_PATH = /Library/PreferenceBundles
AltListTestPreferences_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk