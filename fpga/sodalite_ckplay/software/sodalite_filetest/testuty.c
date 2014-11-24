/*********************************************************************
	Cineraria
	テスト用ユーティリティ 

	2013/04/04 修正
 *********************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <system.h>
#include <io.h>
#include "mmcfs/mmcfs.h"
#include "testuty.h"


/* ファイルシステムオブジェクト */

#ifdef _USE_FATFS
  FATFS FatFs_sysobj;	/* File system object */
  FIL Mmc_fileobj;		/* File object */
#endif


/***************************************
	システムイニシャライズ
 ***************************************/

static void systeminit_mhz(
		unsigned long freq,
		int *p_int,
		int *p_dec
	)
{
	unsigned long khz;
	unsigned long mhz;

	mhz = freq / 1000000;
	khz = (freq % 1000000)/1000;

	*p_int = (int)mhz;
	*p_dec = (int)khz;
}

static void systeminit_fatfs(void)
{
#ifdef _USE_FATFS
	FRESULT res;
	DWORD clust;
	unsigned int total_sector,free_sector;

	memset(&FatFs_sysobj, 0, sizeof(FATFS));	/* Invalidate file system */
	f_mount(0, &FatFs_sysobj);					/* Assign object memory to the FatFs module */

	printf("\n- FatFs module test\n");
  #ifdef MMCDMA_BASE
	printf("MMCDMA clock rate = %dHz\n",IORD(MMCDMA_BASE ,3));
  #endif

	if ( (res = f_getfree("/", &clust, &FatFs_sysobj))== FR_OK ) {
		printf("FAT type = %d\n"              ,(int)FatFs_sysobj.fs_type);
		printf("Bytes/Cluster = %d\n"         ,(int)FatFs_sysobj.csize * 512);
		printf("Number of FATs = %d\n"        ,(int)FatFs_sysobj.n_fats);
		printf("FAT base (lba) = %u\n"        ,FatFs_sysobj.fatbase);
		printf("DIR base (lba,clustor) = %u\n",FatFs_sysobj.dirbase);
		printf("Data base (lba) = %u\n"       ,FatFs_sysobj.database);

		total_sector = (FatFs_sysobj.n_fatent - 2) * FatFs_sysobj.csize;
		free_sector  = clust * FatFs_sysobj.csize;
		printf("%u kB total disk space.\n"    ,total_sector / 2);
		printf("%u kB available.\n"           ,free_sector / 2);

	} else {
		printf("[!] f_getfree fail(%d)\n", (int)res);

	}
#endif
}


