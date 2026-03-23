package com.sportx.controller;

import com.sportx.model.Venue;
import com.sportx.model.enums.SportType;
import com.sportx.service.VenueService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * HomeController — public-facing pages.
 * MVC Role: Controller (C)
 */
@Controller
public class HomeController {

    @Autowired
    private VenueService venueService;

    @GetMapping("/")
    public String home(Model model) {
        List<Venue> featured = venueService.getAllVerified();
        model.addAttribute("venues", featured.stream().limit(6).toList());
        model.addAttribute("sportTypes", SportType.values());
        return "home";
    }

    @GetMapping("/venues")
    public String venues(@RequestParam(required = false) String city,
                         @RequestParam(required = false) SportType sport,
                         Model model) {
        List<Venue> venues = venueService.searchVenues(city, sport);
        model.addAttribute("venues", venues);
        model.addAttribute("sportTypes", SportType.values());
        model.addAttribute("selectedCity", city);
        model.addAttribute("selectedSport", sport);
        return "venues";
    }

    @GetMapping("/venues/{venueId}")
    public String venueDetail(@PathVariable String venueId, Model model) {
        Venue venue = venueService.findByVenueId(venueId)
                .orElseThrow(() -> new RuntimeException("Venue not found"));
        model.addAttribute("venue", venue);
        return "venue-detail";
    }
}

