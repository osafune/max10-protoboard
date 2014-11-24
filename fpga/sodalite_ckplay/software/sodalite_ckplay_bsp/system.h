/*
 * system.h - SOPC Builder system and BSP software package information
 *
 * Machine generated for CPU 'nios2_gen2_f' in SOPC Builder design 'testcore'
 * SOPC Builder design path: ../../testcore.sopcinfo
 *
 * Generated: Mon Nov 17 05:33:43 JST 2014
 */

/*
 * DO NOT MODIFY THIS FILE
 *
 * Changing this file will have subtle consequences
 * which will almost certainly lead to a nonfunctioning
 * system. If you do modify this file, be aware that your
 * changes will be overwritten and lost when this file
 * is generated again.
 *
 * DO NOT MODIFY THIS FILE
 */

/*
 * License Agreement
 *
 * Copyright (c) 2008
 * Altera Corporation, San Jose, California, USA.
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * This agreement shall be governed in all respects by the laws of the State
 * of California and by the laws of the United States of America.
 */

#ifndef __SYSTEM_H_
#define __SYSTEM_H_

/* Include definitions from linker script generator */
#include "linker.h"


/*
 * CPU configuration
 *
 */

#define ALT_CPU_ARCHITECTURE "altera_nios2_gen2"
#define ALT_CPU_BIG_ENDIAN 0
#define ALT_CPU_BREAK_ADDR 0x0fff0820
#define ALT_CPU_CPU_ARCH_NIOS2_R1
#define ALT_CPU_CPU_FREQ 100000000u
#define ALT_CPU_CPU_ID_SIZE 1
#define ALT_CPU_CPU_ID_VALUE 0x00000000
#define ALT_CPU_CPU_IMPLEMENTATION "fast"
#define ALT_CPU_DATA_ADDR_WIDTH 0x1d
#define ALT_CPU_DCACHE_BYPASS_MASK 0x80000000
#define ALT_CPU_DCACHE_LINE_SIZE 32
#define ALT_CPU_DCACHE_LINE_SIZE_LOG2 5
#define ALT_CPU_DCACHE_SIZE 8192
#define ALT_CPU_EXCEPTION_ADDR 0x00000020
#define ALT_CPU_FLUSHDA_SUPPORTED
#define ALT_CPU_FREQ 100000000
#define ALT_CPU_HARDWARE_DIVIDE_PRESENT 0
#define ALT_CPU_HARDWARE_MULTIPLY_PRESENT 1
#define ALT_CPU_HARDWARE_MULX_PRESENT 1
#define ALT_CPU_HAS_DEBUG_CORE 1
#define ALT_CPU_HAS_DEBUG_STUB
#define ALT_CPU_HAS_EXTRA_EXCEPTION_INFO
#define ALT_CPU_HAS_ILLEGAL_INSTRUCTION_EXCEPTION
#define ALT_CPU_HAS_JMPI_INSTRUCTION
#define ALT_CPU_ICACHE_LINE_SIZE 32
#define ALT_CPU_ICACHE_LINE_SIZE_LOG2 5
#define ALT_CPU_ICACHE_SIZE 8192
#define ALT_CPU_INITDA_SUPPORTED
#define ALT_CPU_INST_ADDR_WIDTH 0x1c
#define ALT_CPU_NAME "nios2_gen2_f"
#define ALT_CPU_NUM_OF_SHADOW_REG_SETS 0
#define ALT_CPU_RESET_ADDR 0x0f000000


/*
 * CPU configuration (with legacy prefix - don't use these anymore)
 *
 */

#define NIOS2_BIG_ENDIAN 0
#define NIOS2_BREAK_ADDR 0x0fff0820
#define NIOS2_CPU_ARCH_NIOS2_R1
#define NIOS2_CPU_FREQ 100000000u
#define NIOS2_CPU_ID_SIZE 1
#define NIOS2_CPU_ID_VALUE 0x00000000
#define NIOS2_CPU_IMPLEMENTATION "fast"
#define NIOS2_DATA_ADDR_WIDTH 0x1d
#define NIOS2_DCACHE_BYPASS_MASK 0x80000000
#define NIOS2_DCACHE_LINE_SIZE 32
#define NIOS2_DCACHE_LINE_SIZE_LOG2 5
#define NIOS2_DCACHE_SIZE 8192
#define NIOS2_EXCEPTION_ADDR 0x00000020
#define NIOS2_FLUSHDA_SUPPORTED
#define NIOS2_HARDWARE_DIVIDE_PRESENT 0
#define NIOS2_HARDWARE_MULTIPLY_PRESENT 1
#define NIOS2_HARDWARE_MULX_PRESENT 1
#define NIOS2_HAS_DEBUG_CORE 1
#define NIOS2_HAS_DEBUG_STUB
#define NIOS2_HAS_EXTRA_EXCEPTION_INFO
#define NIOS2_HAS_ILLEGAL_INSTRUCTION_EXCEPTION
#define NIOS2_HAS_JMPI_INSTRUCTION
#define NIOS2_ICACHE_LINE_SIZE 32
#define NIOS2_ICACHE_LINE_SIZE_LOG2 5
#define NIOS2_ICACHE_SIZE 8192
#define NIOS2_INITDA_SUPPORTED
#define NIOS2_INST_ADDR_WIDTH 0x1c
#define NIOS2_NUM_OF_SHADOW_REG_SETS 0
#define NIOS2_RESET_ADDR 0x0f000000


