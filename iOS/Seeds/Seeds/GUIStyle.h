//
//  GUIStyle.h
//  Seeds
//
//  Created by Patrick Deng on 13-5-2.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FlatUIKit.h"

#define COLOR_CIRCULAR_PROGRESS_BACKGROUND [UIColor colorWithRed:236.0/255.0 green:236.0/255.0 blue:236.0/255.0 alpha:1.0]
#define COLOR_CIRCULAR_PROGRESS [UIColor colorWithRed:82.0/255.0 green:135.0/255.0 blue:237.0/255.0 alpha:1.0]

#define COLOR_TEXT_INFO [UIColor colorWithRed:0.196078 green:0.309804 blue:0.521569 alpha:1.0]
#define COLOR_TEXT_LOG [UIColor blueColor]
#define COLOR_TEXT_WARNING [UIColor redColor]

#define COLOR_IMAGEVIEW_BACKGROUND [UIColor colorWithRed:0.752941 green:0.752941 blue:0.752941 alpha:0.5]

#define COLOR_BACKGROUND [UIColor whiteColor]

// UI Style Definitions based on FlatUIKit

#define COLOR_STEELBLUE [UIColor colorFromHexCode:@"4682B4"]
#define COLOR_GREY31 [UIColor colorFromHexCode:@"4F4F4F"]
#define COLOR_GAINSBORO [UIColor colorFromHexCode:@"DCDCDC"]
#define COLOR_SILVER [UIColor silverColor]
#define COLOR_MIDNIGHTBLUE [UIColor midnightBlueColor]
#define COLOR_WHITE [UIColor whiteColor]

#define FLATUI_COLOR_VIEW_BACKGROUND COLOR_GAINSBORO
#define FLATUI_COLOR_PROGRESS COLOR_STEELBLUE
#define FLATUI_COLOR_PROGRESS_TRACK COLOR_SILVER

#define FLATUI_COLOR_TABLECELL COLOR_GAINSBORO
#define FLATUI_COLOR_TABLECELL_SELECTED COLOR_SILVER
#define FLATUI_COLOR_TABLE_SEPERATOR COLOR_SILVER

#define FLATUI_COLOR_BUTTON COLOR_MIDNIGHTBLUE
#define FLATUI_COLOR_BUTTON_SHADOW COLOR_STEELBLUE
#define FLATUI_COLOR_BUTTON_TEXT COLOR_WHITE
#define FLATUI_COLOR_BUTTON_TEXT_HIGHLIGHTED COLOR_GREY31
#define FLATUI_COLOR_BUTTON_TEXT_DISABLED COLOR_GREY31

#define FLATUI_COLOR_NAVIGATIONBAR COLOR_STEELBLUE
#define FLATUI_COLOR_TOOLBAR COLOR_STEELBLUE

#define FLATUI_COLOR_LABEL COLOR_STEELBLUE
#define FLATUI_COLOR_LABEL_SHADOW COLOR_MIDNIGHTBLUE

#define FLATUI_COLOR_BARBUTTONITEM COLOR_MIDNIGHTBLUE
#define FLATUI_COLOR_BARBUTTONITEM_HIGHLIGHTED COLOR_GREY31

#define FLATUI_CORNER_RADIUS 3

@interface GUIStyle : NSObject

+(void) formatUIImageView:(UIImageView*) imageView;

// FlatUI Componenents Formatters
+(void) formatFlatUIButton:(FUIButton*) button buttonColor:(UIColor*) buttonColor shadowColor:(UIColor*) shadowColor shadowHeight:(CGFloat) shadowHeight cornerRadius:(CGFloat) cornerRadius titleColor:(UIColor*) titleColor highlightedTitleColor:(UIColor*) highlightedTitleColor;
+(void) formatFlatUILabel:(UILabel*) label;
+(void) formatFlatUIProgressView:(UIProgressView*) progress;
+(void) formatFlatUINavigationBar:(UINavigationBar*) navigationBar;
+(void) formatFlatUIBarButtonItem:(UIBarButtonItem*) buttonItem;
+(void) formatFlatUIToolbar:(UIToolbar*) toolbar;
+(void) formatFlatUITableViewCell:(UITableViewCell*) cell backColor:(UIColor*) backColor selectedBackColor:(UIColor*) selectedBackColor;

@end
