//-----------------------------------------------------------------//
// Name        | PCO_errt.h                  | Type: ( ) source    //
//-------------------------------------------|       (*) header    //
// Project     | PCO                         |       ( ) others    //
//-----------------------------------------------------------------//
// Platform    | - Embedded platforms like M16C, AVR32, PIC32 etc. //
//             | - PC with several Windows versions, Linux etc.    //
//-----------------------------------------------------------------//
// Environment | - Platform dependent                              //
//-----------------------------------------------------------------//
// Purpose     | PCO - Error text defines                          //
//-----------------------------------------------------------------//
// Author      | FRE, MBL, LWA, PCO AG                             //
//-----------------------------------------------------------------//
// Revision    | versioned using SVN                               //
//-----------------------------------------------------------------//
// Notes       | This error defines should be used in every future //                                  
//             | design. It is designed to hold a huge range of    //
//             | errors and warnings                               //
//-----------------------------------------------------------------//
// (c) 2003-2014 PCO AG * Donaupark 11 * D-93309 Kelheim / Germany //
// *  Phone: +49 (0)9441 / 2005-0  *                               //
// *  Fax:   +49 (0)9441 / 2005-20 *  Email: info@pco.de           //
//-----------------------------------------------------------------//


//-----------------------------------------------------------------//
// Revision History:                                               //
//-----------------------------------------------------------------//
// Rev.:     | Date:      | Changed:                               //
// --------- | ---------- | ---------------------------------------//
//  00.01    | 26.06.2003 |  new file, FRE                         //
//-----------------------------------------------------------------//
//  00.03    | 14.10.2003 |  - FRE:Error text file changed (new V.)//
//           |            |    moved some errors to common area    //
//           | 23.10.2003 |  - LWA:added text strings for:         //
//           |            |  SC2_ERROR_CONNY                       //
//           |            |  PCO_ERROR_FIRMWARE_DEVICE_OPEN_FAILED // 
//-----------------------------------------------------------------//
//  00.04    | 04.11.2003 |  - LWA: completely new developed file  //
//-----------------------------------------------------------------//
//  00.05    | 12.12.2003 |  - FRE: changed GetErrorText to        //
//           |            |         PCO_GetErrorText               //
//           | 17.03.2004 |  - LWA added:                          //
//           |            |    Error text for:                     // 
//           |            |    PCO_ERROR_FIRMWARE_UNKNOWN_COMMAND  // 
//           |            |  (just addition, no new version!)      //
//           | 23.03.2004 |  - descriptions for temperature error  //
//           |            |    and temperature warning.            // 
//           | 24.03.2004 |  - FRW added:                          //
//           |            |  PCO_ERROR_SDKDLL_WRONGBUFFERNR        //
//           | 26.07.2004 |  - FRW added:                          //
//           |            |  PCO_ERROR_SDKDLL_DLLNOTFOUND          //
//           | 10.11.2004 |  - FRE added:                          //
//           |            |  PCO_ERROR_SDKDLL_BUFALREADYASSIGNED   //
//           |            |  PCO_ERROR_SDKDLL_EVENTALREADYASSIGNED //
//           | 08.03.2005 |  - FRE: Added                          //
//           |            |        PCO_ERROR_APPLICATION_WRONGRES  //
//           | 19.12.2005 | - FRE: Added                           //
//           |            |   PCO_ERROR_APPLICATION_DISKFULL       //
//           | 22.08.2006 | - FRE: Added                           //
//           |            |   PCO_ERROR_NOTINIT                    //
//           | 13.04.2007 | - FRE: Added                           //
//           |            |   PCO_ERROR_FILEDLL                    //
//           | 25.06.2008 | - FRE: Added                           //
//           |            |   PCO_ERROR_APPLICATION_SET_VALUES     //
//           | 08.12.2008 | - FRE: Added                           //
//           |            |   PCO_ERROR_SDKDLL_RECORDINGMUSTBEON   //
//           | 12.01.2009 | - FRE: Reviewed error/txt assembly     //
//           |            |   Enhanced error decoding due to       //
//           |            |   device and layer numbering           //
//-----------------------------------------------------------------//

#include "PCO_err.h"
#include <string>
#ifndef PCO_ERRT_H
#define PCO_ERRT_H

#if defined _MSC_VER
#pragma message ("This header file is marked as obsolete. Please use PCO_GetErrorTextSDK instead")
#pragma message ("If you still need access to the texts please use PCO_errtext.h.")
#pragma message ("PCO_errt.h will be removed in future SDK releases.")
#else
#warning ("This header file is marked as obsolete. Please use PCO_GetErrorTextSDK instead")
#warning ("If you still need access to the texts please use PCO_errtext.h.")
#warning ("PCO_errt.h will be removed in future SDK releases.")
#endif