/*
 * Custom instruction macros
 *
 */

#define ALT_CI_PIXELSIMD(n,A,B) __builtin_custom_inii(ALT_CI_PIXELSIMD_N+(n&ALT_CI_PIXELSIMD_N_MASK),(A),(B))
#define ALT_CI_PIXELSIMD_N 0x0
#define ALT_CI_PIXELSIMD_N_MASK ((1<<3)-1)


/*
 * Define for each module class mastered by the CPU
 *
 */

#define __ALTERA_AVALON_JTAG_UART
#define __ALTERA_AVALON_NEW_SDRAM_CONTROLLER
#define __ALTERA_AVALON_ONCHIP_MEMORY2
#define __ALTERA_AVALON_PIO
#define __ALTERA_AVALON_SYSID_QSYS
#define __ALTERA_AVALON_TIMER
#define __ALTERA_MODULAR_ADC
#define __ALTERA_NIOS2_GEN2
#define __ALTERA_ONCHIP_FLASH
#define __MMCDMA
#define __PIXELSIMD
#define __VGA_COMPONENT


/*
 * System configuration
 *
 */

#define ALT_DEVICE_FAMILY "MAX 10 FPGA"
#define ALT_ENHANCED_INTERRUPT_API_PRESENT
#define ALT_IRQ_BASE NULL
#define ALT_LOG_PORT "/dev/null"
#define ALT_LOG_PORT_BASE 0x0
#define ALT_LOG_PORT_DEV null
#define ALT_LOG_PORT_TYPE ""
#define ALT_NUM_EXTERNAL_INTERRUPT_CONTROLLERS 0
#define ALT_NUM_INTERNAL_INTERRUPT_CONTROLLERS 1
#define ALT_NUM_INTERRUPT_CONTROLLERS 1
#define ALT_STDERR "/dev/jtag_uart"
#define ALT_STDERR_BASE 0x10000040
#define ALT_STDERR_DEV jtag_uart
#define ALT_STDERR_IS_JTAG_UART
#define ALT_STDERR_PRESENT
#define ALT_STDERR_TYPE "altera_avalon_jtag_uart"
#define ALT_STDIN "/dev/jtag_uart"
#define ALT_STDIN_BASE 0x10000040
#define ALT_STDIN_DEV jtag_uart
#define ALT_STDIN_IS_JTAG_UART
#define ALT_STDIN_PRESENT
#define ALT_STDIN_TYPE "altera_avalon_jtag_uart"
#define ALT_STDOUT "/dev/jtag_uart"
#define ALT_STDOUT_BASE 0x10000040
#define ALT_STDOUT_DEV jtag_uart
#define ALT_STDOUT_IS_JTAG_UART
#define ALT_STDOUT_PRESENT
#define ALT_STDOUT_TYPE "altera_avalon_jtag_uart"
#define ALT_SYSTEM_NAME "testcore"


/*
 * hal configuration
 *
 */

#define ALT_INCLUDE_INSTRUCTION_RELATED_EXCEPTION_API
#define ALT_MAX_FD 32
#define ALT_SYS_CLK SYSTIMER
#define ALT_TIMESTAMP_CLK none


/*
 * ipl_memory configuration
 *
 */

