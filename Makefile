export PREFIX = $(THEOS)/toolchain/Xcode11.xctoolchain/usr/bin/

TARGET := iphone:clang:13.0:7.0

include $(THEOS)/makefiles/common.mk

FRAMEWORK_NAME = AltList

AltList_FILES = AltList.x $(wildcard *.m)
AltList_PUBLIC_HEADERS = ATLApplicationListControllerBase.h ATLApplicationListMultiSelectionController.h ATLApplicationListSelectionController.h ATLApplicationListSubcontroller.h ATLApplicationListSubcontrollerController.h ATLApplicationSection.h ATLApplicationSelectionCell.h ATLApplicationSubtitleCell.h ATLApplicationSubtitleSwitchCell.h LSApplicationProxy+AltList.h
AltList_INSTALL_PATH = /Library/Frameworks
AltList_CFLAGS = -fobjc-arc
AltList_FRAMEWORKS = MobileCoreServices
AltList_PRIVATE_FRAMEWORKS = Preferences
AltList_LOGOSFLAGS = -c generator=internal

include $(THEOS_MAKE_PATH)/framework.mk
ifeq ($(PACKAGE_BUILDNAME),debug)
SUBPROJECTS += AltListTestBundle
endif
include $(THEOS_MAKE_PATH)/aggregate.mk
