# ------------------------------------------
# Create generated clocks based on PLLs
# ------------------------------------------

derive_pll_clocks



# ---------------------------------------------
# Original Clock
# ---------------------------------------------

create_clock -period "20.000 ns" -name {CLOCK_50} {CLOCK_50}
#create_clock -period "40.690 ns" -name {CLOCK_24} {CLOCK_24}
#create_clock -period "13.468 ns" -name {CLOCK_74} {CLOCK_74}



# ---------------------------------------------
# Set SDRAM I/O requirements
# ---------------------------------------------




