/**********************************************************************

  Battery cell spot welding helper - v0.1
  (c) 2025 by Thomas Heßling <mail@dream-dimensions.de>
 

  Redistribution and use in source and binary forms, with or without 
  modification, are permitted provided that the following conditions 
  are met:
 
    1. Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.
 
    2. Redistributions in binary form must reproduce the above 
       copyright notice, this list of conditions and the following 
       disclaimer in the documentation and/or other materials provided
       with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY 
  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

**********************************************************************/

/* [Cell parameters] */

// Numnber of cells in a row
Number_of_Cells = 5; // [2:1:12]

// Cell diameter in mm
Cell_Diameter = 18.3; // 0.1
// Cell height in mm
Cell_Height = 65; // 0.1

// Cell spacing in mm
Cell_Spacing = 18.5; // 0.1


/* [Magnet parameters] */

// Insert magnets to hold the cells?
Use_Magnets = true;

// Integrated magnets must be inserted during print.
Integrate_Magnets = true;

// Magnet 1 Width in mm
Magnet_1_Width = 10.0; // 0.1
// Magnet 1 Height in mm
Magnet_1_Height = 20.0; // 0.1
// Magnet 1 Depth in mm
Magnet_1_Depth = 3.0; // 0.1

// Magnet 2 Width in mm
Magnet_2_Width = 6.0; // 0.1
// Magnet 2 Height
Magnet_2_Height = 20; // 0.1
// Magnet 2 Depth
Magnet_2_Depth = 2; // 0.1



/* [General dimensions] */

// Use guide axes?
Use_Axis_Guides = true;

// Guide axis diameter in mm
Axis_Diameter = 8; // 0.1

// Base width in mm
Base_Width = 30.0; // 0.1


/* [Tolerances] */

// Basic Tolerance to use in mm
Tol = 0.1; // 0.1

// Your 3D printer's extrusion width
Extrusion_Width = 0.4; // [0.25:0.05:1.0]

// Minimum number of extrusion lines on thin walls
Min_Wall_Lines = 4; // [2:1:10]

// Large bevel width for the base in mm
Bevel_Large = 5.0; // 0.1

// Small bevel width for edges in mm
Bevel_Small = 1.0; // 0.1


// ************ INTERNAL VARIABLES ************
module __Customizer_Limit__ () {}
$fa=1;
$fs=0.1;


// calculated variables
cell_cut_diameter = Cell_Diameter + 0.5;
min_edge_len = Min_Wall_Lines * Extrusion_Width;
base_offset_x = Cell_Spacing / 2 + min_edge_len;
base_offset_y = sqrt((cell_cut_diameter/2)^2 - (Cell_Spacing/2 - min_edge_len/3)^2);

base_width = (Number_of_Cells) * Cell_Spacing + 2 * min_edge_len;
base_height = Cell_Height - 5;

// round base depth to the next integer multiple of 3
tmp = (Cell_Spacing / 2 + (Magnet_1_Depth + 2 * Tol) + 2 * min_edge_len) * 3;
base_depth = (ceil(tmp) + ceil(tmp) % 3)/3;

// guide axis 
axis_offset = 0.75 * Axis_Diameter;
axis_dist = base_width + 2 * axis_offset;

// full width of the base, including axis mounting holes
full_base_width = base_width + 2 * (axis_offset + Axis_Diameter);
base_diff = full_base_width - base_width;

// Ensure a minimum wall thickness between the cell cutout and the magnet pocket
magnet_offset = (cell_cut_diameter/2) + Tol + min_edge_len;

// slider depth is computed similarly
slider_depth = 2 * (magnet_offset - base_offset_y) + (Magnet_2_Depth + 2 * Tol);


// perform some sanity checks
assert(Cell_Spacing > Cell_Diameter, "The cells spacing must be greather than the cell diameter.");
assert(Magnet_1_Width/2 < Cell_Spacing / 2 - min_edge_len, "The magnet 1 is too wide.")
assert(Magnet_2_Width/2 < Cell_Spacing / 4 - min_edge_len, "The magnet 2 is too wide.")
assert(Magnet_1_Height < 0.5 * Cell_Height, "Please use smaller magnets.")
assert(Magnet_2_Height < 0.5 * Cell_Height, "Please use smaller magnets.")



// compute the base body
difference() {
    // the base object
    base_holder();

    // pockets for magnets
    if (Use_Magnets)
        magnets_1_cutout();

    // mounting holes for the guide axis
    if (Use_Axis_Guides)
        axis_cutouts();
}

// compute the second slider body
translate([0, -1.5 * slider_depth, 0])
{
    difference()
    {
        base_slider();

        if (Use_Magnets)
            magnets_2_cutout();
    
        if (Use_Axis_Guides)
            axis_cutouts();
    }
}



