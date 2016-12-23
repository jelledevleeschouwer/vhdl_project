# 
# Synthesis run script generated by Vivado
# 

set_param xicom.use_bs_reader 1
set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
create_project -in_memory -part xc7z010clg400-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir C:/Users/jasper/Documents/Schooljaar_2016-2017/Programmable_logic/vhdl_project/vhdl_project.cache/wt [current_project]
set_property parent.project_path C:/Users/jasper/Documents/Schooljaar_2016-2017/Programmable_logic/vhdl_project/vhdl_project.xpr [current_project]
set_property XPM_LIBRARIES XPM_MEMORY [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language VHDL [current_project]
set_property board_part digilentinc.com:zybo:part0:1.0 [current_project]
add_files -quiet c:/Users/jasper/Documents/Schooljaar_2016-2017/Programmable_logic/vhdl_project/vhdl_project.srcs/sources_1/ip/dual_prt_ram_block_strg_1/dual_prt_ram_block_strg.dcp
set_property used_in_implementation false [get_files c:/Users/jasper/Documents/Schooljaar_2016-2017/Programmable_logic/vhdl_project/vhdl_project.srcs/sources_1/ip/dual_prt_ram_block_strg_1/dual_prt_ram_block_strg.dcp]
read_vhdl -library xil_defaultlib {
  C:/Users/jasper/Documents/Schooljaar_2016-2017/Programmable_logic/vhdl_project/vhdl_project.srcs/sources_1/new/rectangle.vhd
  C:/Users/jasper/Documents/Schooljaar_2016-2017/Programmable_logic/vhdl_project/vhdl_project.srcs/sources_1/new/line.vhd
  C:/Users/jasper/Documents/Schooljaar_2016-2017/Programmable_logic/vhdl_project/vhdl_project.srcs/sources_1/new/block_adjuster.vhd
  C:/Users/jasper/Documents/Schooljaar_2016-2017/Programmable_logic/vhdl_project/vhdl_project.srcs/sources_1/new/PLL_9MHz.vhd
  C:/Users/jasper/Documents/Schooljaar_2016-2017/Programmable_logic/vhdl_project/vhdl_project.srcs/sources_1/new/move_blocks.vhd
  C:/Users/jasper/Documents/Schooljaar_2016-2017/Programmable_logic/vhdl_project/vhdl_project.srcs/sources_1/new/draw_blocks.vhd
  C:/Users/jasper/Documents/Schooljaar_2016-2017/Programmable_logic/vhdl_project/vhdl_project.srcs/sources_1/new/display_driver.vhd
  C:/Users/jasper/Documents/Schooljaar_2016-2017/Programmable_logic/vhdl_project/vhdl_project.srcs/sources_1/imports/new/block_generator.vhd
  C:/Users/jasper/Documents/Schooljaar_2016-2017/Programmable_logic/vhdl_project/vhdl_project.srcs/sources_1/new/background.vhd
  C:/Users/jasper/Documents/Schooljaar_2016-2017/Programmable_logic/vhdl_project/vhdl_project.srcs/sources_1/new/TOP.vhd
}
foreach dcp [get_files -quiet -all *.dcp] {
  set_property used_in_implementation false $dcp
}
read_xdc C:/Users/jasper/Documents/Schooljaar_2016-2017/Programmable_logic/vhdl_project/vhdl_project.srcs/constrs_1/new/My_constraint.xdc
set_property used_in_implementation false [get_files C:/Users/jasper/Documents/Schooljaar_2016-2017/Programmable_logic/vhdl_project/vhdl_project.srcs/constrs_1/new/My_constraint.xdc]


synth_design -top TOP -part xc7z010clg400-1 -flatten_hierarchy none


write_checkpoint -force -noxdef TOP.dcp

catch { report_utilization -file TOP_utilization_synth.rpt -pb TOP_utilization_synth.pb }
