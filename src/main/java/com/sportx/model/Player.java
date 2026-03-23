package com.sportx.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

/**
 * Player — can search venues, book slots, view history, rate venues.
 * Owns use cases: Search, Book, Cancel, History, Rate & Review
 */
@Entity
@DiscriminatorValue("PLAYER")
@Getter
@Setter
@NoArgsConstructor
public class Player extends User {

    @OneToMany(mappedBy = "player", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Booking> bookings = new ArrayList<>();

    @OneToMany(mappedBy = "player", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Review> reviews = new ArrayList<>();

    @Override
    public String getDashboardUrl() {
        return "/player/dashboard";
    }
}