#if defined PCO_ERRT_H_CREATE_OBJECT

#include "PCO_errtext.h"

#if defined _MSC_VER
#if     _MSC_VER < 1400
int sprintf_s(char* buf, int dwlen, const char* cp, ...)
{
  va_list arglist;

  va_start(arglist, cp);
  return _vsnprintf(buf, dwlen, cp, arglist);
}
#endif
#endif

void PCO_GetErrorText(DWORD dwerr, char* pbuf, DWORD dwlen)
{
  std::string layertxt;
  std::string errortxt;
  std::string devicetxt;
  char  msg[200];
  int   index;
  DWORD device;
  DWORD layer;

  if(dwlen < 40)
    return;

  index = dwerr & PCO_ERROR_CODE_MASK;

  if((dwerr == PCO_NOERROR) || (index == 0))
  {
    sprintf_s(pbuf, dwlen, "OK.");
    return;
  }


  // -- evaluate device information within complete error code -- //
  // ------------------------------------------------------------ //

  device = dwerr & PCO_ERROR_DEVICE_MASK;
  layer = dwerr & PCO_ERROR_LAYER_MASK;

  // -- evaluate layer information within complete error code --- //
  // ------------------------------------------------------------ //

  switch(dwerr & PCO_ERROR_LAYER_MASK)   // evaluate layer
  {
    case PCO_ERROR_FIRMWARE:
    {
      layertxt = "Firmware";
      switch(device)
      {
        case SC2_ERROR_POWER_CPLD:   devicetxt = "SC2 Power CPLD";   break;
        case SC2_ERROR_HEAD_UP:      devicetxt = "SC2 Head uP";      break;
        case SC2_ERROR_MAIN_UP:      devicetxt = "SC2 Main uP";      break;
        case SC2_ERROR_FWIRE_UP:     devicetxt = "SC2 Firewire uP";  break;
        case SC2_ERROR_MAIN_FPGA:    devicetxt = "SC2 Main FPGA";    break;
        case SC2_ERROR_HEAD_FPGA:    devicetxt = "SC2 Head FPGA";    break;
        case SC2_ERROR_MAIN_BOARD:   devicetxt = "SC2 Main board";   break;
        case SC2_ERROR_HEAD_CPLD:    devicetxt = "SC2 Head CPLD";    break;
        case SC2_ERROR_SENSOR:       devicetxt = "SC2 Image sensor"; break;
        case SC2_ERROR_POWER:        devicetxt = "SC2 Power Unit";   break;
        case SC2_ERROR_GIGE:         devicetxt = "SC2 GigE board";   break;
        case SC2_ERROR_USB:          devicetxt = "SC2 GigE/USB board"; break;
        case SC2_ERROR_BOOT_FPGA:    devicetxt = "BOOT FPGA";        break;
        case SC2_ERROR_BOOT_UP:      devicetxt = "BOOT uP";          break;
        default: devicetxt = "Unknown device";
      }
      break;
    }
    case PCO_ERROR_DRIVER:
    {
      layertxt = "Driver";
      switch(device)
      {
        case PCI540_ERROR_DRIVER:          devicetxt = "Pixelfly driver";    break;

        case SC2_ERROR_DRIVER:             devicetxt = "pco.camera driver";    break;
        case PCI525_ERROR_DRIVER:          devicetxt = "Sensicam driver";    break;

        case PCO_ERROR_DRIVER_FIREWIRE:    devicetxt = "Firewire driver";    break;
        case PCO_ERROR_DRIVER_USB:         devicetxt = "USB 2.0 driver";    break;
        case PCO_ERROR_DRIVER_GIGE:        devicetxt = "GigE driver";    break;
        case PCO_ERROR_DRIVER_CAMERALINK:  devicetxt = "CameraLink driver";    break;
        case PCO_ERROR_DRIVER_USB3:        devicetxt = "USB 3.0 driver";    break;
        case PCO_ERROR_DRIVER_WLAN:        devicetxt = "WLan driver";    break;
        default: devicetxt = "Unknown device";
      }
      break;
    }
    case PCO_ERROR_SDKDLL:
    {
      layertxt = "SDK DLL";
      switch(device)
      {
        case  PCO_ERROR_PCO_SDKDLL:    devicetxt = "camera sdk dll";    break;
        case  PCO_ERROR_CONVERTDLL:    devicetxt = "convert dll";    break;
        case  PCO_ERROR_FILEDLL:       devicetxt = "file dll";    break;
        case  PCO_ERROR_JAVANATIVEDLL: devicetxt = "java native dll";    break;
        case  PCO_ERROR_PROGLIB:       devicetxt = "programmer library";   break;
        default: devicetxt = "Unknown device";
      }
      break;
    }
    case PCO_ERROR_APPLICATION:
    {
      layertxt = "Application";
      switch(device)
      {
        case PCO_ERROR_CAMWARE:    devicetxt = "CamWare";    break;
        case PCO_ERROR_PROGRAMMER: devicetxt = "Programmer";    break;
        case PCO_ERROR_SDKAPPLICATION: devicetxt = "SDK Application";    break;
        default: devicetxt = "Unknown device";
      }

      break;
    }
    default:
    {
      layertxt = "Undefined layer";
      devicetxt = "Unknown device";
    }
  }


  // -- evaluate error information within complete error code --- //
  // ------------------------------------------------------------ //

  if(dwerr & PCO_ERROR_IS_COMMON)
  {
    if(index < COMMON_MSGNUM)
      errortxt = PCO_ERROR_COMMON_TXT[index];
    else
      errortxt = ERROR_CODE_OUTOFRANGE_TXT;
  }
  else
  {
    switch(dwerr & PCO_ERROR_LAYER_MASK)   // evaluate layer
    {
      case PCO_ERROR_FIRMWARE:

      if(dwerr & PCO_ERROR_IS_WARNING)
      {
        if(index < FWWARNING_MSGNUM)
          errortxt = PCO_ERROR_FWWARNING_TXT[index];
        else
          errortxt = ERROR_CODE_OUTOFRANGE_TXT;
      }
      else
      {
        if(index < FIRMWARE_MSGNUM)
          errortxt = PCO_ERROR_FIRMWARE_TXT[index];
        else
          errortxt = ERROR_CODE_OUTOFRANGE_TXT;
      }
      break;


      case PCO_ERROR_DRIVER:

      if(dwerr & PCO_ERROR_IS_WARNING)
      {
        if(index < DRIVERWARNING_MSGNUM)
          errortxt = PCO_ERROR_DRIVERWARNING_TXT[index];
        else
          errortxt = ERROR_CODE_OUTOFRANGE_TXT;
      }
      else
      {
        if(index < DRIVER_MSGNUM)
          errortxt = PCO_ERROR_DRIVER_TXT[index];
        else
          errortxt = ERROR_CODE_OUTOFRANGE_TXT;
      }
      break;


      case PCO_ERROR_SDKDLL:

      if(dwerr & PCO_ERROR_IS_WARNING)
      {
        if(index < SDKDLLWARNING_MSGNUM)
          errortxt = PCO_ERROR_SDKDLLWARNING_TXT[index];
        else
          errortxt = ERROR_CODE_OUTOFRANGE_TXT;
      }
      else
      {
        if(index < SDKDLL_MSGNUM)
          errortxt = PCO_ERROR_SDKDLL_TXT[index];
        else
          errortxt = ERROR_CODE_OUTOFRANGE_TXT;
      }
      break;


      case PCO_ERROR_APPLICATION:

      if(dwerr & PCO_ERROR_IS_WARNING)
      {
        if(index < APPLICATIONWARNING_MSGNUM)
          errortxt = PCO_ERROR_APPLICATIONWARNING_TXT[index];
        else
          errortxt = ERROR_CODE_OUTOFRANGE_TXT;
      }
      else
      {
        if(index < APPLICATION_MSGNUM)
          errortxt = PCO_ERROR_APPLICATION_TXT[index];
        else
          errortxt = ERROR_CODE_OUTOFRANGE_TXT;
      }
      break;


      default:

      errortxt = "No error text available!";
      break;
    }
  }

  if(dwerr & PCO_ERROR_IS_WARNING)
    sprintf_s(msg, 200, "%s warning %x at device '%s': %s",
    layertxt.c_str(), dwerr, devicetxt.c_str(), errortxt.c_str());
  else
    sprintf_s(msg, 200, "%s error %x at device '%s': %s",
    layertxt.c_str(), dwerr, devicetxt.c_str(), errortxt.c_str());

  if(dwlen <= strlen(msg))    // 1 byte more for zero at end of string
  {
    sprintf_s(pbuf, dwlen, "Error buffer too short. err: %x", dwerr);
    return;
  }
  sprintf_s(pbuf, dwlen, "%s", msg);

}

#else // PCO_ERRT_H_CREATE_OBJECT

// Please define 'PCO_ERRT_H_CREATE_OBJECT' in your files once,
// to avoid a linker error-message if you call GetErrorText!

void PCO_GetErrorText(DWORD dwerr, char* pbuf, DWORD dwlen);

#endif//PCO_ERRT_H_CREATE_OBJECT
#endif//PCO_ERRT_H
// please leave last cr lf intact!!
// =========================================== end of file ============================================== //
