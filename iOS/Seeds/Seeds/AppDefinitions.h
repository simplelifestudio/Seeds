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
#define APP_VERSION @"0.1"
#define NAMESPACE_APP @"com.simplelife.seeds.ios"
#define MODULE_DELAY usleep(300000);

// Module: UserDefaults
#define USERDEFAULTS_KEY_SYNCSTATUSBYDAY @"syncStatusByDay:"
#define PERSISTENTDOMAIN_SYNCSTATUSBYDAY @"syncStatusByDay"

#define USERDEFAULTS_KEY_PASSCODESET @"passcodeSet"
#define USERDEFAULTS_KEY_PASSCODE @"passcode"
#define PERSISTENTDOMAIN_PASSCODE @"passcode"
#define PASSCODE_ATTEMPT_TIMES 3

#define USERDEFAULTS_KEY_3GDOWNLOADIMAGES @"downloadImagesThrough3G"
#define USERDEFAULTS_KEY_CARTID @"cartId"
#define PERSISTENTDOMAIN_NETWORK @"network"

#define USERDEFAULTS_KEY_SERVERMODE @"serverMode"
#define USERDEFAULTS_KEY_APPLAUNCHEDBEFORE @"appLaunchedBefore"
#define USERDEFAULTS_KEY_LASTTHREEDAYS @"lastThreeDays"
#define PERSISTENTDOMAIN_APP @"application"

#define USERDEFAULTS_KEY_THUMBNAILCACHEKEYS @"thumbnailCacheKeys"
#define PERSISTENTDOMAIN_IMAGECACHE @"imageCache"

// Module: Communication
#define RACHABILITY_HOST @"www.apple.com"

#define JSONMESSAGE_KEY_ID @"id"
#define JSONMESSAGE_KEY_BODY @"body"
#define JSONMESSAGE_KEY_DATELIST @"dateList"
#define JSONMESSAGE_KEY_CONTENT @"content"
#define JSONMESSAGE_KEY_SEEDIDLIST @"seedIdList"
#define JSONMESSAGE_KEY_CARTID @"cartId"
#define JSONMESSAGE_KEY_PICLINKS @"picLinks"
#define JSONMESSAGE_KEY_NAME @"name"
#define JSONMESSAGE_KEY_SIZE @"size"
#define JSONMESSAGE_KEY_MOSAIC @"mosaic"
#define JSONMESSAGE_KEY_FORMAT @"format"
#define JSONMESSAGE_KEY_SEEDID @"seedId"
#define JSONMESSAGE_KEY_TYPE @"type"
#define JSONMESSAGE_KEY_SOURCE @"source"
#define JSONMESSAGE_KEY_TORRENTLINK @"torrentLink"
#define JSONMESSAGE_KEY_HASH @"hash"
#define JSONMESSAGE_KEY_PUBLISHDATE @"publishDate"
#define JSONMESSAGE_KEY_MEMO @"memo"
#define JSONMESSAGE_KEY_SUCCESSSEEDIDLIST @"successSeedIdList"
#define JSONMESSAGE_KEY_FAILEDSEEDIDLIST @"failedSeedIdList"
#define JSONMESSAGE_KEY_EXISTSEEDIDLIST @"existSeedIdList"

#define SEEDS_SYNCSTATUS_NOUPDATE @"NO_UPDATE"
#define SEEDS_SYNCSTATUS_NOTREADY @"NOT_UPDATE"
#define SEEDS_SYNCSTATUS_READY @"READY"

#define JSONMESSAGE_COMMAND_ERRORRESPONSE @"ErrorResponse"
#define JSONMESSAGE_COMMAND_ALOHAREQUEST @"AlohaRequest"
#define JSONMESSAGE_COMMAND_ALOHARESPONSE @"AlohaResponse"
#define JSONMESSAGE_COMMAND_SEEDSUPDATESTATUSBYDATESREQUEST @"SeedsUpdateStatusByDatesRequest"
#define JSONMESSAGE_COMMAND_SEEDSUPDATESTATUSBYDATESRESPONSE @"SeedsUpdateStatusByDatesResponse"
#define JSONMESSAGE_COMMAND_SEEDSBYDATESREQUEST @"SeedsByDatesRequest"
#define JSONMESSAGE_COMMAND_SEEDSBYDATESRESPONSE @"SeedsByDatesResponse"
#define JSONMESSAGE_COMMAND_SEEDSTOCARTREQUEST @"SeedsToCartRequest"
#define JSONMESSAGE_COMMAND_SEEDSTOCARTRESPONSE @"SeedsToCartResponse"
#define JSONMESSAGE_COMMAND_EXTERNALSEEDSTOCARTREQUEST @"ExternalSeedsToCartRequest"
#define JSONMESSAGE_COMMAND_EXTERNALSEEDSTOCARTRESPONSE @"ExternalSeedsToCartResponse"

#define BASEURL_SEEDSSERVER @"http://106.187.38.78:80"
#define REMOTEPATH_SEEDSERVICE @"/seeds/seedService"
#define REMOTEPATH_CARTSERVICE @"/seeds/cartService"

