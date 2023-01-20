//-----------------------------------------------------------------//
// Name        | Pco_Edge_GS_Calc_Export.h   | Type: ( ) source    //
//-------------------------------------------|       (*) header    //
// Project     | PCO                         |       ( ) others    //
//-----------------------------------------------------------------//
// Platform    | PC                                                //
//-----------------------------------------------------------------//
// Environment | Visual 'C++'                                      //
//-----------------------------------------------------------------//
// Purpose     | pco edge GlobalShutter conversion                 //
//-----------------------------------------------------------------//
// Author      | MBL, PCO AG                                       //
//-----------------------------------------------------------------//
// Revision    | rev. 1.02 rel. 0.00                               //
//-----------------------------------------------------------------//
// Notes       |                                                   //
//             |                                                   //
//             |                                                   //
//             |                                                   //
//-----------------------------------------------------------------//
// (c) 2011 PCO AG * Donaupark 11 *                                //
// D-93309      Kelheim / Germany * Phone: +49 (0)9441 / 2005-0 *  //
// Fax: +49 (0)9441 / 2005-20 * Email: info@pco.de                 //
//-----------------------------------------------------------------//


//-----------------------------------------------------------------//
// Revision History:                                               //
//-----------------------------------------------------------------//
// Rev.:     | Date:      | Changed:                               //
// --------- | ---------- | ---------------------------------------//
//  0.01     | 15.12.2011 |  new file                              //
//-----------------------------------------------------------------//
//  1.02     | 24.01.2014 |  Added conversion context              //
//           |            |                                        //
//-----------------------------------------------------------------//

#ifdef PCO_EXPORT
 #define GS_CONV_CEXP __declspec(dllexport) WINAPI
#elif PCO_EXPORT_DEF
 #define GS_CONV_CEXP WINAPI
#else
#if !defined CEXP
#define GS_CONV_CEXP __declspec(dllimport) WINAPI
#endif
#endif


#define PCO_GS_CONVERT_DOUBLE 0x01


