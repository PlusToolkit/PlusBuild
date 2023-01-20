/*
 * Copyright (c) 2020 i3system Inc. All rights reserved.
 *
 * This library is licensed under the Creative Commons Attribution 4.0
 * International license. (CC-BY-4.0)
 * Redistribution must reproduce a identification of the creator, a copyright
 * notice, this list of conditions, and the following disclaimer.
 *
 * UNLESS OTHERWISE SEPARATELY UNDERTAKEN BY THE LICENSOR, TO THE
 * EXTENT POSSIBLE, THE LICENSOR OFFERS THE LICENSED MATERIAL AS-IS
 * AND AS-AVAILABLE, AND MAKES NO REPRESENTATIONS OR WARRANTIES OF
 * ANY KIND CONCERNING THE LICENSED MATERIAL, WHETHER EXPRESS,
 * IMPLIED, STATUTORY, OR OTHER. THIS INCLUDES, WITHOUT LIMITATION,
 * WARRANTIES OF TITLE, MERCHANTABILITY, FITNESS FOR A PARTICULAR
 * PURPOSE, NON-INFRINGEMENT, ABSENCE OF LATENT OR OTHER DEFECTS,
 * ACCURACY, OR THE PRESENCE OR ABSENCE OF ERRORS, WHETHER OR NOT
 * KNOWN OR DISCOVERABLE. WHERE DISCLAIMERS OF WARRANTIES ARE NOT
 * ALLOWED IN FULL OR IN PART, THIS DISCLAIMER MAY NOT APPLY TO YOU.

 * TO THE EXTENT POSSIBLE, IN NO EVENT WILL THE LICENSOR BE LIABLE
 * TO YOU ON ANY LEGAL THEORY (INCLUDING, WITHOUT LIMITATION,
 * NEGLIGENCE) OR OTHERWISE FOR ANY DIRECT, SPECIAL, INDIRECT,
 * INCIDENTAL, CONSEQUENTIAL, PUNITIVE, EXEMPLARY, OR OTHER LOSSES,
 * COSTS, EXPENSES, OR DAMAGES ARISING OUT OF THIS PUBLIC LICENSE OR
 * USE OF THE LICENSED MATERIAL, EVEN IF THE LICENSOR HAS BEEN
 * ADVISED OF THE POSSIBILITY OF SUCH LOSSES, COSTS, EXPENSES, OR
 * DAMAGES. WHERE A LIMITATION OF LIABILITY IS NOT ALLOWED IN FULL OR
 * IN PART, THIS LIMITATION MAY NOT APPLY TO YOU.
 */

/** @file
@brief  This file defines abstract class for communication with Thermal Expert
*/
#pragma once
#ifndef I3SYSTEM_TE_H
#define I3SYSTEM_TE_H

#include "i3_types.h"

#define MAX_USB_NUM	32

#ifdef I3_DLL_EXPORT
#define I3_LIB_API __declspec(dllexport)
#else
#define I3_LIB_API __declspec(dllimport)
#endif

#define I3_TE_Q1	0x01
#define I3_TE_V1	0x02
#define I3_TE_EQ1	0x03
#define I3_TE_EV1	0x04
#define I3_TE_M1	0x09
#define I3_TE_EQ2	0x0C
#define I3_TE_EV2	0x0D
#define I3_TE_Q2    0x0E

#define I3_TEMP_SHUTTER		0x0000
#define I3_TIME_SHUTTER		0x0001
#define I3_MANUAL_SHUTTER	0x0002

#define I3_SHUTTER_TIME_MIN 0x0001
#define I3_SHUTTER_TIME_MAX 0x0078

#define I3_SHUTTER_TEMP_MIN 0x0001
#define I3_SHUTTER_TEMP_MAX 0x000A

