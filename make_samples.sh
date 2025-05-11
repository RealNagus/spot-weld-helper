#!/bin/bash
#
# Generate example STL files for common lithium battery cells.
#
# Usage: ./make_samples.sh [cell type or all]
#

SCADFILE=spotweldhelper.scad

if [ -z "$OPENSCAD" ]; then
    OPENSCAD=/usr/bin/openscad
fi

if [ ! -x "$OPENSCAD" ]; then
    echo "Cannot find OpenSCAD"
    exit 1
fi

CELL_TYPE=$1

if [ -z "$CELL_TYPE" ]; then
    CELL_TYPE="all"
fi

if [ "$CELL_TYPE" == "18650" -o "$CELL_TYPE" == "all" ]; then
    echo "Generating samples for 18650 cells"
    outfile=spotweldhelper_sample_5x18650_axis-8mm_int-magnets.stl
    $OPENSCAD -q \
        -D Cell_Diameter=18.3 \
        -D Cell_Height=65 \
        -D Cell_Spacing=18.5 \
        -D Integrate_Magnets=1 \
        -D Number_of_Cells=5 \
        --export-format stl -o $outfile \
        $SCADFILE
    echo -e "\tSample saved to $outfile"

    outfile=spotweldhelper_sample_5x18650_axis-8mm_ext-magnets.stl
    $OPENSCAD -q \
        -D Cell_Diameter=18.3 \
        -D Cell_Height=65 \
        -D Cell_Spacing=18.5 \
        -D Integrate_Magnets=0 \
        -D Number_of_Cells=5 \
        --export-format stl -o $outfile \
        $SCADFILE
    echo -e "\tSample saved to $outfile"
fi

if [ "$CELL_TYPE" == "21700" -o "$CELL_TYPE" == "all" ]; then
    echo "Generating samples for 21700 cells"
    outfile=spotweldhelper_sample_5x21700_axis-8mm_int-magnets.stl
    $OPENSCAD -q \
        -D Cell_Diameter=21.3 \
        -D Cell_Height=70 \
        -D Cell_Spacing=21.5 \
        -D Integrate_Magnets=true \
        -D Number_of_Cells=5 \
        --export-format stl -o $outfile \
        $SCADFILE
    echo -e "\tSample saved to $outfile"

    outfile=spotweldhelper_sample_5x21700_axis-8mm_ext-magnets.stl
    $OPENSCAD -q \
        -D Cell_Diameter=21.3 \
        -D Cell_Height=70 \
        -D Cell_Spacing=21.5 \
        -D Integrate_Magnets=false \
        -D Number_of_Cells=5 \
        --export-format stl -o $outfile \
        $SCADFILE
    echo -e "\tSample saved to $outfile"
fi

if [ "$CELL_TYPE" == "26650" -o "$CELL_TYPE" == "all" ]; then
    echo "Generating samples for 26650 cells"
    outfile=spotweldhelper_sample_5x26650_axis-8mm_int-magnets.stl
    $OPENSCAD -q \
        -D Cell_Diameter=26.3 \
        -D Cell_Height=65 \
        -D Cell_Spacing=26.5 \
        -D Integrate_Magnets=true \
        -D Number_of_Cells=5 \
        --export-format stl -o $outfile \
        $SCADFILE
    echo -e "\tSample saved to $outfile"

    outfile=spotweldhelper_sample_5x26650_axis-8mm_ext-magnets.stl
    $OPENSCAD -q \
        -D Cell_Diameter=26.3 \
        -D Cell_Height=65 \
        -D Cell_Spacing=26.5 \
        -D Integrate_Magnets=false \
        -D Number_of_Cells=5 \
        --export-format stl -o $outfile \
        $SCADFILE
    echo -e "\tSample saved to $outfile"
fi
