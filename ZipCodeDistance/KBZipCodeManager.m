//
//  KBZipCodeManager.m
//  ZipCodeDistance
//
//  Created by Karl Bode on 15.09.12.
//  Copyright (c) 2012 Karl Bode. All rights reserved.
//

#import "KBZipCodeManager.h"
#import "/usr/include/sqlite3.h"
#import <CoreLocation/CoreLocation.h>

@interface KBZipCodeManager ()

- (CLLocation *)locationForZipCode:(NSString *)zipCode;

@end

@implementation KBZipCodeManager {
    sqlite3 *zipCodesDB;
}

- (void)dealloc
{
    sqlite3_close(zipCodesDB);
}

- (id)init
{
    self = [super init];
    if (self) {
        
        const char *zipCodesDBPath = [[[NSBundle mainBundle] pathForResource:@"zip_codes.db" ofType:nil] UTF8String];
        
        if (sqlite3_open(zipCodesDBPath, &zipCodesDB) == SQLITE_OK) {
        } else {
            NSLog(@"failed to open zipCodes db");
        }
        
    }
    return self;
}

- (NSString *)nameForZipCode:(NSString *)zipCode
{
    
    NSString *locationName = nil;
    
    NSString *querySQL = [NSString stringWithFormat:@"SELECT location FROM zip_codes WHERE code = '%@'", zipCode];
    const char *query_stmt = [querySQL UTF8String];
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(zipCodesDB, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            
            locationName = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
            
        }
        sqlite3_finalize(statement);
    }
    
    return locationName;
}

- (double)distanceBetweenZipCode1:(NSString *)zipCode1 andZipCode2:(NSString *)zipCode2
{
    
    CLLocation *location1 = [self locationForZipCode:zipCode1];
    CLLocation *location2 = [self locationForZipCode:zipCode2];
    
    return [location1 distanceFromLocation:location2];
}

- (CLLocation *)locationForZipCode:(NSString *)zipCode
{
    NSString *querySQL = [NSString stringWithFormat:@"SELECT longitude, latitude FROM zip_codes WHERE code = '%@'", zipCode];
    const char *query_stmt = [querySQL UTF8String];
    sqlite3_stmt *statement;
    
    double longitude;
    double latitude;
    
    if (sqlite3_prepare_v2(zipCodesDB, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            
            longitude = sqlite3_column_double(statement, 0);
            latitude = sqlite3_column_double(statement, 1);
            
        }
        sqlite3_finalize(statement);
    }
    
    return [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
}

@end
