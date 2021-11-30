package com.lantanagroup.link.config.query;

import com.lantanagroup.link.config.YamlPropertySourceFactory;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.validator.constraints.URL;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;
import org.springframework.validation.annotation.Validated;

import javax.validation.constraints.*;

@Getter @Setter
@Configuration
@ConfigurationProperties(prefix = "query")
@Validated
@PropertySource(value = "classpath:application.yml", factory = YamlPropertySourceFactory.class)
public class QueryConfig {
  /**
   * <strong>query.fhir-server-base</strong><br>The base URL of the FHIR server that should be queried
   */
  @NotBlank @URL
  private String fhirServerBase;

  /**
   * <strong>query.api-key</strong><br>If running in a Remote scenario (<strong>api.query.mode == "Remote"</strong>), the API Key that the QueryAPI component should expect to allow requests.
   */
  @Size(min = 128)
  private String apiKey;

  /**
   * <strong>query.query-class</strong><br>The class to use for performing the queries.
   */
  @NotBlank
  private String queryClass;

  /**
   * <strong>query.allowed-remote</strong><br>If running in a Remote scenario (<strong>query.api.mode == "Remote"), a list of the IP addresses that are allowed to perform query requests. This is the immediate address of the device performing the request.</strong>
   */
  private String[] allowedRemote;

  /**
   * <strong>query.proxy-address</strong><br>If running in a Remote scenario where the query/agent is supported by a proxy such as NGINX, this is the host/ip address of the proxy.
   */
  private String proxyAddress;

  /**
   * <strong>query.auth-class</strong><br>The class that should be used (if any) to authenticate queries to the specified <strong>query.fhir-server-base</strong>.
   */
  private String authClass;
}
