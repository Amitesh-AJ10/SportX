package com.sportx.config;

import com.sportx.dto.RegisterDTO;
import com.sportx.model.*;
import com.sportx.model.enums.SlotStatus;
import com.sportx.model.enums.SportType;
import com.sportx.model.enums.UserRole;
import com.sportx.repository.*;
import com.sportx.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * Seeds initial demo data on application startup.
 */
@Component
public class DataInitializer implements CommandLineRunner {

    @Autowired private UserService userService;
    @Autowired private VenueRepository venueRepository;
    @Autowired private CourtRepository courtRepository;
    @Autowired private SlotRepository slotRepository;
    @Autowired private UserRepository userRepository;

    @Override
    public void run(String... args) {
        seedUsers();
        seedVenues();
    }

    private void seedUsers() {
        // Admin
        RegisterDTO admin = new RegisterDTO();
        admin.setName("SportX Admin");
        admin.setEmail("admin@sportx.com");
        admin.setPassword("admin123");
        admin.setPhoneNumber("9000000001");
        admin.setRole(UserRole.ADMIN);
        userService.register(admin);

        // Venue Owner
        RegisterDTO owner = new RegisterDTO();
        owner.setName("Rahul Sports");
        owner.setEmail("owner@sportx.com");
        owner.setPassword("owner123");
        owner.setPhoneNumber("9000000002");
        owner.setRole(UserRole.VENUE_OWNER);
        owner.setBusinessLicense("LIC-2024-SPORT");
        userService.register(owner);

        // Player
        RegisterDTO player = new RegisterDTO();
        player.setName("Aditya Kumar");
        player.setEmail("player@sportx.com");
        player.setPassword("player123");
        player.setPhoneNumber("9000000003");
        player.setRole(UserRole.PLAYER);
        userService.register(player);
    }

    private void seedVenues() {
        VenueOwner owner = (VenueOwner) userRepository.findByEmail("owner@sportx.com").orElseThrow();

        // Venue 1: Badminton
        Venue v1 = new Venue();
        v1.setVenueId("VEN-DEMO001");
        v1.setName("Champions Badminton Academy");
        v1.setAddress("12 MG Road");
        v1.setCity("Bangalore");
        v1.setDescription("State-of-the-art badminton courts with synthetic flooring and LED lighting.");
        v1.setImageUrl("https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=800");
        v1.setSportTypes(List.of(SportType.BADMINTON));
        v1.setVerified(true);
        v1.setAvgRating(4.5);
        v1.setOwner(owner);
        venueRepository.save(v1);
        addCourtsAndSlots(v1, "Badminton Court A", SportType.BADMINTON, 400.0);

        // Venue 2: Football
        Venue v2 = new Venue();
        v2.setVenueId("VEN-DEMO002");
        v2.setName("Goal Zone Football Arena");
        v2.setAddress("45 Whitefield");
        v2.setCity("Bangalore");
        v2.setDescription("5-a-side and 7-a-side turf football grounds with floodlights.");
        v2.setImageUrl("https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800");
        v2.setSportTypes(List.of(SportType.FOOTBALL));
        v2.setVerified(true);
        v2.setAvgRating(4.2);
        v2.setOwner(owner);
        venueRepository.save(v2);
        addCourtsAndSlots(v2, "Turf Ground 1", SportType.FOOTBALL, 1200.0);

        // Venue 3: Tennis
        Venue v3 = new Venue();
        v3.setVenueId("VEN-DEMO003");
        v3.setName("Ace Tennis Club");
        v3.setAddress("7 Koramangala");
        v3.setCity("Bangalore");
        v3.setDescription("Professional clay and hard courts, open year-round.");
        v3.setImageUrl("https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?w=800");
        v3.setSportTypes(List.of(SportType.TENNIS));
        v3.setVerified(true);
        v3.setAvgRating(4.7);
        v3.setOwner(owner);
        venueRepository.save(v3);
        addCourtsAndSlots(v3, "Court 1 (Clay)", SportType.TENNIS, 600.0);

        // Venue 4: Cricket
        Venue v4 = new Venue();
        v4.setVenueId("VEN-DEMO004");
        v4.setName("SixerBox Cricket Arena");
        v4.setAddress("22 Indiranagar");
        v4.setCity("Bangalore");
        v4.setDescription("Box cricket ground with pitch, nets, and scoreboard.");
        v4.setImageUrl("https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=800");
        v4.setSportTypes(List.of(SportType.CRICKET));
        v4.setVerified(true);
        v4.setAvgRating(4.3);
        v4.setOwner(owner);
        venueRepository.save(v4);
        addCourtsAndSlots(v4, "Box Cricket Pitch 1", SportType.CRICKET, 2000.0);
    }

    private void addCourtsAndSlots(Venue venue, String courtName, SportType sport, double price) {
        Court court = new Court();
        court.setCourtId("CRT-" + UUID.randomUUID().toString().substring(0, 6).toUpperCase());
        court.setCourtName(courtName);
        court.setSport(sport);
        court.setVenue(venue);
        courtRepository.save(court);

        // Create slots for today and next 3 days
        LocalDateTime base = LocalDateTime.now().toLocalDate().atTime(6, 0);
        for (int day = 0; day < 4; day++) {
            for (int hour = 0; hour < 12; hour++) {
                Slot slot = new Slot();
                slot.setSlotId("SLT-" + UUID.randomUUID().toString().substring(0, 6).toUpperCase());
                slot.setStartTime(base.plusDays(day).plusHours(hour));
                slot.setEndTime(base.plusDays(day).plusHours(hour + 1));
                slot.setPrice(price);
                slot.setStatus(SlotStatus.AVAILABLE);
                slot.setCourt(court);
                slotRepository.save(slot);
            }
        }
    }
}

