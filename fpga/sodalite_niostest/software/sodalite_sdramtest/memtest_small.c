/**************************************************************************
 * Copyright (c) 2009 Altera Corporation, San Jose, California, USA.      *
 * All rights reserved. All use of this software and documentation is     *
 * subject to the License Agreement located at the end of this file below.*
 *************************************************************************/
/**************************************************************************
 *
 * 
 * Description
 *************** 
 * This is a test program which tests RAM memory. 
 *
 * 
 * Requirements
 ****************
 * This is a "Hosted" application. According to the ANSI C standard, hosted 
 * applications can rely on numerous system-services (including properly-
 * initialized device drivers and, in this case, STDOUT).  
 * 
 * When this program is compiled, code is added before main(), so that all 
 * devices are properly-initialized and all system-services (e.g. the <stdio>
 * library) are ready-to-use. In this hosted environment, all standard C 
 * programs will run.
 * 
 * A hosted application (like this example) does not need to concern itself 
 * with initializing devices. As long as it only calls C Standard Library 
 * functions, a hosted application can run "as if on a workstation."
 * 
 * An application runs in a hosted environment if it declares the function 
 * main(), which this application does.
 * 
 * This software example requires a STDOUT component such as a UART or 
 * JTAG UART and 2 RAM components (one for running
 * the program, and one for testing)  Therefore it can run on the following
 * hardware examples:
 * 
 * Nios Development Board, Stratix II Edition:
 * -  Standard
 * -  Full Featured
 *
 * DSP Development Board, Stratix II Edition:
 * -  Standard
 * -  Full Featured
 *
 * Nios Development Board, Stratix Edition:
 * -  Standard
 * -  Full Featured
 * 
 * Nios Development Board, Stratix Professional Edition:
 * -  Standard
 * -  Full Featured
 * 
 * Nios Development Board, Cyclone Edition:
 * -  Standard
 * -  Full Featured
 *
 * Nios Development Board, Cyclone II Edition:
 * -  Standard
 * -  Full Featured
 *
 * Note: This example will not run on the Nios II Instruction Set Simulator
 * 
 **************************************************************************/


#include <stdio.h>
#include <alt_types.h>
#include <io.h>
#include <system.h>
#include <string.h>
#include <stdlib.h>

#include "sys/alt_stdio.h"
#include "system.h"

/******************************************************************
*  Function: MenuHeader
*
*  Purpose: Prints the menu header.
*
******************************************************************/
static void MenuHeader(void)
{
  printf("\n\n");
  printf("             <---->   Nios II Memory Test.   <---->\n");
  printf("This software example tests the memory in your system to assure it\n");
  printf("is working properly.  This test is destructive to the contents of\n");
  printf("the memory it tests. Assure the memory being tested does not contain\n");
  printf("the executable or data sections of this code or the exception address\n");
  printf("of the system.\n");
}

/******************************************************************
*  Function: GetInputString
*
*  Purpose: Parses an input string for the character '\n'.  Then
*           returns the string, minus any '\r' characters it 
*           encounters.
*
******************************************************************/
void GetInputString( char* entry, int size, FILE * stream )
{
  int i;
  int ch = 0;
  
  for(i = 0; (ch != '\n') && (i < size); )
  {
    if( (ch = alt_getchar()) != '\r')
    {
      putchar(ch);
      entry[i] = ch;
      i++;
    }
  }
}

/******************************************************************
*  Function: MemGetAddressRange
*
*  Purpose: Gathers a range of memory from the user.
*
******************************************************************/
static int MemGetAddressRange(int* base_address, int* end_address)
{

  char line[12];
  char *pend;

  while(1)
  {
    /* Get the base address */
    printf("Base address to start memory test: (i.e. 0x800000)\n");
    printf(">");

    GetInputString( line, sizeof(line), stdin );
   
    /* Check the format to make sure it was entered as hex */
    
    if((*base_address = strtol(line, &pend, 16)) < 0)
    {
      printf("%s\n", line);
      printf(" -ERROR: Invalid base address entered.  Address must be in the form '0x800000'\n\n");
      continue;
    }
    
    /* Get the end address */
    printf("End Address:\n");
    printf(">");

    GetInputString( line, sizeof(line), stdin );
    
    /* Check the format to make sure it was entered as hex */
    if((*end_address = strtol(line, &pend, 16)) < 0)
    {
      printf(" -ERROR: Invalid end address entered.  Address must be in the form '0x8FFFFF'\n\n");
      continue;
    }
    
    /* Make sure end address is greater than base address. */
    if (*end_address <= *base_address)
    {
      printf(" -ERROR: End address must be greater than the start address\n\n");

      continue;
    }
    break;
  }

  return(0);
}

