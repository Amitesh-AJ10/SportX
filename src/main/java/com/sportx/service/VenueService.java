package com.sportx.service;

import com.sportx.dto.VenueDTO;
import com.sportx.model.Court;
import com.sportx.model.Slot;
import com.sportx.model.Venue;
import com.sportx.model.VenueOwner;
import com.sportx.model.enums.SportType;
import com.sportx.repository.CourtRepository;
import com.sportx.repository.SlotRepository;
import com.sportx.repository.VenueRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * VenueService — venue CRUD and search.
 * Design Pattern: Facade
 * Design Principle: SRP, OCP
 */
@Service
@Transactional
public class VenueService {

    @Autowired private VenueRepository venueRepository;
    @Autowired private CourtRepository courtRepository;
    @Autowired private SlotRepository slotRepository;

    public List<Venue> searchVenues(String city, SportType sport) {
        if ((city == null || city.isBlank()) && sport == null) {
            return venueRepository.findByIsVerifiedTrue();
        }
        return venueRepository.searchVenues(city, sport);
    }

    public List<Venue> getAllVerified() {
        return venueRepository.findByIsVerifiedTrue();
    }

    public List<Venue> getAllForAdmin() {
        return venueRepository.findAll();
    }

    public Optional<Venue> findByVenueId(String venueId) {
        return venueRepository.findByVenueId(venueId);
    }

    public Optional<Venue> findById(Long id) {
        return venueRepository.findById(id);
    }

    public List<Venue> findByOwner(Long ownerId) {
        return venueRepository.findByOwner_Id(ownerId);
    }

    public Venue createVenue(VenueDTO dto, VenueOwner owner) {
        Venue venue = new Venue();
        venue.setVenueId("VEN-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase());
        venue.setName(dto.getName());
        venue.setAddress(dto.getAddress());
        venue.setCity(dto.getCity());
        venue.setDescription(dto.getDescription());
        venue.setImageUrl(dto.getImageUrl() != null && !dto.getImageUrl().isBlank()
                ? dto.getImageUrl()
                : "https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800");
        venue.setSportTypes(dto.getSportTypes());
        venue.setOwner(owner);
        return venueRepository.save(venue);
    }

    public Venue verifyVenue(String venueId) {
        Venue venue = venueRepository.findByVenueId(venueId)
                .orElseThrow(() -> new RuntimeException("Venue not found"));
        venue.setVerified(true);
        return venueRepository.save(venue);
    }

    public Court addCourt(Long venueId, String courtName, SportType sport) {
        Venue venue = venueRepository.findById(venueId)
                .orElseThrow(() -> new RuntimeException("Venue not found"));
        Court court = new Court();
        court.setCourtId("CRT-" + UUID.randomUUID().toString().substring(0, 6).toUpperCase());
        court.setCourtName(courtName);
        court.setSport(sport);
        court.setVenue(venue);
        return courtRepository.save(court);
    }

    public List<Court> getCourtsForVenue(Long venueId) {
        return courtRepository.findByVenue_Id(venueId);
    }

    public List<Slot> getSlotsForCourt(Long courtId) {
        return slotRepository.findByCourt_Id(courtId);
    }

    public void deleteVenue(Long id) {
        venueRepository.deleteById(id);
    }
}

