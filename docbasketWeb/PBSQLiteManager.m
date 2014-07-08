//
//  PBSQLiteManager.m
//  Pixbee
//
//  Created by jaecheol kim on 11/30/13.
//  Copyright (c) 2013 Pixbee. All rights reserved.
//

#import "PBSQLiteManager.h"
#import "SDImageCache.h"
#import "GlobalValue.h"
#import "Docbasket.h"

@interface PBSQLiteManager ()
{
	sqlite3 *db;
	NSString *databaseName;
}

- (id)initWithDatabaseNamed:(NSString *)name;
- (NSString *)getDatabasePath;
- (NSError *)createDBErrorWithDescription:(NSString*)description andCode:(int)code;
- (NSError *)openDatabase;
- (NSError *)closeDatabase;

@end



@implementation PBSQLiteManager

#pragma mark Init & Dealloc
+(PBSQLiteManager*)sharedInstance
{
    static PBSQLiteManager* sqlManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sqlManager = [[PBSQLiteManager alloc] initWithDatabaseNamed:@"Docbaskets.db"];
    });
    return sqlManager;
}


- (id)initWithDatabaseNamed:(NSString *)name
{
	self = [super init];
	if (self != nil) {
		databaseName = [[NSString alloc] initWithString:name];
		[self openDatabase];
	}
	return self;
}

#pragma mark SQLite Operations

- (void)initDataBase
{

    NSString *createDocbasketTable = @"CREATE TABLE IF NOT EXISTS 'Docbasket' ('id' VARCHAR PRIMARY KEY  NOT NULL  UNIQUE , 'title' VARCHAR, 'description' TEXT, 'latitude' DOUBLE, 'longitude' DOUBLE, 'permission' TEXT, 'is_public' BOOL, 'range' DOUBLE, 'user_id' VARCHAR, 'updated_at' DATETIME, 'begin_at' DATETIME, 'created_at' DATETIME, 'end_at' , 'poi_id' VARCHAR, 'poi_title' VARCHAR, 'telephone' VARCHAR, 'address' VARCHAR,  'timestamp' DATETIME DEFAULT CURRENT_TIMESTAMP);";

    NSString *createUsersTable = @"CREATE TABLE IF NOT EXISTS 'Users' ('UserID' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE , 'UserName' TEXT, 'GUID' TEXT, 'UserNick' TEXT, 'UserProfile' TEXT, 'fbID' TEXT, 'fbName' TEXT, 'fbProfile' TEXT, 'seq' INTEGER DEFAULT 0, 'color' INTEGER DEFAULT 0,  'timestamp' DATETIME DEFAULT CURRENT_TIMESTAMP);";
 
    NSArray *createTable =@[createDocbasketTable, createUsersTable];
    
    for(NSString *sqlQuery in createTable){
        NSError *error = [[PBSQLiteManager sharedInstance] doQuery:sqlQuery];
        if (error != nil) {
            NSLog(@"Error: %@",[error localizedDescription]);
        }
    }
    
}


