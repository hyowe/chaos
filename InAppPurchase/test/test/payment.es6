function sleep(timeout) {
    return new Promise((resolve, reject) => {
            setTimeout(function(){
                resolve();
            }, timeout);
    });
}

function test(p) {
    return new Promise((resolve, reject) => {
        if (p) {
            resolve('yes');
        } else {
            reject('no');
        }
    });
}

var paymentJS = (function() {
    var payment = {};
    payment.testOne = async function(p1){
        paymentOC.testOneParameter(p1);
        paymentOC.testOneParameter((new Date()).toString());
        await sleep(3000);
        paymentOC.testOneParameter((new Date()).toString());
        return "over";
    };
    payment.test = function(p1){
        test(true).then(function(m){
            paymentOC.testOneParameter(m);
        }, function(m){
            paymentOC.testOneParameter(m);
        });
        return "over";
    };

    payment.requestProducts = function() {
         return paymentOC.requestProducts();
    };

    payment.buyProduct = function() {
         return paymentOC.buyProduct();
    };
 
    return payment;
})();
