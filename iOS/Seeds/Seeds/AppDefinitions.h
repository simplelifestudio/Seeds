//
//  AppDefinitions.h
//  Seeds
//
//  Created by Patrick Deng on 13-5-24.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#ifndef Seeds_AppDefinitions_h
#define Seeds_AppDefinitions_h

// App Global
#define NAMESPACE_APP @"com.simplelife.seeds.ios"
#define MODULE_DELAY usleep(300000);

// Module: UserDefaults
#define USERDEFAULTS_KEY_SYNCSTATUSBYDAY @"syncStatusByDay:"
#define PERSISTENTDOMAIN_SYNCSTATUSBYDAY @"syncStatusByDay"


// Module: Communication
#define RACHABILITY_HOST @"www.apple.com"

#define JSONMESSAGE_KEY_COMMAND @"command"
#define JSONMESSAGE_KEY_PARAMLIST @"paramList"
#define JSONMESSAGE_KEY_DATELIST @"datelist"

#define JSONMESSAGE_VAL_NOUPDATE @"NO_UPDATE";
#define JSONMESSAGE_VAL_NOTREADY @"NOT_UPDATE";
#define JSONMESSAGE_VAL_READY @"READY";

#define JSONMESSAGE_COMMAND_ALOHAREQUEST @"AlohaRequest"
#define JSONMESSAGE_COMMAND_ALOHARESPONSE @"AlohaResponse"
#define JSONMESSAGE_COMMAND_SEEDSUPDATESTATUSBYDATESREQUEST @"SeedsUpdateStatusByDatesRequest"
#define JSONMESSAGE_COMMAND_SEEDSUPDATESTATUSBYDATESRESPONSE @"SeedsUpdateStatusByDatesResponse"
#define JSONMESSAGE_COMMAND_SEEDSBYDATESREQUEST @"SeedsByDatesRequest"
#define JSONMESSAGE_COMMAND_SEEDSBYDATESRESPONSE @"SeedsByDatesResponse"

#define BASEURL_SEEDSSERVER @"http://106.187.38.52"
#define PATH_MESSAGELISTENER @"/seeds/messageListener"

#define BASEURL_TORRENT @"http://www.maxp2p.com/"
#define BASEURL_TORRENTCODE @"http://www.maxp2p.com/link.php?ref="
#define FORM_ATTRKEY_REF @"ref"

#define FOLDER_TORRENTS @"torrents"
#define FILE_EXTENDNAME_DOT_TORRENT @".torrent"

#define SEEDPICTURE_MAX_CONCURRENT_DOWNLOADS 10

// Module: Spider
#define SEEDLIST_LINK_DATE_FORMAT @"M-dd"

#define SEEDS_RESOURCE_IP @"174.123.15.31"
#define LINK_SEEDLIST_CHANNEL_PAGE @"&page="
#define LINK_SEEDLIST_CHANNEL @"http://"SEEDS_RESOURCE_IP"/forumdisplay.php?fid=55"
#define LINK_SEEDLIST @"http://"SEEDS_RESOURCE_IP"/viewthread.php?tid=931724&extra=page%3D1"

#define SEEDLIST_LINK_PAGENUM_START 1
#define SEEDLIST_LINK_PAGENUM_END 10

#define DATE_HOLDER @"$DATE$"
#define SEEDLIST_LINK_TITLE @"["DATE_HOLDER"]BT合集"


// Module: Database
enum ServiceDay {TheDayBefore = 0, Yesterday = 1, Today = 2};

#define DATABASE_FILE_NAME @"Seeds_App_Database"
#define DATABASE_FILE_TYPE @"db"
#define DATABASE_FILE_FULL_NAME @"Seeds_App_Database.db"

#define TABLE_SEED @"seed"
#define TABLE_SEED_COLUMN_SEEDID @"seedId"
#define TABLE_SEED_COLUMN_TYPE @"type"
#define TABLE_SEED_COLUMN_SOURCE @"source"
#define TABLE_SEED_COLUMN_PUBLISHDATE @"publishDate"
#define TABLE_SEED_COLUMN_NAME @"name"
#define TABLE_SEED_COLUMN_SIZE @"size"
#define TABLE_SEED_COLUMN_FORMAT @"format"
#define TABLE_SEED_COLUMN_TORRENTLINK @"torrentLink"
#define TABLE_SEED_COLUMN_FAVORITE @"favorite"
#define TABLE_SEED_COLUMN_HASH @"hash"
#define TABLE_SEED_COLUMN_MOSAIC @"mosaic"
#define TABLE_SEED_COLUMN_MEMO @"memo"

#define TABLE_SEEDPICTURE @"seedpicture"
#define TABLE_SEEDPICTURE_COLUMN_PICTUREID @"pictureId"
#define TABLE_SEEDPICTURE_COLUMN_SEEDID @"seedId"
#define TABLE_SEEDPICTURE_COLUMN_PICTURELINK @"pictureLink"
#define TABLE_SEEDPICTURE_COLUMN_MEMO @"memo"

#define SQL_FOREIGN_KEY_ENABLE @"PRAGMA foreign_keys=1"

#define SEED_TYPE_AV @"AV"
#define SEED_SOURCE_MM @"咪咪爱"

// Module: Transmission
#define HTTP_SERVER_NAME @"Seeds Http Server"
#define HTTP_SERVER_PORT 8964

#define FILE_EXTENDNAME_DOT_ZIP @".zip"


// Module: GUI
#define SEGUE_ID_SPLASH2NAVIGATION @"splash2navigation"
#define SEGUE_ID_HOME2SEEDLIST @"home2seedlist"
#define SEGUE_ID_HOME2HELP @"home2help"
#define SEGUE_ID_HOME2CONFIG @"home2config"
#define SEGUE_ID_HOME2TRANSMIT @"home2transmit"
#define SEGUE_ID_HOME2FAVORITESEEDLIST @"home2favoriteseedlist"
#define SEGUE_ID_SEEDLIST2SEEDDETAIL @"seedlist2seeddetail"
#define SEGUE_ID_SEEDDETAIL2SEEDPICTURE @"seeddetail2seedpicture"
#define SEGUE_ID_FAVORITESEEDLIST2SEEDDETAIL @"favoriteseedlist2seeddetail"

#define UI_RENDER_SEEDLISTTABLECELL 1
#define CELL_ID_SEEDLISTTABLECELL @"SeedListTableCell"
#define CELL_HEIGHT_SEEDLISTTABLECELL 100
#define WIDTH_ASYNCIMAGEVIEW_IN_SEEDLISTTABLECELL 100
#define HEIGHT_ASYNCIMAGEVIEW_IN_SEEDLISTTABLECELL 100
#define WIDTH_ASYNCIMAGEVIEW_IN_SEEDPICTURECOLLECTIONCELL 150
#define HEIGHT_ASYNCIMAGEVIEW_IN_SEEDPICTURECOLLECTIONCELL 160

#define CELL_ID_SEEDPICTURECOLLECTIONCELL @"SeedPictureCollectionCell"

#define HUD_SIZE CGSizeMake(135.f, 135.f)
#define HUD_DISPLAY(x) sleep(x);

#define kZoomStep 2

#define RES_PNG_FILE @"png"
#define RES_NOIMAGE_TABLECELL @"noImage_tableCell"
#define RES_NOIMAGE_COLLECTIONCELL @"noImage_collectionCell"
#define RES_XIMAGE_TABLECELL @"xImage_tableCell"
#define RES_XIMAGE_COLLECTIONCELL @"xImage_collectionCell"
#define RES_XIMAGE_PICTUREVIEW @"xImage_pictureView"

#endif
