#!/usr/bin/env python

import os
import subprocess

import pymeshlab as ml
from openscad_runner import OpenScadRunner

from glyph_tables import typeball

FONT = "\"IBM Plex Mono:style=Regular\""
FONT_SIZE = 2.3

if __name__ == "__main__":
    # Create the main mesh set that will contain the final ball
    mainMeshSet = ml.MeshSet()

    # Make a /ballparts folder to hold each individual glyph shape
    if not os.path.exists("ballparts"):
        os.mkdir("ballparts")

    # Process each glyph in sequence
    for shift_state, hemisphere in enumerate(typeball):
        for row, line in enumerate(hemisphere):
            for column, glyph in enumerate(line):
                # Skip this entry if no glyph is provided; otherwise, make an STL with OpenSCAD
                if not glyph :
                    continue

                glyph_stl_path = f"ballparts/{row}-{column}-{shift_state}.stl"
                # Generate an extruded letter using OpenSCAD
                # Pass the glyph's unicode codepoint(s) instead of the glyph itself, which I hope makes this more cross-compatible
                codepoints = [ord(x) for x in glyph]
                codepoints = str(codepoints).replace(" ","")
                scad_runner = OpenScadRunner(scriptfile = "oneletter.scad",
                        outfile = glyph_stl_path,
                        set_vars = {"codepoints": codepoints,
                            "case": shift_state,
                            "row": row,
                            "column": column,
                            "myFont": FONT,
                            "fontSize": FONT_SIZE
                            })
                print(f"Generating glyph {glyph}...")
                scad_runner.run()
                mainMeshSet.load_new_mesh(glyph_stl_path)
                mainMeshSet.generate_by_merging_visible_meshes()
                mainMeshSet.save_current_mesh("ballparts/textForTypeball.STL")
                print(f"Glyph {glyph} complete.")
    
    # Once all glyphs are processed, put them onto the typeball body
    print("Attaching glyphs to typeball body...")
    mainMeshSet = ml.MeshSet() # Just reset the meshset, it's easier this way
    mainMeshSet.load_new_mesh("ballparts/textForTypeball.STL")
    mainMeshSet.load_new_mesh("Selectric_III_typeball.stl")
    mainMeshSet.generate_boolean_union(first_mesh=0, second_mesh=1)
    mainMeshSet.save_current_mesh("typeball_finished.stl")
    print("Typeball finished!")