#ifdef __cplusplus
extern "C" {            //  Assume C declarations for C++
#endif  //C++

DWORD GS_CONV_CEXP PCO_GS_ConvertCreate(HANDLE *ph);
//Create a unique convert context
//A unique set must be used, when the conversion functions are called
//simultaneously from different threads
//When the library is unloaded all created convert context are deleted
//in:
// ph   -> pointer to hold the Handle of the unique set
//         must be set to NULL
//
//out:
// *ph  -> Handle of the unique set


DWORD GS_CONV_CEXP PCO_GS_ConvertDelete(HANDLE *ph);
//Delete a previously created convert context
//in:
// *ph  -> Handle of the conversion set
//
//out:
// *ph  -> NULL if conversion set was deleted successfully

DWORD GS_CONV_CEXP PCO_GS_Build_Random(HANDLE ph,unsigned int seed,int size);
//Does build a table of random numbers, which is needed for the calculation function.
//The memory, which is allocated for the table is released, when the convert context is deleted or
//when the function is called again with a different size.
//
//in:
// ph     -> Handle of the conversion set
// seed   -> initialisation value for random number generator
// size   -> size of table in bytes. Size should be at least 65536.
//           (internal build table has a size of 131072 Bytes)
//
//out:


DWORD GS_CONV_CEXP PCO_GS_Get_Random(HANDLE ph,unsigned int *seed,int *size);
//Get the values which have been used to create the random table for this convert context
//
//in:
// ph     -> Handle of the conversion set
// seed   -> pointer for the seed value for random number generator
// size   -> pointer for the table size
//
//out:
// *seed  -> seed value for random number generator
// *size  -> table size



DWORD GS_CONV_CEXP PCO_GS_Set_Random_Off(HANDLE ph,unsigned int offset);
//Set the offset into the random table for next calculation
//offset is changed in each calculation
//
//in:
// ph      -> Handle of the conversion set
// offset  -> offset into random_table
//
//out:

DWORD GS_CONV_CEXP PCO_GS_Get_Random_Off(HANDLE ph,unsigned int *offset);
//Get the offset into the random table from last calculation
//offset is changed in each calculation
//
//in:
// ph      -> Handle of the conversion set
// offset  -> pointer to hold the offset value
//
//out:
// *offset -> resulting value


DWORD GS_CONV_CEXP PCO_GS_Set_ConvertOptions(HANDLE ph,int flags);
//Change the calculation options in the convert context.
//currently supported flags are:
// PCO_GS_CONVERT_DOUBLE: enable/disable calculation of images grabbed in double mode
//
//in:
// ph      -> Handle of the conversion set
// flags   -> flags to set
//
//out:



DWORD GS_CONV_CEXP PCO_GS_Set_Random_Range(HANDLE ph,int rmin,int rmax);
DWORD GS_CONV_CEXP PCO_GS_Set_Camera_Offset(HANDLE ph,int value);


DWORD GS_CONV_CEXP PCO_GS_Calculate(HANDLE ph,int width,int height,unsigned short *picin,unsigned short *picout);
//Calculate resulting image from a raw pco.edge GlobalShutter image, which does contain the packed 
//reset and data image.
//
//in:
// ph     -> Handle of the conversion set
// width  -> camera image width
// height -> camera image height
// picin  -> pointer of buffer, which contains the packed camera image
//           size of this buffer must be ((width*12)/16)*height*2*2 Bytes  
// picout -> pointer of buffer, which receives the calculated image
//           size of this buffer must be width*height*2 Bytes  
//
//out:
// *picout -> resulting image data

DWORD GS_CONV_CEXP PCO_GS_Calculate_Off(HANDLE ph,int width,int height,unsigned short *picin,unsigned short *picout,unsigned int *random_off);
//Calculate resulting image from a raw pco.edge GlobalShutter image, which does contain the packed 
//reset and data image.
//
//in:
// ph     -> Handle of the conversion set
// width  -> camera image width
// height -> camera image height
// picin  -> pointer of buffer, which contains the packed camera image
//           size of this buffer must be ((width*12)/16)*height*2*2 Bytes  
// picout -> pointer of buffer, which receives the calculated image
//           size of this buffer must be width*height*2 Bytes  
// *random_off  -> offset into random_table
//
//out:
// *picout -> resulting image data
// *random_off  -> offset into random_table after conversion

DWORD GS_CONV_CEXP PCO_GS_Calculate_TS(HANDLE ph,int timestampmode,int width,int height,unsigned short *picin,unsigned short *picout);
//Calculate resulting image from a raw pco.edge GlobalShutter image, which does contain the packed 
//reset and data image.
//
//in:
// ph     -> Handle of the conversion set
// timestampmode -> timestampmode which was set when the image has been grabbed
// width  -> camera image width
// height -> camera image height
// picin  -> pointer of buffer, which contains the packed camera image
//           size of this buffer must be ((width*12)/16)*height*2*2 Bytes  
// picout -> pointer of buffer, which receives the calculated image
//           size of this buffer must be width*height*2 Bytes  
//
//out:
// *picout -> resulting image data

DWORD GS_CONV_CEXP PCO_GS_Calculate_TS_Off(HANDLE ph,int timestampmode,int width,int height,unsigned short *picin,unsigned short *picout,unsigned int *random_off);
//Calculate resulting image from a raw pco.edge GlobalShutter image, which does contain the packed 
//reset and data image.
//
//in:
// ph     -> Handle of the conversion set
// timestampmode -> timestampmode which was set when the image has been grabbed
// width  -> camera image width
// height -> camera image height
// picin  -> pointer of buffer, which contains the packed camera image
//           size of this buffer must be ((width*12)/16)*height*2*2 Bytes  
// picout -> pointer of buffer, which receives the calculated image
//           size of this buffer must be width*height*2 Bytes  
// *random_off  -> offset into random_table
//
//out:
// *picout -> resulting image data
// *random_off  -> offset into random_table after conversion

DWORD GS_CONV_CEXP PCO_GS_Calculate_Bottom(HANDLE ph,int width,int height,unsigned short *picin,unsigned short *picout);
//Calculate resulting image bottom half from a raw pco.edge GlobalShutter image, which does contain the packed 
//reset and data image.
//
//in:
// ph     -> Handle of the conversion set
// width  -> camera image width
// height -> camera image height
// picin  -> pointer of buffer, which contains the packed camera image
//           size of this buffer must be ((width*12)/16)*height*2*2 Bytes  
// picout -> pointer of buffer, which receives the calculated image
//           size of this buffer must be width*height*2 Bytes  
//
//out:
// *picout -> resulting image data


DWORD GS_CONV_CEXP PCO_GS_Calculate_Top(HANDLE ph,int width,int height,unsigned short *picin,unsigned short *picout);
//Calculate resulting image top half from a raw pco.edge GlobalShutter image, which does contain the packed 
//reset and data image.
//
//in:
// ph     -> Handle of the conversion set
// width  -> camera image width
// height -> camera image height
// picin  -> pointer of buffer, which contains the packed camera image
//           size of this buffer must be ((width*12)/16)*height*2*2 Bytes  
// picout -> pointer of buffer, which receives the calculated image
//           size of this buffer must be width*height*2 Bytes  
//
//out:
// *picout -> resulting image data


DWORD GS_CONV_CEXP PCO_GS_Calculate_TS_Top(HANDLE ph,int timestampmode,int width,int height,unsigned short *picin,unsigned short *picout);
//in:
// ph     -> Handle of the conversion set
// timestampmode -> timestampmode which was set when the image has been grabbed
// width  -> camera image width
// height -> camera image height
// picin  -> pointer of buffer, which contains the packed camera image
//           size of this buffer must be ((width*12)/16)*height*2*2 Bytes  
// picout -> pointer of buffer, which receives the calculated image
//           size of this buffer must be width*height*2 Bytes  
//
//out:
// *picout -> resulting image data



//-----------------------------------------------------------------//
//-----------------------------------------------------------------//
//                                                                 //
// The following functions are deprecated and stay here            //
// only for backward compatibility                                 //
//                                                                 //
//-----------------------------------------------------------------//
//-----------------------------------------------------------------//


void GS_CONV_CEXP PCO_Build_Random(unsigned int seed,int size);
//Does build a table of random numbers, which is needed for the calculation function.
//The memory, which is allocated for the table is released, when the library is closed or
//when the function is called again with a different size or when the conversion set is deleted.
//
//in:
// ph     -> Handle of the conversion set
// seed   -> initialisation value for random number generator
// size   -> size of table in bytes. Size should be at least 65536.
//           (internal build table has a size of 131072 Bytes)
//
//out:


DWORD GS_CONV_CEXP PCO_Calculate_GS(int width,int height,unsigned short *picin,unsigned short *picout);
//Calculate resulting image from a raw pco.edge GlobalShutter image, which does contain the packed 
//reset and data image.
//
//in:
// ph     -> Handle of the conversion set
// width  -> camera image width
// height -> camera image height
// picin  -> pointer of buffer, which contains the packed camera image
//           size of this buffer must be ((width*12)/16)*height*2*2 Bytes  
// picout -> pointer of buffer, which receives the calculated image
//           size of this buffer must be width*height*2 Bytes  
//
//out:
//*picout -> resulting image data


DWORD GS_CONV_CEXP PCO_Calculate_GS_TSB(int width,int height,unsigned short *picin,unsigned short *picout);
//Calculate resulting image from a raw pco.edge GlobalShutter image, which does contain the packed 
//reset and data image.
//For images from a camera, which has the binary timestamp enabled
//
//in:
// ph     -> Handle of the conversion set
// width  -> camera image width
// height -> camera image height
// picin  -> pointer of buffer, which contains the packed camera image
//           size of this buffer must be ((width*12)/16)*height*2*2 Bytes  
// picout -> pointer of buffer, which receives the calculated image
//           size of this buffer must be width*height*2 Bytes  
//
//out:
//*picout -> resulting image data


DWORD GS_CONV_CEXP PCO_Calculate_GS_TSA(int width,int height,unsigned short *picin,unsigned short *picout);
//Calculate resulting image from a raw pco.edge GlobalShutter image, which does contain the packed 
//reset and data image.
//For images from a camera, which has the ASCII timestamp enabled
//
//in:
// ph     -> Handle of the conversion set
// width  -> camera image width
// height -> camera image height
// picin  -> pointer of buffer, which contains the packed camera image
//           size of this buffer must be ((width*12)/16)*height*2*2 Bytes  
// picout -> pointer of buffer, which receives the calculated image
//           size of this buffer must be width*height*2 Bytes  
//
//out:
//*picout -> resulting image data

DWORD GS_CONV_CEXP PCO_Calculate_GS_TSBA(int width,int height,unsigned short *picin,unsigned short *picout);
//Calculate resulting image from a raw pco.edge GlobalShutter image, which does contain the packed 
//reset and data image.
//For images from a camera, which has the binary and ASCII timestamp enabled
//
//in:
// ph     -> Handle of the conversion set
// width  -> camera image width
// height -> camera image height
// picin  -> pointer of buffer, which contains the packed camera image
//           size of this buffer must be ((width*12)/16)*height*2*2 Bytes  
// picout -> pointer of buffer, which receives the calculated image
//           size of this buffer must be width*height*2 Bytes  
//
//out:
//*picout -> resulting image data


DWORD GS_CONV_CEXP PCO_Calculate_GS_Bottom(int width,int height,unsigned short *picin,unsigned short *picout);
//Calculate resulting image bottom half from a raw pco.edge GlobalShutter image, which does contain the packed 
//reset and data image.
//For images from a camera, which has the binary and ASCII timestamp enabled
//
//in:
// ph     -> Handle of the conversion set
// width  -> camera image width
// height -> camera image height
// picin  -> pointer of buffer, which contains the packed camera image
//           size of this buffer must be ((width*12)/16)*height*2*2 Bytes  
// picout -> pointer of buffer, which receives the calculated image
//           size of this buffer must be width*height*2 Bytes  
//
//out:
//*picout -> resulting image data



DWORD GS_CONV_CEXP PCO_Calculate_GS_Top(int width,int height,unsigned short *picin,unsigned short *picout);
//Calculate resulting image top half from a raw pco.edge GlobalShutter image, which does contain the packed 
//reset and data image.
//
//in:
// ph     -> Handle of the conversion set
// width  -> camera image width
// height -> camera image height
// picin  -> pointer of buffer, which contains the packed camera image
//           size of this buffer must be ((width*12)/16)*height*2*2 Bytes  
// picout -> pointer of buffer, which receives the calculated image
//           size of this buffer must be width*height*2 Bytes  
//
//out:
//*picout -> resulting image data


DWORD GS_CONV_CEXP PCO_Calculate_GS_TSB_Top(int width,int height,unsigned short *picin,unsigned short *picout);
//Calculate resulting image top half from a raw pco.edge GlobalShutter image, which does contain the packed 
//reset and data image.
//For images from a camera, which has the binary timestamp enabled
//
//in:
// ph     -> Handle of the conversion set
// width  -> camera image width
// height -> camera image height
// picin  -> pointer of buffer, which contains the packed camera image
//           size of this buffer must be ((width*12)/16)*height*2*2 Bytes  
// picout -> pointer of buffer, which receives the calculated image
//           size of this buffer must be width*height*2 Bytes  
//
//out:
//*picout -> resulting image data


DWORD GS_CONV_CEXP PCO_Calculate_GS_TSA_Top(int width,int height,unsigned short *picin,unsigned short *picout);
//Calculate resulting image top half from a raw pco.edge GlobalShutter image, which does contain the packed 
//reset and data image.
//For images from a camera, which has the ASCII timestamp enabled
//
//in:
// ph     -> Handle of the conversion set
// width  -> camera image width
// height -> camera image height
// picin  -> pointer of buffer, which contains the packed camera image
//           size of this buffer must be ((width*12)/16)*height*2*2 Bytes  
// picout -> pointer of buffer, which receives the calculated image
//           size of this buffer must be width*height*2 Bytes  
//
//out:
//*picout -> resulting image data

DWORD GS_CONV_CEXP PCO_Calculate_GS_TSBA_Top(int width,int height,unsigned short *picin,unsigned short *picout);
//Calculate resulting image top half from a raw pco.edge GlobalShutter image, which does contain the packed 
//reset and data image.
//For images from a camera, which has the binary and ASCII timestamp enabled
//
//in:
// ph     -> Handle of the conversion set
// width  -> camera image width
// height -> camera image height
// picin  -> pointer of buffer, which contains the packed camera image
//           size of this buffer must be ((width*12)/16)*height*2*2 Bytes  
// picout -> pointer of buffer, which receives the calculated image
//           size of this buffer must be width*height*2 Bytes  
//
//out:
//*picout -> resulting image data



#ifdef __cplusplus
}       //  Assume C declarations for C++
#endif  //C++