- (void)syncDocBaskets2DB:(NSDictionary*)docbaskets completionHandler:(void (^)(BOOL success))block;
{
    if(!IsEmpty(docbaskets)){
        sqlite3_stmt *statement;
        sqlite3 *sqlDB = [SQLManager getDBContext];
        
        const char* insertSQL = "INSERT INTO Docbasket (id, title, description, latitude, longitude, permission, is_public, range, user_id, updated_at, begin_at, created_at, end_at, poi_id, poi_title, telephone, address ) VALUES (?, ?, ?, ? , ? , ?, ? , ? , ?, ? , ? , ? , ? , ? , ? , ? , ?)";
        
        for(NSDictionary *basket in docbaskets){
            //NSLog(@"basket = %@", basket);

            NSString *basketID =  (IsEmpty(basket[@"id"])?@"":basket[@"id"]);
            NSString *title =  (IsEmpty(basket[@"title"])?@"":basket[@"title"]);
            NSString *description =  (IsEmpty(basket[@"description"])?@"":basket[@"description"]);
            NSString *latitude = (IsEmpty(basket[@"latitude"])?@"":basket[@"latitude"]);
            NSString *longitude = (IsEmpty(basket[@"longitude"])?@"":basket[@"longitude"]);
            NSString *permission = (IsEmpty(basket[@"permission"])?@"":basket[@"permission"]);
            NSString *is_public = (IsEmpty(basket[@"is_public"])?@"":basket[@"is_public"]);
            NSString *range = (IsEmpty(basket[@"range"])?@"":basket[@"range"]);
            NSString *user_id = (IsEmpty(basket[@"user_id"])?@"":basket[@"user_id"]);
            NSString *updated_at = (IsEmpty(basket[@"updated_at"])?@"":basket[@"updated_at"]);
            NSString *begin_at = (IsEmpty(basket[@"begin_at"])?@"":basket[@"begin_at"]);
            NSString *created_at = (IsEmpty(basket[@"created_at"])?@"":basket[@"created_at"]);
            NSString *end_at = (IsEmpty(basket[@"end_at"])?@"":basket[@"end_at"]);
            NSString *poi_id = (IsEmpty(basket[@"poi_id"])?@"":basket[@"poi_id"]);
            NSString *poi_title = (IsEmpty(basket[@"poi_title"])?@"":basket[@"poi_title"]);
            NSString *telephone = (IsEmpty(basket[@"telephone"])?@"":basket[@"telephone"]);
            NSString *address = (IsEmpty(basket[@"address"])?@"":basket[@"address"]);
            
            if (sqlite3_prepare_v2(sqlDB, insertSQL, -1, &statement, nil) == SQLITE_OK)
            {
                sqlite3_bind_text(statement, 1, [basketID UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(statement, 2, [title UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(statement, 3, [description UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_double(statement, 4, [latitude doubleValue]);
                sqlite3_bind_double(statement, 5, [longitude doubleValue]);
                sqlite3_bind_text(statement, 6, [permission UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_int(statement, 7, [is_public intValue]);
                sqlite3_bind_double(statement, 8, [range doubleValue]);
                sqlite3_bind_text(statement, 9, [user_id UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(statement, 10, [updated_at UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(statement, 11, [begin_at UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(statement, 12, [created_at UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(statement, 13, [end_at UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(statement, 14, [poi_id UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(statement, 15, [poi_title UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(statement, 16, [telephone UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(statement, 17, [address UTF8String], -1, SQLITE_TRANSIENT);

                sqlite3_step(statement);
                sqlite3_finalize(statement);
            }
            
        }
        
        NSArray *baskets = [SQLManager getDocBasketsForQuery:@"SELECT * FROM Docbasket;"];
        if(!IsEmpty(baskets)){
            [GVALUE setBaskets:baskets];
        }
        
        block(YES);
        
//        NSString *query = @"SELECT * FROM Docbasket;";
//        NSArray *result = [SQLManager getRowsForQuery:query];
//        if(!IsEmpty(result))
//        {
//            NSLog(@"%@ = %@",query, result);
//        }
    } else {
        block(NO);
    }
}


- (NSArray*)getDocBasketsForQuery:(NSString *)sql {
	
	NSMutableArray *resultsArray = [[NSMutableArray alloc] initWithCapacity:1];
	
	if (db == nil) {
		[self openDatabase];
	}
	
	sqlite3_stmt *statement;
	const char *query = [sql UTF8String];
	int returnCode = sqlite3_prepare_v2(db, query, -1, &statement, NULL);
	
	if (returnCode == SQLITE_ERROR) {
		const char *errorMsg = sqlite3_errmsg(db);
		NSError *errorQuery = [self createDBErrorWithDescription:[NSString stringWithCString:errorMsg encoding:NSUTF8StringEncoding]
                                                         andCode:kDBErrorQuery];
		NSLog(@"%@", errorQuery);
	}
	
	while (sqlite3_step(statement) == SQLITE_ROW) {
		int columns = sqlite3_column_count(statement);
		NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:columns];
        
		for (int i = 0; i<columns; i++) {
			const char *name = sqlite3_column_name(statement, i);
            
			NSString *columnName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
			
			int type = sqlite3_column_type(statement, i);
			
			switch (type) {
				case SQLITE_INTEGER:
				{
					int value = sqlite3_column_int(statement, i);
					[result setObject:[NSNumber numberWithInt:value] forKey:columnName];
					break;
				}
				case SQLITE_FLOAT:
				{
					float value = sqlite3_column_double(statement, i);
					[result setObject:[NSNumber numberWithFloat:value] forKey:columnName];
					break;
				}
				case SQLITE_TEXT:
				{
					const char *value = (const char*)sqlite3_column_text(statement, i);
					[result setObject:[NSString stringWithCString:value encoding:NSUTF8StringEncoding] forKey:columnName];
					break;
				}
                    
				case SQLITE_BLOB:
					break;
				case SQLITE_NULL:
					[result setObject:[NSNull null] forKey:columnName];
					break;
                    
				default:
				{
					const char *value = (const char *)sqlite3_column_text(statement, i);
					[result setObject:[NSString stringWithCString:value encoding:NSUTF8StringEncoding] forKey:columnName];
					break;
				}
                    
			} //end switch
			
			
		} //end for
		
        Docbasket *basket = [[Docbasket alloc] initWithAttributes:result];
        
		[resultsArray addObject:basket];
		
	} //end while
	sqlite3_finalize(statement);
	
    //	[self closeDatabase];
	
	// autorelease resultsArray to prevent memory leaks
	return resultsArray;
	
}



- (NSArray*)getAllBaskets
{
    NSString *query = @"SELECT * FROM Docbasket;";
    NSArray *result = [SQLManager getRowsForQuery:query];
    return result;
}



- (NSError*)openDatabase {
	
	NSError *error = nil;
	
	NSString *databasePath = [self getDatabasePath];
    
	const char *dbpath = [databasePath UTF8String];
	int result = sqlite3_open(dbpath, &db);
	if (result != SQLITE_OK) {
        const char *errorMsg = sqlite3_errmsg(db);
        NSString *errorStr = [NSString stringWithFormat:@"The database could not be opened: %@",[NSString stringWithCString:errorMsg encoding:NSUTF8StringEncoding]];
        error = [self createDBErrorWithDescription:errorStr	andCode:kDBFailAtOpen];
	}
	
	return error;
}

- (NSError *) closeDatabase {
	
	NSError *error = nil;
	
	
	if (db != nil) {
		if (sqlite3_close(db) != SQLITE_OK){
			const char *errorMsg = sqlite3_errmsg(db);
			NSString *errorStr = [NSString stringWithFormat:@"The database could not be closed: %@",[NSString stringWithCString:errorMsg encoding:NSUTF8StringEncoding]];
			error = [self createDBErrorWithDescription:errorStr andCode:kDBFailAtClose];
		}
		
		db = nil;
	}
	
	return error;
}

- (sqlite3 *)getDBContext
{
    NSError *openError = nil;
    if (db == nil) {
		openError = [self openDatabase];
	}
    
    return db;
}

- (NSError*)doQuery:(NSString *)sql {
	
	NSError *openError = nil;
	NSError *errorQuery = nil;
	
	//Check if database is open and ready.
	if (db == nil) {
		openError = [self openDatabase];
	}
	
	if (openError == nil) {
		sqlite3_stmt *statement;
		const char *query = [sql UTF8String];
		sqlite3_prepare_v2(db, query, -1, &statement, NULL);
		
		if (sqlite3_step(statement) == SQLITE_ERROR) {
			const char *errorMsg = sqlite3_errmsg(db);
			errorQuery = [self createDBErrorWithDescription:[NSString stringWithCString:errorMsg encoding:NSUTF8StringEncoding]
													andCode:kDBErrorQuery];
		}
		sqlite3_finalize(statement);
//		errorQuery = [self closeDatabase];
	}
	else {
		errorQuery = openError;
	}
    
	return errorQuery;
}

/**
 * Does an SQL UPDATE query.
 *
 * You should use this method for ONLY UPDATE statements.
 *
 * @param sql the sql statement using ? for params.
 *a
 * @param params NSArray of params type (id), in CORRECT order please.
 *
 * @return nil if everything was ok, NSError in other case.
 UPDATE table_name
 SET column1=value1,column2=value2,...
 WHERE some_column=some_value;
 */

- (NSError*)doUpdateQuery:(NSString *)sql withParams:(NSArray *)params {
	
	NSError *openError = nil;
	NSError *errorQuery = nil;
	
	//Check if database is open and ready.
	if (db == nil) {
		openError = [self openDatabase];
	}
	
	if (openError == nil) {
		sqlite3_stmt *statement;
		const char *query = [sql UTF8String];
		sqlite3_prepare_v2(db, query, -1, &statement, NULL);
        
        //BIND the params!
        int count =0;
        for (id param in params ) {
            count++;
            if ([param isKindOfClass:[NSString class]] )
                sqlite3_bind_text(statement, count, [param UTF8String], -1, SQLITE_TRANSIENT);
            if ([param isKindOfClass:[NSNumber class]] ) {
                if (!strcmp([param objCType], "f"))
                    sqlite3_bind_double(statement, count, [param doubleValue]);
                else if (!strcmp([param objCType], "i"))
                    sqlite3_bind_int(statement, count, [param intValue]);
                else
                    NSLog(@"unknown NSNumber");
            }
        }
		
		if (sqlite3_step(statement) == SQLITE_ERROR) {
			const char *errorMsg = sqlite3_errmsg(db);
			errorQuery = [self createDBErrorWithDescription:[NSString stringWithCString:errorMsg encoding:NSUTF8StringEncoding]
													andCode:kDBErrorQuery];
		}
		sqlite3_finalize(statement);
//		errorQuery = [self closeDatabase];
	}
	else {
		errorQuery = openError;
	}
    
	return errorQuery;
}

/**
 * Does a SELECT query and gets the info from the db.
 *
 * The return array contains an NSDictionary for row, made as: key=columName value= columnValue.
 *
 * For example, if we have a table named "users" containing:
 * name | pass
 * -------------
 * admin| 1234
 * pepe | 5678
 *
 * it will return an array with 2 objects:
 * resultingArray[0] = name=admin, pass=1234;
 * resultingArray[1] = name=pepe, pass=5678;
 *
 * So to get the admin password:
 * [[resultingArray objectAtIndex:0] objectForKey:@"pass"];
 *
 * @param sql the sql query (remember to use only a SELECT statement!).
 *
 * @return an array containing the rows fetched.
 */

- (NSArray*)getRowsForQuery:(NSString *)sql {
	
	NSMutableArray *resultsArray = [[NSMutableArray alloc] initWithCapacity:1];
	
	if (db == nil) {
		[self openDatabase];
	}
	
	sqlite3_stmt *statement;
	const char *query = [sql UTF8String];
	int returnCode = sqlite3_prepare_v2(db, query, -1, &statement, NULL);
	
	if (returnCode == SQLITE_ERROR) {
		const char *errorMsg = sqlite3_errmsg(db);
		NSError *errorQuery = [self createDBErrorWithDescription:[NSString stringWithCString:errorMsg encoding:NSUTF8StringEncoding]
                                                         andCode:kDBErrorQuery];
		NSLog(@"%@", errorQuery);
	}
	
	while (sqlite3_step(statement) == SQLITE_ROW) {
		int columns = sqlite3_column_count(statement);
		NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:columns];
        
		for (int i = 0; i<columns; i++) {
			const char *name = sqlite3_column_name(statement, i);
            
			NSString *columnName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
			
			int type = sqlite3_column_type(statement, i);
			
			switch (type) {
				case SQLITE_INTEGER:
				{
					int value = sqlite3_column_int(statement, i);
					[result setObject:[NSNumber numberWithInt:value] forKey:columnName];
					break;
				}
				case SQLITE_FLOAT:
				{
					float value = sqlite3_column_double(statement, i);
					[result setObject:[NSNumber numberWithFloat:value] forKey:columnName];
					break;
				}
				case SQLITE_TEXT:
				{
					const char *value = (const char*)sqlite3_column_text(statement, i);
					[result setObject:[NSString stringWithCString:value encoding:NSUTF8StringEncoding] forKey:columnName];
					break;
				}
                    
				case SQLITE_BLOB:
					break;
				case SQLITE_NULL:
					[result setObject:[NSNull null] forKey:columnName];
					break;
                    
				default:
				{
					const char *value = (const char *)sqlite3_column_text(statement, i);
					[result setObject:[NSString stringWithCString:value encoding:NSUTF8StringEncoding] forKey:columnName];
					break;
				}
                    
			} //end switch
			
			
		} //end for
		
		[resultsArray addObject:result];
		
	} //end while
	sqlite3_finalize(statement);
	
//	[self closeDatabase];
	
	// autorelease resultsArray to prevent memory leaks
	return resultsArray;
	
}


- (NSString *)getDatabasePath{
	
	if([[NSFileManager defaultManager] fileExistsAtPath:databaseName]){
		// Already Full Path
		return databaseName;
	} else {
        // Get the documents directory
        NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsDir = [dirPaths objectAtIndex:0];
        
        return [docsDir stringByAppendingPathComponent:databaseName];
	}
}

/**
 * Creates an NSError.
 *
 * @param description the description wich can be queried with [error localizedDescription];
 * @param code the error code (code erors are defined as enum in the header file).
 *
 * @return the NSError just created.
 *
 */

- (NSError *)createDBErrorWithDescription:(NSString*)description andCode:(int)code {
	
	NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:description, NSLocalizedDescriptionKey, nil];
	NSError *error = [NSError errorWithDomain:@"SQLite Error" code:code userInfo:userInfo];
	
	return error;
}


/**
 * Creates an SQL dump of the database.
 *
 * This method could get a csv format dump with a few changes.
 * But i prefer working with sql dumps ;)
 *
 * @return an NSString containing the dump.
 */

- (NSString *)getDatabaseDump {
	
	NSMutableString *dump = [[NSMutableString alloc] initWithCapacity:256];
	
	[dump appendString:[NSString stringWithFormat:@"; database %@;\n", [databaseName lastPathComponent]]];
	
	// first get all table information
	
	NSArray *rows = [self getRowsForQuery:@"SELECT * FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';"];
	// last sql query returns something like:
	// {
	// name = users;
	// rootpage = 2;
	// sql = "CREATE TABLE users (id integer primary key autoincrement, user text, password text)";
	// "tbl_name" = users;
	// type = table;
	// }
	
	//loop through all tables
	for (int i = 0; i<[rows count]; i++) {
		
		NSDictionary *obj = [rows objectAtIndex:i];
		//get sql "create table" sentence
		NSString *sql = [obj objectForKey:@"sql"];
		[dump appendString:[NSString stringWithFormat:@"%@;\n",sql]];
        
		//get table name
		NSString *tableName = [obj objectForKey:@"name"];
        
		//get all table content
		NSArray *tableContent = [self getRowsForQuery:[NSString stringWithFormat:@"SELECT * FROM %@",tableName]];
		
		for (int j = 0; j<[tableContent count]; j++) {
			NSDictionary *item = [tableContent objectAtIndex:j];
			
			//keys are column names
			NSArray *keys = [item allKeys];
			
			//values are column values
			NSArray *values = [item allValues];
			
			//start constructing insert statement for this item
			[dump appendString:[NSString stringWithFormat:@"insert into %@ (",tableName]];
			
			//loop through all keys (aka column names)
			NSEnumerator *enumerator = [keys objectEnumerator];
			id obj;
			while (obj = [enumerator nextObject]) {
				[dump appendString:[NSString stringWithFormat:@"%@,",obj]];
			}
			
			//delete last comma
			NSRange range;
			range.length = 1;
			range.location = [dump length]-1;
			[dump deleteCharactersInRange:range];
			[dump appendString:@") values ("];
			
			// loop through all values
			// value types could be:
			// NSNumber for integer and floats, NSNull for null or NSString for text.
			
			enumerator = [values objectEnumerator];
			while (obj = [enumerator nextObject]) {
				//if it's a number (integer or float)
				if ([obj isKindOfClass:[NSNumber class]]){
					[dump appendString:[NSString stringWithFormat:@"%@,",[obj stringValue]]];
				}
				//if it's a null
				else if ([obj isKindOfClass:[NSNull class]]){
					[dump appendString:@"null,"];
				}
				//else is a string ;)
				else{
					[dump appendString:[NSString stringWithFormat:@"'%@',",obj]];
				}
				
			}
			
			//delete last comma again
			range.length = 1;
			range.location = [dump length]-1;
			[dump deleteCharactersInRange:range];
			
			//finish our insert statement
			[dump appendString:@");\n"];
			
		}
		
	}
    
	return dump;
}


#warning TODO
// 1. Users : 새로운 사용자 추가하기 - Unknown
// 2. Users : Update

#pragma mark Users Table

////새로운 User 추가.
//- (NSArray *)newUser
//{
//    //int UserID = -1;
//    NSString *UserName = @"Unknown";
//    
//    NSString *query = @"SELECT * FROM Users WHERE UserName LIKE 'Unknown%';";
//    NSArray *result = [SQLManager getRowsForQuery:query];
//    NSLog(@"[Users] QUERY result = %@", result);
//    int seq = 0;
//    int color = 0; //default black   arc4random_uniform(10);
//    if(!IsEmpty(result))
//    {
//        seq = (int)[result count];
//        UserName = [NSString stringWithFormat:@"Unknown%d", seq];
//    }
//    //INSERT INTO Users (UserName, seq, color) VALUES ('unknown1',  5, 1);
//    //NSString *sqlStr = [NSString stringWithFormat:@"INSERT INTO Users (UserName) VALUES ('%@');", UserName];
//    NSString *sqlStr = [NSString stringWithFormat:@"INSERT INTO Users (UserName, seq, color) VALUES ('%@', %d, %d);", UserName, seq, color];
//    NSError *error = [SQLManager doQuery:sqlStr];
//    if (error != nil) {
//        NSLog(@"Error: %@",[error localizedDescription]);
//    }
//    
//    query = [NSString stringWithFormat:@"SELECT * FROM Users WHERE UserName = '%@';", UserName];
//    result = [SQLManager getRowsForQuery:query];
//    
//    NSLog(@"[Users] INSERT result = %@", result);
//    
//    return result;
//}
//
//// Parse의 facebook session 사용할 때.
//- (int)newUserWithPFUser:(NSDictionary*)profile
//{
//    int UserID = -1;
//    
//    if(IsEmpty(profile)) return UserID;
//    
//    NSString *UserName = profile[@"name"]; //user.name;
//    
//    NSString *query = [NSString stringWithFormat:@"SELECT UserID, UserName FROM Users WHERE UserName = '%@';", UserName];
//    NSArray *result = [SQLManager getRowsForQuery:query];
//    NSLog(@"[Users] QUERY result = %@", result);
//    if([result count] > 0 && result != nil)
//    {
//        UserID = [[[result objectAtIndex:0] objectForKey:@"UserID"] intValue];
//        return UserID;
//    }
//    
//    if(![result count]){
//        NSString *fbID = profile[@"facebookId"]; // user.id;
//        NSString *fbProfileURL = profile[@"pictureURL"]; //[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", user.id];
//        //NSString *fbBirthday = user.birthday;
//        NSString *fbNickName = profile[@"name"]; //user.username;
//        
//        NSString *sqlStr = [NSString stringWithFormat:
//                            @"INSERT INTO Users (UserName, UserNick, UserProfile, fbID, fbName, fbProfile ) VALUES ('%@', '%@', '%@', '%@', '%@', '%@');",
//                            UserName, fbNickName, fbProfileURL, fbID, fbNickName, fbProfileURL];
//        NSLog(@"inser qury :: user = %@", sqlStr);
//        NSError *error = [SQLManager doQuery:sqlStr];
//        if (error != nil) {
//            NSLog(@"Error: %@",[error localizedDescription]);
//        }
//    }
//    
//    result = [SQLManager getRowsForQuery:query];
//    NSLog(@"[Users] INSERT result = %@", result);
//    if([result count] > 0 && result != nil)
//    {
//        UserID = [[[result objectAtIndex:0] objectForKey:@"UserID"] intValue];
//    }
//    
//    return UserID;
//    
//}
//
//
//- (void)setUserProfileImage:(UIImage*)profileImage UserID:(int)UserID
//{
//    NSString *imagePath = [NSString stringWithFormat:@"profileImage_%d.png",UserID];
//
//    [[SDImageCache sharedImageCache] removeImageForKey:imagePath];
//    [[SDImageCache sharedImageCache] storeImage:profileImage forKey:imagePath toDisk:YES];
//    
//    NSArray *result = [SQLManager updateUser:@{ @"UserID" : @(UserID), @"UserProfile" :imagePath}];
//    if(!IsEmpty(result)){
//        NSLog(@"User Profile result = %@", result);
//    }
//
//}
//
//// 해당 User의 Profile 이미지 가져오기
//- (UIImage *)getUserProfileImage:(int)UserID
//{
//#warning 프로필 이미지 가져오기 추가 필요
//    NSArray *userInfo = [SQLManager getUserInfo:UserID];
//    NSString *UserProfile;
//    if(!IsEmpty(userInfo)){
//        UserProfile = userInfo[0][@"UserProfile"];
//    }
//    
//    NSString *imagePath = [NSString stringWithFormat:@"profileImage_%d.png",UserID];
//    UIImage *profileImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imagePath];
//    if(IsEmpty(profileImage)) {
//        profileImage = [UIImage imageNamed:@"ananymous.png"];
//        //profileImage = [UIImage maskImage:image withMask:[UIImage imageNamed:@"photo_profile_hive@2x.png"]];
//        //[[SDImageCache sharedImageCache] storeImage:profileImage forKey:imagePath toDisk:YES];
//    }
//    return profileImage;
//}
//
//#warning profile 수정하기 추가 필요
//
//// 해당 User ID 가져오기.
//- (int)getUserID:(NSString *)UserName
//{
//    int UserID = -1;
//    NSString *query = [NSString stringWithFormat:@"SELECT UserID, UserName FROM Users WHERE UserName = '%@';", UserName];
//    NSArray *result = [SQLManager getRowsForQuery:query];
//    if([result count] > 0 && result != nil)
//    {
//        UserID = [[[result objectAtIndex:0] objectForKey:@"UserID"] intValue];
//    }
//
//    return UserID;
//}
//
//// 해당 User Name 가져오기.
//- (NSString*)getUserName:(int)UserID
//{
//    NSString *UserName = @"";
//    NSString *query = [NSString stringWithFormat:@"SELECT UserID, UserName FROM Users WHERE UserID = %d;", UserID];
//    NSArray *result = [SQLManager getRowsForQuery:query];
//    if([result count] > 0 && result != nil)
//    {
//        UserName = [[result objectAtIndex:0] objectForKey:@"UserName"];
//    }
//    
//    return UserName;
//}
//
//// 해당 User 정보 가져오기.
//- (NSArray *)getUserInfo:(int)UserID
//{
//    //int UserID = [SQLManager getUserID:GlobalValue.userName];
////    NSString *query = [NSString stringWithFormat:@"SELECT UserID, UserName, GUID, UserNick, UserProfile, fbID, fbName, fbProfile, timestamp FROM Users WHERE UserID = %d;", UserID];
//    NSString *query = [NSString stringWithFormat:@"SELECT * FROM Users WHERE UserID = %d;", UserID];
//    NSArray *result = [SQLManager getRowsForQuery:query];
//    return result;
//}
//
//// 모든 등록된 User 정보 가져오기
//- (NSArray*)getAllUsers
//{
//    //select * From Users Order by seq asc
//    NSString *query = @"SELECT * FROM Users ORDER BY seq ASC";
//    NSArray *result = [SQLManager getRowsForQuery:query];
//    return result;
//}
//
///*
//for (id param in params ) {
//    count++;
//    if ([param isKindOfClass:[NSString class]] )
//        sqlite3_bind_text(statement, count, [param UTF8String], -1, SQLITE_TRANSIENT);
//    if ([param isKindOfClass:[NSNumber class]] ) {
//        if (!strcmp([param objCType], "f"))
//            sqlite3_bind_double(statement, count, [param doubleValue]);
//        else if (!strcmp([param objCType], "i"))
//            sqlite3_bind_int(statement, count, [param intValue]);
//        else
//            NSLog(@"unknown NSNumber");
//    }
//}
// 
// NSString *createUsersTable = @"CREATE TABLE IF NOT EXISTS 'Users' ('UserID' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE , 'UserName' TEXT, 'GUID' TEXT, 'UserNick' TEXT, 'UserProfile' TEXT, 'fbID' TEXT, 'fbName' TEXT, 'fbProfile' TEXT, 'timestamp' DATETIME DEFAULT CURRENT_TIMESTAMP);";
//
// NSString *query = @"UPDATE users SET password = ? WHERE user = ?;";
// NSArray *params = @[@"tets", @"1191" ];
// NSError *error = [[PBSQLiteManager sharedInstance] doUpdateQuery:query withParams:params];
//
//     //UPDATE tbl_4 SET city=(SELECT tbl_3.city FROM tbl_3 WHERE tbl_4.idnum =tbl_3.idnum), state = (SELECT tbl_3.state FROM tbl_3 WHERE tbl_4.idnum = tbl_3.idnum)
// 
// 
//
// */
//
//
//// Users 테이블 업데이트
//// Param muset inclue belows
//// NSDictionary *params = @{ @"UserID" : @(UserID), ... };
//// 'UserName' TEXT, 'GUID' TEXT, 'UserNick' TEXT, 'UserProfile' TEXT, 'fbID' TEXT, 'fbName' TEXT, 'fbProfile' TEXT,
//// Ex) NSDictionary *params = @{ @"UserID" : @(UserID), @"UserName" : @"Test User" };
//- (NSArray *)updateUser:(NSDictionary*)params
//{
//    if(IsEmpty(params)) return nil ;
//    
//    NSString *updateParam = nil;
//    NSString *whereParam = nil;
//    int index = 0;
//    int UserID;
//    
//    NSArray *keys = params.allKeys;
//
//    for(NSString*key in keys){
//
//        if([key isEqualToString:@"UserID"]) {
//            UserID = [[params objectForKey:@"UserID"] intValue];
//            whereParam = [NSString stringWithFormat:@" UserID = %d ", UserID];
//        } else {
//
//            NSString *keyNvalue = [NSString stringWithFormat:@" %@ = '%@' ", key, [params objectForKey:key]];
//            if(index > 0 && !IsEmpty(updateParam))
//                updateParam = [NSString stringWithFormat:@" %@ , %@ ", updateParam, keyNvalue];
//            else
//                updateParam = keyNvalue;
//        }
//        index++;
//    }
//
//    if(IsEmpty(updateParam) || IsEmpty(whereParam)) return nil;
//    
//    NSString *query = [NSString stringWithFormat:@"UPDATE Users SET %@ WHERE %@ ;", updateParam, whereParam];
//
////	NSError *error = [[PBSQLiteManager sharedInstance] doUpdateQuery:query withParams:params];
////    
////	if (error != nil) {
////		NSLog(@"Error: %@",[error localizedDescription]);
////	}
//    
//    NSError *error = [SQLManager doQuery:query];
//    if (error != nil) {
//        NSLog(@"Error: %@",[error localizedDescription]);
//    }
//	
//    query = [NSString stringWithFormat:@"SELECT * FROM Users WHERE UserID = %d;", UserID];
//    NSArray *result = [[PBSQLiteManager sharedInstance] getRowsForQuery:query];
//    
//    NSLog(@"result : %@", result);
//    
//    return result;
//    
//}
//
//
//// 해당 UserID의 Users 데이터 모두 삭제.
//// 해당 UserID의 FaceData 데이터 모두 삭제.
//// 해당 UserID의 UserPhotos 데이터 모두 삭제.
//- (BOOL)deleteUser:(int)UserID
//{
//    BOOL success = YES;
//    NSString *sqlStr = [NSString stringWithFormat:@"DELETE FROM Users WHERE UserID = %d", UserID];
//    NSLog(@"delete qury :: %@", sqlStr);
//    NSError *error = [SQLManager doQuery:sqlStr];
//    if (error != nil) {
//    	NSLog(@"Error: %@",[error localizedDescription]);
//        success = NO;
//    }
//    
//    if(success){
//        success = [self deleteAllFacesForUserID:UserID];
//    }
//    if(success){
//        success = [self deleteAllUserPhotosForUserID:UserID];
//    }
//    
//    return success;
//}
//
//
//// 해당 UserID의 FaceData 데이터 모두 삭제.
//- (BOOL)deleteAllFacesForUserID:(int)UserID
//{
//    BOOL success = YES;
//    NSString *sqlStr = [NSString stringWithFormat:@"DELETE FROM FaceData WHERE UserID = %d", UserID];
//    NSLog(@"delete qury :: %@", sqlStr);
//    NSError *error = [SQLManager doQuery:sqlStr];
//    if (error != nil) {
//    	NSLog(@"Error: %@",[error localizedDescription]);
//        success = NO;
//    }
//
//    return success;
//}
//
//
//// 해당 UserID의 UserPhotos 데이터 모두 삭제.
//- (BOOL)deleteAllUserPhotosForUserID:(int)UserID
//{
//    BOOL success = YES;
//    
//    // UnfaceTab에서 참조할 수 있게 Photos 테이블의 CheckType 변경.
//    NSString *sqlStr = [NSString stringWithFormat:@"SELECT PhotoID FROM UserPhotos WHERE UserID = %d", UserID];
//    NSArray *result = [SQLManager getRowsForQuery:sqlStr];
//    for(NSDictionary *info in result){
//        int photoId = [info[@"PhotoID"] intValue];
//        
//        //Photos 에 삭제됨을 저장.
//        NSString *query = [NSString stringWithFormat:@" UPDATE Photos SET CheckType = CheckType - 1 WHERE PhotoID = %d;", photoId];
//        
//        NSError *error = [SQLManager doQuery:query];
//        if (error != nil) {
//            NSLog(@"Error: %@",[error localizedDescription]);
//        }
//    }
//    
//    
//    sqlStr = [NSString stringWithFormat:@"DELETE FROM UserPhotos WHERE UserID = %d", UserID];
//    NSLog(@"delete qury :: %@", sqlStr);
//    NSError *error = [SQLManager doQuery:sqlStr];
//    if (error != nil) {
//    	NSLog(@"Error: %@",[error localizedDescription]);
//        success = NO;
//    }
//    
//    return success;
//}
//
//- (UIColor*)getUserColor:(int)colorID alpha:(float)alpha
//{
//    UIColor *color;
//    switch (colorID) {
//        case 0: color = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:alpha]; break;
//        case 1: color = [UIColor colorWithRed:255/255.0 green:177/255.0 blue:9/255.0 alpha:alpha]; break;
//        case 2: color = [UIColor colorWithRed:255/255.0 green:148/255.0 blue:49/255.0 alpha:alpha]; break;
//        case 3: color = [UIColor colorWithRed:248/255.0 green:106/255.0 blue:39/255.0 alpha:alpha]; break;
//        case 4: color = [UIColor colorWithRed:243/255.0 green:65/255.0 blue:52/255.0 alpha:alpha]; break;
//        case 5: color = [UIColor colorWithRed:205/255.0 green:70/255.0 blue:85/255.0 alpha:alpha]; break;
//        default: color = [UIColor colorWithRed:255/255.0 green:177/255.0 blue:9/255.0 alpha:alpha]; break;
//            
////        case 0: color = COLOR_PINK; break;
////        case 1: color = COLOR_RED; break;
////        case 2: color = COLOR_AMERICANROSE; break;
////        case 3: color = COLOR_ORANGE; break;
////        case 4: color = COLOR_YELLOW; break;
////        case 5: color = COLOR_GREEN; break;
////        case 6: color = COLOR_TURQUOISE; break;
////        case 7: color = COLOR_BLUE; break;
////        case 8: color = COLOR_DARKBLUE; break;
////        case 9: color = COLOR_PURPLE; break;
////        default: color = COLOR_PINK; break;
//    }
//    
//    return color;
//}
//
//#pragma mark FaceData Table
//// 해당 User의 인식용 얼굴 데이터 개수 조사.
//
//- (NSInteger)numberOfFacesForUserID:(int)UserID
//{
//    const char* selectSQL = "SELECT COUNT(*) FROM FaceData WHERE UserID = ?";
//    sqlite3_stmt *statement;
//    sqlite3 *sqlDB = [SQLManager getDBContext];
//    NSInteger count = 0;
//    if (sqlite3_prepare_v2(sqlDB, selectSQL, -1, &statement, nil) == SQLITE_OK) {
//        sqlite3_bind_int(statement, 1, UserID);
//        if (sqlite3_step(statement)== SQLITE_ROW) {
//            count = sqlite3_column_int(statement, 0);
//        }
//    }
//    
//    sqlite3_finalize(statement);
//    
//    return count;
//}
//
//- (NSArray*)getTrainModels
//{
//    NSMutableArray *models = [NSMutableArray array];
//    
//    const char* selectSQL = "SELECT UserID, image FROM FaceData";
//    sqlite3_stmt *statement;
//    
//    sqlite3 *sqlDB = [SQLManager getDBContext];
//    
//    if (sqlite3_prepare_v2(sqlDB, selectSQL, -1, &statement, nil) == SQLITE_OK) {
//        while (sqlite3_step(statement) == SQLITE_ROW) {
//            int UserID = sqlite3_column_int(statement, 0);
//            
//            // First pull out the image into NSData
//            int imageSize = sqlite3_column_bytes(statement, 1);
//            NSData *imageData = [NSData dataWithBytes:sqlite3_column_blob(statement, 1) length:imageSize];
//            
//            [models addObject:@{@"UserID":[NSNumber numberWithInt:UserID],
//                                @"imageData":imageData}];
//
//        }
//    }
//    
//    sqlite3_finalize(statement);
//    
//    
//    return (NSArray*)models;
//}
//
//- (NSArray*)getTrainModelsForID:(int)UserID
//{
//    NSMutableArray *models = [NSMutableArray array];
//    
//    const char* selectSQL = "SELECT UserID, image FROM FaceData where UserID = ?";
//    sqlite3_stmt *statement;
//    
//    sqlite3 *sqlDB = [SQLManager getDBContext];
//    
//    if (sqlite3_prepare_v2(sqlDB, selectSQL, -1, &statement, nil) == SQLITE_OK) {
//        sqlite3_bind_int(statement, 1, UserID);
//        while (sqlite3_step(statement) == SQLITE_ROW) {
//            int imageSize = sqlite3_column_bytes(statement, 1);
//            NSData *imageData = [NSData dataWithBytes:sqlite3_column_blob(statement, 1) length:imageSize];
//
//            [models addObject:@{@"UserID":@(UserID),
//                                @"imageData":imageData}];
//            
//        }
//    }
//    
//    sqlite3_finalize(statement);
//    
//    
//    return (NSArray*)models;
//}
//
//
//- (NSArray*)getTrainImagesForID:(int)UserID
//{
//    NSMutableArray *models = [NSMutableArray array];
//    
//    const char* selectSQL = "SELECT UserID, image FROM FaceData where UserID = ?";
//    sqlite3_stmt *statement;
//    
//    sqlite3 *sqlDB = [SQLManager getDBContext];
//    
//    if (sqlite3_prepare_v2(sqlDB, selectSQL, -1, &statement, nil) == SQLITE_OK) {
//        sqlite3_bind_int(statement, 1, UserID);
//        while (sqlite3_step(statement) == SQLITE_ROW) {
//            int imageSize = sqlite3_column_bytes(statement, 1);
//            NSData *imageData = [NSData dataWithBytes:sqlite3_column_blob(statement, 1) length:imageSize];
//            
//            cv::Mat data = [FaceLib dataToMat:imageData width:@(100) height:@(100)];
//            UIImage *image = [FaceLib MatToUIImage:data];
//            [models addObject:image];
//            
//        }
//    }
//    
//    sqlite3_finalize(statement);
//    
//    
//    return (NSArray*)models;
//}
//
//- (NSArray*)getTrainModelsExceptID:(int)UserID
//{
//    NSMutableArray *models = [NSMutableArray array];
//    
//    const char* selectSQL = "SELECT UserID, image FROM FaceData where UserID IS NOT ?";
//    sqlite3_stmt *statement;
//    
//    sqlite3 *sqlDB = [SQLManager getDBContext];
//    
//    if (sqlite3_prepare_v2(sqlDB, selectSQL, -1, &statement, nil) == SQLITE_OK) {
//        sqlite3_bind_int(statement, 1, UserID);
//        while (sqlite3_step(statement) == SQLITE_ROW) {
//            int imageSize = sqlite3_column_bytes(statement, 1);
//            NSData *imageData = [NSData dataWithBytes:sqlite3_column_blob(statement, 1) length:imageSize];
//            
//            cv::Mat data = [FaceLib dataToMat:imageData width:@(100) height:@(100)];
//            UIImage *image = [FaceLib MatToUIImage:data];
//            [models addObject:image];
//            
//        }
//    }
//    
//    sqlite3_finalize(statement);
//    
//    
//    return (NSArray*)models;
//}
//
//
//- (NSArray*)getUsersFaces
//{
//    NSMutableArray *usersPhotos = [NSMutableArray array];
//    
//    NSString *query = @"SELECT UserID, UserName FROM Users ORDER BY timestamp ASC";
//    NSArray *users = [SQLManager getRowsForQuery:query];
//    for(NSDictionary *user in users){
//        int userID = [user[@"UserID"] intValue];
//        NSArray *result = [SQLManager getTrainImagesForID:userID];
//        //[usersPhotos addObject:@{@"user":user,@"photos":result}];
//        [usersPhotos addObject:result];
//        
//    }
//    return usersPhotos;
//
//}
//
//- (void)addTrainModelForUserID:(int)UserID withFaceData:(NSData*)FaceData
//{
//    const char* insertSQL = "INSERT INTO FaceData (UserID, image) VALUES (?, ?)";
//    sqlite3_stmt *statement;
//    sqlite3 *sqlDB = [SQLManager getDBContext];
//    if (sqlite3_prepare_v2(sqlDB, insertSQL, -1, &statement, nil) == SQLITE_OK) {
//        sqlite3_bind_int(statement, 1, UserID);
//        sqlite3_bind_blob(statement, 2, FaceData.bytes, FaceData.length, SQLITE_TRANSIENT);
//        sqlite3_step(statement);
//    }
//    
//    sqlite3_finalize(statement);
// 
//}
//
//#pragma mark Photos Table
//// sqlite3_bind_double(statement, index, [dateObject timeIntervalSince1970]);
//// where dateObject is an NSDate*. Then, when getting the data out of the DB, use
//// [NSDate dateWithTimeIntervalSince1970:doubleValueFromDatabase];
//static inline double convertDate2Double(NSDate* date){ return [date timeIntervalSince1970]; }
//static inline NSDate* convertDouble2Date(double date){ return [NSDate dateWithTimeIntervalSince1970:date];}
//
//- (int)newPhotoWith:(ALAsset *)asset withGroupAssetURL:(NSString*)GroupURL
//{
//    int PhotoID = -1;
//    
//    NSURL *URL = [asset valueForProperty:ALAssetPropertyAssetURL];
//    NSString *AssetURL  = URL.absoluteString;
//    
//    //NSString *AssetURL = [asset valueForProperty:ALAssetPropertyAssetURL];
//
//    NSString *query = [NSString stringWithFormat:@"SELECT PhotoID FROM Photos WHERE AssetURL = '%@';", AssetURL];
//    NSArray *result = [SQLManager getRowsForQuery:query];
//    NSLog(@"[Photos] QUERY result = %@", result);
//    if(!IsEmpty(result)) //[result count] > 0 && result != nil)
//    {
//        return [[[result objectAtIndex:0] objectForKey:@"PhotoID"] intValue];
//    }
//    else
//    {
//        double Date = convertDate2Double([asset valueForProperty:ALAssetPropertyDate]);
//        //[[asset valueForProperty:ALAssetPropertyDate] timeIntervalSince1970]
//        NSString *AssetType = [asset valueForProperty:ALAssetPropertyType];
//        CLLocation *location = [asset valueForProperty:ALAssetPropertyLocation];
//        double Longitude = (double)location.coordinate.longitude;
//        double Latitude = (double)location.coordinate.latitude;
//        double Duration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
//        
//        NSString *sqlStr = [NSString stringWithFormat:
//                            @"INSERT INTO Photos (AssetURL, GroupURL, Date, AssetType, Longitude, Latitude, Duration) VALUES ('%@', '%@', %f, '%@', %f, %f, %f);",
//                            AssetURL, GroupURL, Date, AssetType, Longitude, Latitude, Duration];
//        NSError *error = [SQLManager doQuery:sqlStr];
//        if (error != nil) {
//            NSLog(@"Error: %@",[error localizedDescription]);
//        } else {
//            query = [NSString stringWithFormat:@"SELECT * FROM Photos WHERE AssetURL = '%@';", AssetURL];
//            result = [SQLManager getRowsForQuery:query];
//            
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"DBEventHandler"
//                                                                object:self
//                                                              userInfo:@{ @"Msg":@"changedGalleryDB", @"result":result, @"Asset":asset }];
//            
//            
//            NSLog(@"[Photos] INSERT result = %@", result);
//            if([result count] > 0 && result != nil)
//            {
//                PhotoID = [[[result objectAtIndex:0] objectForKey:@"PhotoID"] intValue];
//            }
//            
//            return PhotoID;
//        }
//    }
// 
//    
//    return -1;
//
//}
//
//- (NSArray*)getGroupPhotos:(NSString*)GroupURL filter:(BOOL)all
//{
//    NSString *query ;
//    if(!all){
//        query = [NSString stringWithFormat:@"SELECT PhotoID, AssetURL, Longitude, Latitude, Date, CheckType  FROM Photos WHERE GroupURL = '%@';", GroupURL];
//    } else {
//        query = [NSString stringWithFormat:@"SELECT PhotoID, AssetURL, Longitude, Latitude, Date, CheckType  FROM Photos WHERE CheckType = 0 AND GroupURL = '%@';", GroupURL];
//    }
// 
//    NSLog(@"Query : %@", query);
//    
//    NSArray *result = [SQLManager getRowsForQuery:query];
//
//    return result;
//}
//
//
//- (NSArray*)getAllPhotos
//{
//    NSString *query = @"SELECT * FROM Photos ORDER BY PhotoID";
//    
//    NSArray *result = [SQLManager getRowsForQuery:query];
//    return result;
//}
//
//- (NSArray*)getPhoto:(NSString *)assetURL
//{
//    NSString *query = [NSString stringWithFormat:@"SELECT * FROM Photos WHERE AssetURL = %@", assetURL];
//    
//    NSArray *result = [SQLManager getRowsForQuery:query];
//    return result;
//}
//
//- (BOOL)deletePhoto:(int)PhotoID
//{
//    BOOL success = YES;
//    NSString *sqlStr = [NSString stringWithFormat:@"DELETE FROM Photos WHERE PhotoID = %d", PhotoID];
//    NSLog(@"delete qury :: %@", sqlStr);
//    NSError *error = [SQLManager doQuery:sqlStr];
//    if (error != nil) {
//    	NSLog(@"Error: %@",[error localizedDescription]);
//        success = NO;
//    }
//
//    return success;
//}
//
//#pragma mark Faces Table
//- (int)newFaceWith:(int)PhotoID withFeature:(CIFaceFeature *)face withInfo:(NSDictionary*)info
//{
//    int FaceNo = -1;
//    
//    NSString *FaceBound = NSStringFromCGRect(face.bounds);
//    
//    NSString *query = [NSString stringWithFormat:@"SELECT FaceNo, PhotoID, FaceBound FROM Faces WHERE FaceBound = '%@';", FaceBound];
//    NSArray *result = [SQLManager getRowsForQuery:query];
//    NSLog(@"[Faces] QUERY result = %@", result);
//    if([result count] > 0 && result != nil)
//    {
//        FaceNo = [[[result objectAtIndex:0] objectForKey:@"FaceNo"] intValue];
//        return FaceNo;
//    }
//    
//
//    if(![result count]){
//        NSData *serialized = [info objectForKey:@"image"];
//        NSString *PhotoBound = [info objectForKey:@"PhotoBound"];
//        
//        NSString *LEyePoint = NSStringFromCGPoint(face.leftEyePosition);
//        NSString *REyePoint = NSStringFromCGPoint(face.rightEyePosition);
//        NSString *MouthPoint = NSStringFromCGPoint(face.mouthPosition);
//        double FaceAngle = face.faceAngle;
//        double FaceYaw = 0;
//        int FaceSmile = (face.hasSmile)? 1 : 0 ;
//        int LEyeClosed = (face.leftEyeClosed)? 1 : 0 ;
//        int REyeClosed = (face.rightEyeClosed)? 1 : 0 ;
//        
//        
//        const char* insertSQL = "INSERT INTO Faces (PhotoID, PhotoBound, FaceBound, LEyePoint, REyePoint, MouthPoint, FaceAngle, FaceYaw, FaceSmile, LEyeClosed, REyeClosed, image) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
//        sqlite3_stmt *statement;
//        sqlite3 *sqlDB = [SQLManager getDBContext];
//        if (sqlite3_prepare_v2(sqlDB, insertSQL, -1, &statement, nil) == SQLITE_OK) {
//            sqlite3_bind_int(statement, 1, PhotoID);
//            sqlite3_bind_text(statement, 2, [PhotoBound UTF8String], -1, SQLITE_TRANSIENT);
//            sqlite3_bind_text(statement, 3, [FaceBound UTF8String], -1, SQLITE_TRANSIENT);
//            sqlite3_bind_text(statement, 4, [LEyePoint UTF8String], -1, SQLITE_TRANSIENT);
//            sqlite3_bind_text(statement, 5, [REyePoint UTF8String], -1, SQLITE_TRANSIENT);
//            sqlite3_bind_text(statement, 6, [MouthPoint UTF8String], -1, SQLITE_TRANSIENT);
//            sqlite3_bind_double(statement, 7, FaceAngle);
//            sqlite3_bind_double(statement, 8, FaceYaw);
//            sqlite3_bind_int(statement, 9, FaceSmile);
//            sqlite3_bind_int(statement, 10, LEyeClosed);
//            sqlite3_bind_int(statement, 11, REyeClosed);
//            sqlite3_bind_blob(statement, 12, serialized.bytes, serialized.length, SQLITE_TRANSIENT);
//            sqlite3_step(statement);
//        }
//        
//        sqlite3_finalize(statement);
//
//    }
//    query = [NSString stringWithFormat:@"SELECT FaceNo, PhotoID, FaceBound FROM Faces WHERE FaceBound = '%@' AND  PhotoID = %d;",
//             FaceBound,PhotoID];
//    result = [SQLManager getRowsForQuery:query];
//    NSLog(@"[Faces] INSERT result = %@", result);
//    if([result count] > 0 && result != nil)
//    {
//        FaceNo = [[[result objectAtIndex:0] objectForKey:@"FaceNo"] intValue];
//    }
//
//    return FaceNo;
//}
//
//- (NSArray*)getAllFaces
//{
//    NSString *query = @"SELECT * FROM Faces ORDER BY PhotoID";
//    
//    NSArray *result = [SQLManager getRowsForQuery:query];
//    return result;
//}
//
//- (NSArray*)getFace:(int)PhotoID
//{
//    NSString *query = [NSString stringWithFormat:@"SELECT * FROM Faces WHERE PhotoID = %d", PhotoID];
//    
//    NSArray *result = [SQLManager getRowsForQuery:query];
//    return result;
//}
//
//- (BOOL)deleteFace:(int)FaceNo
//{
//    BOOL success = YES;
//    NSString *sqlStr = [NSString stringWithFormat:@"DELETE FROM Faces WHERE FaceNo = %d", FaceNo];
//    NSLog(@"delete qury :: %@", sqlStr);
//    NSError *error = [SQLManager doQuery:sqlStr];
//    if (error != nil) {
//    	NSLog(@"Error: %@",[error localizedDescription]);
//        success = NO;
//    }
//    
//    return success;
//
//}
//
//#pragma mark UserPhotos Table
//- (int)newUserPhotosWith:(int)UserID withPhoto:(int)PhotoID withFace:(int)FaceNo
//{
//    int PhotoNo = -1;
//    
//    NSString *query = [NSString stringWithFormat:@"SELECT * FROM UserPhotos WHERE UserID = %d AND PhotoID = %d AND FaceNo = %d;",
//                       UserID, PhotoID, FaceNo];
//    
//    NSArray *result = [SQLManager getRowsForQuery:query];
//    NSLog(@"[UserPhotos] QUERY result = %@", result);
//    if([result count] > 0 && result != nil)
//    {
//        PhotoNo = [[[result objectAtIndex:0] objectForKey:@"no"] intValue];
//        return PhotoNo;
//    }
//
//    if(![result count]){
//        NSString *sqlStr = [NSString stringWithFormat:
//                            @"INSERT INTO UserPhotos (UserID, PhotoID, FaceNo) VALUES (%d, %d, %d);",
//                            UserID, PhotoID, FaceNo];
//        NSLog(@"INSERT QUERY = %@", sqlStr);
//        NSError *error = [SQLManager doQuery:sqlStr];
//        if (error != nil) {
//            NSLog(@"Error: %@",[error localizedDescription]);
//        } else {
//            //Photos 에 사용됨을 저장.
//            NSString *query = [NSString stringWithFormat:@" UPDATE Photos SET CheckType = CheckType + 1 WHERE PhotoID = %d;", PhotoID];
//
//            NSError *error = [SQLManager doQuery:query];
//            if (error != nil) {
//                NSLog(@"Error: %@",[error localizedDescription]);
//            }
//        }
//    }
//
//    query = [NSString stringWithFormat:@"SELECT * FROM UserPhotos WHERE UserID = %d AND PhotoID = %d AND FaceNo = %d;",
//             UserID, PhotoID, FaceNo];
//    result = [SQLManager getRowsForQuery:query];
//    NSLog(@"[UserPhotos] INSERT result : %@", result);
//    if([result count] > 0 && result != nil)
//    {
//        PhotoNo = [[[result objectAtIndex:0] objectForKey:@"no"] intValue];
//    }
//    
//    return PhotoNo;
//
//}
//
//- (NSMutableArray*)getAllUserPhotos
//{
//    NSMutableArray *usersPhotos = [NSMutableArray array];
//    NSArray *users = [self getAllUsers];
//    for(NSDictionary *user in users){
//        int userID = [[user objectForKey:@"UserID"] intValue];
//        //SELECT U.UserID, U.PhotoID, P.AssetURL FROM UserPhotos AS U  JOIN Photos As P ON U.PhotoID = P.PhotoID WHERE U.UserID = 1
//        //NSString *query = [NSString stringWithFormat:@"SELECT UserID, PhotoID, AssetURL FROM UserPhotos NATURAL JOIN Photos WHERE UserID = %d",userID];
//        NSString *query = [NSString stringWithFormat:@"SELECT U.UserID, U.PhotoID, U.FaceNo, P.AssetURL FROM UserPhotos AS U  JOIN Photos As P ON U.PhotoID = P.PhotoID WHERE U.UserID = %d",userID];
//        NSArray *result = [SQLManager getRowsForQuery:query];
//
//        [usersPhotos addObject:@{@"user":user,@"photos":result}];
//        
//    }
//    return usersPhotos;
//}
//
//- (NSArray *)getUserPhotos:(int)UserID
//{
////    NSDictionary *userPhotos = nil;
////    NSArray *users = [self getUserInfo:UserID];
////    if(!IsEmpty(users)){
////        NSDictionary *user= users[0];
////        NSString *query = [NSString stringWithFormat:@"SELECT U.UserID, U.PhotoID, U.FaceNo, P.AssetURL FROM UserPhotos AS U  JOIN Photos As P ON U.PhotoID = P.PhotoID WHERE U.UserID = %d",UserID];
////        NSLog(@"Query : %@",query);
////        
////        NSArray *result = [SQLManager getRowsForQuery:query];
////
////        userPhotos = @{@"user":user,@"photos":result};
////
////    }
////    return userPhotos;
//    
////    NSDictionary *user= users[0];
////    
////    //NSString *query = [NSString stringWithFormat:@"SELECT * FROM UserPhotos WHERE UserID = %d", UserID];
////    
//    NSString *query = [NSString stringWithFormat:@"SELECT U.UserID, U.PhotoID, U.FaceNo, P.AssetURL FROM UserPhotos AS U  JOIN Photos As P ON U.PhotoID = P.PhotoID WHERE U.UserID = %d",UserID];
//    
//    NSArray *result = [SQLManager getRowsForQuery:query];
//    
//    return result;
//}
//
//- (BOOL)deleteUserPhoto:(int)UserID withPhoto:(int)PhotoID
//{
//    BOOL success = YES;
//    NSString *sqlStr = [NSString stringWithFormat:@"DELETE FROM UserPhotos WHERE UserID = %d And PhotoID = %d", UserID, PhotoID];
//    NSLog(@"delete qury :: %@", sqlStr);
//    NSError *error = [SQLManager doQuery:sqlStr];
//    if (error != nil) {
//    	NSLog(@"Error: %@",[error localizedDescription]);
//        success = NO;
//    } else {
//        //Photos 에 삭제됨을 저장.
//        NSString *query = [NSString stringWithFormat:@" UPDATE Photos SET CheckType = CheckType - 1 WHERE PhotoID = %d;", PhotoID];
//        
//        NSError *error = [SQLManager doQuery:query];
//        if (error != nil) {
//            NSLog(@"Error: %@",[error localizedDescription]);
//        }
//    }
//    
//    return success;
//}
//
//
//
////앨범 간 copy / Move / New Album / Delete   (DB)
//
////사진 촬영 후 해당 사진을 UserPhotos에 저장.
//- (void)saveNewUserPhotoToDB:(ALAsset*)photoAsset users:(NSArray*)users
//{
//    
//    NSLog(@"Asset : %@ / Users : %@", photoAsset, users);
//    
//    NSString *query = [NSString stringWithFormat:@"SELECT GroupURL FROM Groups WHERE GroupName = '%@';", @"Camera Roll"];
//    NSArray *result = [SQLManager getRowsForQuery:query];
//    NSString *GroupURL = @"";
//    if(!IsEmpty(result)){
//        GroupURL = [[result objectAtIndex:0] objectForKey:@"GroupURL"];
//    }
//    
//    // 신규 포토 저장.
//    // Save DB. [Photos] 얼굴이 검출된 사진만 Photos Table에 저장.
//    int PhotoID = [SQLManager newPhotoWith:photoAsset withGroupAssetURL:GroupURL];
//    
//    if(PhotoID >= 0){
//        if(!IsEmpty(users)){
//            for(id user in users){
//                int userID = [user intValue];
//                
//                int PhotoNo = [SQLManager newUserPhotosWith:userID
//                                                  withPhoto:PhotoID
//                                                   withFace:-1];
//                NSLog(@"PhotoNO = %d / UserID = %d", PhotoNo, userID);
//                if(PhotoNo)
//                {
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"AlbumContentsViewEventHandler"
//                                                                        object:self
//                                                                      userInfo:@{@"Msg":@"changedGalleryDB"}];
//                }
//                
//                
//            }
//        } else {
//            int userID = GlobalValue.UserID;
//            
//            int PhotoNo = [SQLManager newUserPhotosWith:userID
//                                              withPhoto:PhotoID
//                                               withFace:-1];
//            NSLog(@"PhotoNO = %d / UserID = %d", PhotoNo, userID);
//            if(PhotoNo)
//            {
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"AlbumContentsViewEventHandler"
//                                                                    object:self
//                                                                  userInfo:@{@"Msg":@"changedGalleryDB"}];
//            }
//        }
//        
//        
//        
//    }
//    
//}



@end