int systeminit(void)
{

  #ifdef _USE_FATFS
  #endif
	int i,d;

	/* stdioストリーム初期化 */
/*	FILE *fp_std;

	fp_std = fopen(ALT_STDIN, "r+");
	if (fp_std) {
		clearerr(fp_std);
		fclose(fp_std);
	}
*/

	/* システム情報 */
	printf("\n***** SYSTEM INITIALIZE *****\n");
	printf("\n- system information\n");

	systeminit_mhz(ALT_CPU_FREQ, &i, &d);
	printf("NiosII/%s %d.%02dMHz\n",NIOS2_CPU_IMPLEMENTATION,i,d);
  #if(NIOS2_ICACHE_SIZE != 0)
	printf("   I-cache %dkbyte\n",NIOS2_ICACHE_SIZE/1024);
  #endif
  #if(NIOS2_DCACHE_SIZE != 0)
	printf("   D-cache %dkbyte\n",NIOS2_DCACHE_SIZE/1024);
  #endif
  #ifdef __ALTERA_NIOS_CUSTOM_INSTR_FLOATING_POINT
	printf("   Floating point custom instruction supported\n");
  #endif
	printf("   EXCEPTION ADDR  0x%08X\n",NIOS2_EXCEPTION_ADDR);
	printf("   RESET ADDR      0x%08X\n",NIOS2_RESET_ADDR);
	printf("   BREAK ADDR      0x%08X\n",NIOS2_BREAK_ADDR);

  #ifdef SDRAM_BASE
	printf("SDRAM      0x%08X-0x%08X\n", SDRAM_BASE,(unsigned int)SDRAM_BASE+SDRAM_SPAN-1);
  #endif
  #ifdef EXT_FLASH_BASE
	printf("CFI FLASH  0x%08X-0x%08X\n", EXT_FLASH_BASE,(unsigned int)EXT_FLASH_BASE+EXT_FLASH_SPAN-1);
  #endif
  #ifdef EPCS_CONTROLLER_BASE
	printf("EPCS FLASH 0x%08X-0x%08X\n", EPCS_CONTROLLER_BASE,(unsigned int)EPCS_CONTROLLER_BASE+EPCS_CONTROLLER_SPAN-1);
  #endif

	printf("sysid : 0x%08X 0x%08X\n",IORD(SYSID_BASE,0),IORD(SYSID_BASE,1));
  #ifdef SYSFRC_BASE
	printf("frc snapshot : 0x%08X\n",IORD(SYSFRC_BASE,0));
  #endif
	printf("software build : %s / %s\n",__DATE__,__TIME__);

	/* カスタム命令テスト */
  #ifdef __PIXELSIMD
	printf("pyuvdec  :  0x%08X\n", ALT_CI_PIXELSIMD(0, 0x0000ffff, 0x00008080) );
	printf("ppack    :  0x%08X\n", ALT_CI_PIXELSIMD(1, 0x008090a0, 0x00102030) );
	printf("punpackl :  0x%08X\n", ALT_CI_PIXELSIMD(2, 0x03e87fff, 0         ) );
	printf("punpackh :  0x%08X\n", ALT_CI_PIXELSIMD(3, 0x03e87fff, 0         ) );
	printf("pblend   :  0x%08X\n", ALT_CI_PIXELSIMD(4, 0xff8090a0, 0x00102030) );
	printf("paddsb   :  0x%08X\n", ALT_CI_PIXELSIMD(6, 0x7f808182, 0x7e7f8081) );
	printf("psubsb   :  0x%08X\n", ALT_CI_PIXELSIMD(7, 0x7f808182, 0x80808080) );
  #endif

	/* ファイルシステムテスト */
	systeminit_fatfs();


	printf("\n\n");
	return 0;
}


/***************************************
	メモリダンプ 
 ***************************************/
void memdump_byte(
		alt_u32 addr
	)
{
	int i,line,c;
	char *p;
	alt_u8 buff[16];

	for(line=0 ; line<16 ; line++) {
		printf("%08X | ",(unsigned int)addr);

		for(i=0 ; i<16 ; i++) {
			buff[i] = (alt_u8)IORD_8DIRECT(addr, 0);
			printf("%02X ", (unsigned int)buff[i]);
			addr++;
		}

		printf(": ");
		p = (char *)&buff[0];
		for(i=0 ; i<16 ; i++) {
			c = *p++;
			if (c < 0x20 || 0x7f > c) c = '.';
			printf("%c",c);
		}
		printf("\n");
	}
}

void memdump_word(
		alt_u32 addr
	)
{
	int i,line,c;
	char *p;
	alt_u16 buff[8];

	addr &= 0xfffffffeUL;

	for(line=0 ; line<16 ; line++) {
		printf("%08X | ",(unsigned int)addr);

		for(i=0 ; i<8 ; i++) {
			buff[i] = (alt_u16)IORD_16DIRECT(addr, 0);
			printf("%04X ", (unsigned int)buff[i]);
			addr+=2;
		}

		printf(": ");
		p = (char *)&buff[0];
		for(i=0 ; i<16 ; i++) {
			c = *p++;
			if (c < 0x20 || 0x7f > c) c = '.';
			printf("%c",c);
		}
		printf("\n");
	}
}

void memdump_dword(
		alt_u32 addr
	)
{
	int i,line,c;
	char *p;
	alt_u32 buff[4];

	addr &= 0xfffffffcUL;

	for(line=0 ; line<16 ; line++) {
		printf("%08X | ",(unsigned int)addr);

		for(i=0 ; i<4 ; i++) {
			buff[i] = IORD_32DIRECT(addr, 0);
			printf("%08X ", (unsigned int)buff[i]);
			addr+=4;
		}

		printf(": ");
		p = (char *)&buff[0];
		for(i=0 ; i<16 ; i++) {
			c = *p++;
			if (c < 0x20 || 0x7f > c) c = '.';
			printf("%c",c);
		}
		printf("\n");
	}
}

