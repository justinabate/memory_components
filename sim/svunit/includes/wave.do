onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group i_fifo_fwft /testrunner/__ts/fifo_sync_sram_based_ut/i_fifo_fwft/i_clk
add wave -noupdate -expand -group i_fifo_fwft /testrunner/__ts/fifo_sync_sram_based_ut/i_fifo_fwft/i_arst_n
add wave -noupdate -expand -group i_fifo_fwft /testrunner/__ts/fifo_sync_sram_based_ut/i_fifo_fwft/i_sclr
add wave -noupdate -expand -group i_fifo_fwft /testrunner/__ts/fifo_sync_sram_based_ut/i_fifo_fwft/i_wena
add wave -noupdate -expand -group i_fifo_fwft -radix hexadecimal /testrunner/__ts/fifo_sync_sram_based_ut/i_fifo_fwft/i_wdat
add wave -noupdate -expand -group i_fifo_fwft /testrunner/__ts/fifo_sync_sram_based_ut/i_fifo_fwft/i_rena
add wave -noupdate -expand -group i_fifo_fwft -radix hexadecimal /testrunner/__ts/fifo_sync_sram_based_ut/i_fifo_fwft/o_rdat
add wave -noupdate -expand -group i_fifo_fwft /testrunner/__ts/fifo_sync_sram_based_ut/i_fifo_fwft/o_empt
add wave -noupdate -expand -group i_fifo_fwft /testrunner/__ts/fifo_sync_sram_based_ut/i_fifo_fwft/o_full
add wave -noupdate -expand -group i_fifo_fwft /testrunner/__ts/fifo_sync_sram_based_ut/i_fifo_fwft/o_almf
add wave -noupdate -expand -group i_fifo_fwft /testrunner/__ts/fifo_sync_sram_based_ut/i_fifo_fwft/o_alme
add wave -noupdate -expand -group i_fifo_fwft -radix unsigned /testrunner/__ts/fifo_sync_sram_based_ut/i_fifo_fwft/o_flvl
add wave -noupdate -expand -group i_fifo_basic /testrunner/__ts/fifo_sync_sram_based_ut/i_fifo_basic/i_clk
add wave -noupdate -expand -group i_fifo_basic /testrunner/__ts/fifo_sync_sram_based_ut/i_fifo_basic/i_srst_n
add wave -noupdate -expand -group i_fifo_basic /testrunner/__ts/fifo_sync_sram_based_ut/i_fifo_basic/i_wena
add wave -noupdate -expand -group i_fifo_basic -radix hexadecimal /testrunner/__ts/fifo_sync_sram_based_ut/i_fifo_basic/i_wdat
add wave -noupdate -expand -group i_fifo_basic /testrunner/__ts/fifo_sync_sram_based_ut/i_fifo_basic/o_werr
add wave -noupdate -expand -group i_fifo_basic /testrunner/__ts/fifo_sync_sram_based_ut/i_fifo_basic/i_rena
add wave -noupdate -expand -group i_fifo_basic -radix hexadecimal /testrunner/__ts/fifo_sync_sram_based_ut/i_fifo_basic/o_rdat
add wave -noupdate -expand -group i_fifo_basic /testrunner/__ts/fifo_sync_sram_based_ut/i_fifo_basic/o_rerr
add wave -noupdate -expand -group i_fifo_basic /testrunner/__ts/fifo_sync_sram_based_ut/i_fifo_basic/o_full
add wave -noupdate -expand -group i_fifo_basic /testrunner/__ts/fifo_sync_sram_based_ut/i_fifo_basic/o_empt
add wave -noupdate -expand -group i_fifo_basic -radix unsigned /testrunner/__ts/fifo_sync_sram_based_ut/i_fifo_basic/o_flvl
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {29 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 210
configure wave -valuecolwidth 108
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {129 ps}
