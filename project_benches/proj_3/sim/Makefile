export ECE745_PROJECT_HOME ?= $(PWD)/../../..

GEN_TRANS_TYPE ?= wb_transaction
SEED ?= 7

include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/wb_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/i2c_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/environment_packages/i2cmb_env_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/ncsu_pkg/Makefile

clean: 
	rm -rf work *.wlf transcript covhtmlreport *.ucdb

comp_I2C_MB:
	vcom -cover sbcefx ../rtl/iicmb_int_pkg.vhd 
	vcom -cover sbcefx ../rtl/iicmb_pkg.vhd 
	vcom -cover sbcefx ../rtl/mbyte.vhd 
	vcom -cover sbcefx ../rtl/mbit.vhd 
	vcom -cover sbcefx ../rtl/bus_state.vhd 
	vcom -cover sbcefx ../rtl/filter.vhd 
	vcom -cover sbcefx ../rtl/conditioner.vhd 
	vcom -cover sbcefx ../rtl/conditioner_mux.vhd 
	vcom -cover sbcefx ../rtl/iicmb_m.vhd 
	vcom -cover sbcefx ../rtl/regblock.vhd 
	vcom -cover sbcefx ../rtl/wishbone.vhd 
	vcom -cover sbcefx ../rtl/iicmb_m_wb.vhd 

comp_bench: comp_ncsu_pkg comp_wb_pkg comp_i2c_pkg comp_i2cmb_env_pkg 
	vlog -cover sbcefx ../testbench/top.sv 

optimize:
	vopt +cover=bcefsx +acc top -o optimized_debug_top_tb

compile: comp_I2C_MB comp_bench optimize

simulate:
	vsim  -coverage -sv_seed $(SEED) -i -classdebug -msgmode both -do "set NoQuitOnFinish 1; do wave.do;run -a;do coverage_merge_and_report.do;" +GEN_TRANS_TYPE=$(GEN_TRANS_TYPE) optimized_debug_top_tb

debug_sim: clean compile simulate

run_cli:
	vsim  -coverage -c -sv_seed $(SEED) -do "set NoQuitOnFinish 1; run -a; coverage attribute -name TESTNAME -value $(GEN_TRANS_TYPE); coverage save $(GEN_TRANS_TYPE).$(SEED).ucdb; quit -f" +GEN_TRANS_TYPE=$(GEN_TRANS_TYPE) optimized_debug_top_tb

run_gui:
	vsim  -coverage -sv_seed $(SEED) -i -classdebug -msgmode both -do "set NoQuitOnFinish 1; do wave.do;run -a; coverage open ./sim_and_testplan_merged.ucdb" +GEN_TRANS_TYPE=$(GEN_TRANS_TYPE) optimized_debug_top_tb

cli: clean compile run_cli

convert_testplan:
	xml2ucdb -format Excel ./i2cmb_test_plan.xml ./i2cmb_test_plan.ucdb

merge_coverage:
	vcover merge -stats=none -strip 0 -totals sim_and_testplan_merged.ucdb ./*.ucdb 

report_coverage:
	vcover report -details -html -htmldir covhtmlreport -assert -directive -cvg -code bcefst -threshL 50 -threshH 90 ./sim_and_testplan_merged.ucdb

debug: clean convert_testplan compile run_cli merge_coverage report_coverage run_gui