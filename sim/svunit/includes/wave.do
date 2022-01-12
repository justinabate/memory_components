onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group i_fifo /testrunner/__ts/fifo_sync_sram_based_ut/i_fifo/i_clk
add wave -noupdate -expand -group i_fifo /testrunner/__ts/fifo_sync_sram_based_ut/i_fifo/i_rena
add wave -noupdate -expand -group i_fifo /testrunner/__ts/fifo_sync_sram_based_ut/i_fifo/i_rst_n
add wave -noupdate -expand -group i_fifo -radix hexadecimal -radixshowbase 1 /testrunner/__ts/fifo_sync_sram_based_ut/i_fifo/i_wdat
add wave -noupdate -expand -group i_fifo /testrunner/__ts/fifo_sync_sram_based_ut/i_fifo/i_wena
add wave -noupdate -expand -group i_fifo /testrunner/__ts/fifo_sync_sram_based_ut/i_fifo/o_empt
add wave -noupdate -expand -group i_fifo /testrunner/__ts/fifo_sync_sram_based_ut/i_fifo/o_flvl
add wave -noupdate -expand -group i_fifo /testrunner/__ts/fifo_sync_sram_based_ut/i_fifo/o_full
add wave -noupdate -expand -group i_fifo -radix hexadecimal -radixshowbase 1 /testrunner/__ts/fifo_sync_sram_based_ut/i_fifo/o_rdat
add wave -noupdate -expand -group i_fifo /testrunner/__ts/fifo_sync_sram_based_ut/i_fifo/o_rerr
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
WaveRestoreZoom {0 ps} {47 ps}
