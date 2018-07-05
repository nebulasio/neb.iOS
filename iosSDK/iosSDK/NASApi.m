//
//  NASApi.m
//  iosSDK
//
//  Created by Bobby on 2018/6/2.
//

#import "NASApi.h"

#define NAS_HOST_DEBUG @"https://testnet.nebulas.io%@"
#define NAS_HOST @"https://mainnet.nebulas.io%@"

static NSString *kNASHost = NAS_HOST;

@implementation NASApi

+ (void)debug:(BOOL)debug {
    if (debug) {
        kNASHost = NAS_HOST_DEBUG;
    } else {
        kNASHost = NAS_HOST;
    }
}

+ (NSDictionary *)contractWithSource:(NSString *)source
                       andSourceType:(NSString *)sourceType
                         andFunction:(NSString *)function
                             andArgs:(NSArray<NSString *> *)args {
    NSData *argsData = [NSJSONSerialization dataWithJSONObject:args options:0 error:nil];
    return @{
             @"source" : source ?: @"",
             @"sourceType" : sourceType ?: @"",
             @"function" : function ?: @"",
             @"args" : [[NSString alloc] initWithData:argsData encoding:NSUTF8StringEncoding]
             };
}

+ (NSNumber *)weiFromNas:(NSNumber *)nas {
    return @(1000000000000000000L * [nas doubleValue]);
}

+ (void)executeNetworkRequest:(NSURLRequest *)request
        withCompletionHandler:(void (^)(NSDictionary *data))handler
                 errorHandler:(void (^)(NSString *msg))errorHandler {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (errorHandler) {
                errorHandler(error.description);
            }
        } else {
            NSDictionary *resDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([resDict[@"error"] length] == 0) {
                if (handler) {
                    handler(resDict[@"result"]);
                }
            } else {
                if (errorHandler) {
                    errorHandler(resDict[@"error"]);
                }
            }
        }
    }];
    [sessionDataTask resume];
}

+ (NSURLRequest *)postRequestWithUrl:(NSURL *)url andData:(NSDictionary *)data {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
    [request addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    return request;
}

+ (void)fetchNebStateWithCompletionHandler:(void (^)(NSDictionary *data))handler
                              errorHandler:(void (^)(NSString *msg))errorHandler {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kNASHost, @"/v1/user/nebstate"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self executeNetworkRequest:request withCompletionHandler:handler errorHandler:errorHandler];
}

+ (void)fetchAccountState:(NSString *)address
                andHeight:(NSInteger)height
    withCompletionHandler:(void (^)(NSDictionary *data))handler
             errorHandler:(void (^)(NSString *msg))errorHandler {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kNASHost, @"/v1/user/accountstate"]];
    NSDictionary *dict = @{
                           @"address" : address ?: @"",
                           @"height" : @(height)
                           };
    [self executeNetworkRequest:[self postRequestWithUrl:url andData:dict]
          withCompletionHandler:handler
                   errorHandler:errorHandler];
}

+ (void)fetchLatestIrreversibleBlockWithCompletionHandler:(void (^)(NSDictionary *data))handler
                                             errorHandler:(void (^)(NSString *msg))errorHandler {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kNASHost, @"/v1/user/lib"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self executeNetworkRequest:request withCompletionHandler:handler errorHandler:errorHandler];
}

+ (void)callFuctionFrom:(NSString *)fromAddr
                     to:(NSString *)toAddr
              withValue:(NSNumber *)nas
               andNonce:(NSInteger)nonce
            andGasPrice:(NSNumber *)gasNas
            andGasLimit:(NSNumber *)gasNasLimit
            andContract:(NSDictionary *)contract
  withCompletionHandler:(void (^)(NSDictionary *data))handler
           errorHandler:(void (^)(NSString *msg))errorHandler {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kNASHost, @"/v1/user/call"]];
    NSDictionary *dict = @{
                           @"from" : fromAddr ?: @"",
                           @"to" : toAddr ?: @"",
                           @"value" : [NSString stringWithFormat:@"%.0f", [[self weiFromNas:nas] doubleValue]],
                           @"nonce" : @(nonce),
                           @"gasPrice" : [NSString stringWithFormat:@"%.0f", [[self weiFromNas:gasNas] doubleValue]],
                           @"gasLimit" : [NSString stringWithFormat:@"%.0f", [[self weiFromNas:gasNasLimit] doubleValue]],
                           @"contract" : contract ?: @{}
                           };
    [self executeNetworkRequest:[self postRequestWithUrl:url andData:dict]
          withCompletionHandler:handler
                   errorHandler:errorHandler];
}

+ (void)sendRawTransaction:(NSString *)data
     withCompletionHandler:(void (^)(NSDictionary *data))handler
              errorHandler:(void (^)(NSString *msg))errorHandler {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kNASHost, @"/v1/user/rawtransaction"]];
    NSDictionary *dict = @{
                           @"data" : data ?: @""
                           };
    [self executeNetworkRequest:[self postRequestWithUrl:url andData:dict]
          withCompletionHandler:handler
                   errorHandler:errorHandler];
}