void memdump(
		alt_u32 addr,
		int mode
	)
{
	switch (mode) {
	default:
		break;

	case DUMPMODE_BYTE :
		memdump_byte(addr);
		break;

	case DUMPMODE_WORD :
		memdump_word(addr);
		break;

	case DUMPMODE_DWORD :
		memdump_dword(addr);
		break;
	}
}



/***************************************
	CRC16計算 
 ***************************************/

// CRC16演算テーブル 
static alt_u16 memcrc16table[256] = {
	0x0000, 0x1021, 0x2042, 0x3063, 0x4084, 0x50A5, 0x60C6, 0x70E7,
	0x8108, 0x9129, 0xA14A, 0xB16B, 0xC18C, 0xD1AD, 0xE1CE, 0xF1EF,
	0x1231, 0x0210, 0x3273, 0x2252, 0x52B5, 0x4294, 0x72F7, 0x62D6,
	0x9339, 0x8318, 0xB37B, 0xA35A, 0xD3BD, 0xC39C, 0xF3FF, 0xE3DE,
	0x2462, 0x3443, 0x0420, 0x1401, 0x64E6, 0x74C7, 0x44A4, 0x5485,
	0xA56A, 0xB54B, 0x8528, 0x9509, 0xE5EE, 0xF5CF, 0xC5AC, 0xD58D,
	0x3653, 0x2672, 0x1611, 0x0630, 0x76D7, 0x66F6, 0x5695, 0x46B4,
	0xB75B, 0xA77A, 0x9719, 0x8738, 0xF7DF, 0xE7FE, 0xD79D, 0xC7BC,

	0x48C4, 0x58E5, 0x6886, 0x78A7, 0x0840, 0x1861, 0x2802, 0x3823,
	0xC9CC, 0xD9ED, 0xE98E, 0xF9AF, 0x8948, 0x9969, 0xA90A, 0xB92B,
	0x5AF5, 0x4AD4, 0x7AB7, 0x6A96, 0x1A71, 0x0A50, 0x3A33, 0x2A12,
	0xDBFD, 0xCBDC, 0xFBBF, 0xEB9E, 0x9B79, 0x8B58, 0xBB3B, 0xAB1A,
	0x6CA6, 0x7C87, 0x4CE4, 0x5CC5, 0x2C22, 0x3C03, 0x0C60, 0x1C41,
	0xEDAE, 0xFD8F, 0xCDEC, 0xDDCD, 0xAD2A, 0xBD0B, 0x8D68, 0x9D49,
	0x7E97, 0x6EB6, 0x5ED5, 0x4EF4, 0x3E13, 0x2E32, 0x1E51, 0x0E70,
	0xFF9F, 0xEFBE, 0xDFDD, 0xCFFC, 0xBF1B, 0xAF3A, 0x9F59, 0x8F78,

	0x9188, 0x81A9, 0xB1CA, 0xA1EB, 0xD10C, 0xC12D, 0xF14E, 0xE16F,
	0x1080, 0x00A1, 0x30C2, 0x20E3, 0x5004, 0x4025, 0x7046, 0x6067,
	0x83B9, 0x9398, 0xA3FB, 0xB3DA, 0xC33D, 0xD31C, 0xE37F, 0xF35E,
	0x02B1, 0x1290, 0x22F3, 0x32D2, 0x4235, 0x5214, 0x6277, 0x7256,
	0xB5EA, 0xA5CB, 0x95A8, 0x8589, 0xF56E, 0xE54F, 0xD52C, 0xC50D,
	0x34E2, 0x24C3, 0x14A0, 0x0481, 0x7466, 0x6447, 0x5424, 0x4405,
	0xA7DB, 0xB7FA, 0x8799, 0x97B8, 0xE75F, 0xF77E, 0xC71D, 0xD73C,
	0x26D3, 0x36F2, 0x0691, 0x16B0, 0x6657, 0x7676, 0x4615, 0x5634,

	0xD94C, 0xC96D, 0xF90E, 0xE92F, 0x99C8, 0x89E9, 0xB98A, 0xA9AB,
	0x5844, 0x4865, 0x7806, 0x6827, 0x18C0, 0x08E1, 0x3882, 0x28A3,
	0xCB7D, 0xDB5C, 0xEB3F, 0xFB1E, 0x8BF9, 0x9BD8, 0xABBB, 0xBB9A,
	0x4A75, 0x5A54, 0x6A37, 0x7A16, 0x0AF1, 0x1AD0, 0x2AB3, 0x3A92,
	0xFD2E, 0xED0F, 0xDD6C, 0xCD4D, 0xBDAA, 0xAD8B, 0x9DE8, 0x8DC9,
	0x7C26, 0x6C07, 0x5C64, 0x4C45, 0x3CA2, 0x2C83, 0x1CE0, 0x0CC1,
	0xEF1F, 0xFF3E, 0xCF5D, 0xDF7C, 0xAF9B, 0xBFBA, 0x8FD9, 0x9FF8,
	0x6E17, 0x7E36, 0x4E55, 0x5E74, 0x2E93, 0x3EB2, 0x0ED1, 0x1EF0
};

