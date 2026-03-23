package com.sportx.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

/**
 * VenueOwner — manages venues, courts, slots, views reports.
 * Owns use cases: Add Venue, Manage Slots & Pricing, Manage Bookings, View Reports
 */
@Entity
@DiscriminatorValue("VENUE_OWNER")
@Getter
@Setter
@NoArgsConstructor
public class VenueOwner extends User {

    private String businessLicense;

    @OneToMany(mappedBy = "owner", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Venue> venues = new ArrayList<>();

    @Override
    public String getDashboardUrl() {
        return "/owner/dashboard";
    }

    public void addVenue(Venue venue) {
        venue.setOwner(this);
        this.venues.add(venue);
    }
}