#define ALT_MODULE_CLASS_ipl_memory altera_avalon_onchip_memory2
#define IPL_MEMORY_ALLOW_IN_SYSTEM_MEMORY_CONTENT_EDITOR 0
#define IPL_MEMORY_ALLOW_MRAM_SIM_CONTENTS_ONLY_FILE 0
#define IPL_MEMORY_BASE 0xf000000
#define IPL_MEMORY_CONTENTS_INFO ""
#define IPL_MEMORY_DUAL_PORT 0
#define IPL_MEMORY_GUI_RAM_BLOCK_TYPE "AUTO"
#define IPL_MEMORY_INIT_CONTENTS_FILE "testcore_ipl_memory"
#define IPL_MEMORY_INIT_MEM_CONTENT 1
#define IPL_MEMORY_INSTANCE_ID "NONE"
#define IPL_MEMORY_IRQ -1
#define IPL_MEMORY_IRQ_INTERRUPT_CONTROLLER_ID -1
#define IPL_MEMORY_NAME "/dev/ipl_memory"
#define IPL_MEMORY_NON_DEFAULT_INIT_FILE_ENABLED 0
#define IPL_MEMORY_RAM_BLOCK_TYPE "AUTO"
#define IPL_MEMORY_READ_DURING_WRITE_MODE "DONT_CARE"
#define IPL_MEMORY_SINGLE_CLOCK_OP 0
#define IPL_MEMORY_SIZE_MULTIPLE 1
#define IPL_MEMORY_SIZE_VALUE 8192
#define IPL_MEMORY_SPAN 8192
#define IPL_MEMORY_TYPE "altera_avalon_onchip_memory2"
#define IPL_MEMORY_WRITABLE 1


/*
 * jtag_uart configuration
 *
 */

#define ALT_MODULE_CLASS_jtag_uart altera_avalon_jtag_uart
#define JTAG_UART_BASE 0x10000040
#define JTAG_UART_IRQ 1
#define JTAG_UART_IRQ_INTERRUPT_CONTROLLER_ID 0
#define JTAG_UART_NAME "/dev/jtag_uart"
#define JTAG_UART_READ_DEPTH 64
#define JTAG_UART_READ_THRESHOLD 8
#define JTAG_UART_SPAN 8
#define JTAG_UART_TYPE "altera_avalon_jtag_uart"
#define JTAG_UART_WRITE_DEPTH 64
#define JTAG_UART_WRITE_THRESHOLD 8


/*
 * led configuration
 *
 */

#define ALT_MODULE_CLASS_led altera_avalon_pio
#define LED_BASE 0x10000060
#define LED_BIT_CLEARING_EDGE_REGISTER 0
#define LED_BIT_MODIFYING_OUTPUT_REGISTER 0
#define LED_CAPTURE 0
#define LED_DATA_WIDTH 1
#define LED_DO_TEST_BENCH_WIRING 0
#define LED_DRIVEN_SIM_VALUE 0
#define LED_EDGE_TYPE "NONE"
#define LED_FREQ 40000000
#define LED_HAS_IN 0
#define LED_HAS_OUT 1
#define LED_HAS_TRI 0
#define LED_IRQ -1
#define LED_IRQ_INTERRUPT_CONTROLLER_ID -1
#define LED_IRQ_TYPE "NONE"
#define LED_NAME "/dev/led"
#define LED_RESET_VALUE 0
#define LED_SPAN 16
#define LED_TYPE "altera_avalon_pio"


/*
 * mmcdma configuration
 *
 */

#define ALT_MODULE_CLASS_mmcdma mmcdma
#define MMCDMA_BASE 0x10000400
#define MMCDMA_IRQ 9
#define MMCDMA_IRQ_INTERRUPT_CONTROLLER_ID 0
#define MMCDMA_NAME "/dev/mmcdma"
#define MMCDMA_SPAN 1024
#define MMCDMA_TYPE "mmcdma"


/*
 * modular_adc_0_sample_store_csr configuration
 *
 */

#define ALT_MODULE_CLASS_modular_adc_0_sample_store_csr altera_modular_adc
#define MODULAR_ADC_0_SAMPLE_STORE_CSR_BASE 0x10000800
#define MODULAR_ADC_0_SAMPLE_STORE_CSR_IRQ -1
#define MODULAR_ADC_0_SAMPLE_STORE_CSR_IRQ_INTERRUPT_CONTROLLER_ID -1
#define MODULAR_ADC_0_SAMPLE_STORE_CSR_NAME "/dev/modular_adc_0_sample_store_csr"
#define MODULAR_ADC_0_SAMPLE_STORE_CSR_SPAN 512
#define MODULAR_ADC_0_SAMPLE_STORE_CSR_TYPE "altera_modular_adc"


/*
 * modular_adc_0_sequencer_csr configuration
 *
 */

