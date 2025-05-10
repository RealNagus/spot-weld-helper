/* [Cell parameters] */

// Numnber of cells in a row
Number_of_Cells = 5; // [2:1:12]

// Cell diameter in mm
Cell_Diameter = 18.0; // 0.1
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

// Base width in mm
Base_Width = 40.0; // 0.1

// Use axss?
Use_Axis_Guides = true;

// Guide axis diameter in mm
Axis_Diameter = 8; // 0.1


/* [Tolerances] */

// Basic Tolerance to use in mm
Tol = 0.1; // 0.1

// Your 3D printer's extrusion width
Extrusion_Width = 0.4; // [0.25:0.05:1.0]

// Minimum number of extrusion lines on thin walls
Min_Wall_Lines = 2; // [1:1:10]

// Large bevel width for the base in mm
Bevel_Large = 5.0; // 0.1

// Small bevel width for edges in mm
Bevel_Small = 1.0; // 0.1

module __Customizer_Limit__ () {}

// ************ INTERNAL VARIABLES ************
$fa=1;
$fs=0.1;

assert(Cell_Spacing > Cell_Diameter, "The cells spacing must be greather than the cell diameter.");

// calculated variables
base_width = (Number_of_Cells + 0.5) * Cell_Spacing;
base_height = Cell_Height - 5;
base_shift_y = sqrt(Cell_Spacing^2 - (Cell_Spacing - Min_Wall_Lines * Extrusion_Width / 2)^2);
base_diff = 6 * Axis_Diameter;
full_base_width = base_width + base_diff;

tmp = (Cell_Spacing / 2 + Magnet_1_Depth + 2 * (Min_Wall_Lines * Extrusion_Width)) * 3;
base_depth = (ceil(tmp) + ceil(tmp) % 3)/3;

axis_dist = (Number_of_Cells + 1) * Cell_Spacing + 2 * Axis_Diameter;


// Ensure a minimum wall thickness between the cell cutout and the magnet pocket
magnet_1_offset = Cell_Spacing / 2 + Min_Wall_Lines * Extrusion_Width;




difference() {
    base_holder();

    // cell cutouts
    for (i=[0:1:Number_of_Cells-1]) {
        translate([i*Cell_Spacing,0,-1]){
            cylinder(Cell_Height, Cell_Diameter/2+0.25, Cell_Diameter/2+0.25);
        }
    }

    if (Use_Axis_Guides)
        axis_cutouts();
    
    if (Use_Magnets)
        magnets_1_cutout();
}


// the base object that will have the axis mounts
module base_holder()
{
    union(){
        translate([-Cell_Spacing*0.75, base_shift_y, 0])
        linear_extrude(height=base_height)
        polygon([
            [0, 0],
            [base_width, 0],
            [base_width, base_depth-Bevel_Large],
            [base_width-Bevel_Large, base_depth],
            [Bevel_Large, base_depth],
            [0, base_depth-Bevel_Large],
        ]);
        //cube([base_width, base_depth, base_height]);

        translate([-base_diff/2-Cell_Spacing*0.75, Base_Width, 0])
        rotate([90, 0, 0])
        linear_extrude(height=Base_Width-base_shift_y)
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

}

module axis_cutouts()
{
    translate([base_diff/2+Cell_Spacing*0.75, base_shift_y + Base_Width - 5, Axis_Diameter])
    union() 
    {
        mirror(v=[1, 0, 0])
        axis_cylinder();

        axis_cylinder();
    }    
}

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
            translate([i*Cell_Spacing - Magnet_1_Width/2-Tol, magnet_1_offset, base_height/2-Magnet_1_Height/2-Tol])
                cube([Magnet_1_Width+2*Tol, Magnet_1_Depth+2*Tol,Magnet_1_Height+2*Tol]);
        }
        else
        {
            translate([i*Cell_Spacing - Magnet_1_Width/2-Tol, magnet_1_offset, -Tol])
                cube([Magnet_1_Width+2*Tol, Magnet_1_Depth+2*Tol, Magnet_1_Height/2 + base_height/2 + 2*Tol]);
        }
    }
}
