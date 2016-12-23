proc start_step { step } {
  set stopFile ".stop.rst"
  if {[file isfile .stop.rst]} {
    puts ""
    puts "*** Halting run - EA reset detected ***"
    puts ""
    puts ""
    return -code error
  }
  set beginFile ".$step.begin.rst"
  set platform "$::tcl_platform(platform)"
  set user "$::tcl_platform(user)"
  set pid [pid]
  set host ""
  if { [string equal $platform unix] } {
    if { [info exist ::env(HOSTNAME)] } {
      set host $::env(HOSTNAME)
    }
  } else {
    if { [info exist ::env(COMPUTERNAME)] } {
      set host $::env(COMPUTERNAME)
    }
  }
  set ch [open $beginFile w]
  puts $ch "<?xml version=\"1.0\"?>"
  puts $ch "<ProcessHandle Version=\"1\" Minor=\"0\">"
  puts $ch "    <Process Command=\".planAhead.\" Owner=\"$user\" Host=\"$host\" Pid=\"$pid\">"
  puts $ch "    </Process>"
  puts $ch "</ProcessHandle>"
  close $ch
}

proc end_step { step } {
  set endFile ".$step.end.rst"
  set ch [open $endFile w]
  close $ch
}

proc step_failed { step } {
  set endFile ".$step.error.rst"
  set ch [open $endFile w]
  close $ch
}

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000

start_step init_design
set rc [catch {
  create_msg_db init_design.pb
  set_param xicom.use_bs_reader 1
  create_project -in_memory -part xc7z010clg400-1
  set_property board_part digilentinc.com:zybo:part0:1.0 [current_project]
  set_property design_mode GateLvl [current_fileset]
  set_param project.singleFileAddWarning.threshold 0
  set_property webtalk.parent_dir C:/Users/jasper/Documents/Schooljaar_2016-2017/Programmable_logic/vhdl_project/vhdl_project.cache/wt [current_project]
  set_property parent.project_path C:/Users/jasper/Documents/Schooljaar_2016-2017/Programmable_logic/vhdl_project/vhdl_project.xpr [current_project]
  set_property ip_repo_paths c:/Users/jasper/Documents/Schooljaar_2016-2017/Programmable_logic/vhdl_project/vhdl_project.cache/ip [current_project]
  set_property ip_output_repo c:/Users/jasper/Documents/Schooljaar_2016-2017/Programmable_logic/vhdl_project/vhdl_project.cache/ip [current_project]
  set_property XPM_LIBRARIES XPM_MEMORY [current_project]
  add_files -quiet C:/Users/jasper/Documents/Schooljaar_2016-2017/Programmable_logic/vhdl_project/vhdl_project.runs/synth_2/TOP.dcp
  add_files -quiet c:/Users/jasper/Documents/Schooljaar_2016-2017/Programmable_logic/vhdl_project/vhdl_project.srcs/sources_1/ip/dual_prt_ram_block_strg_1/dual_prt_ram_block_strg.dcp
  set_property netlist_only true [get_files c:/Users/jasper/Documents/Schooljaar_2016-2017/Programmable_logic/vhdl_project/vhdl_project.srcs/sources_1/ip/dual_prt_ram_block_strg_1/dual_prt_ram_block_strg.dcp]
  read_xdc -mode out_of_context -ref dual_prt_ram_block_strg -cells U0 c:/Users/jasper/Documents/Schooljaar_2016-2017/Programmable_logic/vhdl_project/vhdl_project.srcs/sources_1/ip/dual_prt_ram_block_strg_1/dual_prt_ram_block_strg_ooc.xdc
  set_property processing_order EARLY [get_files c:/Users/jasper/Documents/Schooljaar_2016-2017/Programmable_logic/vhdl_project/vhdl_project.srcs/sources_1/ip/dual_prt_ram_block_strg_1/dual_prt_ram_block_strg_ooc.xdc]
  read_xdc C:/Users/jasper/Documents/Schooljaar_2016-2017/Programmable_logic/vhdl_project/vhdl_project.srcs/constrs_1/new/My_constraint.xdc
  link_design -top TOP -part xc7z010clg400-1
  write_hwdef -file TOP.hwdef
  close_msg_db -file init_design.pb
} RESULT]
if {$rc} {
  step_failed init_design
  return -code error $RESULT
} else {
  end_step init_design
}

start_step opt_design
set rc [catch {
  create_msg_db opt_design.pb
  opt_design 
  write_checkpoint -force TOP_opt.dcp
  report_drc -file TOP_drc_opted.rpt
  close_msg_db -file opt_design.pb
} RESULT]
if {$rc} {
  step_failed opt_design
  return -code error $RESULT
} else {
  end_step opt_design
}

start_step place_design
set rc [catch {
  create_msg_db place_design.pb
  implement_debug_core 
  place_design 
  write_checkpoint -force TOP_placed.dcp
  report_io -file TOP_io_placed.rpt
  report_utilization -file TOP_utilization_placed.rpt -pb TOP_utilization_placed.pb
  report_control_sets -verbose -file TOP_control_sets_placed.rpt
  close_msg_db -file place_design.pb
} RESULT]
if {$rc} {
  step_failed place_design
  return -code error $RESULT
} else {
  end_step place_design
}

start_step route_design
set rc [catch {
  create_msg_db route_design.pb
  route_design 
  write_checkpoint -force TOP_routed.dcp
  report_drc -file TOP_drc_routed.rpt -pb TOP_drc_routed.pb
  report_timing_summary -warn_on_violation -max_paths 10 -file TOP_timing_summary_routed.rpt -rpx TOP_timing_summary_routed.rpx
  report_power -file TOP_power_routed.rpt -pb TOP_power_summary_routed.pb -rpx TOP_power_routed.rpx
  report_route_status -file TOP_route_status.rpt -pb TOP_route_status.pb
  report_clock_utilization -file TOP_clock_utilization_routed.rpt
  close_msg_db -file route_design.pb
} RESULT]
if {$rc} {
  step_failed route_design
  return -code error $RESULT
} else {
  end_step route_design
}

start_step write_bitstream
set rc [catch {
  create_msg_db write_bitstream.pb
  catch { write_mem_info -force TOP.mmi }
  write_bitstream -force TOP.bit 
  catch { write_sysdef -hwdef TOP.hwdef -bitfile TOP.bit -meminfo TOP.mmi -file TOP.sysdef }
  catch {write_debug_probes -quiet -force debug_nets}
  close_msg_db -file write_bitstream.pb
} RESULT]
if {$rc} {
  step_failed write_bitstream
  return -code error $RESULT
} else {
  end_step write_bitstream
}

