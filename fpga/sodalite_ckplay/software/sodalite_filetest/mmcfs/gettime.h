/**************************************************************************
	MMC/SDカードSPIアクセスペリフェラル
		ファイルサブシステム・デバイスドライバ関数 (NiosII HAL version)

		UPDATE 2011/12/28
 **************************************************************************/

// ******************************************************************* //
//     Copyright (C) 2011, J-7SYSTEM Works.  All rights Reserved.      //
//                                                                     //
// * This module is a free sourcecode and there is NO WARRANTY.        //
// * No restriction on use. You can use, modify and redistribute it    //
//   for personal, non-profit or commercial products UNDER YOUR        //
//   RESPONSIBILITY.                                                   //
// * Redistributions of source code must retain the above copyright    //
//   notice.                                                           //
// ******************************************************************* //

#ifndef __gettime_h_
#define __gettime_h_


#include "fatfs/integer.h"	/* Basic integer types */


/***** 定数・マクロ定義 ***************************************************/



/***** 構造体定義 *********************************************************/



/***** プロトタイプ宣言 ***************************************************/

/* タイムスタンプを返す */
DWORD get_fattime (void);



#endif
/**************************************************************************/
