//-----------------------------------------------------------------//
// Name        | Pco_ConvDlgExport.h         | Type: ( ) source    //
//-------------------------------------------|       (*) header    //
// Project     | PCO                         |       ( ) others    //
//-----------------------------------------------------------------//
// Platform    | PC                                                //
//-----------------------------------------------------------------//
// Environment | Visual 'C++'                                      //
//-----------------------------------------------------------------//
// Purpose     | PCO - Convert DLL dialog function API definitions //
//-----------------------------------------------------------------//
// Author      | MBL, FRE, HWI, PCO AG                             //
//-----------------------------------------------------------------//
// Revision    |  rev. 2.00 rel. 2.00                              //
//-----------------------------------------------------------------//
// Notes       |                                                   //
//-----------------------------------------------------------------//
// (c) 2002 PCO AG * Donaupark 11 *                                //
// D-93309      Kelheim / Germany * Phone: +49 (0)9441 / 2005-0 *  //
// Fax: +49 (0)9441 / 2005-20 * Email: info@pco.de                 //
//-----------------------------------------------------------------//


//-----------------------------------------------------------------//
// Revision History:                                               //
//-----------------------------------------------------------------//
// Rev.:     | Date:      | Changed:                               //
// --------- | ---------- | ---------------------------------------//
//  1.10     | 03.07.2003 |  gamma, alignement added, FRE          //
//-----------------------------------------------------------------//
//  1.12     | 16.03.2005 |  PCO_CNV_COL_SET added, FRE            //
//-----------------------------------------------------------------//
//  1.14     | 12.05.2006 |  conv24 and conv16 added, FRE          //
//-----------------------------------------------------------------//
//  1.15     | 23.10.2007 |  PCO_CNV_COL_SET removed, FRE          //
//           |            |  Adapted all structures due to merging //
//           |            |  the data sets of the dialoges         //
//-----------------------------------------------------------------//
//  2.0      | 08.04.2009 |  New file, FRE                         //
//-----------------------------------------------------------------//
#ifdef PCO_CONVERT_DIALOG_DO_EXPORTS
//__declspec(dllexport) + .def file funktioniert nicht mit 64Bit Compiler
#if defined _WIN64
  #define PCO_CONVERT_DIALOG_EXPORTS
#else
  #define PCO_CONVERT_DIALOG_EXPORTS __declspec(dllexport) WINAPI
#endif
#else
#define PCO_CONVERT_DIALOG_EXPORTS __declspec(dllimport) WINAPI
#endif
 
#ifdef __cplusplus
extern "C" {
#endif  /* __cplusplus */


int PCO_CONVERT_DIALOG_EXPORTS PCO_OpenConvertDialog(HANDLE *hLutDialog, HWND parent, char *title,int msg_id, HANDLE hLut, int xpos,int ypos);
int PCO_CONVERT_DIALOG_EXPORTS PCO_CloseConvertDialog(HANDLE hLutDialog);
int PCO_CONVERT_DIALOG_EXPORTS PCO_GetStatusConvertDialog(HANDLE hLutDialog, int *hwnd,int *status);
int PCO_CONVERT_DIALOG_EXPORTS PCO_SetConvertDialog(HANDLE hLutDialog, HANDLE hLut);
int PCO_CONVERT_DIALOG_EXPORTS PCO_GetConvertDialog(HANDLE hLutDialog, HANDLE hLut);
int PCO_CONVERT_DIALOG_EXPORTS PCO_SetDataToDialog(HANDLE hLutDialog, int ixres, int iyres, void *b16_image,  void *rgb_image);
int PCO_CONVERT_DIALOG_EXPORTS PCO_UpdateHistData(HANDLE ph, int ixres, int iyres);
typedef struct
{
  WORD         wCommand;               // Command sent to the main application
  PCO_Convert* pstrConvert;            // Pointer to the controlled PCO_Convert
  int iXPos;                           // Actual left position
  int iYPos;                           // Actual upper position
  unsigned int iReserved[10];          // Reserved for future use, set to zero.
}PCO_ConvDlg_Message;

#define PCO_CNV_DLG_CMD_CLOSING      0x0001 // Dialog is closing (bye, bye)
#define PCO_CNV_DLG_CMD_UPDATE       0x0002 // Changed values in dialog
#define PCO_CNV_DLG_CMD_WHITEBALANCE 0x0010 // White balance button pressed
#define PCO_CNV_DLG_CMD_MINMAX       0x0011 // Minmax button pressed
#define PCO_CNV_DLG_CMD_MINMAXSMALL  0x0012 // Minmax small button pressed


#ifdef __cplusplus
}
#endif
