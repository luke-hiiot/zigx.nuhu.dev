#!/bin/bash

# Transpile .zx files to .zig files
echo "Transpiling .zx files to .zig files..."

# Use a function to process each file to avoid issues with sed on macOS
process_file() {
  input_file="$1"
  output_file="$2"
  
  # Create the output directory if it doesn't exist
  mkdir -p "$(dirname "$output_file")"
  
  # On macOS, need to use different sed syntax
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS uses BSD sed
    sed 's/\.zx"/.zig"/g; s/\.zx)/.zig)/g; s/\.zx\./.zig./g; s/\.zx,/\.zig,/g' "$input_file" > "$output_file"
  else
    # Linux and other systems use GNU sed
    sed 's/\.zx"/.zig"/g; s/\.zx)/.zig)/g; s/\.zx\.//.zig./g; s/\.zx,/\.zig,/g' "$input_file" > "$output_file"
  fi
}

# Find all .zx files and convert them to .zig
find site -name "*.zx" -type f | while read -r file; do
  # Create the corresponding .zig file path
  zig_file="${file%.zx}.zig"
  
  # Process the file
  process_file "$file" "$zig_file"
  
  echo "Transpiled: $file -> $zig_file"
done

echo "Transpilation completed!"