#define BASEURL_TORRENTSTORE @"www.maxp2p.com"
#define BASEURL_TORRENT @"http://www.maxp2p.com/"
#define BASEURL_TORRENTCODE @"http://www.maxp2p.com/link.php?ref="
#define FORM_ATTRKEY_REF @"ref"
#define URL_LOADPAGE @"load.php"
#define URL_INDEXPAGE @"index.html"
#define HTTP_HEADER_ACCEPT @"Accept"
#define HTTP_HEADER_FORMDATA @"multipart/form-data"

#define FOLDER_TORRENTS @"torrents"
#define FOLDER_FAVORITES @"favorites"
#define FILE_EXTENDNAME_DOT_TORRENT @".torrent"
#define FILE_EXTENDNAME_TORRENT @"torrent"

#define SEEDPICTURE_MAX_CONCURRENT_DOWNLOADS 40
#define SEEDPICTURE_PREFETCHER_MAX_CONCURRENT_DOWNLOADS 20

#define CACHE_EXPIRE_PERIOD 60*60*24*7

#define CACHEKEY_SUFFIX_THUMBNAIL_SEEDLISTTABLECELL @"seeds.thumbnails.seedlisttablecell"
#define CACHEKEY_SUFFIX_THUMBNAIL_SEEDPICTURECOLLECTIONCELL @"Seeds.thumbnails.seedpicturecollectioncell"
#define CACHEKEY_SUFFIX_THUMBNAIL_SEEDPICTUREVIEW @"seeds.thumbnails.seedpictureview"


// Module: Spider
#define SEEDS_RESOURCE_IP @"174.123.15.31"
#define LINK_SEEDLIST_CHANNEL_PAGE @"&page="
#define LINK_SEEDLIST_CHANNEL @"http://"SEEDS_RESOURCE_IP"/forumdisplay.php?fid=55"
#define LINK_SEEDLIST @"http://"SEEDS_RESOURCE_IP"/viewthread.php?tid=931724&extra=page%3D1"

#define SEEDLIST_LINK_PAGENUM_START 1
#define SEEDLIST_LINK_PAGENUM_END 3

#define DATE_HOLDER @"$DATE$"
#define SEEDLIST_LINK_TITLE @"["DATE_HOLDER"]BT合集"


// Module: Database
typedef enum {TheDayBefore = 0, Yesterday = 1, Today = 2} DayIndex;

#define DATABASE_FILE_NAME @"Seeds_App_Database"
#define DATABASE_FILE_TYPE @"db"
#define DATABASE_FILE_FULL_NAME @"Seeds_App_Database.db"

#define TABLE_SEED @"seed"
#define TABLE_SEED_COLUMN_LOCALID @"localId"
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
#define TABLE_SEEDPICTURE_COLUMN_SEEDLOCALID @"seedLocalId"
#define TABLE_SEEDPICTURE_COLUMN_SEEDID @"seedId"
#define TABLE_SEEDPICTURE_COLUMN_PICTURELINK @"pictureLink"
#define TABLE_SEEDPICTURE_COLUMN_MEMO @"memo"

#define SQL_FOREIGN_KEY_ENABLE @"PRAGMA foreign_keys=1"

#define SEED_TYPE_AV @"AV"
#define SEED_SOURCE_MM @"咪咪爱"

// Module: Transmission
#define HTTP_SERVER_NAME @"Seeds Http Server"
#define HTTP_SERVER_PORT 8964

#define FILE_EXTENDNAME_ZIP @"zip"
#define FILE_EXTENDNAME_DOT_ZIP @".zip"
#define FILE_EXTENDNAME_HTML @"html"
#define FILE_EXTENDNAME_DOT_HTML @".html"
#define FILE_NAME_INDEX @"index"

//#define FILE_PREFIXNAME_SEED @"seed_"

#define CONSOLE_LINEINFO_DISPLAY_DELAY usleep(0);

// Module: GUI
#define STORYBOARD_IPHONE @"MainStoryboard_iPhone"
#define STORYBOARD_IPAD @"MainStoryboard_iPad"

#define STORYBOARD_ID_SPLASHVIEWCONTROLLER @"sbid_splashviewcontroller"
#define STORYBOARD_ID_NAVIGATIONCONTROLLER @"sbid_navigationcontroller"
#define STORYBOARD_ID_HOMEVIEWCONTROLLER @"sbid_homeviewcontroller"
#define STORYBOARD_ID_CONFIGVIEWCONTROLLER @"sbid_configviewcontroller"
#define STORYBOARD_ID_HELPVIEWCONTROLLER @"sbid_helpviewcontroller"
#define STORYBOARD_ID_SEEDLISTVIEWCONTROLLER @"sbid_seedlistviewcontroller"
#define STORYBOARD_ID_SEEDDETAILVIEWCONTROLLER @"sbid_seeddetailviewcontroller"
#define STORYBOARD_ID_SEEDPICTUREVIEWCONTROLLER @"sbid_seedpictureviewcontroller"
#define STORYBOARD_ID_TRANSMISSIONVIEWCONTROLLER @"sbid_transmissionviewcontroller"
#define STORYBOARD_ID_FAVORITESEEDLISTVIEWCONTROLLER @"sbid_favoriteseedlistviewcontroller"
#define STORYBOARD_ID_DOWNLOADSEEDLISTVIEWCONTROLLER @"sbid_downloadseedlistviewcontroller"
#define STORYBOARD_ID_WARNINGVIEWCONTROLLER @"sbid_warningviewcontroller"
#define STORYBOARD_ID_CARTIDVIEWCONTROLLER @"sbid_cartidviewcontroller"

