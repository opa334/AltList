ifeq ($(THEOS_PACKAGE_SCHEME),rootless)
TARGET := iphone:clang:16.2:15.0
else
TARGET := iphone:clang:14.5:7.0
endif

include $(THEOS)/makefiles/common.mk

include $(THEOS_MAKE_PATH)/bundle.mk
