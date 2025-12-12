$fn = 64;

// ---------- USER PARAMETERS ----------
pcb_length      = 150;
pcb_width       = 67;
pcb_thickness   = 1.6;

corner_offset_x = 3.5;
corner_offset_y = 3.5;

pilot_d         = 2;     // pilot for M2.5 nylon screw
boss_radius     = 2.5;

standoff_height = 8.0;
base_thickness  = 2.0;
wall_thickness  = 4.0;

head_recess_d   = 6.0;
head_recess_h   = 1.8;

chuck_width     = 20;
chuck_length    = 20;
chuck_clearance = 1.0;


// ---------- Derived ----------
total_height = base_thickness + standoff_height;

mount_positions = [
    [ corner_offset_x,                 corner_offset_y ],
    [ pcb_length - corner_offset_x,    corner_offset_y ],
    [ pcb_length - corner_offset_x,    pcb_width - corner_offset_y ],
    [ corner_offset_x,                 pcb_width - corner_offset_y ]
];

outer_size_x = pcb_length + 2*wall_thickness;
outer_size_y = pcb_width  + 2*wall_thickness;

// ---------- MODULES ----------
module standoff_with_hole() {
    difference() {
        // main boss
        cylinder(standoff_height, boss_radius, boss_radius);

        // pilot hole through full height
        cylinder(standoff_height + 0.1, pilot_d/2, pilot_d/2);

        // screw‑head recess
        translate([0,0,standoff_height - head_recess_h])
            cylinder(head_recess_h + 0.1, head_recess_d/2, head_recess_d/2);
    }
}


// ---------- MODEL ----------
difference() {

    // Base + outer walls
    linear_extrude(height = total_height)
        square([outer_size_x, outer_size_y], center = false);

    // Big cavity for PCB + parts
    translate([wall_thickness, wall_thickness, base_thickness])
        linear_extrude(height = standoff_height + pcb_thickness)
            square([pcb_length, pcb_width], center = false);

    // Chuck clearance pocket
    translate([
        wall_thickness + pcb_length/2 - chuck_width/2,
        wall_thickness + pcb_width/2  - chuck_length/2,
        0
    ])
        linear_extrude(height = base_thickness - 0.2)
            square([chuck_width + chuck_clearance*2,
                    chuck_length + chuck_clearance*2], center = false);
}


// ---------- ADD STANDOFFS AT CORNERS ----------
for (p = mount_positions)
    translate([wall_thickness + p[0], wall_thickness + p[1], base_thickness])
        standoff_with_hole();