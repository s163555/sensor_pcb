$fn = 64;

// ======================================================
// USER PARAMETERS
// ======================================================

// PCB
pcb_length      = 83;
pcb_width       = 50;
pcb_thickness   = 1.6;

// PCB mounting
corner_offset_x = 2.6;
corner_offset_y = 2.6;

// PCB screw / standoff
pilot_d         = 2.5;     // M2.5 nylon self-tapping
standoff_height = 8.0;

// Standoff robustness
standoff_size   = 6;     // square cross-section
rib_thickness   = 2.5;

// PCB holder body
base_thickness  = 2.0;
wall_thickness  = 4.0;

// Chuck mounting
chuck_plate_thickness = 2.5;
chuck_mount_hole_d    = 3.4;   // M3 clearance

// Chuck hole spacing (center-to-center)
chuck_spacing_x = 95.5;
chuck_spacing_y = 80.5;

// Plate trimming
chuck_edge_margin = 4;

// PCB removal push-out hole
pushout_size_x = 35;
pushout_size_y = 35;
pcb_bottom_z = chuck_plate_thickness + base_thickness;

// ======================================================
// DERIVED
// ======================================================

total_height = base_thickness + standoff_height;

outer_size_x = pcb_length + 2 * wall_thickness;
outer_size_y = pcb_width  + 2 * wall_thickness;

// PCB standoff locations
mount_positions = [
    [ corner_offset_x,              corner_offset_y ],
    [ pcb_length - corner_offset_x, corner_offset_y ],
    [ pcb_length - corner_offset_x, pcb_width - corner_offset_y ],
    [ corner_offset_x,              pcb_width - corner_offset_y ]
];

sidewall_height        = base_thickness + standoff_height;
standoff_actual_height = standoff_height - pcb_thickness;

// Bottom plate size
chuck_plate_size_x = chuck_spacing_x + 2 * chuck_edge_margin;
chuck_plate_size_y = chuck_spacing_y + 2 * chuck_edge_margin;

// Offsets
pcb_block_offset_x = (chuck_plate_size_x - outer_size_x) / 2;
pcb_block_offset_y = (chuck_plate_size_y - outer_size_y) / 2;

pcb_center_x = chuck_plate_size_x / 2;
pcb_center_y = chuck_plate_size_y / 2;

dx = chuck_spacing_x / 2;
dy = chuck_spacing_y / 2;

// Chuck mounting hole positions
chuck_mount_positions = [
    [ pcb_center_x - dx, pcb_center_y - dy ],
    [ pcb_center_x + dx, pcb_center_y - dy ],
    [ pcb_center_x + dx, pcb_center_y + dy ],
    [ pcb_center_x - dx, pcb_center_y + dy ]
];

// ======================================================
// MODULES
// ======================================================

// Reinforced flat-top PCB standoff
module reinforced_standoff(anchor_dir = [0,0]) {

    difference() {
        union() {
            // Main square tower (LOWER than sidewall)
            cube([standoff_size, standoff_size, standoff_actual_height]);

            // Rib tying into wall
            translate([
                anchor_dir[0] * standoff_size/2,
                anchor_dir[1] * standoff_size/2,
                0
            ])
                cube([
                    abs(anchor_dir[0]) * rib_thickness + (anchor_dir[1]==0 ? standoff_size : rib_thickness),
                    abs(anchor_dir[1]) * rib_thickness + (anchor_dir[0]==0 ? standoff_size : rib_thickness),
                    standoff_actual_height
                ]);
        }

        // Pilot hole (full height of standoff only)
        translate([standoff_size/2, standoff_size/2, -0.1])
            cylinder(h = standoff_actual_height + 0.2, r = pilot_d/2);
    }
}


// ======================================================
// MAIN MODEL
// ======================================================

difference() {

    // ---------- SOLID ----------
    union() {

        // Bottom chuck plate
        cube([chuck_plate_size_x,
              chuck_plate_size_y,
              chuck_plate_thickness]);

        // PCB holder body
        translate([pcb_block_offset_x,
                   pcb_block_offset_y,
                   chuck_plate_thickness])
            linear_extrude(height = sidewall_height)
                square([outer_size_x, outer_size_y]);
    }

    // ---------- SUBTRACT ----------
    // PCB cavity
    translate([pcb_block_offset_x + wall_thickness,
               pcb_block_offset_y + wall_thickness,
               chuck_plate_thickness + base_thickness])
        linear_extrude(height = standoff_height + pcb_thickness)
            square([pcb_length, pcb_width]);
    // PCB push-out hole (from bottom up to PCB underside)
    translate([
        pcb_block_offset_x + wall_thickness + pcb_length/2 - pushout_size_x/2,
        pcb_block_offset_y + wall_thickness + pcb_width/2  - pushout_size_y/2,
        -0.1
    ])
        linear_extrude(height = pcb_bottom_z + 0.2)
            square([pushout_size_x, pushout_size_y], center=false);
    // Chuck mounting holes
    for (p = chuck_mount_positions)
        translate([p[0], p[1], -0.1])
            cylinder(h = chuck_plate_thickness + 0.2,
                     r = chuck_mount_hole_d/2);
}

// ======================================================
// ADD PCB STANDOFFS
// ======================================================

for (p = mount_positions) {

    anchor = [
        p[0] < pcb_length/2 ? -1 : 1,
        p[1] < pcb_width/2  ? -1 : 1
    ];

    translate([
        pcb_block_offset_x + wall_thickness + p[0] - standoff_size/2,
        pcb_block_offset_y + wall_thickness + p[1] - standoff_size/2,
        chuck_plate_thickness + base_thickness
    ])
        reinforced_standoff(anchor);
}
