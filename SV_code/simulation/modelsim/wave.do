onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/clk
add wave -noupdate /testbench/reset
add wave -noupdate /testbench/clk
add wave -noupdate /testbench/reset
add wave -noupdate -radix unsigned /testbench/train_mod/H_Cont_down
add wave -noupdate -radix unsigned /testbench/train_mod/V_Cont_down
add wave -noupdate /testbench/train_mod/start_pixel
add wave -noupdate /testbench/train_mod/start_stream
add wave -noupdate /testbench/train_mod/W_en
add wave -noupdate -radix decimal /testbench/train_mod/new_weights
add wave -noupdate -radix decimal /testbench/train_mod/weight/weights_in
add wave -noupdate -radix hexadecimal /testbench/train_mod/weight/weight_row
add wave -noupdate -radix decimal /testbench/train_mod/cur_weights
add wave -noupdate -radix unsigned /testbench/train_mod/weight/index
add wave -noupdate /testbench/train_mod/train_unit/train_unit/state
add wave -noupdate {/testbench/train_mod/weight/weights_in[9]}
add wave -noupdate {/testbench/train_mod/weight/weights_in[8]}
add wave -noupdate {/testbench/train_mod/weight/weights_in[7]}
add wave -noupdate {/testbench/train_mod/weight/weights_in[6]}
add wave -noupdate {/testbench/train_mod/weight/weights_in[5]}
add wave -noupdate {/testbench/train_mod/weight/weights_in[4]}
add wave -noupdate {/testbench/train_mod/weight/weights_in[3]}
add wave -noupdate {/testbench/train_mod/weight/weights_in[2]}
add wave -noupdate {/testbench/train_mod/weight/weights_in[1]}
add wave -noupdate {/testbench/train_mod/weight/weights_in[0]}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {25102681 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 289
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {25093299 ps} {25112422 ps}
