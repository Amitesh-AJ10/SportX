package com.sportx.repository;

import com.sportx.model.Venue;
import com.sportx.model.enums.SportType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface VenueRepository extends JpaRepository<Venue, Long> {
    Optional<Venue> findByVenueId(String venueId);
    List<Venue> findByIsVerifiedTrue();
    List<Venue> findByCityContainingIgnoreCaseAndIsVerifiedTrue(String city);
    List<Venue> findByOwner_Id(Long ownerId);

    @Query("SELECT v FROM Venue v JOIN v.sportTypes s WHERE s = :sport AND v.isVerified = true")
    List<Venue> findBySportType(@Param("sport") SportType sport);

    @Query("SELECT v FROM Venue v JOIN v.sportTypes s WHERE " +
           "(:city IS NULL OR LOWER(v.city) LIKE LOWER(CONCAT('%', :city, '%'))) AND " +
           "(:sport IS NULL OR s = :sport) AND v.isVerified = true")
    List<Venue> searchVenues(@Param("city") String city, @Param("sport") SportType sport);
}

