/* IBM Selectric III type-ball
 *
 * Based on the work of Steve Malikoff, who generously licensed it as CC-BY, and included the following
 * dedication:
 *
 *      In memory of John Thompson, an Australian IBM OPCE from whom I "inherited" his Selectric CE tool set:
 *          http://qccaustralia.org/vale.htm
 *
 * Note: the above content is no longer available, but is archived at
 * https://web.archive.org/web/20191119001811/http://qccaustralia.org/vale.htm
 * 
 * To be packaged and used in conjunction with a lightly modified version of Sam Ettinger's excellent
 * program, which is licensed under BSD-3
 *
 * Adapted by Peter Schoener
 */

// d) Tilt position latitudes on the typeball, This may need adjusting depending on the font and size
//    Sometime I will properly measure the angles, when I make a surface plate caliper bracket.

T0_LATITUDE = 34;  // degrees North of equator
T1_LATITUDE = 16;  // degrees North of equator
T2_LATITUDE = 1;   // degrees North of equator
T3_LATITUDE = -14; // degrees South of equator

// e) The letter face tilt angle from the zenith toward North (+ve) or South (-ve)

NORTHWARDS_ZENITH_OFFSET = 0;

// f) sloppiness fit on spigot

UPPER_BALL_SOCKET_TOLERANCE = 0;

CLIP_SCREW_DIA = 1.8;

// Rendering granularity for F5 preview and F6 render. Rendering takes a LOT of time.
PREVIEW_FACETS = 40;
RENDER_FACETS = 135;

FACETS = $preview ? PREVIEW_FACETS : RENDER_FACETS;
FONT_FACETS = FACETS;
$fn = FACETS;

TYPEBALL_RAD = 16.828;
TYPEBALL_WALL_THICKNESS = 2;
// Top face parameters
TYPEBALL_TOP_ABOVE_CENTRE = 11.86; // Flat top is this far above the sphere centre
DEL_BASE_FROM_CENTRE = 8.2;
DEL_DEPTH = 1.7;

// Detent teeth skirt parameters
TYPEBALL_SKIRT_TOP_BELOW_CENTRE = -4.2; // Where the lower latitude of the sphere meets the top of the skirt
SKIRT_HEIGHT = 5.6;
TOOTH_PEAK_OFFSET_FROM_CENTRE = 6.1; // Lateral offset of the tilt ring detent pawl

// Parameters for the centre boss that goes onto tilt ring spigot (upper ball socket)
BOSS_INNER_RAD = 4.30 + UPPER_BALL_SOCKET_TOLERANCE;
BOSS_OUTER_RAD = 5.3;
BOSS_HEIGHT = 8.32;
SLOT_ANGLE = -45;
SLOT_WIDTH = 2.210;
SLOT_DEPTH = 0.7;
NOTCH_ANGLE = SLOT_ANGLE + 180;
NOTCH_WIDTH = 1.143;
NOTCH_DEPTH = 0.7;
NOTCH_HEIGHT = 40;

// Inside reinforcement ribs
RIBS = 12;
RIB_LENGTH = 8.8;
RIB_WIDTH = 2;
RIB_HEIGHT = 3;

// Rabbit ears wire retaining clip screw hole parameters
RABBIT_EARS_CLIP_MOUNTING_SCREWS_CENTRE_TO_CENTRE = 11.6;
RABBIT_EARS_CLIP_MOUNTING_SCREWS_FROM_TILT_RING_SPIGOT = 6.8;
SCREW_BOSS_RAD = CLIP_SCREW_DIA + 0.8; // Inside, between ribs
CHARACTERS_PER_LATITUDE = 24; // also used as tooth ct

// Generate the model.
TypeBall();
//SpigotOnly();
//DetentTeeth();
//Tooth();
//TeethTrimJig();

// Make only a cylinder for test fitting on the upper ball socket spigot
module SpigotOnly()
{
    intersection()
    {
        TypeBall();
        cylinder(r=11,h=100);        
    }
}

// The entire typeball model proper.
module TypeBall()
{
    difference()
    {
        HollowBall();
        Slot();
        Notch();
        ScrewHoles();
        Del();
    }
}