#define ALT_MODULE_CLASS_modular_adc_0_sequencer_csr altera_modular_adc
#define MODULAR_ADC_0_SEQUENCER_CSR_BASE 0x10000a00
#define MODULAR_ADC_0_SEQUENCER_CSR_IRQ -1
#define MODULAR_ADC_0_SEQUENCER_CSR_IRQ_INTERRUPT_CONTROLLER_ID -1
#define MODULAR_ADC_0_SEQUENCER_CSR_NAME "/dev/modular_adc_0_sequencer_csr"
#define MODULAR_ADC_0_SEQUENCER_CSR_SPAN 8
#define MODULAR_ADC_0_SEQUENCER_CSR_TYPE "altera_modular_adc"


/*
 * onchip_flash_0_csr configuration
 *
 */

#define ALT_MODULE_CLASS_onchip_flash_0_csr altera_onchip_flash
#define ONCHIP_FLASH_0_CSR_BASE 0x1000f000
#define ONCHIP_FLASH_0_CSR_BYTES_PER_PAGE 2048
#define ONCHIP_FLASH_0_CSR_IRQ -1
#define ONCHIP_FLASH_0_CSR_IRQ_INTERRUPT_CONTROLLER_ID -1
#define ONCHIP_FLASH_0_CSR_NAME "/dev/onchip_flash_0_csr"
#define ONCHIP_FLASH_0_CSR_READ_ONLY_MODE 0
#define ONCHIP_FLASH_0_CSR_SECTOR1_ENABLED 1
#define ONCHIP_FLASH_0_CSR_SECTOR1_END_ADDR 0x3fff
#define ONCHIP_FLASH_0_CSR_SECTOR1_START_ADDR 0
#define ONCHIP_FLASH_0_CSR_SECTOR2_ENABLED 1
#define ONCHIP_FLASH_0_CSR_SECTOR2_END_ADDR 0x7fff
#define ONCHIP_FLASH_0_CSR_SECTOR2_START_ADDR 0x4000
#define ONCHIP_FLASH_0_CSR_SECTOR3_ENABLED 0
#define ONCHIP_FLASH_0_CSR_SECTOR3_END_ADDR 0xffffffff
#define ONCHIP_FLASH_0_CSR_SECTOR3_START_ADDR 0xffffffff
#define ONCHIP_FLASH_0_CSR_SECTOR4_ENABLED 0
#define ONCHIP_FLASH_0_CSR_SECTOR4_END_ADDR 0xffffffff
#define ONCHIP_FLASH_0_CSR_SECTOR4_START_ADDR 0xffffffff
#define ONCHIP_FLASH_0_CSR_SECTOR5_ENABLED 0
#define ONCHIP_FLASH_0_CSR_SECTOR5_END_ADDR 0xffffffff
#define ONCHIP_FLASH_0_CSR_SECTOR5_START_ADDR 0xffffffff
#define ONCHIP_FLASH_0_CSR_SPAN 8
#define ONCHIP_FLASH_0_CSR_TYPE "altera_onchip_flash"


/*
 * onchip_flash_0_data configuration
 *
 */

#define ALT_MODULE_CLASS_onchip_flash_0_data altera_onchip_flash
#define ONCHIP_FLASH_0_DATA_BASE 0xf100000
#define ONCHIP_FLASH_0_DATA_BYTES_PER_PAGE 2048
#define ONCHIP_FLASH_0_DATA_IRQ -1
#define ONCHIP_FLASH_0_DATA_IRQ_INTERRUPT_CONTROLLER_ID -1
#define ONCHIP_FLASH_0_DATA_NAME "/dev/onchip_flash_0_data"
#define ONCHIP_FLASH_0_DATA_READ_ONLY_MODE 0
#define ONCHIP_FLASH_0_DATA_SECTOR1_ENABLED 1
#define ONCHIP_FLASH_0_DATA_SECTOR1_END_ADDR 0x3fff
#define ONCHIP_FLASH_0_DATA_SECTOR1_START_ADDR 0
#define ONCHIP_FLASH_0_DATA_SECTOR2_ENABLED 1
#define ONCHIP_FLASH_0_DATA_SECTOR2_END_ADDR 0x7fff
#define ONCHIP_FLASH_0_DATA_SECTOR2_START_ADDR 0x4000
#define ONCHIP_FLASH_0_DATA_SECTOR3_ENABLED 0
#define ONCHIP_FLASH_0_DATA_SECTOR3_END_ADDR 0xffffffff
#define ONCHIP_FLASH_0_DATA_SECTOR3_START_ADDR 0xffffffff
#define ONCHIP_FLASH_0_DATA_SECTOR4_ENABLED 0
#define ONCHIP_FLASH_0_DATA_SECTOR4_END_ADDR 0xffffffff
#define ONCHIP_FLASH_0_DATA_SECTOR4_START_ADDR 0xffffffff
#define ONCHIP_FLASH_0_DATA_SECTOR5_ENABLED 0
#define ONCHIP_FLASH_0_DATA_SECTOR5_END_ADDR 0xffffffff
#define ONCHIP_FLASH_0_DATA_SECTOR5_START_ADDR 0xffffffff
#define ONCHIP_FLASH_0_DATA_SPAN 32768
#define ONCHIP_FLASH_0_DATA_TYPE "altera_onchip_flash"


