package com.sportx.config;

import com.sportx.dto.RegisterDTO;
import com.sportx.model.Admin;
import com.sportx.model.Player;
import com.sportx.model.User;
import com.sportx.model.VenueOwner;
import org.springframework.stereotype.Component;

import java.util.UUID;

/**
 * Factory Method Pattern — encapsulates user creation logic.
 * Controllers/Services never call "new Player()" directly.
 * Design Pattern: Creational — Factory Method
 */
@Component
public class UserFactory {

    public User createUser(RegisterDTO dto, String encodedPassword) {
        return switch (dto.getRole()) {
            case PLAYER -> buildPlayer(dto, encodedPassword);
            case VENUE_OWNER -> buildVenueOwner(dto, encodedPassword);
            case ADMIN -> buildAdmin(dto, encodedPassword);
        };
    }

    private Player buildPlayer(RegisterDTO dto, String encodedPassword) {
        Player player = new Player();
        populate(player, dto, encodedPassword);
        return player;
    }

    private VenueOwner buildVenueOwner(RegisterDTO dto, String encodedPassword) {
        VenueOwner owner = new VenueOwner();
        populate(owner, dto, encodedPassword);
        owner.setBusinessLicense(dto.getBusinessLicense());
        return owner;
    }

    private Admin buildAdmin(RegisterDTO dto, String encodedPassword) {
        Admin admin = new Admin();
        populate(admin, dto, encodedPassword);
        return admin;
    }

    private void populate(User user, RegisterDTO dto, String encodedPassword) {
        user.setUserId("USR-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase());
        user.setName(dto.getName());
        user.setEmail(dto.getEmail());
        user.setPhoneNumber(dto.getPhoneNumber());
        user.setPassword(encodedPassword);
    }
}

