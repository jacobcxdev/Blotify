include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ColorifyXI
ColorifyXI_FILES = Tweak.xm $(wildcard FRPreferences/*.m)
ColorifyXI_LIBRARIES = colorpicker

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Spotify"
