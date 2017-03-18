proc Addwaves{} {
	;#Add waves we're interested in to the Wave window
	#add wave -position end sim:/decoder_tb/clk
}
vlib work
 
;#Compile components
vcom
vcom


;# start simulation
vsim

;# Generate a clock with 1ns period
force -deposit clk 0 0 ns, 1 0.5 ns -repeat 1 ns

;# Add the waves
AddWaves

;# RUn for 500ns
run 500ns