// The unadorned ball shell with internal ribs and screw bosses
module HollowBall()
{
    //difference()
    {
        Ball();
        offset(-3)
            Ball();
    }
    Ribs();
    ScrewBosses();
}

module Ball()
{
    arbitraryRemovalBlockHeight = 20;
    // Basic ball, trimmed flat top and bottom
    difference()
    {
        sphere(r=TYPEBALL_RAD, center = true);
        translate([-50,-50, TYPEBALL_TOP_ABOVE_CENTRE])
            cube([100,100,arbitraryRemovalBlockHeight]);
        translate([-50,-50, TYPEBALL_SKIRT_TOP_BELOW_CENTRE - arbitraryRemovalBlockHeight]) // ball/skirt fudge factor
            cube([100,100,arbitraryRemovalBlockHeight]);
        sphere(r=TYPEBALL_RAD - TYPEBALL_WALL_THICKNESS, center = true);
    }
    // Fill top back in
    TopFace();
    DetentTeethSkirt();
    CentreBoss();
}

//////////////////////////////////////////////////////////////////////////
//// Detent teeth around bottom of ball
module DetentTeethSkirt()
{
    SKIRT_OUTSIDE_UPPER_RAD = 16.30;
    SKIRT_OUTSIDE_LOWER_RAD = 15.11;
    TOOTH_TIP_THICK = 1.2; //1.5;
    // Detent teeth skirt
    difference()
    {
        translate([0,0, TYPEBALL_SKIRT_TOP_BELOW_CENTRE - SKIRT_HEIGHT])
            cylinder(r2=SKIRT_OUTSIDE_UPPER_RAD, r1=SKIRT_OUTSIDE_LOWER_RAD, h=SKIRT_HEIGHT);
        translate([0,0, TYPEBALL_SKIRT_TOP_BELOW_CENTRE - SKIRT_HEIGHT])
            cylinder(r2=SKIRT_OUTSIDE_UPPER_RAD - TYPEBALL_WALL_THICKNESS, r1=SKIRT_OUTSIDE_LOWER_RAD + TOOTH_TIP_THICK - TYPEBALL_WALL_THICKNESS, h=SKIRT_HEIGHT);        
        translate([0,0, TYPEBALL_SKIRT_TOP_BELOW_CENTRE - SKIRT_HEIGHT])
            DetentTeeth();
    }
}

// Ring of detent teeth in skirt
module DetentTeeth()
{
    segment = 360 / CHARACTERS_PER_LATITUDE;
    half_tooth = 0;
    for (i=[0:CHARACTERS_PER_LATITUDE - 1])
        rotate([0, 0, segment * i + half_tooth])
            Tooth();
}

module Tooth()
{
    translate([0, TOOTH_PEAK_OFFSET_FROM_CENTRE, 0])
        rotate([180, -90, 0])
        {
            linear_extrude(30)
            {
                polygon(points=[[3,0], [0,1.9], [0,-1.9]]);
                translate([0, -.15, 0])
                    square([3.1, .3]);
            }
        }
}

//// Flat top of typeball, punch tilt ring spigot hole through and subtract del triangle
module TopFace()
{
    // Fill top back in, after the inside sphere was subtracted before this fn was called
    difference()
    {
        translate([0, 0, TYPEBALL_TOP_ABOVE_CENTRE - TYPEBALL_WALL_THICKNESS])
            cylinder(r=12.5, h=TYPEBALL_WALL_THICKNESS);
        translate([0, 0, TYPEBALL_TOP_ABOVE_CENTRE - TYPEBALL_WALL_THICKNESS])
            cylinder(r=BOSS_INNER_RAD,h=TYPEBALL_WALL_THICKNESS*2);
        Del();
    }   
}

// Alignment marker triangle on top face
module Del()
{
    translate([DEL_BASE_FROM_CENTRE, 0, TYPEBALL_TOP_ABOVE_CENTRE - DEL_DEPTH])
        color("white")  // TODO red triangle for Composer typeball
        linear_extrude(DEL_DEPTH)
            polygon(points=[[3.4,0],[0,1.5],[0,-1.5]]);
}

// Clean up any base girth bits of T0-ring characters projecting above top face
module TrimTop()
{
    translate([-50,-50, TYPEBALL_TOP_ABOVE_CENTRE])
        cube([100,100,20]);
}


