##
# mksnapshot
# ===================================================
LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

# Set up the target identity
LOCAL_IS_HOST_MODULE := true
LOCAL_MODULE := mksnapshot
LOCAL_MODULE_CLASS := EXECUTABLES
intermediates := $(call local-intermediates-dir)

V8_LOCAL_SRC_FILES :=
V8_LOCAL_JS_LIBRARY_FILES :=
include $(LOCAL_PATH)/Android.v8common.mk

LOCAL_SRC_FILES := $(addprefix v8/, $(V8_LOCAL_SRC_FILES))
LOCAL_SRC_FILES += \
  v8/src/mksnapshot.cc \
  v8/src/arm/simulator-arm.cc \
  v8/src/snapshot-empty.cc

LOCAL_JS_LIBRARY_FILES := $(addprefix $(LOCAL_PATH)/v8/, $(V8_LOCAL_JS_LIBRARY_FILES))

# Generate libraries.cc
GEN2 := $(intermediates)/libraries.cc $(intermediates)/libraries-empty.cc
$(GEN2): SCRIPT := $(LOCAL_PATH)/v8/tools/js2c.py
$(GEN2): $(LOCAL_JS_LIBRARY_FILES)
	@echo "Generating libraries.cc"
	@mkdir -p $(dir $@)
	python $(SCRIPT) $(GEN2) CORE $(LOCAL_JS_LIBRARY_FILES)
LOCAL_GENERATED_SOURCES := $(intermediates)/libraries.cc

LOCAL_CFLAGS := \
	-Wno-endif-labels \
	-Wno-import \
	-Wno-format \
	-ansi \
	-fno-rtti

ifeq ($(TARGET_ARCH),arm)
  LOCAL_CFLAGS += -DV8_TARGET_ARCH_ARM
endif

ifeq ($(TARGET_ARCH),x86)
  LOCAL_CFLAGS += -DV8_TARGET_ARCH_IA32
endif

LOCAL_CFLAGS += -DENABLE_LOGGING_AND_PROFILING

LOCAL_C_INCLUDES := $(LOCAL_PATH)/v8/src

# This is on host.
LOCAL_LDLIBS := -lpthread

include $(BUILD_HOST_EXECUTABLE)
