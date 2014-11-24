/**************************************************************************
	MMC/SDカードSPIアクセスペリフェラル
		ファイルサブシステム・デバイスドライバ関数 (NiosII HAL version)

		UPDATE 2011/02/19
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

#ifndef __mmcfs_h_
#define __mmcfs_h_


/***** 定数・マクロ定義 ***************************************************/

#define MMCFS_FD_MAXNUM		(16)


/***** 構造体定義 *********************************************************/



/***** プロトタイプ宣言 ***************************************************/

/* デバイス登録とファイルシステム初期化 */
int mmcfs_setup(void);



#endif
/**************************************************************************/
