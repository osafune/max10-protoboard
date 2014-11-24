/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2014 Altera Corporation, San Jose, California, USA.           *
* All rights reserved.                                                        *
*                                                                             *
* Permission is hereby granted, free of charge, to any person obtaining a     *
* copy of this software and associated documentation files (the "Software"),  *
* to deal in the Software without restriction, including without limitation   *
* the rights to use, copy, modify, merge, publish, distribute, sublicense,    *
* and/or sell copies of the Software, and to permit persons to whom the       *
* Software is furnished to do so, subject to the following conditions:        *
*                                                                             *
* The above copyright notice and this permission notice shall be included in  *
* all copies or substantial portions of the Software.                         *
*                                                                             *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  *
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    *
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE *
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      *
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     *
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         *
* DEALINGS IN THE SOFTWARE.                                                   *
*                                                                             *
* This agreement shall be governed in all respects by the laws of the State   *
* of California and by the laws of the United States of America.              *
*                                                                             *
******************************************************************************/

#ifndef __ALTERA_MODULAR_ADC_SEQUENCER_REGS_H__
#define __ALTERA_MODULAR_ADC_SEQUENCER_REGS_H__

#include <io.h>

/*
 * Sequencer Core Command Register Register
 */
#define ALTERA_MODULAR_ADC_SEQUENCER_CMD_REG                    0
#define ALTERA_MODULAR_ADC_SEQUENCER_CMD_MSK                    (0x0000000F)

#define ALTERA_MODULAR_ADC_SEQUENCER_CMD_RUN_MSK                (0x00000001)
#define ALTERA_MODULAR_ADC_SEQUENCER_CMD_RUN_START              (0x00000001)
#define ALTERA_MODULAR_ADC_SEQUENCER_CMD_RUN_STOP               (0x00000000)

#define ALTERA_MODULAR_ADC_SEQUENCER_CMD_MODE_MSK               (0x0000000E)
#define ALTERA_MODULAR_ADC_SEQUENCER_CMD_MODE_CONTINUOUS        (0x00000000)
#define ALTERA_MODULAR_ADC_SEQUENCER_CMD_MODE_ONCE              (0x00000002)
#define ALTERA_MODULAR_ADC_SEQUENCER_CMD_MODE_RECALIBRATE       (0x0000000E)

#endif /* __ALTERA_MODULAR_ADC_SEQUENCER_REGS_H__ */
