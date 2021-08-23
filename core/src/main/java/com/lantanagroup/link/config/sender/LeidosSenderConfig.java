package com.lantanagroup.link.config.sender;

import com.lantanagroup.link.config.YamlPropertySourceFactory;
import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;

import java.util.List;

@Getter @Setter
@Configuration
@ConfigurationProperties(prefix = "sender.leidos")
@PropertySource(value = "classpath:application.yml", factory = YamlPropertySourceFactory.class)
public class LeidosSenderConfig {
    /**
     * <strong>api.send-url</strong><br>The list of URLs to send reports to
     */
    private List<String> sendUrls;
}
