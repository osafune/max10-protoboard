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

#ifndef __ALT_MODULAR_ADC_H__
#define __ALT_MODULAR_ADC_H__

#include <stddef.h>
#include "priv/alt_dev_llist.h"
#include "sys/alt_dev.h"
#include "os/alt_sem.h"
#include "altera_modular_adc_sequencer_regs.h"
#include "altera_modular_adc_sample_store_regs.h"

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

typedef struct alt_modular_adc_dev
{
    alt_dev dev;
} alt_modular_adc_dev;

/*
 * Public APIs
 */
alt_modular_adc_dev* altera_modular_adc_open (const char *name);

/*
 *   Use by alt_sys_init.c
 *
 */

#define ALTERA_MODULAR_ADC_INSTANCE(name, dev) \
static alt_modular_adc_dev dev =    \
{                                   \
  {                                 \
    ALT_LLIST_ENTRY,                \
    name##_SEQUENCER_CSR_NAME,      \
    altera_modular_adc_open,        \
    NULL,                           \
    NULL,                           \
    NULL,                           \
    NULL,                           \
    NULL,                           \
    NULL,                           \
  }                                 \
}

extern void altera_modular_adc_init
(
    alt_modular_adc_dev* dev
);

#define ALTERA_MODULAR_ADC_INIT(name, dev) \
{                                           \
    altera_modular_adc_init                 \
    (                                       \
        &dev                                \
    );                                      \
}

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __ALT_MODULAR_ADC_H__ */
