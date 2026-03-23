package com.sportx.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Map;

/**
 * Context that selects the correct PaymentStrategy at runtime.
 * Design Pattern: Behavioral — Strategy (Context class)
 * Design Principle: OCP — new payment methods added without touching existing code.
 */
@Component
public class PaymentContext {

    private final Map<String, PaymentStrategy> strategies;

    @Autowired
    public PaymentContext(Map<String, PaymentStrategy> strategies) {
        this.strategies = strategies;
    }

    public String executePayment(String method, double amount) {
        PaymentStrategy strategy = switch (method.toUpperCase()) {
            case "UPI"    -> strategies.get("upiPayment");
            case "WALLET" -> strategies.get("walletPayment");
            default       -> strategies.get("cardPayment");
        };
        return strategy.pay(amount);
    }
}

