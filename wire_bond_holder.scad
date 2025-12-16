$fn = 64;

// ======================================================
// USER PARAMETERS
// ======================================================

// PCB
pcb_length      = 150;
pcb_width       = 67;
pcb_thickness   = 1.6;

// PCB mounting
corner_offset_x = 3.5;
corner_offset_y = 3.5;

// PCB screw / standoff
pilot_d         = 2.0;     // pilot for M2.5 nylon screw
boss_radius     = 2.5;
standoff_height = 8.0;

// PCB holder body
base_thickness  = 2.0;
wall_thickness  = 4.0;

// Screw head recess
head_recess_d   = 6.0;
head_recess_h   = 1.8;

// Chuck access window
chuck_width     = 20;
chuck_length    = 20;
chuck_clearance = 1.0;

// Chuck mounting plate
chuck_plate_thickness = 2.5;
chuck_mount_spacing   = 150;   // assumed 150 mm
chuck_mount_hole_d    = 3.4;   // M3 clearance

// ======================================================
// DERIVED VALUES
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

// Bottom plate sizing (guarantees chuck holes fit)
chuck_plate_size_x = max(outer_size_x, chuck_mount_spacing + 20);
chuck_plate_size_y = max(outer_size_y, chuck_mount_spacing + 20);

// Center offsets
pcb_block_offset_x = (chuck_plate_size_x - outer_size_x) / 2;
pcb_block_offset_y = (chuck_plate_size_y - outer_size_y) / 2;

pcb_center_x = chuck_plate_size_x / 2;
pcb_center_y = chuck_plate_size_y / 2;

chuck_offset = chuck_mount_spacing / 2;

// Chuck mounting hole positions
chuck_mount_positions = [
    [ pcb_center_x - chuck_offset, pcb_center_y - chuck_offset ],
    [ pcb_center_x + chuck_offset, pcb_center_y - chuck_offset ],
    [ pcb_center_x + chuck_offset, pcb_center_y + chuck_offset ],
    [ pcb_center_x - chuck_offset, pcb_center_y + chuck_offset ]
];

// ======================================================
// MODULES
// ======================================================

// PCB standoff with self-tapping hole
module standoff_with_hole() {
    difference() {
        cylinder(h = standoff_height,
                 r = boss_radius);

        // Pilot hole
        cylinder(h = standoff_height + 0.2,
                 r = pilot_d/2);

        // Screw head recess
        translate([0,0,standoff_height - head_recess_h])
            cylinder(h = head_recess_h + 0.2,
                     r = head_recess_d/2);
    }
}

// ======================================================
// MAIN MODEL
// ======================================================

difference() {

    // ---------- SOLID GEOMETRY ----------
    union() {

        // Bottom chuck mounting plate
        cube([chuck_plate_size_x,
              chuck_plate_size_y,
              chuck_plate_thickness],
             center = false);

        // PCB holder body (on top of chuck plate)
        translate([pcb_block_offset_x,
                   pcb_block_offset_y,
                   chuck_plate_thickness])
            linear_extrude(height = total_height)
                square([outer_size_x, outer_size_y], center = false);
    }

    // ---------- SUBTRACTIVE GEOMETRY ----------

    // PCB cavity
    translate([pcb_block_offset_x + wall_thickness,
               pcb_block_offset_y + wall_thickness,
               chuck_plate_thickness + base_thickness])
        linear_extrude(height = standoff_height + pcb_thickness)
            square([pcb_length, pcb_width], center = false);

    // Chuck access pocket
    translate([
        pcb_block_offset_x + wall_thickness + pcb_length/2 - chuck_width/2,
        pcb_block_offset_y + wall_thickness + pcb_width/2  - chuck_length/2,
        chuck_plate_thickness
    ])
        linear_extrude(height = base_thickness - 0.2)
            square([chuck_width + 2*chuck_clearance,
                    chuck_length + 2*chuck_clearance], center = false);

    // Chuck mounting holes (M3)
    for (p = chuck_mount_positions)
        translate([p[0], p[1], -0.1])
            cylinder(h = chuck_plate_thickness + 0.2,
                     r = chuck_mount_hole_d/2);
}

// ======================================================
// ADD PCB STANDOFFS
// ======================================================

for (p = mount_positions)
    translate([
        pcb_block_offset_x + wall_thickness + p[0],
        pcb_block_offset_y + wall_thickness + p[1],
        chuck_plate_thickness + base_thickness
    ])
        standoff_with_hole();