#define I3_COLORMAP_WHITEHOT		0
#define I3_COLORMAP_BLACKHOT		1
#define I3_COLORMAP_IRON			2
#define I3_COLORMAP_BLUERED			3
#define I3_COLORMAP_MEDICAL			4
#define I3_COLORMAP_PURPLE			5
#define I3_COLORMAP_PURPLEYELLOW	6
#define I3_COLORMAP_DARKBLUE		7
#define I3_COLORMAP_CYAN			8
#define I3_COLORMAP_RAINBOW			9

namespace i3 {

    typedef int (*img_cb_fn)(void* _inBuf, void* _outBuf, void *_args);

	class ITE_A_Impl;
	class ITE_B_Impl;

	/*! \brief Interface for communication with Thermal Expert Type A(EQ1, EV1, EQ2, EV2)
	*/
	class TE_A {
	public:
		/**
			@brief Constructor of TE_A class
		*/
		TE_A(void *_initParams);

		/**
			@brief Destructor of TE_A class
		*/
		virtual ~TE_A();

		/**
			@brief Disconnect Thermal Expert
			@remark This function disconnect the Thermal Expert and delete data. Call this function after finishing the work.
		*/
		virtual void CloseTE();

		/**
			@brief Receive image data
			@param pRecvImage : variable to get image data (384x288 for QVGA and 640x480 for VGA, 16bits)
			@param _AGC_On : if set true, AGC algorithm is applied. Otherwise, AGC is not applied.
			@return 1: Read image successfully
			@return 2: Read image of size 0
			@return 3: Recieved image size is not equal to requested size
			@return 4: Data read fail
			@remark This function receive data from Thermal Expert and calibrate to show image. It send image data to pRecvImage. If _AGC_On is set to true, gain and offset value is automatically calculated so that image data will be fitted to 16bit range.
		*/
		virtual int RecvImage(unsigned short *pRecvImage, bool _AGC_On);

		/**
           @brief Receive image data with temperature limit
           @param img_buf : variable to get image data (384x288 for QVGA and 640x480 for VGA, 16bits)
           @param temp_min : minimum temperature to express in image
           @param temp_max : maximum temperature to express in image
           @return 1: Read image successfully
           @return 2: Read image of size 0
           @return 3: Recieved image size is not equal to requested size
           @return 4: Data read fail
           @remark This function receive image data from Thermal Expert and manipulate data to express scene within temperature range. if temperature is smaller than temp_min, 0 will be assigned, and if temperature is greater than temp_max, 65535 will be assigned.  temperature within those limit will set value between 0 and 65535 depending on temperature.
		*/
		virtual int RecvImage(unsigned short *img_buf, float temp_min, float temp_max);

		/**
           @brief Receive image data which image processing algorithm is applied to.
           @param dst : Buffer to get output image.
           @return 1: Read image successfully
           @return 2: Read image of size 0
           @return 3: Recieved image size is not equal to requested size
           @return 4: Data read fail
           @remark This function receives data from Thermal Expert and applies image processing algorithm depending on parameters set. Parameters for image processing algorithms can be set in SetImgOutPrms function. AGC is enabled and other image processing algorithms are disabled in default setting.
		*/
        virtual int RecvImage(unsigned short *dst);

		/**
           @brief Set Image Output Parameters
           @param prms : Parameters to apply.
           @remark This function sets parameters to determine image processing algorithms which is appiled after receiving raw data from thermal detector. These parameters are applied when user gets image from RecvImage(unsigned short *dst) function. Other RecvImage function does not apply these parameters and returns data depending on its own arguments.
		*/
        virtual void SetImgOutPrms(IMGOUTPRMS prms);

		/**
			@brief Get image width
			@return Image width
			@remark Return width of image, i.e. it returns 384 for QVGA and 640 for VGA
		*/
		virtual int GetImageWidth();

		/**
			@brief Get image height
			@return Image height
			@remark Return height of image, i.e. it returns 288 for QVGA and 480 for VGA
		*/
		virtual int GetImageHeight();

