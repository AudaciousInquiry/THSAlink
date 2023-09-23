package com.lantanagroup.link.tasks.helpers;

import lombok.Getter;
import lombok.Setter;
import org.springframework.context.annotation.Configuration;

import java.util.Calendar;

@Getter
@Setter
@Configuration
public class EndDateAdjuster extends DateAdjuster {
    protected void SetDateEdge() {
        super.SetDateEdge();
        if (dateEdge) {
            calendar.set(Calendar.HOUR_OF_DAY, 23);
            calendar.set(Calendar.MINUTE, 59);
            calendar.set(Calendar.SECOND, 59);
            calendar.set(Calendar.MILLISECOND, 0);
        }
    }
}