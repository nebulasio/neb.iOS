//
//  NASSmartContracts.m
//  iosSDK
//
//  Created by Bobby on 2018/5/28.
//

#import <UIKit/UIKit.h>
#import "NASSmartContracts.h"

#define NAS_NANO_SCHEMA_URL @"openapp.nasnano://virtual?params=%@"

#define NAS_CALLBACK_DEBUG @"https://pay.nebulas.io/api/pay"
#define NAS_CHECK_URL_DEBUG @"https://pay.nebulas.io/api/pay/query?payId=%@"
#define NAS_HOST_DEBUG @"https://testnet.nebulas.io%@"

#define NAS_CALLBACK @"https://pay.nebulas.io/api/mainnet/pay"
#define NAS_CHECK_URL @"https://pay.nebulas.io/api/mainnet/pay/query?payId=%@"
#define NAS_HOST @"https://mainnet.nebulas.io%@"

static NSString *kNASCallback = NAS_CALLBACK;
static NSString *kNASCheckUrl = NAS_CHECK_URL;

@implementation NASSmartContracts

+ (void)debug:(BOOL)debug {
    if (debug) {
        kNASCallback = NAS_CALLBACK_DEBUG;
        kNASCheckUrl = NAS_CHECK_URL_DEBUG;
    } else {
        kNASCallback = NAS_CALLBACK;
        kNASCheckUrl = NAS_CHECK_URL;
    }
}

+ (BOOL)nasNanoInstalled {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:NAS_NANO_SCHEMA_URL]];
}

+ (void)goToNasNanoAppStore {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/cn/app/id1281191905?mt=8"]];
}

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
        [[UIApplication sharedApplication] openURL:url];
        return nil;
    }
    return [NSError errorWithDomain:@"Need NasNano"
                               code:-1
                           userInfo:@{
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
                           @"callback" : kNASCallback
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
                           @"callback" : kNASCallback
                           };
    NSString *url = [NSString stringWithFormat:NAS_NANO_SCHEMA_URL,
                     [self queryValueWithSerialNumber:sn andInfo:info]];
    return [self openUrl:url];
}

+ (void)checkStatusWithSerialNumber:(NSString *)number
              withCompletionHandler:(void (^)(NSDictionary *data))handler
                       errorHandler:(void (^)(NSInteger code, NSString *msg))errorHandler {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kNASCheckUrl, number]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (errorHandler) {
                errorHandler(error.code, error.description);
            }
        } else {
            NSDictionary *resDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (resDict[@"code"] && [resDict[@"code"] integerValue] == 0) {
                if (handler) {
                    handler(resDict[@"data"]);
                }
            } else {
                if (errorHandler) {
                    errorHandler([resDict[@"code"] integerValue], resDict[@"msg"]);
                }
            }
        }
    }];
    [sessionDataTask resume];
}

@end
