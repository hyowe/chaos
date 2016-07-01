//
//  Payment.h
//  test
//
//  Created by iGOD on 16/5/5.
//  Copyright © 2016年 gamtee. All rights reserved.
//

#import "JavaScriptCore.h"
#import <StoreKit/StoreKit.h>
#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol PaymentProtocol <JSExport>

- (NSString *)testOneParameter:(NSString *)message;
- (NSString *)testTwo:(NSString *)message1 Parameter:(NSString *)meesage2;


- (BOOL)canMakePay;
- (void)requestProducts:(NSSet *)productIdentifiers;
- (void)buyProduct:(SKProduct *)product;
- (void)buyProduct:(SKProduct *)product ByQuantity:(NSInteger)quantity;
- (NSInteger)verifyReceipt:(NSURL *)url;
@end


@interface Payment : NSObject<PaymentProtocol, SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property JavaScriptCore *js;
@property NSSet *productIdentifiers;
@property NSMutableSet *purchasedProducts;
@property SKPaymentTransaction *transaction;

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void) completeTransaction: (SKPaymentTransaction *)transaction;
- (void) restoreTransaction: (SKPaymentTransaction *)transaction;
- (void) failedTransaction: (SKPaymentTransaction *)transaction;
@end
