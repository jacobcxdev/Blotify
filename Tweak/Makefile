FINALPACKAGE = 1
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Blotify
Blotify_FILES = Tweak.xm $(wildcard FRPreferences/*.m)
Blotify_LIBRARIES = colorpicker
Blotify_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Spotify"
