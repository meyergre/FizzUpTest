//
//  SQLiteMgr.h
//  FizzUpTest
//
//  Created by Grégory Meyer on 05/01/2017.
//  Copyright © 2017 Grégory Meyer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface SQLiteMgr : NSObject
{
    NSString *dbPath;
}

+(SQLiteMgr*)getSharedInstance;
-(BOOL)createDB;
-(BOOL)saveData:(NSNumber*)id image: (NSString*)image name: (NSString*)name;
-(NSMutableArray*) getAll;
-(BOOL) clearAll;

@end
