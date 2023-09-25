package com.lantanagroup.link.cli;

import com.lantanagroup.link.config.YamlPropertySourceFactory;
import com.lantanagroup.link.config.auth.LinkOAuthConfig;
import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;
import org.springframework.validation.annotation.Validated;

import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;

@Getter
@Setter
@Configuration
@ConfigurationProperties(prefix = "cli.generate-and-submit")
@Validated
@PropertySource(value = "classpath:application.yml", factory = YamlPropertySourceFactory.class)
public class OldGenerateAndSubmitConfig {

  private String apiUrl;
  private OldGenerateAndSubmitPeriodStart periodStart;
  private OldGenerateAndSubmitPeriodEnd periodEnd;
  private LinkOAuthConfig auth;
  @NotNull
  @Size(min = 1)
  private String[] bundleIds;
}

@Getter
@Setter
class OldGenerateAndSubmitPeriodStart {

  private int adjustDay;
  private int adjustMonth;
  private boolean startOfDay;
}

@Getter
@Setter
class OldGenerateAndSubmitPeriodEnd {

  private int adjustDay;
  private int adjustMonth;
  private boolean endOfDay;
}
