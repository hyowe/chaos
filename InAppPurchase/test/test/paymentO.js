var paymentJS = (function() {
    var payment = {};
                 
    payment.testOne = function(p1){
        return paymentOC.testOneParameter(p1);
    };


    payment.requestProducts = function() {
         return paymentOC.requestProducts();
    };

    payment.buyProduct = function() {
         return paymentOC.buyProduct();
    };
 
    return payment;
})();