// Tilt ring boss assembly
module CentreBoss()
{
    translate([0,0, TYPEBALL_TOP_ABOVE_CENTRE - BOSS_HEIGHT])
        difference()
        {
            cylinder(r=BOSS_OUTER_RAD, h=BOSS_HEIGHT);
            cylinder(r=BOSS_INNER_RAD, h=BOSS_HEIGHT);
        }    
}

// The full-length slot in the tilt ring boss at the half past one o'clock position
module Slot()
{
    rotate([0, 0, SLOT_ANGLE])
        translate([0, -SLOT_WIDTH/2, 0])
            cube([SLOT_DEPTH + BOSS_INNER_RAD, SLOT_WIDTH, 40]);
}

// The partial-length slot in the tilt ring boss at the half past seven o'clock position
module Notch()
{
    rotate([0, 0, NOTCH_ANGLE])
        translate([0, -NOTCH_WIDTH/2, TYPEBALL_TOP_ABOVE_CENTRE - BOSS_HEIGHT])
            cube([NOTCH_DEPTH + BOSS_INNER_RAD, NOTCH_WIDTH, NOTCH_HEIGHT]);
    rotate([0, 0, NOTCH_ANGLE - 90])
        translate([0, -NOTCH_WIDTH/2, TYPEBALL_TOP_ABOVE_CENTRE - BOSS_HEIGHT])
            cube([NOTCH_DEPTH + BOSS_INNER_RAD, NOTCH_WIDTH, NOTCH_HEIGHT]);
    rotate([0, 0, NOTCH_ANGLE + 90])
        translate([0, -NOTCH_WIDTH/2, TYPEBALL_TOP_ABOVE_CENTRE - BOSS_HEIGHT])
            cube([NOTCH_DEPTH + BOSS_INNER_RAD, NOTCH_WIDTH, NOTCH_HEIGHT]);
}

// The reinforcement spokes on the underside of the top face, from the tilt ring boss 
// to the inner sphere wall
module Ribs()
{
    segment = 360 / RIBS;
    for (i=[0:RIBS - 1])
        rotate([0, 0, segment * i])
            translate([BOSS_OUTER_RAD - 0.5, -RIB_WIDTH/2, TYPEBALL_TOP_ABOVE_CENTRE - TYPEBALL_WALL_THICKNESS - RIB_HEIGHT])
                cube([RIB_LENGTH, RIB_WIDTH, RIB_HEIGHT]);
    
}

// The two self-tapping screw holes in the top face
module ScrewHoles()
{
    translate([RABBIT_EARS_CLIP_MOUNTING_SCREWS_FROM_TILT_RING_SPIGOT, RABBIT_EARS_CLIP_MOUNTING_SCREWS_CENTRE_TO_CENTRE/2, 0])
        cylinder(d=CLIP_SCREW_DIA, h=50);
    translate([RABBIT_EARS_CLIP_MOUNTING_SCREWS_FROM_TILT_RING_SPIGOT, -RABBIT_EARS_CLIP_MOUNTING_SCREWS_CENTRE_TO_CENTRE/2, 0])
        cylinder(d=CLIP_SCREW_DIA, h=50);
}

// The underside of the screw holes
module ScrewBosses()
{
    translate([RABBIT_EARS_CLIP_MOUNTING_SCREWS_FROM_TILT_RING_SPIGOT, RABBIT_EARS_CLIP_MOUNTING_SCREWS_CENTRE_TO_CENTRE/2,TYPEBALL_TOP_ABOVE_CENTRE - TYPEBALL_WALL_THICKNESS - RIB_HEIGHT])
        cylinder(r=SCREW_BOSS_RAD, h=RIB_HEIGHT);
    translate([RABBIT_EARS_CLIP_MOUNTING_SCREWS_FROM_TILT_RING_SPIGOT, -RABBIT_EARS_CLIP_MOUNTING_SCREWS_CENTRE_TO_CENTRE/2,TYPEBALL_TOP_ABOVE_CENTRE - TYPEBALL_WALL_THICKNESS - RIB_HEIGHT])
        cylinder(r=SCREW_BOSS_RAD, h=RIB_HEIGHT);
}
