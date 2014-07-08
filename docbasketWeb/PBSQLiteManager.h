//
//  PBSQLiteManager.h
//  Pixbee
//
//  Created by jaecheol kim on 11/30/13.
//  Copyright (c) 2013 Pixbee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

#define SQLManager [PBSQLiteManager sharedInstance]

enum errorCodes {
	kDBNotExists,
	kDBFailAtOpen,
	kDBFailAtCreate,
	kDBErrorQuery,
	kDBFailAtClose
};

@interface PBSQLiteManager : NSObject
+(PBSQLiteManager*)sharedInstance;


#pragma mark SQLite Operations
- (sqlite3 *)getDBContext;

- (void)initDataBase;
- (NSError*)doQuery:(NSString *)sql;
- (NSError*)doUpdateQuery:(NSString *)sql withParams:(NSArray *)params;
- (NSArray*)getRowsForQuery:(NSString *)sql;
- (NSString*)getDatabaseDump;

#pragma mark Users Table

- (void)syncDocBaskets2DB:(NSDictionary*)docbaskets completionHandler:(void (^)(BOOL success))block;
- (NSArray*)getDocBasketsForQuery:(NSString *)sql;



@end
