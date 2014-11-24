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

#ifndef __ALT_ONCHIP_FLASH_H__
#define __ALT_ONCHIP_FLASH_H__

#include "alt_types.h"
#include "sys/alt_flash_dev.h"
#include "sys/alt_llist.h"

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

/*
 *  Getting started:
 *  Nios II Software Developer's Handbook (URL: http://www.altera.com/literature/lit-nio2.jsp)
 *  -> Section II. Hardware Abstraction Layer
 *     -> Chapter 6. Developing Programs Using the Hardware Abstraction Layer
 *        -> Using Flash Devices
 */

/*
 *  Description of the flash
 */
typedef struct alt_onchip_flash_dev
{
    /* Flash common declaration */
    alt_flash_dev dev;

    /* IP specific information */
    int           is_read_only;
    void          *csr_base;
    int           sector1_enabled;
    int           sector1_start_addr;
    int           sector1_end_addr;
    int           sector2_enabled;
    int           sector2_start_addr;
    int           sector2_end_addr;
    int           sector3_enabled;
    int           sector3_start_addr;
    int           sector3_end_addr;
    int           sector4_enabled;
    int           sector4_start_addr;
    int           sector4_end_addr;
    int           sector5_enabled;
    int           sector5_start_addr;
    int           sector5_end_addr;
    int           page_size;
} alt_onchip_flash_dev;

/*
*   Macros used by alt_sys_init.c
*
*/
#define ALTERA_ONCHIP_FLASH_INSTANCE(name, dev) \
static alt_onchip_flash_dev dev =   \
{                                   \
  {                                 \
    ALT_LLIST_ENTRY,                \
    name##_DATA_NAME,               \
    NULL,                           \
    NULL,                           \
    alt_onchip_flash_write,         \
    alt_onchip_flash_read,          \
    alt_onchip_flash_get_info,      \
    alt_onchip_flash_erase_block,   \
    alt_onchip_flash_write_block,   \
    ((void*)(name##_DATA_BASE)),    \
    ((int)(name##_DATA_SPAN)),      \
    0                               \
  },                                \
  name##_DATA_READ_ONLY_MODE,       \
  ((void*)(name##_CSR_BASE)),       \
  name##_DATA_SECTOR1_ENABLED,      \
  name##_DATA_SECTOR1_START_ADDR,   \
  name##_DATA_SECTOR1_END_ADDR,     \
  name##_DATA_SECTOR2_ENABLED,      \
  name##_DATA_SECTOR2_START_ADDR,   \
  name##_DATA_SECTOR2_END_ADDR,     \
  name##_DATA_SECTOR3_ENABLED,      \
  name##_DATA_SECTOR3_START_ADDR,   \
  name##_DATA_SECTOR3_END_ADDR,     \
  name##_DATA_SECTOR4_ENABLED,      \
  name##_DATA_SECTOR4_START_ADDR,   \
  name##_DATA_SECTOR4_END_ADDR,     \
  name##_DATA_SECTOR5_ENABLED,      \
  name##_DATA_SECTOR5_START_ADDR,   \
  name##_DATA_SECTOR5_END_ADDR,     \
  name##_DATA_BYTES_PER_PAGE        \
}

/*
    Public API

    Refer to “Using Flash Devices” in the
    Developing Programs Using the Hardware Abstraction Layer chapter
    of the Nios II Software Developer’s Handbook.

*/

int alt_onchip_flash_read(alt_flash_dev *flash_info, int offset, void *dest_addr, int length);

int alt_onchip_flash_get_info(alt_flash_fd *fd, flash_region **info, int *number_of_regions);

int alt_onchip_flash_erase_block(alt_flash_dev *flash_info, int block_offset);

int alt_onchip_flash_write_block(alt_flash_dev *flash_info, int block_offset, int data_offset, const void *data, int length);

int alt_onchip_flash_write(alt_flash_dev *flash_info, int offset, const void *src_addr, int length);

/*
 * Initialization function
 */
extern void altera_onchip_flash_init(alt_onchip_flash_dev *dev);

/*
 * alt_sys_init.c will call this macro automatically
 */
#define ALTERA_ONCHIP_FLASH_INIT(name, dev) { altera_onchip_flash_init(&dev); }


/*
	Private API

	Helper functions used by Public API functions.
*/

int alt_onchip_flash_poll_for_status_to_go_idle(alt_onchip_flash_dev *flash);

int alt_onchip_flash_poll_for_status_erase_passed(alt_onchip_flash_dev* flash);

int alt_onchip_flash_poll_for_status_write_passed(alt_onchip_flash_dev* flash);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __ALT_ONCHIP_FLASH_H__ */
