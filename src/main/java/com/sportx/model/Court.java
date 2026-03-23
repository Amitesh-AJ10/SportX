package com.sportx.model;

import com.sportx.model.enums.SportType;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Court — a specific playable area within a Venue for a particular sport.
 */
@Entity
@Table(name = "courts")
@Getter
@Setter
@NoArgsConstructor
public class Court {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String courtId;

    @Column(nullable = false)
    private String courtName;

    @Enumerated(EnumType.STRING)
    private SportType sport;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "venue_id")
    private Venue venue;

    @OneToMany(mappedBy = "court", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Slot> slots = new ArrayList<>();

    public List<Slot> getAvailableSlots(LocalDate date) {
        return slots.stream()
                .filter(s -> s.getStartTime().toLocalDate().equals(date)
                        && s.getStatus().name().equals("AVAILABLE"))
                .collect(Collectors.toList());
    }
}

