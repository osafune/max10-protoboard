#SODALITE

[Japanese document(日本語の説明)](https://github.com/osafune/sodalite/blob/master/README-jp.md)

"SODALITE" is a FPGA board for prototyping with the DIP shape equipped with Altera MAX10 device.

![SODALITE](https://lh3.googleusercontent.com/-fBGcmyD2sEY/VHNSUxrROWI/AAAAAAAAHIY/pMdg5tDgemA/w619-h464-no/DSC_0340.JPG)


------------------------------------------------------------------------
##Overview

![SODALITE TOPVIEW](https://lh3.googleusercontent.com/-e6P0SKS46Xc/VHNEk6tXomI/AAAAAAAAHHw/hiFEVjnDsTw/w379-h380-no/sodalite_topview.png)

- 40 pin DIP shape of the 1100mil width
- MAX10 device loading of 8kLE (10M08SAE144C8GES)
- On-board with 256MbitSDRAM
- On-board OSC which can choose 3 kinds of frequency
- Most 34 of PIO, 6 of analog input and 8 channels of LVDS differential pair
- On-board with a user LED
- A driven 3.3V single power supply
- With VREF for ADC/REFGND and a VIO external input pin
- A dual configuration is supported.


###Blockdiagram

![SODALITE Blockdiagram](https://lh4.googleusercontent.com/-9MY5agBSNxU/VHNElCTIsCI/AAAAAAAAHH0/HBXVVxgH8Xo/w619-h447-no/sodalite_block.png)


------------------------------------------------------------------------
##Pin assignment

###Prototyping connector

|Number|FPGA pin|contents|
|---|---|---|
|1|PIN_28|PIO0/CLK_n|
|2|PIN_29|PIO1/CLK_p|
|3| |VCCIO power supply|
|4|PIN_38|PIO2/LVDS0_n|
|5|PIN_39|PIO3/LVDS0_p|
|6|PIN_41|PIO4/LVDS1_n|
|7|PIN_43|PIO5/LVDS1_p|
|8|PIN_44|PIO6/LVDS2_n|
|9|PIN_45|PIO7/LVDS2_p|
|10|PIN_46|PIO8/LVDS3_n|
|11|PIN_47|PIO9/LVDS3_p|
|12|PIN_50|PIO10/LVDS4_n|
|13|PIN_52|PIO11/LVDS4_p|
|14|PIN_55|PIO12/LVDS5_n|
|15|PIN_56|PIO13/LVDS5_p|
|16|PIN_57|PIO14/LVDS6_n|
|17|PIN_58|PIO15/LVDS6_p|
|18|PIN_59|PIO16/LVDS7_n|
|19|PIN_60|PIO17/LVDS7_p|
|20| |GND|
|21| |GND|
|22|PIN_120|PIO18|
|23|PIN_121|PIO19|
|24|PIN_122|PIO20|
|25|PIN_124|PIO21|
|26|PIN_126|BOOT_SEL/PIO22|
|27|PIN_127|PIO23|
|28|PIN_130|PIO24|
|29|PIN_131|PIO25|
|30|PIN_132|PIO26|
|31|PIN_134|PIO27|
|32| |ADC REFGND(connected to GND)|
|33|PIN_6|AIN1/PIO28|
|34|PIN_7|AIN2/PIO29|
|35|PIN_8|AIN3/PIO30|
|36|PIN_10|AIN4/PIO31|
|37|PIN_11|AIN5/PIO32|
|38|PIN_12|AIN6/PIO33|
|39| |ADC VREF(When unused, Open or connect to REFGND)|
|40| |3.3V power supply|

- When LVDS use, 2.5V is added to a pin number 3(VCCIO input).
- When 3.3V-LVTTL or 3.3V-CMOS use, 3.3V is added to a pin number 3(VCCIO input).
- When 3.0V-CMOS use, 3.0V is added to a pin number 3(VCCIO input).
- When supplying the outside reference power supply to ADC and using it, the reference voltage is added to a pin number 39(ADC VREF input).
- The time of a boot moves as BOOT_SEL pin for a pin number 26. When using it as I/O pin because a pull-up to 3.3V by 10k-Ohm in the board again, be careful.


###JTAG connector

|Number|FPGA pin|contents|
|---|---|---|
|1|PIN_18|TCK|
|2| |GND|
|3|PIN_20|TDO|
|4| |3.3V|
|5|PIN_16|TMS|
|6| |n.c|
|7| |n.c|
|8|PIN_15|JTAG_EN|
|9|PIN_19|TDI|
|10| |GND|

- TDI,TMS,JTAG_EN a pull-up to 3.3V by 10k-Ohm.
- TCK a pull-down to GND by 1k-Ohm.

* It's equipped with a device of ES items in SODALITE v1.0.
* When a defect of JTAG occurred in SODALITE, it sometimes becomes stable by inserting 74HC buffer in a signal line of TCK/TDO/TMS.
* Please check the latest errata on the Web site of ALTERA for more information.


###Onboard-OSC

|Signal|FPGA pin|Dir|contets|
|---|---|---|---|
|FREQ_SEL|PIN_26|O|Frequency select|
|CLKIN|PIN_27|I|Clock input|

On-board OSC can choose 3 kinds of 50.000 MHz/24.576 MHz/74.25 MHz in the state of the FREQ_SEL pin.

|FREQ_SEL output|OSC Frequency|
|---|---|
|H|50.000MHz|
|L|74.250MHz|
|Hi-Z|24.576MHz|


###SDRAM

|Signal|FPGA pin|Dir|contets|
|---|---|---|---|
|SDR_A0|PIN_77|O|address|
|SDR_A1|PIN_76|O|address|
|SDR_A2|PIN_75|O|address|
|SDR_A3|PIN_74|O|address|
|SDR_A4|PIN_69|O|address|
|SDR_A5|PIN_70|O|address|
|SDR_A6|PIN_66|O|address|
|SDR_A7|PIN_65|O|address|
|SDR_A8|PIN_64|O|address|
|SDR_A9|PIN_62|O|address|
|SDR_A10|PIN_78|O|address and Auto Pre-charge|
|SDR_A11|PIN_61|O|address|
|SDR_A12|PIN_87|O|address|
|SDR_BA0|PIN_80|O|bank-address|
|SDR_BA1|PIN_79|O|bank-address|
|SDR_CS_N|PIN_81|O|Chip select|
|SDR_RAS_N|PIN_84|O|Row active|
|SDR_CAS_N|PIN_85|O|Column active|
|SDR_WE_N|PIN_86|O|Write enable|
|SDR_CLK|PIN_89|O|Clock output|
|SDR_CLE|PIN_88|O|Clock enable|
|SDR_DQM0|PIN_96|O|Lower-byte data enable|
|SDR_DQM1|PIN_90|O|Upper-byte data enable|
|SDR_DQ0|PIN_106|I/O|data|
|SDR_DQ1|PIN_105|I/O|data|
|SDR_DQ2|PIN_102|I/O|data|
|SDR_DQ3|PIN_101|I/O|data|
|SDR_DQ4|PIN_100|I/O|data|
|SDR_DQ5|PIN_99|I/O|data|
|SDR_DQ6|PIN_98|I/O|data|
|SDR_DQ7|PIN_97|I/O|data|
|SDR_DQ8|PIN_91|I/O|data|
|SDR_DQ9|PIN_92|I/O|data|
|SDR_DQ10|PIN_93|I/O|data|
|SDR_DQ11|PIN_110|I/O|data|
|SDR_DQ12|PIN_111|I/O|data|
|SDR_DQ13|PIN_113|I/O|data|
|SDR_DQ14|PIN_114|I/O|data|
|SDR_DQ15|PIN_118|I/O|data|


###LED

|Signal|FPGA pin|Dir|contents|
|---|---|---|---|
|LED|PIN_135|O|lights up by 'H'|


------------------------------------------------------------------------
##Electrical characteristics

|Item|contents|
|---|---|
|Voltage|3.3V +/-5%|
|VCCIO Voltage|3.3V, 3.0V, 2.5V|
|ADC VREF Voltage|2.5V +/-5%|
|Op. Current|250mA(Typical value of 100MHz driven)|
|I/O rating|+/-8mA(max)|

- A VCCIO voltage is proportionate to the I/O standard of MAX10.
- A ADC VREF voltage is at the time of the outside reference voltage use.
- A consumption current is at the time of resource usage rate 85%, 100MHz drive and SDRAM movement.
- The I/O pin rating is based on the specification of MAX10 device.


------------------------------------------------------------------------
##Schematic

Refer to a repository for a schematic and a sample of a project.


------------------------------------------------------------------------
##License

SODALITE Hardware is released under the [Creative Commons,CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)  
![CC BY](https://licensebuttons.net/l/by/4.0/88x31.png)  

