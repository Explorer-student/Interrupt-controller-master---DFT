

set DESIGN INTR_CNTRL


  if {![file exist ./SPF] } {
  sh mkdir -p ./SPF
  }
  
  if {![file exist ./CTL]} {
  sh mkdir -p ./CTL
  }
  
  if {![file exist ./REPORTS]} {
  sh mkdir -p ./REPORTS
  }
  if {![file exist ./BIN]} {
  sh mkdir -p ./BIN
  }
  
  if {![file exist ./OUTPUT_DATA]} {
  sh mkdir -p ./OUTPUT_DATA
  }

#calling link, target and symbol library
set link_library {/home/vlsilab/Downloads/SAED90nm_EDK_10072017/SAED90nm_EDK_10072017/SAED90_EDK/SAED_EDK90nm/Digital_Standard_cell_Library/synopsys/models/saed90nm_typ.db}
set target_library {/home/vlsilab/Downloads/SAED90nm_EDK_10072017/SAED90nm_EDK_10072017/SAED90_EDK/SAED_EDK90nm/Digital_Standard_cell_Library/synopsys/models/saed90nm_typ.db}
set symbol_library ""
#set physical_library ""
#set mw_reference_library ""


set symbol_library [join "
$symbol_library 
"]

set link_library [join "
$link_library
dw_foundation.sldb

"]

set target_library [join "
$target_library "]

#set  SCAN_DIR  pwd
#set  SPF  $pwd/SPF
#set  CTL  $pwd/CTL
#set  REPORTS  $pwd/REPORTS
#set  LOGS  $pwd/LOGS
#set  OUTPUT_DATA  $pwd/OUTPUT_DATA

#return
set_dont_use [get_lib_cells */DFFASRX*]
set_dont_use [get_lib_cells */DFFSSRX*]
set_dont_use [get_lib_cells */DFFNASRX*]
set_dont_use [get_lib_cells */DFFNASRNX*]
set_dont_use [get_lib_cells */SDFFASRX*]
set_dont_use [get_lib_cells */SDFFASRSX*]
set_dont_use [get_lib_cells */SDFFSSRX*]
set_dont_use [get_lib_cells */SDFFNASRX*]

read_file -rtl -format verilog {/home/vlsilab/sagar_harsh_soham/Interrupt_Controller-master/src/intrCntrl.v}

#read_file -rtl -format verilog { }
analyze -library WORK -format verilog {/home/vlsilab/sagar_harsh_soham/Interrupt_Controller-master/src/intrCntrl.v}

#analyze -library WORK -format verilog {/home/vlsilab/sagar_harsh_soham/64bitcounter/64bitcounter.v }

#write_sdf /home/vlsilab/sagar_harsh_soham/4bitCounter/4bitcounter.sdf
write_sdf /home/vlsilab/sagar_harsh_soham/Interrupt_Controller-master.sdf

#read_verilog ../sim/counter.v 


current_design ${DESIGN}

create_port scan_clk -dir IN
create_port SCAN_MODE -dir IN 
#above can also be written as TEST_MODE
create_port pll_bypass -dir IN
#Extra scan chain inserted for testing.
create_port TEST_SI2 -dir IN
create_port TEST_SO2 -dir OUT

create_clock clk_in -period 20
# Above frequency is in Mhz. Below one also
create_clock scan_clk -period 50
#create_clock clk_in -period 20
set_input_delay -max 1.35 -clock clk_in { rst_in  TEST_SE  TEST_SI0  TEST_SI1  TEST_SI2  }
#set_input_delay -max 1.35 -clock clk_in { rst_in }
#set_input_delay -max 1.5 -clock clk q[*]
set_output_delay -max 1.5 -clock clk_in {  TEST_SO0  TEST_SO1  TEST_SO2  }
#set_output_delay -max 1.5 -clock clk_in { TEST_SO0 TEST_SO1 }

#extract_physical_constraints def_file_name
#set_dont_use [get_lib_cells */DFFASRX*]
#set_dont_use [get_lib_cells */DFFSSRX*]
#set_dont_use [get_lib_cells */DFFNASRX*]
#set_dont_use [get_lib_cells */DFFNASRNX*]
#set_dont_use [get_lib_cells */SDFFASRX*]
#set_dont_use [get_lib_cells */SDFFASRSX*]
#set_dont_use [get_lib_cells */SDFFSSRX*]
#set_dont_use [get_lib_cells */SDFFNASRX*]
#return
# Map and optimize the design
set_app_var compile_seqmap_disable_qn_pin_connections true
compile -scan
#above command map and optimize the design.


#:w
#set_compile_directives -local_optimization true
# Analyze and debug the design
report_timing > timing.rpt 
# > this sign is used for redirecting any important data into a file.
# For redirect timing reports into the above file.
write_file -format ddc -hierarchy -output OUTPUT_DATA/${DESIGN}_netlist_pre_scan.ddc
write_file -format verilog -hierarchy -output OUTPUT_DATA/${DESIGN}_netlist_pre_scan.v
write_sdf OUTPUT_DATA/${DESIGN}_netlist_pre_scan.sdf
#write_parasitics -output parasitics_file_name
write_sdc OUTPUT_DATA/${DESIGN}_netlist_pre_scan.sdc

#link


## DFT PORTS DEFINE
#create_port TEST_EN -dir IN
#create_port scan_clk -dir IN
#create_port SCAN_MODE -dir In
#create port pll_bypass_Intr -dir In

set_dft_signal -view spec -type TestMode -port SCAN_MODE -active_state 1 -test_mode all
# Below is the Scan Enable port for Test Mode here functional mode becomes inactive.
set_dft_signal -view spec -type ScanEnable -port TEST_SE -test_mode all

#for {set i 0} {$i < 6} {incr i} { set_dft_signal -view spec -type ScanDataIn -port TEST_SI[$i] -test_mode all_dft }
#for {set i 0 } {$i < 6} {incr i} {set_dft_signal -view spec -type ScanDataOut -port TEST_SO[$i] -test_mode all_dft } 

#Occ starts
set test_integration_top_occ TRUE

#set_dft_signal -view existing_dft -type ScanClock -timing {45 95} -port scan_clk -test_mode all
#set_dft_signal -view existing_dft -type ScanClock -timing {45 95} -port clk_in -test_mode all
#set_dft_signal -view spec -type Reset -active_state 0 -port rst_in -test_mode all_dft
#set_dft_signal -view spec -type pll_bypass -active_state 1 -port pll_bypass_Intr -test_mode all

#Clock Controller Enabled
set_dft_configuration -clock_controller enable

#Main Command
set_dft_clock_controller -cell_name occ_snps_pll_controller -design snps_clk_mux -cycles_per_clock 4 -chain_count 1 -pllclocks [get_ports clk_in ] -ateclock [get_ports scan_clk ] -test_mode_port [get_ports SCAN_MODE ]
#In the above command above pllclocks is the fast clock which is coming from the clk_in pin and ateclock is the slow clock which is coming from scan_clk pin.
#return 

set_scan_configuration -chain_count 3

set_dft_signal -view spec -type ScanEnable -port TEST_SE -type ScanEnable -view spec -test_mode all
set_dft_signal -view spec -type ScanDataIn -port TEST_SI0 -test_mode all
set_dft_signal -view spec -type ScanDataOut -port TEST_SO0 -test_mode all

set_dft_signal -view spec -type ScanDataIn -port TEST_SI1 -test_mode all
set_dft_signal -view spec -type ScanDataOut -port TEST_SO1 -test_mode all

set_dft_signal -view spec -type ScanDataIn -port TEST_SI2 -test_mode all
set_dft_signal -view spec -type ScanDataOut -port TEST_SO2 -test_mode all


set_dft_signal -view existing_dft -type ScanClock -timing {45 95} -port scan_clk -test_mode all
set_dft_signal -view existing_dft -type ScanClock -timing {45 95} -port clk_in -test_mode all
set_dft_signal -view existing_dft -type Reset -active_state 1 -port rst_in -test_mode all_dft
set_dft_signal -view existing_dft -type pll_bypass -active_state 1 -port pll_bypass -test_mode all







#set_dft_signal -view spec -type ScanEnable -port TEST_SE -type ScanEnable -view spec -test_mode all
#set_dft_signal -view spec -type ScanDataIn -port TEST_SI -test_mode all
#set_dft_signal -view spec -type ScanDataOut -port TEST_SO -test_mode all
#set_dft_signal -view existing_dft -type ScanClock -timing {45 95} -port clk_in -test_mode all
#set_dft_signal -view spec -type Reset -active_state 0 -port rst_in -test_mode all_dft



set_scan_configuration -internal_clocks multi -test_mode all

# clock mixing reccomendation is to not mix edges
set_scan_configuration -clock_mixing mix_clocks_not_edges -test_mode all 


create_test_protocol
#return
echo "dft_drc start. Date and time: [date]"
#start_gui
dft_drc -verbose > ./REPORTS/dft_drc_pre_verbose_flow.rpt

echo "dft_drc end. Date and time: [date]"


#set_dft_insertion_configuration -synthesis_optimization none -preserve_design_name true

echo "insert_dft start. Date and time: [date]"
insert_dft
#return
echo "insert_dft end. Date and time: [date]"

write -f verilog -hier -o  ./OUTPUT_DATA/${DESIGN}_netlist_scan.v

write_scan_def -output  ./OUTPUT_DATA/${DESIGN}_netlist_scan.def

write_test_model -format ctl -o ./CTL/${DESIGN}_netlist_scan_post_dft_test_model.ctl
write_test_model -format ddc -o ./OUTPUT_DATA/${DESIGN}_scan_post_dft_test_model.ctlddc

report_area > REPORTS/report_area_post_Scan.rpt

report_dft_configuration > REPORTS/dft_configuration.tcl

#PK Disabling so that internal pin does not come in SPF
set_dft_drc_configuration -internal_pins disable
 
write_test_protocol -test_mode Internal_scan -o SPF/${DESIGN}netlist_Internal_scan.spf
#write_test_protocol -test_mode ScanCompression_mode -o $SPF/${DESIGN}_ScanCompression_mode.spf

# SCAN CHAIN DATA DUMP
report_scan_path -view existing_dft -chain all -test_mode Internal_scan > REPORTS/scan_chains_int.rpt
#report_scan_path -view existing_dft -chain all  -test_mode ScanCompression_mode > REPORTS/scan_chains_sc.rpt

# SCAN CELL DATA DUMP
report_scan_path -view existing_dft -cell all  -test_mode Internal_scan > REPORTS/scan_cells_int.rpt
#report_scan_path -view existing_dft -cell all  -test_mode ScanCompression_mode > ./REPORTS/scan_cells_sc.rpt

report_scan_configuration > ./REPORTS/top_config.rpt
report_qor > ./REPORTS/report_qor_post_insertion.rpt
report_hierarchy > ./REPORTS/report_hierarchy_post_insertion.rpt
check_design > ./REPORTS/report_check_top_design.rpt
check_scan_def > ./REPORTS/check_top_scan_def.log
