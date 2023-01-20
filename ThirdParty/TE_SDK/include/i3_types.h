/** @file
    @brief  This file defines data structures.
*/

#ifndef I3_TYPES_H
#define I3_TYPES_H

namespace i3 {

	/*! \brief struct for getting connected TE info.
	*
	* This structure is used for ScanTE function. ScanTE function returns connected TE info in this structure.
	*/
	typedef struct TEScanData {
		unsigned char	bDevCon;	/**< indicates if TE is connected or not. 1 means connected, otherwise not connected. */
		unsigned int	nCoreID;	/**< ID of connected TE */
		unsigned int	nProdVer;	/**<  Connected model. 1 for Q1, 2 for V1, 3 for EQ1, 4 for EV1, 9 for M1, 12 for EQ2, 13 for EV2*/
		TEScanData() {
			bDevCon = 0;
			nCoreID = 0;
			nProdVer = 0;
		}
	}SCANINFO;




	/*! \brief struct for setting values of TE.
	*
	* This structure is used to save or get setting values of TE.
	*/
	typedef struct TE_Setting {
		unsigned short frameRate;
		unsigned short exportable;
		unsigned short shutterMode;    /**< Shutter Operation Mode. */
		unsigned short shutterTime;    /**< Period of Shutter Operation (x30 sec). */
		unsigned short shutterTemp;    /**< Temperature Difference to Operate Shutter. */
		unsigned short highTempMode;

		TE_Setting& operator = (const TE_Setting &_in){
			frameRate = _in.frameRate;
			exportable = _in.exportable;
			shutterMode = _in.shutterMode;
			shutterTime = _in.shutterTime;
			shutterTemp = _in.shutterTemp;
			highTempMode = _in.highTempMode;
			return *this;
		}
	} TE_SETTING;


	/*! \brief struct for setting image processing parameters.
	*
	* This structure is used to set image processing algorithm parameters.
	*/
	typedef struct {
		bool enable;            /**< Enable Image Processing Algorithm. */
		bool tnf;               /**< Enable temporal noise filter. */
		bool snf;               /**< Enable spatial noise filter. */
		float edgeLevel;        /**< Edge enhancement strength. It should be greater than 0. Default value is 1. */
	}IMGPROCPRMS;

	/*! \brief struct for setting image output parameters.
	*
	* This structure is used to set parameters for image processing algorithms.
	* These parameters are applied when user gets data from RecvImage(unsigned short *dst) function.
	* Other RecvImage function does not apply these parameters.
	*/
	typedef struct {
		bool agc;               /**< Enable AGC Algorithm. Appied only when image processing algorithm is disabled */
		IMGPROCPRMS imgProc;    /**< Parameters for image processing algorithm. */
	} IMGOUTPRMS;


}


#endif // I3_TYPES_H
