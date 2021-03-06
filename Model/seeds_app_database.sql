Pragma foreign_keys=false;
Begin Transaction;
Drop Table If Exists [Seed];
CREATE TABLE IF NOT EXISTS  "Seed"(
[memo] varchar(256)
,[favorite] bit(1) NOT NULL DEFAULT 0
,[type] varchar(64) NOT NULL ON CONFLICT Fail
,[publishDate] datetime NOT NULL ON CONFLICT Fail
,[torrentLink] varchar(256) NOT NULL ON CONFLICT Fail
,[mosaic] bit(1) NOT NULL DEFAULT 0
,[hash] varchar(64) NOT NULL ON CONFLICT Fail
,[format] varchar(64) NOT NULL ON CONFLICT Fail
,[size] varchar(64) NOT NULL ON CONFLICT Fail
,[name] varchar(256) NOT NULL ON CONFLICT Fail
,[seedId] bigint UNIQUE NOT NULL ON CONFLICT Fail
, Primary Key(seedId) ON CONFLICT Fail   
);
Drop Table If Exists [SeedPicture];
CREATE TABLE IF NOT EXISTS  [SeedPicture](
[memo] varchar(256)
,[seedId] bigint NOT NULL ON CONFLICT Fail REFERENCES [Seed] ([seedId]) On Delete CASCADE On Update CASCADE
,[pictureLink] varchar(256) NOT NULL ON CONFLICT Fail
,[pictureId] int NOT NULL ON CONFLICT Fail
, Primary Key(pictureId) ON CONFLICT Fail   
);
Commit Transaction;
Pragma foreign_keys=true;