#define SEGUE_ID_SPLASH2NAVIGATION @"splash2navigation"
#define SEGUE_ID_HOME2SEEDLIST @"home2seedlist"
#define SEGUE_ID_HOME2HELP @"home2help"
#define SEGUE_ID_HOME2CONFIG @"home2config"
#define SEGUE_ID_HOME2TRANSMIT @"home2transmit"
#define SEGUE_ID_HOME2FAVORITESEEDLIST @"home2favoriteseedlist"
#define SEGUE_ID_SEEDLIST2SEEDDETAIL @"seedlist2seeddetail"
#define SEGUE_ID_SEEDDETAIL2SEEDPICTURE @"seeddetail2seedpicture"
#define SEGUE_ID_FAVORITESEEDLIST2SEEDDETAIL @"favoriteseedlist2seeddetail"
#define SEGUE_ID_DOWNLOADSEEDLIST2SEEDDETAIL @"downloadseedlist2seeddetail"

#define UI_RENDER_SEEDLISTTABLECELL 1
#define CELL_ID_SEEDLISTTABLECELL @"SeedListTableCell"
#define CELL_ID_SEEDLISTTABLEACTIONCELL @"SeedListTableActionCell"

#define WIDTH_ASYNCIMAGEVIEW_IN_SEEDLISTTABLECELL 100
#define HEIGHT_ASYNCIMAGEVIEW_IN_SEEDLISTTABLECELL 60
#define WIDTH_ASYNCIMAGEVIEW_IN_SEEDPICTURECOLLECTIONCELL 150
#define HEIGHT_ASYNCIMAGEVIEW_IN_SEEDPICTURECOLLECTIONCELL 170

#define HEIGHT_NAVIGATION_BAR 44

#define PAGE_SIZE_SEEDLISTTABLE 7
#define PAGE_SIZE_SEEDDETAILCOLLECTION 4

#define CELL_ID_SEEDPICTURECOLLECTIONCELL @"SeedPictureCollectionCell"

#define VIEW_ID_SEEDDETAILHEADERVIEW @"SeedDetailHeaderView"

#define NIB_ID_PAGINGTOOLBAR @"PagingToolbar"

#define HUD_CENTER_SIZE CGSizeMake(135.f, 135.f)
#define HUD_NOTIFICATION_SIZE CGSizeMake(300, 40)
#define HUD_NOTIFICATION_YOFFSET 250

#define HUD_DISPLAY(x) usleep(x * 1000 * 1000);

#define kZoomStep 2

#define WARNING_DISPLAY_SECONDS 5

#define HELPSCREEN_DISPLAY_SECONDS 3

#define TABLEVIEW_LOAD_DISPLAY_SECONDS 0.3

#define CARTID_MAX_LENGTH 32

#define WARNING_ID_APPFIRSTLAUNCHED @"appFirstLaunched"
#define WARNING_ID_UNSUPPORTDEVICES @"unsupportDevices"
#define WARNING_ID_PASSCODEFAILEDATTEMPTS @"passcodeFailedAttempts"

#define RES_PNG_FILE @"png"
#define RES_NOIMAGE_TABLECELL @"noImage_tableCell"
#define RES_NOIMAGE_COLLECTIONCELL @"noImage_collectionCell"
#define RES_XIMAGE_TABLECELL @"xImage_tableCell"
#define RES_XIMAGE_COLLECTIONCELL @"xImage_collectionCell"
#define RES_XIMAGE_PICTUREVIEW @"xImage_pictureView"

#define THUMBNAIL_SIZE_SEEDLISTTABLECELL CGSizeMake(150, 90)
#define THUMBNAIL_SIZE_SEEDPICTURECOLLECTIONCELL CGSizeMake(225, 255)
#define THUMBNAIL_SIZE_SEEDPICTUREVIEW CGSizeMake(320, 480)

// Module: Notifications
#define NOTIFICATION_ID_SEEDPICTUREPREFETCH_FINISHED @"seedPicturePrefetchFinished"

#define NOTIFICATION_ID_SEEDDOWNLOADSTATUS_UPDATED @"seedDownloadStatusUpdated"
#define NOTIFICATION_ID_SEEDDOWNLOADSTATUS_UPDATED_KEY_SEED @"seed"
#define NOTIFICATION_ID_SEEDDOWNLOADSTATUS_UPDATED_KEY_STATUS @"status"

#endif
