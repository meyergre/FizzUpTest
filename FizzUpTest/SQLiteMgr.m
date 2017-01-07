//
//  SQLiteMgr.m
//  FizzUpTest
//
//  Created by Grégory Meyer on 05/01/2017.
//  Copyright © 2017 Grégory Meyer. All rights reserved.
//

#import "SQLiteMgr.h"

static SQLiteMgr *sharedInstance = nil;
static sqlite3 *db = nil;
static sqlite3_stmt *stmt = nil;

@implementation SQLiteMgr

+(SQLiteMgr*)getSharedInstance{
    if(!sharedInstance) {
        sharedInstance = [[super allocWithZone:nil]init];
        [sharedInstance createDB];
    }
    return sharedInstance;
}

-(BOOL)createDB{
    NSString *docPath;
    
    // Get the documents directory
    docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0];
    
    // Build path for database file
    dbPath = [[NSString alloc] initWithString:[docPath stringByAppendingPathComponent: @"dbteskt.sqlite"]];
    BOOL ret = false;
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if(![fm fileExistsAtPath: dbPath]) {
        if(sqlite3_open([dbPath UTF8String], &db) == SQLITE_OK) {
            char *errorMsg;
            const char *stmt = "CREATE TABLE IF NOT EXISTS entries (id INTEGER PRIMARY KEY, image TEXT, name TEXT)";
            if(sqlite3_exec(db, stmt, nil, nil, &errorMsg) != SQLITE_OK) {
                ret = false;
                NSLog(@"Failed to create table 'entries' : %s", errorMsg);
            }
            sqlite3_close(db);
            return ret;
        }
    } else {
        ret = false;
    }
    return ret;
}

-(BOOL)saveData:(NSNumber *)id image:(NSData *)image name:(NSString *)name;
{
    BOOL ret = false;
    if(sqlite3_open([dbPath UTF8String], &db) == SQLITE_OK) {
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO entries (id, image, name) VALUES(\"%@\", \"%@\", \"%@\")", id, image, name];
        const char *query_stmt = [sql UTF8String];
        sqlite3_prepare_v2(db, query_stmt, -1, &stmt, nil);
        if(sqlite3_step(stmt) == SQLITE_DONE) {
            NSLog(@"Data inserted for name : %@", name);
            ret = true;
        } else {
            ret = false;
        }
        sqlite3_reset(stmt);
    }
    return ret;
}

-(NSMutableArray*)getAll{
    NSMutableArray *ret = [[NSMutableArray alloc]init];
    if(sqlite3_open([dbPath UTF8String], &db) == SQLITE_OK) {
        NSString *sql = @"SELECT * FROM entries";
        if(sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
            while(sqlite3_step(stmt) == SQLITE_ROW){
                NSMutableArray *row = [[NSMutableArray alloc]init];
                NSNumber *id = [[NSNumber alloc]initWithInt:sqlite3_column_int(stmt, 0)];
                [row addObject: id];
                NSString *image = [[NSString alloc]initWithUTF8String:(const char*) sqlite3_column_text(stmt, 1)];
                [row addObject: image];
                NSString *name = [[NSString alloc]initWithUTF8String:(const char*) sqlite3_column_text(stmt, 2)];
                [row addObject: name];
                [ret addObject:row];
            }
        }
    }
    return ret;
}

-(BOOL)clearAll{
    BOOL ret = false;
    if(sqlite3_open([dbPath UTF8String], &db) == SQLITE_OK) {
        NSString *sql = @"DELETE FROM entries";
        if(sqlite3_exec(db, [sql UTF8String], nil, nil, nil)==SQLITE_OK)
        {
            ret = true;
            NSLog(@"All your data are belong to us :o)");
        }
    }
    return ret;
}


@end