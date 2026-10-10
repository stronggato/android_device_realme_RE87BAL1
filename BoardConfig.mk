#
# Copyright (C) 2026 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#
DEVICE_PATH := device/generic/RE87BAL1

# For building with minimal manifest
ALLOW_MISSING_DEPENDENCIES := true

# Architecture (AOSP values: combo file is resolved as TARGET_linux-$(TARGET_ARCH),
# then core/combo/arch/$(TARGET_ARCH)/$(TARGET_ARCH_VARIANT).mk must exist.
# Available arm64 profiles in AOSP 12.1: armv8-a, armv8-2a, armv8-2a-dotprod.mk, armv8-a-branchprot.mk)
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 := 
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := generic
# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := vendor_boot
TARGET_NO_BOOTLOADER := true

# Display
TARGET_SCREEN_DENSITY := 480

# Kernel
# NOTE: 12.1 uses BOARD_BOOT_HEADER_VERSION (the old BOARD_BOOTIMG_HEADER_VERSION
# is silently ignored). >= 3 is what enables BUILDING_VENDOR_BOOT_IMAGE.
BOARD_BOOT_HEADER_VERSION := 4
BOARD_KERNEL_BASE := 0x00000000
# Stock vendor_boot vendor_cmdline is "console=ttyS1,115200n8 buildvariant=user".
# build/make passes INTERNAL_KERNEL_CMDLINE (= BOARD_KERNEL_CMDLINE + "buildvariant=...")
# as --vendor_cmdline, so the console part must live here.
BOARD_KERNEL_CMDLINE := console=ttyS1,115200n8
BOARD_KERNEL_PAGESIZE := 4096
BOARD_RAMDISK_OFFSET := 0x05400000
BOARD_KERNEL_TAGS_OFFSET := 0x00000100
BOARD_KERNEL_IMAGE_NAME := Image
# NOTE: BOARD_INCLUDE_DTB_IN_BOOTIMG is deliberately NOT set. It makes build/make
# define INSTALLED_DTBIMAGE_TARGET = $(PRODUCT_OUT)/dtb.img and depend on it, but a
# rule for that file exists only when BOARD_PREBUILT_DTBIMAGE_DIR is set -- and that
# rule only matches *.dtb files. Without it the build dies with
# "No rule to make target .../dtb.img". The dtb is passed directly instead (below),
# which is also what the SPRD twrpdtgen fork does.
TARGET_FORCE_PREBUILT_KERNEL := true
ifeq ($(TARGET_FORCE_PREBUILT_KERNEL),true)
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/kernel
TARGET_PREBUILT_DTB := $(DEVICE_PATH)/prebuilt/dtb.img
endif

# Partitions
BOARD_FLASH_BLOCK_SIZE := 262144
BOARD_BOOTIMAGE_PARTITION_SIZE := 104857600
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 104857600
BOARD_HAS_LARGE_FILESYSTEM := true
BOARD_SYSTEMIMAGE_PARTITION_TYPE := ext4
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_COPY_OUT_VENDOR := vendor

# Recovery-in-vendor_boot (this device has NO recovery partition).
# These three together are what makes 12.1 emit vendor_boot.img with the TWRP
# ramdisk as the vendor ramdisk:
#   BOARD_BOOT_HEADER_VERSION >= 4              -> BUILDING_VENDOR_BOOT_IMAGE := true
#   BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT -> recovery resources go to vendor_boot
#   BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE        -> assert-max-image-size (correct spelling!)
BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 104857600

# mkbootimg gets NO --header_version from build/make for vendor_boot (the recipe is
# only "$(MKBOOTIMG) $(INTERNAL_VENDOR_BOOTIMAGE_ARGS) $(BOARD_MKBOOTIMG_ARGS) ...",
# and INTERNAL_MKBOOTIMG_VERSION_ARGS -- which carries --os_version/--os_patch_level,
# never --header_version -- is not even passed there). So without this the image is
# written as header v0 and the bootloader rejects it.
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)
# DTB lives in the stock vendor_boot (163968 bytes) and must be passed explicitly.
BOARD_MKBOOTIMG_ARGS += --dtb $(TARGET_PREBUILT_DTB)

# Platform
TARGET_BOARD_PLATFORM := ums9230

# Recovery
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
TW_THEME := portrait_hdpi
TW_EXTRA_LANGUAGES := true
TW_SCREEN_BLANK_ON_BOOT := true
TW_INPUT_BLACKLIST := "hbtp_vm"
TW_USE_TOOLBOX := true
# Hack: prevent anti rollback
PLATFORM_SECURITY_PATCH := 2099-12-31
VENDOR_SECURITY_PATCH := 2099-12-31
PLATFORM_VERSION := 12.1.0