		/**
           @brief Get temperature (1 pixel)
           @param _x : x coordinate
           @param _y : y coordinate
           @remark This function returns temperature for given pixel. RecvImage function should be called before calling this function. Returned values are modified to fit into 2byte. To get temperature, user should subtract 5000 and then divide by 100, i.e. (real temperature value) = (return value - 5000) / 100
		*/
		virtual unsigned short CalcTemp(unsigned short _x, unsigned short _y);

		/**
			@brief Get temperature of 1 frame
			@param _pTempBuf : buffer to get temperature data (384x288 for QVGA and 640x480 for VGA)
			@remark This function returns temperature data for entire image which is most recently received. Therefore RecvImage function should be called before calling this function. Returned values are modified to fit into 2byte. To get temperature, user should subtract 5000 and then divide by 100, i.e. (real temperature value) = (return value - 5000) / 100
		*/
		virtual void CalcTemp(unsigned short *_pTempBuf);

		/**
			@brief Reset TE engine
			@return true if reset signal is transferred successfully, otherwise return false
			@remark It sends signal to reset TE engine. After calling this function, TE will be rebooted.
		*/
		virtual bool ResetMainBoard();

		/**
			@brief Set emissivity value
			@param _emissivity : emissivity value to apply
			@remark It sets emissivity value and afterwards emissivity applied temperature value will be returned when calling CalcTemp function.
		*/
		virtual void SetEmissivity(float _emissivity);

		/**
           @brief Save current setting in TE
           @param _pSetting : Pointer of TE_SETTING struct which contains setting values to save
           @return true if save setting signal is transferred successfully, otherwise return false
           @remark It sends signal to save setting values in TE engine. Values in _pSetting struct will be saved. But, saved setting values are not applied until power is off. If settings are successfully saved, thsee values will be applied when TE is connected.
		*/
		virtual bool SaveSetting(TE_SETTING *_pSetting);

		/**
           @brief Get current setting in TE
           @param _pSetting : Pointer of TE_SETTING struct to get setting values
           @remark It returns current setting values in _pSetting variable.
		*/
		virtual void GetSetting(TE_SETTING *_pSetting);

		virtual bool UpdateTempData(float _target1, float _meas1, float _target2, float _meas2);

		/**
           @brief Set shutter operation mode
           @param _mode : Shutter operation mode. (Time mode = I3_TIME_SHUTTER, Temperature mode = I3_TEMP_SHUTTER)
           @return true : Signal is transferred successfully
           @return false : Transfer of signal failed
           @remark Shutter in TE engine is automatically closed and do calibration to maintain high image quality. This function set a condition when shutter is closed. It supports time mode which closes shutter periodically with specified period and temperature mode which closes shutter when temperature of shutter is changed with specified amount.
           @remark See SetShutterTemperature and SetShutterTime.
		*/
		virtual bool SetShutterMode(unsigned short _mode);

		/**
           @brief Set period of shutter operation
           @param _time : Period of shutter operation. This value should be withnin I3_SHUTTER_TIME_MIN and I3_SHUTTER_TIME_MAX.
           @return true : set signal is transferred successfully
           @return false : Transfer of signal failed
           @remark This function is used to set period of shutter operation. Shutter is close for every _time * 30 sec if time shutter mode is set.
           @remark See SetShutterMode.
		*/
		virtual bool SetShutterTime(unsigned short _time);

		/**
           @brief Set temperature variation limit to close shutter
           @param _temp : temperature variation limit. This value should be withnin I3_SHUTTER_TEMP_MIN and I3_SHUTTER_TEMP_MAX.
           @return true : set signal is transferred successfully
           @return false : Transfer of signal failed
           @remark When temperature shutter mode is set, shutter will be closed if temperature change of shutter is over temperature variation limit. This function set the limit.
           @remark See SetShutterMode.
		*/
		virtual bool SetShutterTemperature(unsigned short _temp);

		/**
           @brief Do calibration
           @return true: success
           @return false: fail
           @remark This function will close shutter and recalculate offset values to obtain uniform image.
		*/
		virtual bool ShutterCalibrationOn();