// the base object that will have the axis mounts
module base_holder()
{
    difference()
    {
        // cell holder with elongated base
        union(){
            // the "vertical" part holding the cells
            translate([-base_offset_x, base_offset_y, 0])
            linear_extrude(height=base_height)
            polygon([
                [0, 0],
                [base_width, 0],
                [base_width, base_depth-Bevel_Large],
                [base_width-Bevel_Large, base_depth],
                [Bevel_Large, base_depth],
                [0, base_depth-Bevel_Large],
            ]);
            
            // the bottom base with the axis inserts
            translate([-base_diff/2-base_offset_x, Base_Width+base_offset_y, 0])
            rotate([90, 0, 0])
            linear_extrude(height=Base_Width)
            polygon([
                [0, 0],
                [full_base_width, 0],
                [full_base_width, 2*Axis_Diameter],
                [base_width+base_diff/2, 2*Axis_Diameter],
                [base_width+base_diff/2-Bevel_Large, 2*Axis_Diameter-Bevel_Large],
                [base_diff/2+Bevel_Large, 2*Axis_Diameter-Bevel_Large],
                [base_diff/2, 2*Axis_Diameter],
                [0, 2*Axis_Diameter]
            ]);
        }

        // cell cutouts
        for (i=[0:1:Number_of_Cells-1]) {
            translate([i*Cell_Spacing, 0, -1])
            cylinder(Cell_Height, r=cell_cut_diameter/2);
        }
    
    }
}



// the second, movable base object
module base_slider()
{
    translate([0, base_offset_y, 0])
    difference()
    {
        translate([-base_offset_x, 0, 0])
        union()
        {
            linear_extrude(height=base_height)
            polygon([
                [0, 0],
                [base_width, 0],
                [base_width, slider_depth - Bevel_Large],
                [base_width - Bevel_Large, slider_depth],
                [Bevel_Large, slider_depth],
                [0, slider_depth - Bevel_Large]
            ]);    

            translate([-base_diff/2, 0, 0])
            cube([full_base_width, slider_depth-Bevel_Large, 2*Axis_Diameter]);
        }

        union()
        {
            translate([0, -base_offset_y, 0])
            for (i=[0:1:Number_of_Cells-1]) {
                translate([i*Cell_Spacing, 0, -1])
                cylinder(Cell_Height, r=cell_cut_diameter/2);
            }
            
            translate([Cell_Spacing/2, slider_depth + base_offset_y, 0])
            for (i=[0:1:Number_of_Cells-2]) {
                translate([i*Cell_Spacing, 0, -1])
                cylinder(Cell_Height, r=cell_cut_diameter/2);
            }
        }
    }
}


// create axis cylinders by mirroring and positioning
module axis_cutouts()
{
    translate([
        axis_dist/2 - base_offset_x - axis_offset, 
        base_offset_y + Base_Width - 5, 
        Axis_Diameter
    ])
    union() 
    {
        mirror(v=[1, 0, 0])
        axis_cylinder();
        axis_cylinder();
    }    
}

// build a single axis shifted by half-axis-distance in x
module axis_cylinder()
{
    translate([-axis_dist/2, 0, 0])
    rotate([90, 0, 0])
    cylinder(h=200, r=(Axis_Diameter+Tol)/2);
}



// Cutout for magnets in the base
module magnets_1_cutout() 
{
    for(i=[0:1:Number_of_Cells-1])
    {
        // the cutout is either embedded in the center or extends all the way to the bottom,
        // allowing the magnets to be inserted after printing.
        if (Integrate_Magnets)
        {
            translate([i*Cell_Spacing - Magnet_1_Width/2-Tol, magnet_offset, base_height/2-Magnet_1_Height/2-2*Tol])
                cube([Magnet_1_Width+2*Tol, Magnet_1_Depth+2*Tol,Magnet_1_Height+4*Tol]);
        }
        else
        {
            translate([i*Cell_Spacing - Magnet_1_Width/2-Tol, magnet_offset, -2*Tol])
                cube([Magnet_1_Width+2*Tol, Magnet_1_Depth+2*Tol, Magnet_1_Height/2 + base_height/2 + 4*Tol]);
        }
    }
}

// Cutout for magnets in the base
module magnets_2_cutout() 
{
    for(i=[0:1:2*Number_of_Cells-2])
    {
        // the cutout is either embedded in the center or extends all the way to the bottom,
        // allowing the magnets to be inserted after printing.
        if (Integrate_Magnets)
        {
            translate([i*Cell_Spacing/2 - Magnet_2_Width/2-Tol, magnet_offset, base_height/2-Magnet_2_Height/2-2*Tol])
                cube([Magnet_2_Width+2*Tol, Magnet_2_Depth+2*Tol,Magnet_2_Height+4*Tol]);
        }
        else
        {
            translate([i*Cell_Spacing/2 - Magnet_2_Width/2-Tol, magnet_offset, -2*Tol])
                cube([Magnet_2_Width+2*Tol, Magnet_2_Depth+2*Tol, Magnet_2_Height/2 + base_height/2 + 4*Tol]);
        }
    }
}
