//
//  KBZipCodeManager.h
//  ZipCodeDistance
//
//  Created by Karl Bode on 15.09.12.
//  Copyright (c) 2012 Karl Bode. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KBZipCodeManager : NSObject

- (NSString *)nameForZipCode:(NSString *)zipCode;

- (double)distanceBetweenZipCode1:(NSString *)zipCode1 andZipCode2:(NSString *)zipCode2;

@end
