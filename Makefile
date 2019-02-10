MODULES = jailed
#FINALPACKAGE = 1
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ColorifyXI
DISPLAY_NAME = ColorifyXI
BUNDLE_ID = com.jacobcxdev.colorifyxi

ColorifyXI_FILES = Tweak.xm $(wildcard FRPreferences/*.m)
ColorifyXI_IPA = Spotify-v8.4.92.ipa
ColorifyXI_CFLAGS = -fobjc-arc
ColorifyXI_USE_FLEX = 1
ColorifyXI_EMBED_LIBRARIES = Resources/Frameworks/libcolorpicker.dylib

include $(THEOS_MAKE_PATH)/tweak.mk