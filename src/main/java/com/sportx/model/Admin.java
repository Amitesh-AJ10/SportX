package com.sportx.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

/**
 * Admin — verifies venues, manages users.
 * Owns use cases: Verify Venue/Partner, Manage Users
 */
@Entity
@DiscriminatorValue("ADMIN")
@Getter
@Setter
@NoArgsConstructor
public class Admin extends User {

    @Override
    public String getDashboardUrl() {
        return "/admin/dashboard";
    }

    public void verifyVenue(String venueId) {
        // Delegated to AdminService
    }

    public void manageUsers(String userId) {
        // Delegated to AdminService
    }
}