/******************************************************************
*  Function: MemTestDataBus
*
*  Purpose: Tests that the data bus is connected with no 
*           stuck-at's, shorts, or open circuits.
*
******************************************************************/
static int MemTestDataBus(unsigned int address)
{
  unsigned int pattern;
  unsigned int ret_code = 0x0;

  /* Perform a walking 1's test at the given address. */
  for (pattern = 1; pattern != 0; pattern <<= 1)
  {
    /* Write the test pattern. */
    IOWR_32DIRECT(address, 0, pattern);

    /* Read it back (immediately is okay for this test). */
    if (IORD_32DIRECT(address, 0) != pattern)
    {
      ret_code = pattern;
      break;
    }
  }
  return ret_code;
}


/******************************************************************
*  Function: MemTestAddressBus
*
*  Purpose: Tests that the address bus is connected with no 
*           stuck-at's, shorts, or open circuits.
*
******************************************************************/
static int MemTestAddressBus(unsigned int memory_base, unsigned int nBytes)
{
  unsigned int address_mask = (nBytes - 1);
  unsigned int offset;
  unsigned int test_offset;

  unsigned int pattern     = 0xAAAAAAAA;
  unsigned int antipattern  = 0x55555555;

  unsigned int ret_code = 0x0;

  /* Write the default pattern at each of the power-of-two offsets. */
  for (offset = sizeof(unsigned int); (offset & address_mask) != 0; offset <<= 1)
  {
    IOWR_32DIRECT(memory_base, offset, pattern);
  }

  /* Check for address bits stuck high. */
  test_offset = 0;
  IOWR_32DIRECT(memory_base, test_offset, antipattern);
  for (offset = sizeof(unsigned int); (offset & address_mask) != 0; offset <<= 1)
  {
     if (IORD_32DIRECT(memory_base, offset) != pattern)
     {
        ret_code = (memory_base+offset);
        break;
     }
  }

  /* Check for address bits stuck low or shorted. */
  IOWR_32DIRECT(memory_base, test_offset, pattern);
  for (test_offset = sizeof(unsigned int); (test_offset & address_mask) != 0; test_offset <<= 1)
  {
    if (!ret_code)
    {
      IOWR_32DIRECT(memory_base, test_offset, antipattern);
      for (offset = sizeof(unsigned int); (offset & address_mask) != 0; offset <<= 1)
      {
        if ((IORD_32DIRECT(memory_base, offset) != pattern) && (offset != test_offset))
        {
          ret_code = (memory_base + test_offset);
          break;
        }
      }
      IOWR_32DIRECT(memory_base, test_offset, pattern);
    }
  }

  return ret_code;
}


/******************************************************************
*  Function: MemTest8_16BitAccess
*
*  Purpose: Tests that the memory at the specified base address
*           can be read and written in both byte and half-word 
*           modes.
*
******************************************************************/
static int MemTest8_16BitAccess(unsigned int memory_base)
{
  int ret_code = 0x0;

  /* Write 4 bytes */
  IOWR_8DIRECT(memory_base, 0, 0x0A);
  IOWR_8DIRECT(memory_base, 1, 0x05);
  IOWR_8DIRECT(memory_base, 2, 0xA0);
  IOWR_8DIRECT(memory_base, 3, 0x50);

  /* Read it back as one word */
  if(IORD_32DIRECT(memory_base, 0) != 0x50A0050A)
  {
    ret_code = memory_base;
  }

  /* Read it back as two half-words */
  if (!ret_code)
  {
    if ((IORD_16DIRECT(memory_base, 2) != 0x50A0) ||
        (IORD_16DIRECT(memory_base, 0) != 0x050A))
    {
      ret_code = memory_base;
    }
  }

  /* Read it back as 4 bytes */
  if (!ret_code)
  {
    if ((IORD_8DIRECT(memory_base, 3) != 0x50) ||
        (IORD_8DIRECT(memory_base, 2) != 0xA0) ||
        (IORD_8DIRECT(memory_base, 1) != 0x05) ||
        (IORD_8DIRECT(memory_base, 0) != 0x0A))
    {
    ret_code = memory_base;
    }
  }

  /* Write 2 half-words */
  if (!ret_code)
  {
    IOWR_16DIRECT(memory_base, 0, 0x50A0);
    IOWR_16DIRECT(memory_base, 2, 0x050A);

    /* Read it back as one word */
    if(IORD_32DIRECT(memory_base, 0) != 0x050A50A0)
    {
      ret_code = memory_base;
    }
  }

  /* Read it back as two half-words */
  if (!ret_code)
  {
    if ((IORD_16DIRECT(memory_base, 2) != 0x050A) ||
        (IORD_16DIRECT(memory_base, 0) != 0x50A0))
    {
      ret_code = memory_base;
    }
  }

  /* Read it back as 4 bytes */
  if (!ret_code)
  {
    if ((IORD_8DIRECT(memory_base, 3) != 0x05) ||
        (IORD_8DIRECT(memory_base, 2) != 0x0A) ||
        (IORD_8DIRECT(memory_base, 1) != 0x50) ||
        (IORD_8DIRECT(memory_base, 0) != 0xA0))
    {
      ret_code = memory_base;
    }
  }

  return(ret_code);
}


