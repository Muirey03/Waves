GO_EASY_ON_ME=1

ARCHS = armv7 arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Waves
Waves_FILES = $(wildcard *.xm BAFluidView/*.m)
Waves_FRAMEWORKS = UIKit CoreMotion
Waves_CFLAGS = -fobjc-arc
Waves_LDFLAGS += -lCSColorPicker

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += waves
include $(THEOS_MAKE_PATH)/aggregate.mk
