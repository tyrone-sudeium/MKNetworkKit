//
//  NSDate+RFC1123.m
//  MKNetworkKit
//
//  Created by Marcus Rohrmoser
//  http://blog.mro.name/2009/08/nsdateformatter-http-header/
//
//  No obvious license attached

#import "NSDate+RFC1123.h"

@implementation NSDate (RFC1123)

+(NSDate*)dateFromRFC1123:(NSString*)value_
{
    if(value_ == nil)
        return nil;    
    
    static dispatch_queue_t _lockQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _lockQueue = dispatch_queue_create("NSDate+RFC1123_dateFromRFC1123_lockQueue", NULL);
    });
    
    __strong static NSDateFormatter *rfc1123 = nil;
    __strong static NSDateFormatter *rfc850 = nil;
    __strong static NSDateFormatter *asctime = nil;
    
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        rfc1123 = [[NSDateFormatter alloc] init];
        rfc1123.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        rfc1123.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        rfc1123.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss z";
        
        rfc850 = [[NSDateFormatter alloc] init];
        rfc850.locale = rfc1123.locale;
        rfc850.timeZone = rfc1123.timeZone;
        rfc850.dateFormat = @"EEEE',' dd'-'MMM'-'yy HH':'mm':'ss z";
        
        asctime = [[NSDateFormatter alloc] init];
        asctime.locale = rfc1123.locale;
        asctime.timeZone = rfc1123.timeZone;
        asctime.dateFormat = @"EEE MMM d HH':'mm':'ss yyyy";
    });
    
    __block NSDate *ret = nil;
    dispatch_sync(_lockQueue, ^{
        ret = [rfc1123 dateFromString:value_];
        if(ret == nil)
            return;
        
        ret = [rfc850 dateFromString:value_];
        if(ret != nil)
            return;
        
        ret = [asctime dateFromString:value_];
    });
    return ret;
}

-(NSString*)rfc1123String
{
    static NSDateFormatter *df = nil;
    if(!df)
    {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            df = [[NSDateFormatter alloc] init];
            df.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            df.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            df.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'";
        });
    }
    return [df stringFromDate:self];
}

@end
