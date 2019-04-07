MODULES = jailed
#FINALPACKAGE = 1
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Blotify
DISPLAY_NAME = Blotify
BUNDLE_ID = com.jacobcxdev.blotify

Blotify_FILES = Tweak.xm $(wildcard FRPreferences/*.m)
Blotify_IPA = Spotify-v8.5.0.ipa
Blotify_CFLAGS = -fobjc-arc
#Blotify_USE_FLEX = 1
Blotify_EMBED_LIBRARIES = Resources/Frameworks/libcolorpicker.dylib

include $(THEOS_MAKE_PATH)/tweak.mk