/******************************************************************
*  Function: MemTestDevice
*
*  Purpose: Tests that every bit in the memory device within the 
*           specified address range can store both a '1' and a '0'.
*
******************************************************************/
static int MemTestDevice(unsigned int memory_base, unsigned int nBytes)
{
  unsigned int offset;
  unsigned int pattern;
  unsigned int antipattern;
  unsigned int ret_code = 0x0;

  /* Fill memory with a known pattern. */
  for (pattern = 1, offset = 0; offset < nBytes; pattern++, offset+=4)
  {
    IOWR_32DIRECT(memory_base, offset, pattern);
  }

  printf(" .");

  /* Check each location and invert it for the second pass. */
  for (pattern = 1, offset = 0; offset < nBytes; pattern++, offset+=4)
  {
    if (IORD_32DIRECT(memory_base, offset) != pattern)
    {
      ret_code = (memory_base + offset);
      break;
    }
    antipattern = ~pattern;
    IOWR_32DIRECT(memory_base, offset, antipattern);
  }

  printf(" .");

  /* Check each location for the inverted pattern and zero it. */
  for (pattern = 1, offset = 0; offset < nBytes; pattern++, offset+=4)
  {
    antipattern = ~pattern;
    if (IORD_32DIRECT(memory_base, offset) != antipattern)
    {
      ret_code = (memory_base + offset);
      break;
    }
    IOWR_32DIRECT(memory_base, offset, 0x0);
  }
  return ret_code;
}

/******************************************************************
*  Function: TestRam
*
*  Purpose: Performs a full-test on the RAM specified.  The tests
*           run are:
*             - MemTestDataBus
*             - MemTestAddressBus
*             - MemTest8_16BitAccess
*             - MemTestDevice
*
******************************************************************/
static void TestRam(void)
{
  
  int memory_base, memory_end, memory_size;
  int ret_code = 0x0;

  /* Find out what range of memory we are testing */
  MemGetAddressRange(&memory_base, &memory_end);
  memory_size = (memory_end - memory_base);

  printf("\n");
  printf("Testing RAM from 0x%X to 0x%X\n", memory_base, (memory_base + memory_size));

  /* Test Data Bus. */
  ret_code = MemTestDataBus(memory_base);

  if (ret_code)
   printf(" -Data bus test failed at bit 0x%X", (int)ret_code);
  else
    printf(" -Data bus test passed\n");

  /* Test Address Bus. */
  if (!ret_code)
  {
    ret_code  = MemTestAddressBus(memory_base, memory_size);
    if  (ret_code)
      printf(" -Address bus test failed at address 0x%X", (int)ret_code);
    else
      printf(" -Address bus test passed\n");
  }

  /* Test byte and half-word access. */
  if (!ret_code)
  {
    ret_code = MemTest8_16BitAccess(memory_base);
    if  (ret_code)
      printf(" -Byte and half-word access test failed at address 0x%X", (int)ret_code);
    else
      printf(" -Byte and half-word access test passed\n");
  }

  /* Test that each bit in the device can store both 1 and 0. */
  if (!ret_code)
  {
    printf(" -Testing each bit in memory device.");
    ret_code = MemTestDevice(memory_base, memory_size);
    if  (ret_code)
      printf("  failed at address 0x%X", (int)ret_code);
    else
      printf("  passed\n");
  }
      
  if (!ret_code)
    printf("Memory at 0x%X Okay\n", memory_base);
}

/******************************************************************
*  Function: main
*
*  Purpose: Continually prints the menu and performs the actions
*           requested by the user.
* 
******************************************************************/
int main(void)
{

  int ch;

  /* Print the Header */
  MenuHeader();

  IOWR(LED_BASE, 0, 1);

  while (1)
  {
    printf("\nPress enter to continue or 'q' to quit.\n");
    ch = alt_getchar();
    putchar(ch);
    if(ch == 'q' || ch == 'Q')
    {
        printf( "\nExiting from Memory Test.\n");
	/* Add this so that it will return back to command prompt */
	printf( "%c", 0x4);
        break;
    }
    else if (ch == '\n')
    {
        TestRam();
    }
  }
  return (0);
}


/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2004 Altera Corporation, San Jose, California, USA.           *
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
* Altera does not recommend, suggest or require that this reference design    *
* file be used in conjunction or combination with any other product.          *
******************************************************************************/
