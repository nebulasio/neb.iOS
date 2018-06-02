//
//  NASApi.h
//  iosSDK
//
//  Created by Bobby on 2018/6/2.
//

#import <Foundation/Foundation.h>

// Document is in https://github.com/nebulasio/wiki/blob/e340e736c6756d54bca7a655e432db9f9a257544/rpc.md
@interface NASApi : NSObject

/**
 * Go to debug mode. Default is product mode.
 **/
+ (void)debug:(BOOL)debug;

/**
 * Generate a contract dict for using as paramter.
 **/
+ (NSDictionary *)contractWithSource:(NSString *)source
                       andSourceType:(NSString *)sourceType
                         andFunction:(NSString *)function
                             andArgs:(NSArray<NSString *> *)args;

#pragma mark - API
// We do not define model for response and return a dictionary instead.
// You can use your favorite json library to parse the data.

/**
 * Return the state of the neb.
 **/
+ (void)fetchNebStateWithCompletionHandler:(void (^)(NSDictionary *data))handler
                              errorHandler:(void (^)(NSString *msg))errorHandler;

/**
 * Return the state of the account. Balance and nonce of the given address will be returned.
 * address - Hex string of the account addresss.
 * height  - block account state with height. If not specified, use 0 as tail height.
 **/
+ (void)fetchAccountState:(NSString *)address
                andHeight:(NSInteger)height
    withCompletionHandler:(void (^)(NSDictionary *data))handler
             errorHandler:(void (^)(NSString *msg))errorHandler;

/**
 * Return the latest irreversible block.
 **/
+ (void)fetchLatestIrreversibleBlockWithCompletionHandler:(void (^)(NSDictionary *data))handler
                                             errorHandler:(void (^)(NSString *msg))errorHandler;

/**
 * Call a smart contract function. The smart contract must have been submited. Method calls are run only on the current node, not broadcast.
 **/
+ (void)callFuctionFrom:(NSString *)fromAddr
                     to:(NSString *)toAddr
              withValue:(NSNumber *)nas
               andNonce:(NSInteger)nonce
            andGasPrice:(NSNumber *)gasNas
            andGasLimit:(NSNumber *)gasNasLimit
            andContract:(NSDictionary *)contract
  withCompletionHandler:(void (^)(NSDictionary *data))handler
           errorHandler:(void (^)(NSString *msg))errorHandler;

/**
 * Submit the signed transaction.
 **/
+ (void)sendRawTransaction:(NSString *)data
     withCompletionHandler:(void (^)(NSDictionary *data))handler
              errorHandler:(void (^)(NSString *msg))errorHandler;

/**
 * Get block header info by the block hash.
 **/
+ (void)fetchBlockByHash:(NSString *)hash
     fullfillTransaction:(BOOL)fullfill
   withCompletionHandler:(void (^)(NSDictionary *data))handler
            errorHandler:(void (^)(NSString *msg))errorHandler;

/**
 * Get block header info by the block height.
 **/
+ (void)fetchBlockByHeight:(NSInteger)height
       fullfillTransaction:(BOOL)fullfill
     withCompletionHandler:(void (^)(NSDictionary *data))handler
              errorHandler:(void (^)(NSString *msg))errorHandler;

/**
 * Get transactionReceipt info by tansaction hash. If the transaction not submit or only submit and not packaged on chain, it will reurn not found error.
 **/
+ (void)fetchTransactionReceiptByHash:(NSString *)hash
                withCompletionHandler:(void (^)(NSDictionary *data))handler
                         errorHandler:(void (^)(NSString *msg))errorHandler;

/**
 * Get transactionReceipt info by contract address. If contract not exists or packaged on chain, a not found error will be returned.
 **/
+ (void)fetchTransactionByContract:(NSString *)address
             withCompletionHandler:(void (^)(NSDictionary *data))handler
                      errorHandler:(void (^)(NSString *msg))errorHandler;

/**
 * Return current gasPrice.
 **/
+ (void)fetchGasPriceWithCompletionHandler:(void (^)(NSDictionary *data))handler
                              errorHandler:(void (^)(NSString *msg))errorHandler;

/**
 * Return the estimate gas of transaction.
 **/
+ (void)estimateGasFrom:(NSString *)fromAddr
                     to:(NSString *)toAddr
              withValue:(NSNumber *)nas
               andNonce:(NSInteger)nonce
            andGasPrice:(NSNumber *)gasNas
            andGasLimit:(NSNumber *)gasNasLimit
               contract:(NSDictionary *)contract
                 binary:(NSArray<NSNumber *> *)binary
  withCompletionHandler:(void (^)(NSDictionary *data))handler
           errorHandler:(void (^)(NSString *msg))errorHandler;

/**
 * Return the events list of transaction.
 **/
+ (void)fetchEventByHash:(NSString *)hash
   withCompletionHandler:(void (^)(NSDictionary *data))handler
            errorHandler:(void (^)(NSString *msg))errorHandler;

/**
 * GetDynasty get dpos dynasty.
 **/
+ (void)fetchDynasty:(NSInteger)height
withCompletionHandler:(void (^)(NSDictionary *data))handler
        errorHandler:(void (^)(NSString *msg))errorHandler;

@end
