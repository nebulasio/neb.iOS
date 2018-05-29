//
//  NASSmartContracts.h
//  iosSDK
//
//  Created by Bobby on 2018/5/28.
//

#import <Foundation/Foundation.h>

@interface NASSmartContracts : NSObject

/**
 * Go to debug mode. Default is product mode.
 **/
+ (void)debug:(BOOL)debug;

/**
 * Check if NasNano is installed.
 **/
+ (BOOL)nasNanoInstalled;

/**
 * Go to appstore for NasNano.
 **/
+ (void)goToNasNanoAppStore;

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
              withCompletionHandler:(void (^)(NSDictionary *data))handler
                       errorHandler:(void (^)(NSInteger code, NSString *msg))errorHandler;

@end
