//
//  GUIStyle.h
//  Seeds
//
//  Created by Patrick Deng on 13-5-2.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SEGUE_ID_SPLASH2NAVIGATION @"splash2navigation"
#define SEGUE_ID_HOME2SEEDLIST @"home2seedlist"
#define SEGUE_ID_HOME2HELP @"home2help"
#define SEGUE_ID_HOME2FAVORITESEEDLIST @"home2favoriteseedlist"
#define SEGUE_ID_SEEDLIST2SEEDDETAIL @"seedlist2seeddetail"
#define SEGUE_ID_SEEDDETAIL2SEEDPICTURE @"seeddetail2seedpicture"
#define SEGUE_ID_FAVORITESEEDLIST2SEEDDETAIL @"favoriteseedlist2seeddetail"

#define UI_RENDER_SEEDLISTTABLECELL 1
#define CELL_ID_SEEDLISTTABLECELL @"SeedListTableCell"
#define CELL_HEIGHT_SEEDLISTTABLECELL 100

#define CELL_ID_SEEDPICTURECOLLECTIONCELL @"SeedPictureCollectionCell"

#define COLOR_CIRCULAR_PROGRESS_BACKGROUND [UIColor colorWithRed:236.0/255.0 green:236.0/255.0 blue:236.0/255.0 alpha:1.0]
#define COLOR_CIRCULAR_PROGRESS [UIColor colorWithRed:82.0/255.0 green:135.0/255.0 blue:237.0/255.0 alpha:1.0]

@interface GUIStyle : NSObject

@end
