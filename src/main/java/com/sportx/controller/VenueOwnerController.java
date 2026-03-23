package com.sportx.controller;

import com.sportx.dto.SlotDTO;
import com.sportx.dto.VenueDTO;
import com.sportx.model.*;
import com.sportx.model.enums.SportType;
import com.sportx.service.*;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

/**
 * VenueOwnerController — manage venues, courts, slots, bookings, reports.
 * MVC Role: Controller (C)
 * Owns use cases: Add/Update Venue, Manage Slots & Pricing, Manage Bookings, View Reports
 */
@Controller
@RequestMapping("/owner")
public class VenueOwnerController {

    @Autowired private UserService userService;
    @Autowired private VenueService venueService;
    @Autowired private BookingService bookingService;
    @Autowired private SlotService slotService;

    private VenueOwner getCurrentOwner(UserDetails userDetails) {
        return (VenueOwner) userService.findByEmail(userDetails.getUsername())
                .orElseThrow(() -> new RuntimeException("Owner not found"));
    }

    /* ── Dashboard ── */
    @GetMapping("/dashboard")
    public String dashboard(@AuthenticationPrincipal UserDetails userDetails, Model model) {
        VenueOwner owner = getCurrentOwner(userDetails);
        List<Venue> venues = venueService.findByOwner(owner.getId());
        long totalBookings = venues.stream()
                .mapToLong(v -> bookingService.countVenueBookings(v.getId()))
                .sum();

        model.addAttribute("owner", owner);
        model.addAttribute("venues", venues);
        model.addAttribute("totalBookings", totalBookings);
        return "venueowner/dashboard";
    }

    /* ── Add Venue ── */
    @GetMapping("/venue/add")
    public String addVenuePage(Model model) {
        model.addAttribute("venueDTO", new VenueDTO());
        model.addAttribute("sportTypes", SportType.values());
        return "venueowner/add-venue";
    }

    @PostMapping("/venue/add")
    public String addVenue(@Valid @ModelAttribute("venueDTO") VenueDTO dto,
                            BindingResult result,
                            @AuthenticationPrincipal UserDetails userDetails,
                            Model model,
                            RedirectAttributes redirectAttributes) {
        if (result.hasErrors()) {
            model.addAttribute("sportTypes", SportType.values());
            return "venueowner/add-venue";
        }
        VenueOwner owner = getCurrentOwner(userDetails);
        Venue venue = venueService.createVenue(dto, owner);
        redirectAttributes.addFlashAttribute("successMsg",
                "Venue '" + venue.getName() + "' submitted for admin verification.");
        return "redirect:/owner/dashboard";
    }

    /* ── Venue Courts ── */
    @GetMapping("/venue/{venueId}/courts")
    public String manageCourts(@PathVariable String venueId, Model model) {
        Venue venue = venueService.findByVenueId(venueId)
                .orElseThrow(() -> new RuntimeException("Venue not found"));
        model.addAttribute("venue", venue);
        model.addAttribute("courts", venueService.getCourtsForVenue(venue.getId()));
        model.addAttribute("sportTypes", SportType.values());
        return "venueowner/courts";
    }

    @PostMapping("/venue/{venueId}/court/add")
    public String addCourt(@PathVariable String venueId,
                            @RequestParam String courtName,
                            @RequestParam SportType sport,
                            RedirectAttributes redirectAttributes) {
        Venue venue = venueService.findByVenueId(venueId)
                .orElseThrow(() -> new RuntimeException("Venue not found"));
        venueService.addCourt(venue.getId(), courtName, sport);
        redirectAttributes.addFlashAttribute("successMsg", "Court added successfully.");
        return "redirect:/owner/venue/" + venueId + "/courts";
    }

    /* ── Manage Slots ── */
    @GetMapping("/court/{courtId}/slots")
    public String manageSlots(@PathVariable Long courtId, Model model) {
        model.addAttribute("slots", slotService.getAvailableSlots(courtId));
        model.addAttribute("courtId", courtId);
        model.addAttribute("slotDTO", new SlotDTO());
        return "venueowner/slots";
    }

    @PostMapping("/slot/add")
    public String addSlot(@ModelAttribute SlotDTO dto, RedirectAttributes redirectAttributes) {
        slotService.createSlot(dto);
        redirectAttributes.addFlashAttribute("successMsg", "Slot created successfully.");
        return "redirect:/owner/court/" + dto.getCourtId() + "/slots";
    }

    @PostMapping("/slot/block/{slotId}")
    public String blockSlot(@PathVariable String slotId,
                             @RequestParam Long courtId,
                             RedirectAttributes redirectAttributes) {
        slotService.blockSlot(slotId);
        redirectAttributes.addFlashAttribute("successMsg", "Slot blocked.");
        return "redirect:/owner/court/" + courtId + "/slots";
    }

    /* ── Manage Bookings ── */
    @GetMapping("/venue/{venueId}/bookings")
    public String manageBookings(@PathVariable String venueId, Model model) {
        Venue venue = venueService.findByVenueId(venueId)
                .orElseThrow(() -> new RuntimeException("Venue not found"));
        model.addAttribute("venue", venue);
        model.addAttribute("bookings", bookingService.getVenueBookings(venue.getId()));
        return "venueowner/bookings";
    }

    /* ── View Reports ── */
    @GetMapping("/venue/{venueId}/reports")
    public String viewReports(@PathVariable String venueId, Model model) {
        Venue venue = venueService.findByVenueId(venueId)
                .orElseThrow(() -> new RuntimeException("Venue not found"));
        List<Booking> bookings = bookingService.getVenueBookings(venue.getId());
        double revenue = bookings.stream()
                .filter(b -> b.getStatus().name().equals("CONFIRMED") ||
                             b.getStatus().name().equals("COMPLETED"))
                .mapToDouble(Booking::getTotalAmount)
                .sum();

        model.addAttribute("venue", venue);
        model.addAttribute("bookings", bookings);
        model.addAttribute("totalRevenue", revenue);
        model.addAttribute("totalBookings", bookings.size());
        return "venueowner/reports";
    }
}

