# (C) 2001-2014 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License Subscription 
# Agreement, Altera MegaCore Function License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


# NPROGRAM and NERASE are async signals in hard IP
set_false_path -from [get_registers {*altera_onchip_flash_avmm_data_controller:avmm_data_controller|write_state.*}] -to {*altera_onchip_flash_block:altera_onchip_flash_block|ufm_block~NPROGRAM[*]}
set_false_path -from [get_registers {*altera_onchip_flash_avmm_data_controller:avmm_data_controller|erase_state.*}] -to {*altera_onchip_flash_block:altera_onchip_flash_block|ufm_block~NERASE[*]}
