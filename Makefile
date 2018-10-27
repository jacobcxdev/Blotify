MODULES = jailed
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ColorifyXI
DISPLAY_NAME = ColorifyXI
BUNDLE_ID = com.jacobcxdev.ColorifyXI

ColorifyXI_FILES = Tweak.xm $(wildcard FRPreferences/*.m)
ColorifyXI_IPA = Spotify-v8.4.77.ipa
ColorifyXI_USE_FLEX = 1
ColorifyXI_EMBED_LIBRARIES = Resources/Frameworks/libcolorpicker.dylib

include $(THEOS_MAKE_PATH)/tweak.mk