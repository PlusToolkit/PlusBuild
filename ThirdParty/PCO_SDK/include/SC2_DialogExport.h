//-----------------------------------------------------------------//
// Name        | SC2_DialogExport.cpp        | Type: ( ) source    //
//-------------------------------------------|       (*) header    //
// Project     | PCO SC2 Camera Dialog       |       ( ) others    //
//-----------------------------------------------------------------//
// Platform    | PC                                                //
//-----------------------------------------------------------------//
// Environment | Visual 'C++'                                      //
//-----------------------------------------------------------------//
// Purpose     | PCO - SC2 Camera Dialog DLL Function definitions  //
//-----------------------------------------------------------------//
// Author      | FRE, PCO AG                                       //
//-----------------------------------------------------------------//
// Revision    |  rev. 1.05 rel. 1.05                              //
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
//  0.10     | 03.07.2003 | new file, FRE                          //
//-----------------------------------------------------------------//
//  0.13     | 08.12.2003 | Adapted some functions.                //
//           |            | Changed the functionality.             //
//-----------------------------------------------------------------//
//  0.16     | 23.03.2004 | changed SDK-structures, FRE            //
//-----------------------------------------------------------------//
//  1.0      | 04.05.2004 | Released to market                     //
//           |            |                                        //
//-----------------------------------------------------------------//
//  1.03     | xx.yy.2005 |  CLSer eingebaut, MBL                  //
//-----------------------------------------------------------------//
//  1.04     | 21.04.2005 |  Noisefilter eingebaut, FRE            //
//-----------------------------------------------------------------//
//  1.05     | 27.02.2006 |  Added PCO_GetCameraName, FRE          //
//-----------------------------------------------------------------//

#if !defined SC2_STRUCTURES_H
#error Include SC2_SDKStructures.h first!
#endif

#ifdef SC2_DLG_EXPORTS
//mbl: __declspec(dllexport) + .def file funktioniert nicht mit 64Bit Compiler
//#define SC2_SDK_FUNC_DLG __declspec(dllexport) 
#define SC2_SDK_FUNC_DLG
#else
#define SC2_SDK_FUNC_DLG __declspec(dllimport)
#endif

