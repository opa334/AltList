TARGET := iphone:clang:13.0:7.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = AltListTestBundle

AltListTestBundle_FILES = APPRootListController.m
AltListTestBundle_FRAMEWORKS = UIKit
AltListTestBundle_PRIVATE_FRAMEWORKS = Preferences
AltListTestBundle_EXTRA_FRAMEWORKS = AltList
AltListTestBundle_INSTALL_PATH = /Library/PreferenceBundles
AltListTestBundle_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk