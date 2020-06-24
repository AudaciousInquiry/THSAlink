package com.lantanagroup.nandina;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.core.env.MapPropertySource;
import org.springframework.core.env.PropertySource;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.support.EncodedResource;
import org.springframework.core.io.support.PropertySourceFactory;

import java.io.IOException;
import java.util.Map;

public class JsonPropertySourceFactory implements PropertySourceFactory {

    @Override
    public PropertySource<?> createPropertySource(String name, EncodedResource resource) throws IOException {
        String localConfig = System.getProperty("config");
        Map readValue = null;
        if (null != localConfig) {
            EncodedResource localResource = new EncodedResource(new ClassPathResource(localConfig));
            readValue = new ObjectMapper().readValue(localResource.getInputStream(), Map.class);
        } else {
            readValue = new ObjectMapper().readValue(resource.getInputStream(), Map.class);
        }

        return new MapPropertySource("json-property", readValue);
    }
}