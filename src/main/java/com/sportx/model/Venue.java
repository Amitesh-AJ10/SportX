package com.sportx.model;

import com.sportx.model.enums.SportType;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

/**
 * Venue — a sports facility that contains multiple courts.
 */
@Entity
@Table(name = "venues")
@Getter
@Setter
@NoArgsConstructor
public class Venue {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true)
    private String venueId;

    @Column(nullable = false)
    private String name;

    private String address;

    private String city;

    private String imageUrl;

    private String description;

    private double avgRating = 0.0;

    private boolean isVerified = false;

    @ElementCollection(targetClass = SportType.class)
    @Enumerated(EnumType.STRING)
    @CollectionTable(name = "venue_sports", joinColumns = @JoinColumn(name = "venue_id"))
    @Column(name = "sport_type")
    private List<SportType> sportTypes = new ArrayList<>();

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id")
    private VenueOwner owner;

    @OneToMany(mappedBy = "venue", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Court> courts = new ArrayList<>();

    @OneToMany(mappedBy = "venue", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Review> reviews = new ArrayList<>();

    public String getDetails() {
        return String.format("Venue: %s at %s — Rating: %.1f", name, address, avgRating);
    }

    public void updateAvgRating() {
        if (reviews != null && !reviews.isEmpty()) {
            this.avgRating = reviews.stream()
                    .mapToInt(Review::getRating)
                    .average()
                    .orElse(0.0);
        }
    }
}

