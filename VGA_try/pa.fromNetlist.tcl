
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name VGA_try -dir "/home/student/Desktop/VGA/VGA_try/planAhead_run_2" -part xc3s500efg320-5
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "/home/student/Desktop/VGA/VGA_try/top.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {/home/student/Desktop/VGA/VGA_try} }
set_property target_constrs_file "constraints.ucf" [current_fileset -constrset]
add_files [list {constraints.ucf}] -fileset [get_property constrset [current_run]]
link_design
