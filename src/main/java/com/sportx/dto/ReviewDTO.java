package com.sportx.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ReviewDTO {
    private String venueId;

    @Min(1) @Max(5)
    private int rating;

    private String comment;
}