/*
 * sdram configuration
 *
 */

#define ALT_MODULE_CLASS_sdram altera_avalon_new_sdram_controller
#define SDRAM_BASE 0x0
#define SDRAM_CAS_LATENCY 2
#define SDRAM_CONTENTS_INFO
#define SDRAM_INIT_NOP_DELAY 0.0
#define SDRAM_INIT_REFRESH_COMMANDS 8
#define SDRAM_IRQ -1
#define SDRAM_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SDRAM_IS_INITIALIZED 1
#define SDRAM_NAME "/dev/sdram"
#define SDRAM_POWERUP_DELAY 200.0
#define SDRAM_REFRESH_PERIOD 7.8125
#define SDRAM_REGISTER_DATA_IN 1
#define SDRAM_SDRAM_ADDR_WIDTH 0x18
#define SDRAM_SDRAM_BANK_WIDTH 2
#define SDRAM_SDRAM_COL_WIDTH 9
#define SDRAM_SDRAM_DATA_WIDTH 16
#define SDRAM_SDRAM_NUM_BANKS 4
#define SDRAM_SDRAM_NUM_CHIPSELECTS 1
#define SDRAM_SDRAM_ROW_WIDTH 13
#define SDRAM_SHARED_DATA 0
#define SDRAM_SIM_MODEL_BASE 0
#define SDRAM_SPAN 33554432
#define SDRAM_STARVATION_INDICATOR 0
#define SDRAM_TRISTATE_BRIDGE_SLAVE ""
#define SDRAM_TYPE "altera_avalon_new_sdram_controller"
#define SDRAM_T_AC 6.5
#define SDRAM_T_MRD 3
#define SDRAM_T_RCD 21.0
#define SDRAM_T_RFC 63.0
#define SDRAM_T_RP 21.0
#define SDRAM_T_WR 14.0


/*
 * sysid configuration
 *
 */

#define ALT_MODULE_CLASS_sysid altera_avalon_sysid_qsys
#define SYSID_BASE 0x10000000
#define SYSID_ID 538186003
#define SYSID_IRQ -1
#define SYSID_IRQ_INTERRUPT_CONTROLLER_ID -1
#define SYSID_NAME "/dev/sysid"
#define SYSID_SPAN 8
#define SYSID_TIMESTAMP 1416068547
#define SYSID_TYPE "altera_avalon_sysid_qsys"


/*
 * systimer configuration
 *
 */

#define ALT_MODULE_CLASS_systimer altera_avalon_timer
#define SYSTIMER_ALWAYS_RUN 0
#define SYSTIMER_BASE 0x10000020
#define SYSTIMER_COUNTER_SIZE 32
#define SYSTIMER_FIXED_PERIOD 0
#define SYSTIMER_FREQ 40000000
#define SYSTIMER_IRQ 0
#define SYSTIMER_IRQ_INTERRUPT_CONTROLLER_ID 0
#define SYSTIMER_LOAD_VALUE 39999
#define SYSTIMER_MULT 0.0010
#define SYSTIMER_NAME "/dev/systimer"
#define SYSTIMER_PERIOD 1
#define SYSTIMER_PERIOD_UNITS "ms"
#define SYSTIMER_RESET_OUTPUT 0
#define SYSTIMER_SNAPSHOT 1
#define SYSTIMER_SPAN 32
#define SYSTIMER_TICKS_PER_SEC 1000
#define SYSTIMER_TIMEOUT_PULSE_OUTPUT 0
#define SYSTIMER_TYPE "altera_avalon_timer"


/*
 * vga configuration
 *
 */

#define ALT_MODULE_CLASS_vga vga_component
#define VGA_BASE 0x10001000
#define VGA_IRQ 4
#define VGA_IRQ_INTERRUPT_CONTROLLER_ID 0
#define VGA_NAME "/dev/vga"
#define VGA_SPAN 16
#define VGA_TYPE "vga_component"

#endif /* __SYSTEM_H_ */
