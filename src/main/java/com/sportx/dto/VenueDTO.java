package com.sportx.dto;

import com.sportx.model.enums.SportType;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class VenueDTO {
    @NotBlank(message = "Venue name is required")
    private String name;

    @NotBlank(message = "Address is required")
    private String address;

    @NotBlank(message = "City is required")
    private String city;

    private String description;
    private String imageUrl;
    private List<SportType> sportTypes;
}

