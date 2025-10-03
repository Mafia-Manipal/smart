# Makefile for Smart Irrigation System
# Target: LPC1768 (ARM Cortex-M3)

# Toolchain
CC = arm-none-eabi-gcc
CXX = arm-none-eabi-g++
OBJCOPY = arm-none-eabi-objcopy
SIZE = arm-none-eabi-size

# Target configuration
TARGET = smart_irrigation
MCU = cortex-m3
CPU_FLAGS = -mcpu=$(MCU) -mthumb -mfloat-abi=soft

# Directories
SRC_DIR = .
BUILD_DIR = build
OBJ_DIR = $(BUILD_DIR)/obj

# Source files
SOURCES = smart_irrigation.cpp
OBJECTS = $(SOURCES:%.cpp=$(OBJ_DIR)/%.o)

# Compiler flags
CFLAGS = $(CPU_FLAGS) -Wall -Wextra -O2 -g
CFLAGS += -ffunction-sections -fdata-sections
CFLAGS += -fno-exceptions -fno-rtti
CFLAGS += -D__ARM_FP=0

# Include paths (adjust based on your mbed installation)
INCLUDES = -I.
INCLUDES += -I/usr/local/mbed-sdk/inc
INCLUDES += -I/usr/local/mbed-sdk/inc/platform
INCLUDES += -I/usr/local/mbed-sdk/inc/platform/cmsis

# Linker flags
LDFLAGS = $(CPU_FLAGS) -Wl,--gc-sections
LDFLAGS += -Wl,-Map=$(BUILD_DIR)/$(TARGET).map
LDFLAGS += -T /usr/local/mbed-sdk/targets/TARGET_NXP/TARGET_LPC176X/device/TOOLCHAIN_GCC_ARM/LPC1768.ld

# Libraries (adjust paths as needed)
LIBS = -lm

# Default target
all: $(BUILD_DIR)/$(TARGET).bin

# Create directories
$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Compile source files
$(OBJ_DIR)/%.o: %.cpp | $(OBJ_DIR)
	$(CXX) $(CFLAGS) $(INCLUDES) -c $< -o $@

# Link executable
$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS) | $(BUILD_DIR)
	$(CXX) $(OBJECTS) $(LDFLAGS) $(LIBS) -o $@
	$(SIZE) $@

# Create binary
$(BUILD_DIR)/$(TARGET).bin: $(BUILD_DIR)/$(TARGET).elf
	$(OBJCOPY) -O binary $< $@

# Create hex file
$(BUILD_DIR)/$(TARGET).hex: $(BUILD_DIR)/$(TARGET).elf
	$(OBJCOPY) -O ihex $< $@

# Clean build files
clean:
	rm -rf $(BUILD_DIR)

# Flash to target (requires OpenOCD or similar)
flash: $(BUILD_DIR)/$(TARGET).bin
	openocd -f interface/cmsis-dap.cfg -f target/lpc1768.cfg -c "program $(BUILD_DIR)/$(TARGET).bin 0x0 verify reset exit"

# Debug with GDB
debug: $(BUILD_DIR)/$(TARGET).elf
	arm-none-eabi-gdb $(BUILD_DIR)/$(TARGET).elf

# Show help
help:
	@echo "Available targets:"
	@echo "  all     - Build the project (default)"
	@echo "  clean   - Remove build files"
	@echo "  flash   - Flash to target (requires OpenOCD)"
	@echo "  debug   - Start GDB debug session"
	@echo "  help    - Show this help"

# Phony targets
.PHONY: all clean flash debug help

# Dependencies
$(OBJ_DIR)/smart_irrigation.o: smart_irrigation.cpp