#ifdef __cplusplus
extern "C" {            //  Assume C declarations for C++
#endif  //C++
// Init flags
#define SC2_SDK_DEF_DLG_PASSIV                   0x00000001 // Dialog does not call set commands in sc2_cam.dll
#define SC2_SDK_DEF_DLG_NO_ADAPT_MEM             0x00000002 // Keeps memory size for segment 4 (preview segment) 
#define SC2_SDK_DEF_DLG_CAN_HANDLE_RECORDER_MODE 0x00000004 // Application can deal with sequence/ring buffer
#define SC2_SDK_DEF_DLG_NO_CREATE_CHECK          0x00000100 // Open dialog does not check for successful creation of dialog
#define SC2_SDK_DEF_DLG_NO_WAIT_MSG_IN_OPEN      0x00000200 // Open dialog does not release message loop during creation of dialog
  // Status flags
#define SC2_SDK_DEF_DLG_OFF     0x00000000 // Dialog is off
#define SC2_SDK_DEF_DLG_ON      0x00000001 // Dialog is on
#define SC2_SDK_DEF_DLG_ENABLED 0x00000002 // Dialog is enabled
#define SC2_SDK_DEF_DLG_CHANGED 0x00000004 // Dialog value has changed
#define SC2_SDK_DEF_DLG_EXTERN  0x00010000 // Dialog changed externally

SC2_SDK_FUNC_DLG int WINAPI PCO_OpenDialogCam(HANDLE *ptr,
                                              HANDLE hHandleCam,
                                              HWND hParent,
                                              UINT uiFlags,
                                              UINT uiMsgArm,
                                              UINT uiMsgCtrl,
                                              int iXPos,
                                              int iYPos,
                                              char *pcCaption);
// Opens a new SC2 control dialog and loads the dialog values from the camera structures.
// In: HANDLE* ptr -> Pointer to a handle to receive the dialog handle
//     HANDLE hHandleCam -> Handle of the camera got by PCO_OpenCamera(HANDLE *ph, WORD wCamNum);
//     HWND hParent -> Main application window handle
//     UINT uiFlags -> Flags to control the behaviour of the dialog.
//          0x00000001 : Passive mode only. The dialog does not send any changed values
//                       to the camera.
//     UINT uiMsgArm -> Message which is sent to the main application window in case of
//                      the accept button being pressed, can be 0 (no message sent)
//     UINT uiMsgCtrl -> Message which is sent to the main application window in case of
//                      some values are changed, can be 0 (no message sent)
//     int iXPos -> X position of the upper left corner of the dialog.
//     int iYPos -> Y position of the upper left corner of the dialog.
//     char *pcCaption -> String to be displayed in the caption bar of the dialog.
//     In case you need to set a UNICODE string, please create the 
//     string in this way:
//     Create a structure in your application:
//     struct 
//     {
//       char cUNI[4];
//       wchar_t szName[100];
//     }strOpenText;
//     Fill the structure with the following strings
//     sprintf_s(&strOpenText.cUNI[0],4, "UNI");// char string (will be recognized by the dll)
//     swprintf_s(&strOpenText.szName[0], 100, L"Your UNICODE string");// UNICODE string
//     Then set this parameter pcCaption to (char*)&strOpenText.cUNI[0]
// Out: int -> Error message.
/* Example:
  HANDLE hDialog;
  HANDLE hCamera;
  ...
  int err = PCO_OpenCamera(&hCamera, 0);
  ...
  if(err == PCO_NOERROR)
    PCO_OpenDialogCam(&hDialog, hCamera, AfxGetApp()->m_pMainWnd->GetSafeHWnd(), 0,
                      WM_APP + 10, WM_APP + 11, 200, 300, "SC2 Camera control window");
  ...
*/

SC2_SDK_FUNC_DLG int WINAPI PCO_CloseDialogCam(HANDLE ptr);
// Closes a previously opened camera control dialog.
// In: HANDLE ptr -> Handle of the dialog
// Out: int -> Error message.
/* Example:
  HANDLE hDialog;
  ...
  int err = PCO_CloseDialogCam(hDialog);
  ...
*/

SC2_SDK_FUNC_DLG int WINAPI PCO_EnableDialogCam(HANDLE ptr, bool bEnable);
// Enables or diables a camera control dialog.
// In: HANDLE ptr -> Handle of the dialog
//     bool bEnable -> FALSE: Disables dialog, TRUE: Enables dialog
// Out: int -> Error message.
/* Example:
  HANDLE hDialog;
  ...
  int err = PCO_EnableDialogCam(hDialog, FALSE);// disable dialog
  ...
*/

SC2_SDK_FUNC_DLG int WINAPI PCO_GetDialogCam(HANDLE ptr, PCO_Camera* strCam);
// Gets the dialog settings.
// In: HANDLE ptr -> Handle of the dialog
//     PCO_Camera* strCam -> Camera struct to receive the values.
//                           The strCam->wSize parameter has to be set to sizeof(PCO_Camera),
//                           before calling this function. This is in order to check the
//                           correct structure size.
// Out: int -> Error message.
// If the error message shows: PCO_ERROR_SDKDLL_BUFFERSIZE + SC2_ERROR_SDKDLL,
// you have to check the version of your SDK header files. The may not fit to the correct
// structure size used inside the SC2_Dlg.dll and/or SC2_Camera.dll.
/* Example:
  HANDLE hDialog;
  PCO_Camera strCam;
  ...
  strCam.wSize = sizeof(PCO_Camera);
  int err = PCO_GetDialogCam(hDialog, &strCam);
  ...
*/

SC2_SDK_FUNC_DLG int WINAPI PCO_SetDialogCam(HANDLE ptr, PCO_Camera* strCam);
// Sets the dialog settings.
// In: HANDLE ptr -> Handle of the dialog
//     PCO_Camera* strCam -> Camera struct to hold the values which should be set.
//                           The strCam->wSize parameter has to be set to sizeof(PCO_Camera),
//                           before calling this function. This is in order to check the
//                           correct structure size.
//                           It would be best, to get the actual settings from the dialog, first.
//                           This parameter can be NULL. In this case the dialog reloads its
//                           settings directly from the camera structures.
// Out: int -> Error message.
// If the error message shows: PCO_ERROR_SDKDLL_BUFFERSIZE + SC2_ERROR_SDKDLL,
// you have to check the version of your SDK header files. The may not fit to the correct
// structure size used inside the SC2_Dlg.dll and/or SC2_Camera.dll.
/* Example 1:
  HANDLE hDialog;
  PCO_Camera strCam;
  ...
  strCam.wSize = sizeof(PCO_Camera);
  int err = PCO_GetDialogCam(hDialog, &strCam);
  ...
  strCam.... = xxx;                    // change some values
  int err = PCO_SetDialogCam(hDialog, &strCam);
  ...
*/
/* Example 2:
  HANDLE hDialog;
  ...
  int err = PCO_SetDialogCam(hDialog, NULL);
  ...
*/

SC2_SDK_FUNC_DLG DWORD WINAPI PCO_GetStatusDialogCam(HANDLE ptr, DWORD *dwStatus);
// Gets the status of the camera control dialog.
// In: HANDLE ptr -> Handle of the dialog
//     DWORD* dwStatus -> DWORD pointer to receive the status
// Stat: 0xnnnnmmmm - n: auto reset during PCO_GetStatusDialogCam, m: static
//       0x00000000 - Dialog off
//       0x00000001 - Dialog on
//       0x00000002 - Dialog enabled
//       0x00000004 - Dialog value has changed
//       0x00010000 - Dialog changed externally
// Out: int -> Error message.
/* Example:
  HANDLE hDialog;
  ...
  int status, err;
  err = PCO_GetStatusDialogCam(hDialog, &status);
  ...
*/

SC2_SDK_FUNC_DLG int WINAPI PCO_SetLanguageDialogCam(char *szLanguage);
// Sets the dialog language.
// In: char* szLanguage -> char pointer to set the dialog language, e.g. 'german'

#ifdef __cplusplus
}
#endif  //C++
