//
//  NASSmartContracts.h
//  iosSDK
//
//  Created by Bobby on 2018/5/28.
//

#import <Foundation/Foundation.h>

#define NAS_NANO_SCHEMA_URL @"openapp.nasnano://virtual?params=%@"

#ifdef DEBUG
#define NAS_CALLBACK @"https://pay.nebulas.io/api/pay"
#define NAS_CHECK_URL @"https://pay.nebulas.io/api/pay/query?payId=%@"
#else
#define NAS_CALLBACK @"https://pay.nebulas.io/api/mainnet/pay"
#define NAS_CHECK_URL @"https://pay.nebulas.io/api/mainnet/pay/query?payId=%@"
#endif

@interface NASSmartContracts : NSObject

/**
 * Way to generate serialNumber.
 **/
+ (NSString *)randomCodeWithLength:(NSInteger)length;

/**
 * Pay for goods. Return nil if successful.
 **/
+ (NSError *)payNas:(NSNumber *)nas
          toAddress:(NSString *)address
   withSerialNumber:(NSString *)sn
       forGoodsName:(NSString *)name
            andDesc:(NSString *)desc;

/**
 * Call a smart contract function. Return nil if successful.
 **/
+ (NSError *)callWithMethod:(NSString *)method
                    andArgs:(NSArray *)args
                     payNas:(NSNumber *)nas
                  toAddress:(NSString *)address
           withSerialNumber:(NSString *)sn
               forGoodsName:(NSString *)name
                    andDesc:(NSString *)desc;

/**
 * Check status for an action.
 **/
+ (void)checkStatusWithSerialNumber:(NSString *)number
              withCompletionHandler:(void (^)(NSString *data))handler;

@end