		/**
           @brief Get serial number of TE
           @return serial number
           @remark This function returns serial number of TE which is unique for each product.
		*/
		virtual unsigned int GetID();

		/**
           @brief Get FPA temperature
           @return fpa temperature
           @remark This function returns fpa temperature. This value depends on environment temperature. Also it is different for every TE even though TEs are in same condition.
           @remark FPA temperature is updated when image is taken from TE and this function returns most recently received value.
		*/
		virtual float GetFpaTemp();

		/**
           @brief Get PT100 sensor output
           @return PT100 sensor output
           @remark PT100 sensor is attached to shutter in order to calibrate temperature and it returns this PT100 sensor output.
           @remark PT100 output value is updated when shutter is closed. Therefore if shutter is not closed for long time, it may return incorrect value. User should close shutter periodically to get correct value by calling ShutterCalibrationOn or SetShutterMode function.
           @remark Also, TE sends this value at the end of image data, so it returns PT100 output which is received at last RecvImage function call. To get current PT100 output, RecvImage needs to be called before calling this function.
		*/
		virtual unsigned short GetShutterPt100RawValue();

		/**
           @brief Get Shutter temperature
           @return Shutter temperature
           @remark PT100 sensor is attached to shutter in order to calibrate temperature and it returns this shutter temperature computed from this PT100 sensor output.
           @remark PT100 output value is updated when shutter is closed. Therefore if shutter is not closed for long time, it may return incorrect value. User should close shutter periodically to get correct value by calling ShutterCalibrationOn or SetShutterMode function.
           @remark Also, TE sends this value at the end of image data, so it returns PT100 output which is received at last RecvImage function call. To get current PT100 output, RecvImage needs to be called before calling this function.
		*/
		virtual float GetShutterPt100Temp();

		/**
           @brief Save calibration data in file
           @return true: success
           @return false: fail
           @remark This function will save offset values to obtain uniform image in file with given path. Before calling this function, call LensShadingCorrection function.
		*/
		virtual bool SaveCalibration(const char *_path);

        /**
           @brief Load calibration data
           @param _path : file name to load
           @return true : succeeded to load data
           @return false : failed to load data (file open fail, incorrect file size, or incorrect data load)
           @remark If user have calibration data (using SaveCalibration function), user can load that file and apply calibration data to improve image quality.
           @remark Incorrect file load can cause bad image quality or file load fail.
		*/

		virtual bool LoadCalibration(const char *_path);

        /**
           @brief Do Lens Shading Correction
           @return true if success. otherwise false
           @remark This function calibrate shading at outer position generated by lens effect in order to make uniform image. Thermal Expert engine should see uniform scene before executing this function.
        */
		virtual bool LensShadingCorrection();

	private:
		/**
		@brief TE_A implementation class
		*/
		ITE_A_Impl *m_pTE_Impl;
	};

	/*! \brief Interface for communication with Thermal Expert Type B(Q1, V1, M1)
	*/
	class TE_B {
	public:

		/**
			@brief Constructor of TE_B class
		*/
		TE_B(unsigned int _coreID, unsigned int _rcgData, int hnd_dev, int _modelNum);

		/**
			@brief Destructor of TE_B class
		*/
		virtual ~TE_B();

		/**
			@brief Disconnect Thermal Expert
			@remark This function disconnect the Thermal Expert and delete data. Do this function after finishing the work.
		*/
		virtual void	CloseTE();

		/**
			@brief Receive image data
			@param pRecvImage : variable to get image data (384x288 for QVGA and 640x480 for VGA, 32 bits gray data (not normalized))
			@return 1: Read image successfully
			@return 2: Read image of size 0
			@return 3: Recieved image size is not equal to requested size
			@return 4: Data read fail
			@return 7: Flash Data is not read
			@remark This function receive data from Thermal Expert and calibrate to show image. It send image data to pRecvImage in which AGC algorithm is not applied. Gain and offset value should be applied in user side.
		*/
		virtual int		RecvImage(float *pRecvImage);

