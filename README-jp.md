#MAX10 PROTO-BOARD

## ※製品化に伴い、このリポジトリのメンテナンスは終了します。

------------------------------------------------------------------------

このボードはAltera MAX10デバイスを搭載したDIP形状のプロトタイピング向けFPGAボードです。

![SODALITE](https://lh3.googleusercontent.com/-fBGcmyD2sEY/VHNSUxrROWI/AAAAAAAAHIY/pMdg5tDgemA/w619-h464-no/DSC_0340.JPG)



------------------------------------------------------------------------
##Overview

![SODALITE TOPVIEW](https://lh3.googleusercontent.com/-e6P0SKS46Xc/VHNEk6tXomI/AAAAAAAAHHw/hiFEVjnDsTw/w379-h380-no/sodalite_topview.png)

- 1100mil幅40ピンDIP形状
- 8kLEのMAX10デバイス搭載(10M08SAE144C8GES)
- 256MbitSDRAM搭載
- 3種類の周波数を選択できるオンボードOSC
- 最大34本のPIO、アナログ入力6本、LVDS差動ペア8チャネル
- オンボードにユーザーLED
- 3.3V単一電源駆動
- ADC用VREF/REFGNDおよびVIO外部入力ピンあり
- デュアルコンフィグレーション対応


###ブロック図

![SODALITE Blockdiagram](https://lh4.googleusercontent.com/-9MY5agBSNxU/VHNElCTIsCI/AAAAAAAAHH0/HBXVVxgH8Xo/w619-h447-no/sodalite_block.png)


------------------------------------------------------------------------
##ピンアサイン

###プロトタイピングコネクタ

|番号|FPGAピン|内容|
|---|---|---|
|1|PIN_28|PIO0/CLK_n|
|2|PIN_29|PIO1/CLK_p|
|3| |VCCIO入力|
|4|PIN_38|PIO2/LVDS0_n|
|5|PIN_39|PIO3/LVDS0_p|
|6|PIN_41|PIO4/LVDS1_n|
|7|PIN_43|PIO5/LVDS1_p|
|8|PIN_44|PIO6/LVDS2_n|
|9|PIN_45|PIO7/LVDS2_p|
|10|PIN_46|PIO8/LVDS3_n|
|11|PIN_47|PIO9/LVDS3_p|
|12|PIN_50|PIO10/LVDS4_n|
|13|PIN_52|PIO11/LVDS4_p|
|14|PIN_55|PIO12/LVDS5_n|
|15|PIN_56|PIO13/LVDS5_p|
|16|PIN_57|PIO14/LVDS6_n|
|17|PIN_58|PIO15/LVDS6_p|
|18|PIN_59|PIO16/LVDS7_n|
|19|PIN_60|PIO17/LVDS7_p|
|20| |GND|
|21| |GND|
|22|PIN_120|PIO18|
|23|PIN_121|PIO19|
|24|PIN_122|PIO20|
|25|PIN_124|PIO21|
|26|PIN_126|BOOT_SEL/PIO22|
|27|PIN_127|PIO23|
|28|PIN_130|PIO24|
|29|PIN_131|PIO25|
|30|PIN_132|PIO26|
|31|PIN_134|PIO27|
|32| |ADC REFGND(GNDに接続)|
|33|PIN_6|AIN1/PIO28|
|34|PIN_7|AIN2/PIO29|
|35|PIN_8|AIN3/PIO30|
|36|PIN_10|AIN4/PIO31|
|37|PIN_11|AIN5/PIO32|
|38|PIN_12|AIN6/PIO33|
|39| |ADC VREF(未使用時は解放またはREFGNDに接続)|
|40| |3.3V電源|

- LVDS使用時には3番ピン(VCCIO入力)には2.5Vを加える。
- 3.3V-LVTTLまたは3.3V-CMOS使用時には3番ピンには3.3Vを加える。
- 3.0V-CMOS使用時には3番ピンには3.0Vを加える。
- ADCに外部リファレンス電源を供給して使う場合には39番ピンにリファレンス電圧を加える。
- 26番ピンはブート時はBOOT_SELピンとして動作する。またボード内で10kΩで3.3VへプルアップされているためI/Oピンとして使う場合には注意すること。


###JTAGコネクタ

|番号|FPGAピン|内容|
|---|---|---|
|1|PIN_18|TCK|
|2| |GND|
|3|PIN_20|TDO|
|4| |3.3V|
|5|PIN_16|TMS|
|6| |n.c|
|7| |n.c|
|8|PIN_15|JTAG_EN|
|9|PIN_19|TDI|
|10| |GND|

- TDI,TMS,JTAG_ENは10kΩで3.3Vへプルアップされている。
- TCKは1kΩでGNDへプルダウンされている。

本ボードではES品のデバイスを搭載しています。
ES品はUSB-Blaster Rev.BおよびRev.Cの動作に不具合があることが報告されています。
詳しくはALTERAのWebサイトで最新のエラッタを確認してください。

SODALITEにてJTAGの不具合が発生した場合は、TCK/TDO/TMSの信号ラインに74HCバッファを挿入することで安定する場合があります。


###オンボードOSC

|信号名|FPGAピン|方向|内容|
|---|---|---|---|
|FREQ_SEL|PIN_26|O|周波数選択|
|CLKIN|PIN_27|I|クロック入力|


オンボードOSCは50.000MHz/24.576MHz/74.25MHzの３種類をFREQ_SELピンの状態で選択できます。

|FREQ_SEL出力|OSC発振周波数|
|---|---|
|H|50.000MHz|
|L|74.250MHz|
|Hi-Z|24.576MHz|


###SDRAM

|信号名|FPGAピン|方向|内容|
|---|---|---|---|
|SDR_A0|PIN_77|O|アドレス|
|SDR_A1|PIN_76|O|アドレス|
|SDR_A2|PIN_75|O|アドレス|
|SDR_A3|PIN_74|O|アドレス|
|SDR_A4|PIN_69|O|アドレス|
|SDR_A5|PIN_70|O|アドレス|
|SDR_A6|PIN_66|O|アドレス|
|SDR_A7|PIN_65|O|アドレス|
|SDR_A8|PIN_64|O|アドレス|
|SDR_A9|PIN_62|O|アドレス|
|SDR_A10|PIN_78|O|アドレス、オートプリチャージ指示|
|SDR_A11|PIN_61|O|アドレス|
|SDR_A12|PIN_87|O|アドレス|
|SDR_BA0|PIN_80|O|バンクアドレス|
|SDR_BA1|PIN_79|O|バンクアドレス|
|SDR_CS_N|PIN_81|O|チップセレクト|
|SDR_RAS_N|PIN_84|O|ロウアクティブ指示|
|SDR_CAS_N|PIN_85|O|カラムアクティブ指示|
|SDR_WE_N|PIN_86|O|ライトイネーブル指示|
|SDR_CLK|PIN_89|O|クロック出力|
|SDR_CLE|PIN_88|O|クロックイネーブル|
|SDR_DQM0|PIN_96|O|下位バイトデータイネーブル|
|SDR_DQM1|PIN_90|O|上位バイトデータイネーブル|
|SDR_DQ0|PIN_106|I/O|データ|
|SDR_DQ1|PIN_105|I/O|データ|
|SDR_DQ2|PIN_102|I/O|データ|
|SDR_DQ3|PIN_101|I/O|データ|
|SDR_DQ4|PIN_100|I/O|データ|
|SDR_DQ5|PIN_99|I/O|データ|
|SDR_DQ6|PIN_98|I/O|データ|
|SDR_DQ7|PIN_97|I/O|データ|
|SDR_DQ8|PIN_91|I/O|データ|
|SDR_DQ9|PIN_92|I/O|データ|
|SDR_DQ10|PIN_93|I/O|データ|
|SDR_DQ11|PIN_110|I/O|データ|
|SDR_DQ12|PIN_111|I/O|データ|
|SDR_DQ13|PIN_113|I/O|データ|
|SDR_DQ14|PIN_114|I/O|データ|
|SDR_DQ15|PIN_118|I/O|データ|


###LED

|信号名|FPGAピン|方向|内容|
|---|---|---|---|
|LED|PIN_135|O|'H'で点灯|


------------------------------------------------------------------------
##電気特性

|項目|内容|
|---|---|
|電源電圧|3.3V±5%|
|VCCIO電圧|3.3V、3.0V、2.5V|
|ADC VREF電圧|2.5V|
|消費電流|250mA(100MHz動作時の代表値)|
|I/Oピン定格|±8mA|

- VCCIO電圧の各値はMAX10のI/O規格に準ずる。
- ADC VREF電圧は外部リファレンス電圧使用時の値。
- 消費電流はリソース使用率85%、100MHz駆動、SDRAM動作時の値。
- I/Oピン定格はMAX10デバイスの仕様に基づく。


------------------------------------------------------------------------
##回路図

回路図およびプロジェクトのサンプルはリポジトリを参照してください。


------------------------------------------------------------------------
##ライセンス

MAX10 PROTO-BOARD Hardware is released under the [Creative Commons,CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)  
![CC BY](https://licensebuttons.net/l/by/4.0/88x31.png)  

