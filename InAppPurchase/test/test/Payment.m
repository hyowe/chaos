//
//  Payment.m
//  test
//
//  Created by iGOD on 16/5/5.
//  Copyright © 2016年 gamtee. All rights reserved.
//

#import "Payment.h"

@implementation Payment

- (NSString *)testOneParameter:(NSString *)message {
    NSLog(@"testOneParameter = %@", message);
    return @"testOneParameter";
}

- (NSString *)testTwo:(NSString *)message1 Parameter:(NSString *)meesage2 {
    NSLog(@"testTwoParameter = %@ %@", message1, meesage2);
    return @"tesTwoParameter";
}

//是否允许应用内付费
- (BOOL)canMakePay {
    return [SKPaymentQueue canMakePayments];
}

//初始化产品信息(非一次消费是否产品已经购买)
- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    if (self = [super init]) {
        self.productIdentifiers = productIdentifiers;
        NSMutableSet *purchsedProducts = [NSMutableSet set];
        
        //初始化js环境
        //self.js = [[JavaScriptCore alloc] initWithPath:@"test.js"];
        
        for (NSString *productIdentifier in self.productIdentifiers) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier]) {
                [purchsedProducts addObject:productIdentifier];
            }
        }
        self.purchasedProducts = purchsedProducts;
    }
    return self;
}

//请求查询iTunes Connect产品信息
- (void)requestProducts:(NSSet *)productIdentifiers {
    NSLog(@"------------请求产品信息-------------");
    
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    request.delegate = self;
    [request start];
}

//收到产品返回信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSLog(@"------------收到产品返回信息-------------");

    for (SKProduct *pro in response.products) {
        NSLog(@"SKProduct描述信息: %@", [pro description]);
        NSLog(@"产品标题: %@", pro.localizedTitle);
        NSLog(@"产品描述信息: %@", pro.localizedDescription);
        NSLog(@"产品价格: %@", pro.price);
        NSLog(@"product id: %@", pro.productIdentifier);
        
        NSLocale *storeLocale = pro.priceLocale;
        NSString *storeCountry = (NSString *)CFLocaleGetValue((CFLocaleRef)storeLocale, kCFLocaleCountryCode);
        NSLog(@"store country: %@", storeCountry);
    }
    NSLog(@"验证有效产品数量: %lu, 无法被识别的产品信息: %@", [response.products count], response.invalidProductIdentifiers);
    //返回到js
    [self.js call:@"productsRequest" WithArguments:response.products];
}

//为支付队列（payment queue）注册一个观察者对象
//在应用启动时添加一个交易队列观察者，原因是重启后程序会继续上次未完的交易，这时就添加观察者对象就不会漏掉之前的交易信息
//http://www.cocoachina.com/industry/20140818/9407.html

//发送购买产品请求
- (void)buyProduct:(SKProduct *)product {
    NSLog(@"------------请求购买产品-------------");
    
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

//发送购买产品请求,支持选择同一件商品的数量
- (void)buyProduct:(SKProduct *)product ByQuantity:(NSInteger)quantity {
    NSLog(@"------------请求购买产品-------------");
    
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    payment.quantity = quantity;
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

//收到产品购买结果
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

//交易成功的信息包含transactionIdentifier和transactionReceipt的属性。
//其中，transactionReceipt记录了支付的详细信息，这个信息可以帮助你跟踪、审(我们的)查交易
//如果用服务器来交付内容，transactionReceipt可以被传送到服务器，然后通过App Store验证交易
- (void) completeTransaction: (SKPaymentTransaction *)transaction {
    NSLog(@"------------产品购买成功-------------");
    //self.transaction = transaction;
    [self.js call:@"completeTransaction" WithArguments:@[transaction]];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
}

//服务器验证购买凭据
- (NSInteger)verifyReceipt:(NSURL *)url {
    //发送网络POST请求，对购买凭据进行验证, 国内访问苹果服务器比较慢，timeoutInterval需要长一点
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f];
    request.HTTPMethod = @"POST";
    //BASE64编码字符串
    //NSString *encodeStr = [self.transaction.transactionReceipt base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    NSString *encodeStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    //以JSON数据格式发送给App Store
    NSString *payload = [NSString stringWithFormat:@"{\"receipt-data\": \"%@\"}", encodeStr];
    request.HTTPBody = [payload dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    //提交验证请求，并获得官方的验证JSON结果
    //NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    __block NSData *result;
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request
                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                 result = data;
    }];
    [task resume];
    
    //结果验证
    NSInteger status = 1;
    if (result == nil) {
        NSLog(@"------------购买凭据验证失败-------------");
    } else {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:nil];
        if (dict != nil && [[dict objectForKey:@"status"] integerValue] == 0) {
            status = 0;
            NSLog(@"------------购买凭据验证成功-------------");
        } else {
            NSLog(@"------------购买凭据验证失败-------------");
        }
    }
    return status;
}

//恢复购买内容提供一个新的交易信息，这个信息包含了新的transaction的标识和receipt数据。
//如果需要的话，可以把这些信息单独保存下来，供追溯审查之用。
//但更多的情况下，在交易完成时，你可能需要覆盖原始的transaction数据，并使用其中的商品标识
- (void) restoreTransaction: (SKPaymentTransaction *)transaction {
    NSLog(@"------------产品已经购买过-------------");
    [self.js call:@"restoreTransaction" WithArguments:@[transaction]];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

//交易失败, 通常情况下，交易失败的原因是取消购买商品的流程, 可以从error中读出交易失败的详细信息。
- (void) failedTransaction: (SKPaymentTransaction *)transaction {
    NSLog(@"------------产品购买失败-------------");
    if (transaction.error.code == SKErrorPaymentCancelled)
    {
        NSLog(@"------------用户取消购买-------------");
    } else {
        NSInteger code = transaction.error.code;
        NSString *productIdentifier = transaction.payment.productIdentifier;
        switch (code) {
            case SKErrorUnknown:
                NSLog(@"Unknown Error (%ld), product: %@", (long)code, productIdentifier);
                break;
            case SKErrorClientInvalid:
                NSLog(@"Client invalid (%ld), product: %@", (long)code, productIdentifier);
                break;
            case SKErrorPaymentInvalid:
                NSLog(@"Payment invalid (%ld), product: %@", (long)code, productIdentifier);
                break;
            case SKErrorPaymentNotAllowed:
                NSLog(@"Payment not allowed (%ld), product: %@", (long)code, productIdentifier);
                break;
            default:
                break;
        }
    }
    [self.js call:@"failedTransaction" WithArguments:@[transaction]];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

@end