		/**
			@brief Receive image data
			@param pRecvImage : variable to get image data (384x288 for QVGA and 640x480 for VGA, 16 bits gray data)
			@return 1: Read image successfully
			@return 2: Read image of size 0
			@return 3: Recieved image size is not equal to requested size
			@return 4: Data read fail
			@return 7: Flash Data is not read
			@remark This function receive data from Thermal Expert and calibrate to show image. It applies AGC algorithm, and then send image data fitted to 16bits to input argument pRecvImage.
		*/
		virtual int		RecvImage(unsigned short *pRecvImage);


        /**
           @brief Receive image data which image processing algorithm is applied to.
           @param dst : Buffer to get output image. If no post processing is applied, float data is returned, so buffer size should be (4 * pixel num). Otherwise, 16 bit data is returned and buffer size should be (2 * pixel num).
           @return 1: Read image successfully
           @return 2: Read image of size 0
           @return 3: Recieved image size is not equal to requested size
           @return 4: Data read fail
           @remark This function receives data from Thermal Expert and applies image processing algorithm depending on parameters set. Parameters for image processing algorithms can be set in SetImgOutPrms function. AGC is enabled and other image processing algorithms are disabled in default setting.
		*/
        virtual int RecvImage(void *dst);

		/**
           @brief Set Image Output Parameters
           @param prms : Parameters to apply.
           @remark This function sets parameters to determine image processing algorithms which is appiled after receiving raw data from thermal detector. These parameters are applied when user gets image from RecvImage(void *dst) function. Other RecvImage function does not apply these parameters and returns data depending on its own arguments.
		*/
        virtual void SetImgOutPrms(IMGOUTPRMS prms);

		/**
			@brief Do calibration
			@return 1: success
			@return 2: fail
			@remark This function will recalculate offset data for calibration.
			@remark Before calibration, stop receiving image data from Thermal Expert, and set Thermal Expert to see uniform temperature scene. It will recalculate offset to obtain uniform image.
		*/
		virtual int ShutterCalibrationOn();

		/**
			@brief Calculate temperature
			@param _x : Horizontal position of target pixel (0~383 for QVGA, 0~639 for VGA)
            @param _y : Vertical position of target pixel (0~287 for QVGA, 0~479 for VGA)
			@return Temperature (Celsius)
			@remark Return temperature of target pixel (_x, _y) from previously received image data.
		*/
		virtual float CalcTemp(int _x, int _y);

		/**
			@brief Calculate temperature of all image pixels
			@param pRecvTemp : variable to get temperature data (384x288 for QVGA and 640x480 for VGA, 32bits)
			@remark Return temperature array of all pixels to pRecvTemp from previously received image data.
		*/
		virtual void CalcEntireTemp(float *pRecvTemp);

		/**
			@brief Update bad pixels
			@return 0 : fail to update
			@return 1 : succeed to update
			@remark In some cases, bad pixels can be generated while using TE which does not exist before, so it is considered non-dead pixel in flash data. This function receive images and analyze if additional bad pixels exist. If bad pixels exist, it will update dead data and calibration process will be applied to those pixels afterwards.
			@remark Update data is not stored after disconnection. So, User should call this function for every reconnection if user want to update bad pixels.
		*/
		virtual int UpdateDead();

		/**
           @brief Update bad pixels & save in files
           @return 0 : fail to update
           @return 1 : succeed to update
           @remark In some cases, bad pixels can be generated while using TE which does not exist before, so it is considered non-dead pixel in flash data. This function receive images and analyze if additional bad pixels exist. If bad pixels exist, it will update and save dead data and calibration process will be applied to those pixels afterwards. This function appends bad pixels in file, so to refresh bad pixels, delete file and call this function.
           @remark Update data is not stored after disconnection. So, User should call this function for every reconnection if user want to update bad pixels.
		*/
		virtual int UpdateDead(const char *path);

		virtual int UpdateDead(const char *path, double _crit);

