#!/bin/bash

# This script converts all SVG files to PNG files and resizes them to 225x225 so they can be used on the board

input_folder="./assets/svg"
output_folder="./assets/png"

mkdir -p "$output_folder"

for svg_file in "$input_folder"/*.svg; do
    base_name=$(basename "$svg_file" .svg)

    inkscape "$svg_file" \
        --export-type="png" \
        --export-width=225 \
        --export-height=225 \
        --export-dpi=300 \
        --export-filename="$output_folder/$base_name.png"

    echo "Converted $svg_file to $output_folder/$base_name.png"
done

echo "All SVGs have been converted to PNGs and resized to 225x225!"
