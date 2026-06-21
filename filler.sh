#!/bin/bash

# Configuration
TARGET_DIR="./fill_test"
FILE_COUNT=10
FILE_SIZE="100M"

# Create the directory if it does not exist
mkdir -p "$TARGET_DIR"

echo "Creating $FILE_COUNT files of size $FILE_SIZE in $TARGET_DIR..."

# Loop to generate files
for i in $(seq -w 1 $FILE_COUNT); do
    dd if=/dev/urandom of="$TARGET_DIR/dummy_file_$i.bin" bs=$FILE_SIZE count=1 status=none
    echo "Created file $i of $FILE_COUNT"
done

echo "Done! Directory filled."

