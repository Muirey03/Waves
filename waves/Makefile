include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Waves
Waves_FILES = WVSRootListController.m
Waves_INSTALL_PATH = /Library/PreferenceBundles
Waves_FRAMEWORKS = UIKit
Waves_PRIVATE_FRAMEWORKS = Preferences
Waves_EXTRA_FRAMEWORKS += Cephei CepheiPrefs
Waves_LDFLAGS += -lCSColorPicker
Waves_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Waves.plist$(ECHO_END)
