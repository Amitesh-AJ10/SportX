package com.sportx.config;

import org.springframework.stereotype.Component;

/**
 * Concrete Strategy: Card Payment
 */
@Component("cardPayment")
class CardPaymentStrategy implements PaymentStrategy {
    @Override
    public String pay(double amount) {
        return "CARD-TXN-" + System.currentTimeMillis();
    }

    @Override
    public String getMethodName() { return "CARD"; }
}

/**
 * Concrete Strategy: UPI Payment
 */
@Component("upiPayment")
class UpiPaymentStrategy implements PaymentStrategy {
    @Override
    public String pay(double amount) {
        return "UPI-TXN-" + System.currentTimeMillis();
    }

    @Override
    public String getMethodName() { return "UPI"; }
}

/**
 * Concrete Strategy: Wallet Payment
 */
@Component("walletPayment")
class WalletPaymentStrategy implements PaymentStrategy {
    @Override
    public String pay(double amount) {
        return "WALLET-TXN-" + System.currentTimeMillis();
    }

    @Override
    public String getMethodName() { return "WALLET"; }
}

