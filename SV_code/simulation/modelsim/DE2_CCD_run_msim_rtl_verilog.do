transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/mchong6/ECE385/Final/SV_code {C:/Users/mchong6/ECE385/Final/SV_code/mult_accum.v}
vlog -sv -work work +incdir+C:/Users/mchong6/ECE385/Final/SV_code {C:/Users/mchong6/ECE385/Final/SV_code/pixel_counter_sim.sv}
vlog -sv -work work +incdir+C:/Users/mchong6/ECE385/Final/SV_code {C:/Users/mchong6/ECE385/Final/SV_code/weights_controller.sv}
vlog -sv -work work +incdir+C:/Users/mchong6/ECE385/Final/SV_code {C:/Users/mchong6/ECE385/Final/SV_code/train_functions.sv}
vlog -sv -work work +incdir+C:/Users/mchong6/ECE385/Final/SV_code {C:/Users/mchong6/ECE385/Final/SV_code/train_test.sv}

vlog -sv -work work +incdir+C:/Users/mchong6/ECE385/Final/SV_code {C:/Users/mchong6/ECE385/Final/SV_code/testbench_full.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  testbench

add wave *
view structure
view signals
run 1000 ns
