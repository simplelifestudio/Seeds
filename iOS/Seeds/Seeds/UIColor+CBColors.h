//
//  UIColor+CBColors.h
//  Seeds
//
//  Created by Patrick Deng on 13-8-27.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

// RGB Color Table: http://www.5tu.cn/colors/rgb-peisebiao.html
@interface UIColor (CBColors)

+(UIColor*) colorWithHexCode:(NSString *)hexString;

+(UIColor*) Snow;           // Snow             250 250 250 #FFFAFA
+(UIColor*) GhostWhite;     // GhostWhite       248 248 255 #F8F8FF
+(UIColor*) WhiteSmoke;     // WhiteSmoke       245 245 245 #F5F5F5
+(UIColor*) Gainsboro;      // Gainsboro        220 220 220 #DCDCDC
+(UIColor*) FloralWhite;    // FloralWhite      255 250 240 #FFFAF0
+(UIColor*) OldLace;        // OldLace          253 245 230 #FDF5E6
+(UIColor*) Line;           // Linen            250 240 230 #FAF0E6
+(UIColor*) AntiqueWhite;   // AntiqueWhite     250 235 215	#FAEBD7
+(UIColor*) PapayaWhip;     // PapayaWhip       255 239 213 #FFEFD5
+(UIColor*) BlancedAlmond;  // BlanchedAlmond   255 235 205 #FFEBCD
+(UIColor*) Bisque;         // Bisque           255 228 196 #FFE4C4
+(UIColor*) PeachPuff;      // PeachPuff        255 218 185 #FFDAB9
+(UIColor*) NavajoWhite;    // NavajoWhite      255 222 173	#FFDEAD
+(UIColor*) Moccasin;       // Moccasin         255 228 181	#FFE4B5
+(UIColor*) Cornsilk;       // Cornsilk         255 248 220	#FFF8DC
+(UIColor*) Ivory;          // Ivory            255 255 240 #FFFFF0
+(UIColor*) LemonChiffon;   // LemonChiffon     255 250 205	#FFFACD
+(UIColor*) Seashell;       // Seashell         255 245 238	#FFF5EE
+(UIColor*) Honeydew;       // Honeydew         240 255 240	#F0FFF0
+(UIColor*) MintCream;      // MintCream        245 255 250 #F5FFFA
+(UIColor*) Azure;          // Azure            240 255 255 #F0FFFF
+(UIColor*) AliceBlue;      // AliceBlue        240 248 255	#F0F8FF
+(UIColor*) Lavender;       // Lavender         230 230 250	#E6E6FA
+(UIColor*) LavenderBlush;  // LavenderBlush	255 240 245	#FFF0F5
+(UIColor*) MistyRose;      // MistyRose        255 228 225	#FFE4E1
+(UIColor*) White;          // White            255 255 255	#FFFFFF
+(UIColor*) Black;          // Black            0   0   0	#000000
+(UIColor*) DarkSlateGray;  // DarkSlateGray	47  79  79	#2F4F4F
+(UIColor*) DimGrey;        // DimGrey          105 105 105	#696969
+(UIColor*) SlateGrey;      // SlateGrey        112 128 144	#708090
+(UIColor*) LightSlateGray; // LightSlateGray	119 136 153	#778899

/*

 */

@end
