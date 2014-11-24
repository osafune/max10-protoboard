/*********************************************************************
	PERIDOT
	テスト用ユーティリティ 
 *********************************************************************/
#ifndef __testuty_h__
#define __testuty_h__

#include <alt_types.h>

#define _USE_FATFS


#ifdef _USE_FATFS
  #include "mmcfs/fatfs/ff.h"
  #include "mmcfs/fatfs/diskio.h"

  extern FATFS FatFs_sysobj;		/* File system object */
  extern FIL Mmc_fileobj;			/* File object */

  #define FILE_TOP_DIR	"/SODALITE/"

/* ファイルを開く */
  FIL *testfile_open(const char *fname);

/* メモリイメージを書き込む */
  void write_binary(
		const char *fname,
		void *ptr,
		int byte
	);

/* メモリイメージを読み込む */
  int read_binary(
		const char *fname,
		void *ptr
	);
#endif


/* システムイニシャライズ */
int systeminit(void);

/* メモリダンプ */
#define DUMPMODE_BYTE		(0)
#define DUMPMODE_WORD		(1)
#define DUMPMODE_DWORD		(2)

void memdump(
		alt_u32 addr,
		int mode
	);


/* CRC16を計算 */
alt_u16 memcrc16(
		const alt_u8 *p_data,
		int length
	);


#endif