// CRC16を計算 
alt_u16 memcrc16(
		const alt_u8 *p_data,
		int length
	)
{
//	alt_u16 crc16 = 0xffff;
	alt_u16 crc16 = 0;

    while( length ) {
        crc16 = (crc16 << 8) ^ memcrc16table[ ((crc16 >> 8) ^ (alt_u16)(*p_data)) & 255 ];
		p_data++;
		length--;
    }

    return crc16;
}



/***************************************
	ファイル入出力
 ***************************************/
//#ifdef _USE_FATFS
#if 0

/* ファイルを開く */
FIL *testfile_open(const char *fname)
{
	char fn[256] = FILE_TOP_DIR;
	FIL *fp = &Mmc_fileobj;
	BYTE res;

	strcat(fn, fname);

	if ( (res = f_open(fp, fn, FA_OPEN_EXISTING | FA_READ)) != FR_OK ) {
		printf("[!] %s が読み込めません. (f_open fail:%d)\n",fn,res);
		fp = NULL;
	} else {
		printf("input file : %s\n",fn);
	}

	return fp;
}


/* メモリイメージを読み込む */
int read_binary(
		const char *fname,
		void *ptr
	)
{
	BYTE res;
	WORD readsize;
	FIL *fp;

	int byte;
	alt_u8 *p;

	if ( (fp = testfile_open(fname))== NULL) return (-1);

	byte = 0;
	p    = (alt_u8 *)ptr;

	printf("read ");

	do {
	    if ( (res = f_read(fp, p, 256, &readsize)) != FR_OK ) {
			printf("[!] f_read fail(%d)\n",res);
			break;
		}
		byte += readsize;
		p    += readsize;

		if ( !(byte & (128*1024-1)) ) printf(".");
	} while(readsize == 256);

	printf(" done\n");
	printf("%dbyte\n",byte);

	res = f_close(fp);

	return byte;
}


/* メモリイメージを書き込む */
void write_binary(
		const char *fname,
		void *ptr,
		int byte
	)
{
	BYTE res;
	WORD writesize;
	FIL *fp = &Mmc_fileobj;
	char fn[256] = FILE_TOP_DIR;

	int i,j;
	alt_u8 *p;

	strcat(fn, fname);

	if ( (res = f_open(fp, fn, FA_CREATE_ALWAYS | FA_WRITE)) != FR_OK ) {
		printf("[!] %s が書けません. (f_open fail:%d)\n",fn,res);
		return;
	}
	printf("output file : %s\n",fn);

	p = (alt_u8 *)ptr;
	j = 0;

	printf("write ");
	do {
		if (byte >= 256) i = 256; else i = byte;

		if ( (res = f_write(fp, p, i, &writesize)) != FR_OK ) {
			printf("[!] f_write fail(%d)\n",res);
			break;
		}
		byte -= writesize;
		p    += writesize;
		j    += writesize;

		if ( !(byte & (128*1024-1)) ) printf(".");
	} while(byte);

	printf(" done\n");
	printf("%dbyte\n",j);

	res = f_close(fp);
}

#endif


