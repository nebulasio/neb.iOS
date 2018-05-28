//
//  NASSmartContracts.m
//  iosSDK
//
//  Created by Bobby on 2018/5/28.
//

#import <UIKit/UIKit.h>
#import "NASSmartContracts.h"

@implementation NASSmartContracts

+ (NSString *)randomCodeWithLength:(NSInteger)length {
    static NSString *charSet = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *string = [NSMutableString string];
    for (int i = 0; i < length; i++) {
        int index = arc4random() % [charSet length];
        [string appendString:[charSet substringWithRange:NSMakeRange(index, 1)]];
    }
    return [string copy];
}

+ (NSError *)openUrl:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        return nil;
    }
    return [NSError errorWithDomain:@"Need NasNano" code:-1 userInfo:@{
                                                                       @"msg" : @"没安装Nebulas智能数字钱包，请下载安装"
                                                                       }];
}

+ (NSString *)queryValueWithSerialNumber:(NSString *)sn andInfo:(NSDictionary *)info {
    NSMutableDictionary *dict = [NSMutableDictionary
                                 dictionaryWithDictionary:@{
                                                            @"category" : @"jump",
                                                            @"des" : @"confirmTransfer"
                                                            }];
    NSMutableDictionary *pageParams = [NSMutableDictionary
                                       dictionaryWithDictionary:@{ @"serialNumber" : sn ?: @"" }];
    if (info) {
        [pageParams addEntriesFromDictionary:info];
    }
    dict[@"pageParams"] = pageParams;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    return [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]
            stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet
                                                                URLPathAllowedCharacterSet]];
}

+ (NSError *)payNas:(NSNumber *)nas
          toAddress:(NSString *)address
   withSerialNumber:(NSString *)sn
       forGoodsName:(NSString *)name
            andDesc:(NSString *)desc {
    NSNumber *wei = @(1000000000000000000L * [nas doubleValue]);
    NSDictionary *info = @{
                           @"goods" : @{
                                   @"name" : name ?: @"",
                                   @"desc" : desc ?: @""
                                   },
                           @"pay" : @{
                                   @"value" : [NSString stringWithFormat:@"%lld", [wei longLongValue]],
                                   @"to" :  address ?: @"",
                                   @"payload" : @{
                                           @"type" : @"binary"
                                           },
                                   @"currency" : @"NAS"
                                   },
                           @"callback" : NAS_CALLBACK
                           };
    NSString *url = [NSString stringWithFormat:NAS_NANO_SCHEMA_URL,
                     [self queryValueWithSerialNumber:sn andInfo:info]];
    return [self openUrl:url];
}

+ (NSError *)callWithMethod:(NSString *)method
                    andArgs:(NSArray *)args
                     payNas:(NSNumber *)nas
                  toAddress:(NSString *)address
           withSerialNumber:(NSString *)sn
               forGoodsName:(NSString *)name
                    andDesc:(NSString *)desc {
    NSNumber *wei = @(1000000000000000000L * [nas doubleValue]);
    NSData *argsData = [NSJSONSerialization dataWithJSONObject:args options:0 error:nil];
    NSDictionary *info = @{
                           @"goods" : @{
                                   @"name" : name ?: @"",
                                   @"desc" : desc ?: @""
                                   },
                           @"pay" : @{
                                   @"value" : [NSString stringWithFormat:@"%lld", [wei longLongValue]],
                                   @"to" :  address ?: @"",
                                   @"payload" : @{
                                           @"type" : @"call",
                                           @"function" : method ?: @"",
                                           @"args" : [[NSString alloc] initWithData:argsData encoding:NSUTF8StringEncoding]
                                           },
                                   @"currency" : @"NAS"
                                   },
                           @"callback" : NAS_CALLBACK
                           };
    NSString *url = [NSString stringWithFormat:NAS_NANO_SCHEMA_URL,
                     [self queryValueWithSerialNumber:sn andInfo:info]];
    return [self openUrl:url];
}

+ (void)checkStatusWithSerialNumber:(NSString *)number withCompletionHandler:(void (^)(NSString *data))handler {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:NAS_CHECK_URL, number]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (handler) {
            handler([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        }
    }];
    [sessionDataTask resume];
}

@end