		/**
           @brief Add or remove bad pixel
           @param x : x coordinate of bad pixel
           @param y : y coordinate of bad pixel
           @return TRUE : pixel set as bad pixel
           @return FALSE : pixel set as not bad pixel
           @remark When some pixels look like dead pixels, user may want to set those pixels as bad pixels manually and do calibration for those pixels afterwards. It provides those functionality.
           @remark Insert x & y coordinate in arguments and it will set this pixel as bad pixel and calibartion will be done. To remove from bad pixel, call this function once more.
		*/
		virtual int AddDead(unsigned int x, unsigned int y);

		/**
           @brief Add or remove bad pixel
           @param pos : (width of image) * (y coordinate of bad pixel) + (x coordinate of bad pixel)
           @return TRUE : pixel set as bad pixel
           @return FALSE : pixel set as not bad pixel
           @remark When some pixels look like dead pixels, user may want to set those pixels as bad pixels manually and do calibration for those pixels afterwards. It provides those functionality.
           @remark Insert index of bad pixel in arguments and it will set this pixel as bad pixel and calibartion will be done. To remove from bad pixel, call this function once more.
		*/
		virtual int AddDead(unsigned int pos);

		/**
           @brief Get image width
           @return Image width
           @remark Return width of image, i.e. it returns 384 for QVGA and 640 for VGA
		*/
		virtual int		GetImageWidth();

		/**
           @brief Get image height
           @return Image height
           @remark Return height of image, i.e. it returns 288 for QVGA and 480 for VGA
		*/
		virtual int		GetImageHeight();

		/**
           @brief Set emissivity value
           @param _emissivity : emissivity value to apply
           @remark It sets emissivity value and afterwards emissivity applied temperature value will be returned when calling CalcTemp function.
		*/
		virtual void	SetEmissivity(float _emissivity);

		/**
           @brief Get FPA temperature
           @return fpa temperature
           @remark This function returns fpa temperature. This value depends on environment temperature. Also it is different for every TE even though TEs are in same condition.
           @remark FPA temperature is updated when image is taken from TE and this function returns most recently received value.
		*/
		virtual float GetFpaTemp();

		/**
           @brief Get FPA temperature raw value
           @return fpa temperature
           @remark This function returns fpa temperature. This value depends on environment temperature. Also it is different for every TE even though TEs are in same condition.
           @remark FPA temperature is updated when image is taken from TE and this function returns most recently received value.
		*/
		virtual unsigned short GetFPATemp();

        /**
           @brief Get 1 frame temperature data
           @param pRecvTemp : output temperature buffer
           @return 1: Read image successfully
           @return 2: Read image of size 0
           @return 3: Recieved image size is not equal to requested size
           @return 4: Data read fail
           @return 7: Flash Data is not read
           @remark This function returns 1 frame temperature data. Compared to CalcEntireTemp function, it does not use previously received data. It takes new data and calaculate temperature values.
		*/
		virtual int getFrameTemperature(float *pRecvTemp);

		/**
		@brief Save calibration data
		@param _file : file name to save data
		@return true : succeeded to save data
		@return false : failed to save data (file open fail or incorrect data save)
		@remark User can use ShutterCalibrationOn function to make uniform image. If user want to save this calibration data and use it later, user can use this function. (call ShutterCalibrationOn function first)
		@remark It saves calibration data in _file. This file can be used in Loadcalibration.
		*/
		virtual bool SaveCalibration(const char *_file);

		/**
		@brief Load calibration data
		@param _file : file name to load data
		@return true : succeeded to load data
		@return false : failed to load data (file open fail, incorrect file size, or incorrect data load)
		@remark If user have calibration data (using SaveCalibration function), user can load that file and apply calibration data to improve image quality.
		@remark Incorrect file load can cause bad image quality or file load fail.
		*/
		virtual bool LoadCalibration(const char *_file);

	private:
		/**
		@brief TE_B implementation class
		*/
		ITE_B_Impl *m_pTE_Impl;
	};


