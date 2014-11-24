/* ファイルシステムテスト */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <system.h>
#include <io.h>
#include <sys/alt_cache.h>

#include "mmcfs/mmcfs.h"
#include "nd_lib/nd_egl.h"
#include "testuty.h"

int loadbmp(const char *bmpname, alt_u16 *pFrameBuffer);

void nd_halt(void)
{
	while(1) {}
}


int main(void)
{
	int i,c;
	alt_u16 *pFrameBuffer;


	// システム初期化 

	systeminit();
	nd_GsVgaInit();

	mmcfs_setup();


	// 画像を展開 

	pFrameBuffer = (alt_u16 *)alt_uncached_malloc(na_VRAM_size);
	if (pFrameBuffer != NULL) {
		printf("Framebuffer assignment = 0x%08X\n",(unsigned int)pFrameBuffer);

		nd_GsVgaSetBuffer((nd_u32)pFrameBuffer);
        nd_GsEglPage((nd_u32)pFrameBuffer,(nd_u32)pFrameBuffer,0);

		nd_GsVgaScanOn();

		nd_color(nd_COLORGRAY, 0, 256);
		nd_boxfill(0, 0, window_xmax, window_ymax);

        nd_color(nd_COLORWHITE, 0, 256);
		nd_line(0,0, 0,window_ymax);
        nd_color(nd_COLORRED, 0, 256);
		nd_line(window_xmax,0, window_xmax,window_ymax);
        nd_color(nd_COLORLIGHTGREEN, 0, 256);
		nd_line(0,0, window_xmax,0);
        nd_color(nd_COLORBLUE, 0, 256);
		nd_line(0,window_ymax, window_xmax,window_ymax);
		usleep(1000000);

		loadbmp("mmcfs:/sodalite/uzuko10.bmp",pFrameBuffer);
		usleep(1000000);

	} else {
		printf("[!] Framebuffer not assignment.\r\n");
	}


	// 終了 

	printf("done.\n");
    nd_halt();

	return 0;
}