+ (void)fetchBlockByHash:(NSString *)hash
     fullfillTransaction:(BOOL)fullfill
   withCompletionHandler:(void (^)(NSDictionary *data))handler
            errorHandler:(void (^)(NSString *msg))errorHandler {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kNASHost, @"/v1/user/getBlockByHash"]];
    NSDictionary *dict = @{
                           @"hash" : hash ?: @"",
                           @"full_fill_transaction" : fullfill ? @"true" : @"false"
                           };
    [self executeNetworkRequest:[self postRequestWithUrl:url andData:dict]
          withCompletionHandler:handler
                   errorHandler:errorHandler];
}

+ (void)fetchBlockByHeight:(NSInteger)height
       fullfillTransaction:(BOOL)fullfill
     withCompletionHandler:(void (^)(NSDictionary *data))handler
              errorHandler:(void (^)(NSString *msg))errorHandler {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kNASHost, @"/v1/user/getBlockByHeight"]];
    NSDictionary *dict = @{
                           @"height" : @(height),
                           @"full_fill_transaction" : fullfill ? @"true" : @"false"
                           };
    [self executeNetworkRequest:[self postRequestWithUrl:url andData:dict]
          withCompletionHandler:handler
                   errorHandler:errorHandler];
}

+ (void)fetchTransactionReceiptByHash:(NSString *)hash
                withCompletionHandler:(void (^)(NSDictionary *data))handler
                         errorHandler:(void (^)(NSString *msg))errorHandler {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kNASHost, @"/v1/user/getTransactionReceipt"]];
    NSDictionary *dict = @{
                           @"hash" : hash ?: @""
                           };
    [self executeNetworkRequest:[self postRequestWithUrl:url andData:dict]
          withCompletionHandler:handler
                   errorHandler:errorHandler];
}

+ (void)fetchTransactionByContract:(NSString *)address
             withCompletionHandler:(void (^)(NSDictionary *data))handler
                      errorHandler:(void (^)(NSString *msg))errorHandler {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kNASHost, @"/v1/user/getTransactionByContract"]];
    NSDictionary *dict = @{
                           @"address" : address ?: @""
                           };
    [self executeNetworkRequest:[self postRequestWithUrl:url andData:dict]
          withCompletionHandler:handler
                   errorHandler:errorHandler];
}

+ (void)fetchGasPriceWithCompletionHandler:(void (^)(NSDictionary *data))handler
                              errorHandler:(void (^)(NSString *msg))errorHandler {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kNASHost, @"/v1/user/getGasPrice"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self executeNetworkRequest:request withCompletionHandler:handler errorHandler:errorHandler];
}

+ (void)estimateGasFrom:(NSString *)fromAddr
                     to:(NSString *)toAddr
              withValue:(NSNumber *)nas
               andNonce:(NSInteger)nonce
            andGasPrice:(NSNumber *)gasNas
            andGasLimit:(NSNumber *)gasNasLimit
               contract:(NSDictionary *)contract
                 binary:(NSArray<NSNumber *> *)binary
  withCompletionHandler:(void (^)(NSDictionary *data))handler
           errorHandler:(void (^)(NSString *msg))errorHandler {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kNASHost, @"/v1/user/estimateGas"]];
    NSString *binaryString = nil;
    if (binary) {
        NSData *binaryData = [NSJSONSerialization dataWithJSONObject:binary options:0 error:nil];
        binaryString = [[NSString alloc] initWithData:binaryData encoding:NSUTF8StringEncoding];;
    }
    NSDictionary *dict = @{
                           @"from" : fromAddr ?: @"",
                           @"to" : toAddr ?: @"",
                           @"value" : [NSString stringWithFormat:@"%.0f", [[self weiFromNas:nas] doubleValue]],
                           @"nonce" : @(nonce),
                           @"gas_price" : [NSString stringWithFormat:@"%.0f", [[self weiFromNas:gasNas] doubleValue]],
                           @"gas_limit" : [NSString stringWithFormat:@"%.0f", [[self weiFromNas:gasNasLimit] doubleValue]],
                           @"contract" : contract ?: @{},
                           @"binary" : binaryString ?: @""
                           };
    [self executeNetworkRequest:[self postRequestWithUrl:url andData:dict]
          withCompletionHandler:handler
                   errorHandler:errorHandler];
}

+ (void)fetchEventByHash:(NSString *)hash
   withCompletionHandler:(void (^)(NSDictionary *data))handler
            errorHandler:(void (^)(NSString *msg))errorHandler {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kNASHost, @"/v1/user/getEventsByHash"]];
    NSDictionary *dict = @{
                           @"hash" : hash ?: @""
                           };
    [self executeNetworkRequest:[self postRequestWithUrl:url andData:dict]
          withCompletionHandler:handler
                   errorHandler:errorHandler];
}

+ (void)fetchDynasty:(NSInteger)height
withCompletionHandler:(void (^)(NSDictionary *data))handler
        errorHandler:(void (^)(NSString *msg))errorHandler {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kNASHost, @"/v1/user/dynasty"]];
    NSDictionary *dict = @{
                           @"height" : @(height)
                           };
    [self executeNetworkRequest:[self postRequestWithUrl:url andData:dict]
          withCompletionHandler:handler
                   errorHandler:errorHandler];
}

@end