	/**
	@brief Apply color to input image
	@param dst : output image (24bit color image, brg888)
	@param src : input image (8bit gray image)
	@param color : colormap to apply. its value ranges from I3_COLORMAP_WHITEHOT to I3_COLORMAP_RAINBOW.
	@param width : width of image
	@param height : height of image
	@remark : This function convert 8 bit input gray image to 24 bit (bgr888) color image. Supported colormaps are whitehot, blackhot, iron, bluered, medical, purple, purpleyellow, darkblue, cyan, and rainbow.
	@remark : Since received image from Thermal Expert is 16 bit, it needs to be converted to 8 bit image before applay this function.
	*/
	extern "C" I3_LIB_API void ApplyColorMap(unsigned char *dst, unsigned char *src, int color, int width, int height);

	/**
	@brief Check connected TE.
	@param pDevCon : Buffer to get scan results. It should MAX_USB_NUM size array.
	@return 1 : Scan successfully
	@return Otherwise : Failed to scan
	@remark This function scans connected TE and return the results. The result contains connected devices's ID, Product Model, and device number.
	@remark For each connected TE, a device number(0 ~ MAX_USB_NUM - 1) is assigned. TE which has device number i corresponeds to i-th element of pDevCon and its scaned result is stored in i-th element of pDevCon. This device number is used in other function as hnd_dev.
	*/
	extern "C" I3_LIB_API int ScanTE(SCANINFO *pDevCon);

	/**
	@brief Connect Thermal Expert of Type A model.
	@param hnd_dev : device number for TE to connect
	@return  nullptr : fail to open TE.
	@return  TE_A*(not nullptr) : pointer of TE_A class
	@remark This function get TE device handle and make TE ready to communicate with host. It must be called to communicate with TE.
	*/
	extern "C" I3_LIB_API TE_A*  OpenTE_A(int hnd_dev);

	/**
	@brief Connect Thermal Expert of Type B model.
	@param _model : Indicator for TE model. Set I3_TE_Q1 for Q1, I3_TE_V1 for V1 and I3_TE_Q2 for Q2.
	@param hnd_dev : Device number for TE to connect
	@return  nullptr : fail to open TE.
	@return  TE_B*(not nullptr) : pointer of TE_B class
	@remark This function get TE device handle and make TE ready to communicate with host. After connection, calibration data will be read from flash memory to create image. It may take few seconds.
	@remark This function must be called to communicate with TE.
	*/
	extern "C" I3_LIB_API TE_B*  OpenTE_B(int _model, int hnd_dev);

	/**
	@brief Check TE connection
	@param iMsg : USB connection is changed or not
	@param wParam : TE is removed or arrived
	@param lParam : device information
	@return  1 : TE is arrived successfully
	@return  2 : TE is arrived but driver is not opened successfully
	@return  3 : TE is removed successfully
	@remark This function checks TE connection. Insert this function in WindowProc function of MFC dialog. Then it will return 1 if TE is connected through usb port and return 3 if TE is removed from usb port.
	*/
	extern "C" I3_LIB_API int __cdecl WindowProcTE(UINT iMsg, WPARAM wParam, LPARAM lParam);

	/**
	@brief Register TE device to get PNP information
	@param hwnd : A handle to the window that will receive device events.
	@return true : succeed in register
	@return false : failed to register
	@remark : This function register device for PNP notification. To get PNP information, call this function once when initialize program
	*/
	extern "C" I3_LIB_API bool __cdecl RegisterTE(HWND hwnd);

	/**
	@brief Unregister TE
	@remark : This function unregister device. call this function when PNP information is not required
	*/
	extern "C" I3_LIB_API void __cdecl UnregisterTE();

	//extern "C" I3_LIB_API void __cdecl testfnc();

}
#endif // !I3SYSTEM_TE_H

/*! \brief Example code for TE type A. */
/*! \page Example_A
*  \include Example_A.cpp
*/
/*! \brief Example code for TE type B. */
/*! \page Example_B
*  \include Example_B.cpp
*/

