package com.sportx.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class BookingDTO {
    private String slotId;
    private String paymentMethod; // CARD, UPI, WALLET
}

