# ------------------------------------------
# Create generated clocks based on PLLs
# ------------------------------------------

derive_pll_clocks



# ---------------------------------------------
# Original Clock
# ---------------------------------------------

create_clock -period "20.000 ns" -name {CLOCK_50} {CLOCK_50}
create_clock -period "13.468 ns" -name {CLOCK_74} {CLOCK_74}



# ---------------------------------------------
# Set SDRAM I/O requirements
# ---------------------------------------------




