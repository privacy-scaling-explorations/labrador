CC ?= /usr/bin/gcc
RM = /bin/rm

# Directories
SRC_DIR   := src
INC_DIR   := include
TEST_DIR   := test
EXTRA_DIR := extra # Contains extra includes

BUILD_DIR  := build
TEST_BUILD := $(BUILD_DIR)/test

# Source files (wildcard for .S and .c)
SOURCES := $(wildcard $(SRC_DIR)/*.S) $(wildcard $(SRC_DIR)/*.c)
HEADERS := $(wildcard $(INC_DIR)/*.h)

OBJS := $(patsubst $(SRC_DIR)/%.S,$(BUILD_DIR)/src/%.o,$(filter %.S,$(SOURCES))) \
        $(patsubst $(SRC_DIR)/%.c,$(BUILD_DIR)/src/%.o,$(filter %.c,$(SOURCES)))

TEST_SRCS := $(wildcard $(TEST_DIR)/*.c)
TEST_TARGET :=$(patsubst $(TEST_DIR)/%.c,$(TEST_BUILD)/%,$(filter %.c,$(TEST_SRCS)))
TARGET := $(BUILD_DIR)/libdogs.so

# Flags
CFLAGS += -std=c2x -Wall -Wextra -Wmissing-prototypes -Wredundant-decls \
  -Wshadow -Wpointer-arith -Wno-unused-function -flto=auto \
  -fwrapv -march=native -mtune=native -O3

CFLAGS += -iquote ./$(INC_DIR) -iquote ./$(EXTRA_DIR)
TEST_FLAGS = $(CFLAGS) -DTEST


# Build rules
.PHONY: all
all: $(TARGET) $(TEST_TARGET)

.PHONY: test
test: $(TEST_TARGET)

.PHONY: lib
lib: $(TARGET)

$(BUILD_DIR)/src/%.o: $(SRC_DIR)/%.c | $(BUILD_DIR)/src
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/src/%.o: $(SRC_DIR)/%.S | $(BUILD_DIR)/src
	$(CC) -pipe  $(CFLAGS)-c $< -o $@

$(TEST_BUILD)/%: $(TEST_DIR)/%.c  $(OBJS)  | $(TEST_BUILD)
	$(CC) $(TEST_FLAGS)   $^ -o $@ -lm -lgmp -lcrypto

$(TARGET): $(SOURCES)  | $(BUILD_DIR)
	$(CC) -shared -fPIC -fvisibility=hidden $(CFLAGS) $^ -o $@

# Create directories
$(BUILD_DIR) $(BUILD_DIR)/src $(TEST_BUILD):
	mkdir -p $@

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)
