package com.lantanagroup.link.cli;

import com.auth0.jwt.exceptions.JWTVerificationException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.jcraft.jsch.ChannelSftp;
import com.jcraft.jsch.SftpException;
import com.lantanagroup.link.auth.OAuth2Helper;
import com.lantanagroup.link.model.GenerateRequest;
import com.lantanagroup.link.model.UploadFile;
import org.apache.http.HttpHeaders;
import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.ByteArrayEntity;
import org.apache.http.entity.ContentType;
import org.apache.http.entity.StringEntity;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpEntity;
import org.springframework.shell.standard.ShellComponent;
import org.springframework.shell.standard.ShellMethod;
import org.springframework.shell.standard.ShellOption;
import java.text.SimpleDateFormat;
import java.util.*;

@ShellComponent
public class ParklandInventoryImportCommand extends BaseShellCommand {
  private static final Logger logger = LoggerFactory.getLogger(ParklandInventoryImportCommand.class);

  private ParklandInventoryImportConfig config;

  @ShellMethod(key = "parkland-inventory-import", value = "Download an inventory via SFTP and submit it to Link.")
  public void execute(String fileType, @ShellOption(defaultValue="") String fileName) {
    try {
      logger.info("Parkland Inventory Import ({}} Started", fileType);

      registerBeans();
      config = applicationContext.getBean(ParklandInventoryImportConfig.class);
      validate(config);
      logger.info("Configuration Validated");

      // Check to make sure the downloader & submissionInfo sections
      // exist for the fileType
      if (config.getDownloader().get(fileType) == null) {
        String errorMessage = String.format("parkland-inventory-import.downloader configuration for File Type '%s' is not available.", fileType);
        logger.error(errorMessage);
        throw new Exception(errorMessage);
      }
      if (config.getSubmissionInfo().get(fileType) == null) {
        String errorMessage = String.format("parkland-inventory-import.submission-info configuration for File Type '%s' is not available.", fileType);
        logger.error(errorMessage);
        throw new Exception(errorMessage);
      }

      // If specified file type is CSV, for parkland we need to know icu-identifers
      if (fileType.equals("csv") &&
              ((config.getSubmissionInfo().get(fileType).getIcuIdentifiers() == null) ||
                      (config.getSubmissionInfo().get(fileType).getIcuIdentifiers().length < 1))) {
        String errorMessage = String.format("parkland-inventory-import.submission-info configuration for File Type '%s' does not contain icu-identifiers.", fileType);
        logger.error(errorMessage);
        throw new Exception(errorMessage);
      }

      UploadFile uploadFile = new UploadFile();
      uploadFile.setType(fileType);
      uploadFile.setSource("parkland");

      // If csv set the options in UploadFile to have ICU Identifiers
      if (uploadFile.getType().equals("csv")) {
        Map<String, Object> icuCodes = new HashMap<>();
        icuCodes.put("icu-codes",
                Arrays.asList(config.getSubmissionInfo().get(fileType).getIcuIdentifiers())
        );
        uploadFile.setOptions(icuCodes);
        logger.info("ICU Facility Identifiers: {}", String.join(",",
                config.getSubmissionInfo().get(fileType).getIcuIdentifiers()));
      }

      // Set the name of the file to download
      String fileToDownload = getFileNameToDownload(uploadFile.getType(), fileName);
      uploadFile.setName(fileToDownload);
      config.getDownloader().get(uploadFile.getType()).setFileName(fileToDownload);
      logger.info("File to be downloaded: {}", fileToDownload);

      // Download file
      SftpDownloader downloader = new SftpDownloader(config.getDownloader().get(uploadFile.getType()));
      byte[] data = downloader.download();
      logger.info("File downloaded, byte size: {}", data.length);

      uploadFile.setContent(Base64.getEncoder().encodeToString(data));

      // Upload file to API
      sendDataToApi(uploadFile);
      logger.info("Data uploaded to API");

      logger.info("Parkland Inventory Import ({}} Completed", fileType);

    } catch (SftpException ex) {
      if (ex.id == ChannelSftp.SSH_FX_NO_SUCH_FILE) {
        logger.error("Attempted to download file that is not on server");
      }
    } catch (Exception ex) {
      logger.error("Parkland Inventory Import execute issue: {}", ex.getMessage());
      System.exit(1);
    }
    System.exit(0);
  }

  private void sendDataToApi(UploadFile uploadFile) throws Exception {
    try {
      String submissionUrl = config.getSubmissionInfo().get(uploadFile.getType()).getSubmissionUrl();
      logger.info("Submitting data to API, url: {}", submissionUrl);

      HttpPost request = new HttpPost(submissionUrl);
      request.addHeader(HttpHeaders.CONTENT_TYPE, ContentType.APPLICATION_JSON.toString());

      String token = OAuth2Helper.getToken(config.getSubmissionInfo().get(uploadFile.getType()).getSubmissionAuth());
      if (OAuth2Helper.validateHeaderJwtToken(token)) {
        request.addHeader(HttpHeaders.AUTHORIZATION, String.format("Bearer %s", token));
      } else {
        throw new JWTVerificationException("Invalid token format");
      }

      ObjectMapper mapper = new ObjectMapper();
      String payloadJson = mapper.writeValueAsString(uploadFile);
      request.setEntity(new StringEntity(payloadJson));

      HttpResponse response = Utility.HttpExecutor(request);

      logger.info("HTTP Response Code {}", response.getStatusLine().getStatusCode());

    } catch (Exception ex) {
      logger.error("Issue with data submission to API: {}", ex.getMessage());
      throw ex;
    }

  }

  private String getFileNameToDownload(String fileType, String fileName) {
        /* The Parkland server path will have Excel files named by day.  So...
      2023-06-04.xlsx
      2023-06-05.xlsx
      etc...

      CSV files will be named like:

      THSA_Saner_Bed_List20230908.csv

      One can run the command and specify a filename, but if that is blank, here we
      will default to the current date.
     */
    if (fileName == null || fileName.trim().isEmpty()){
      if (fileType.equals("csv")) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
        String today = sdf.format(new Date());
        fileName = String.format("THSA_Saner_Bed_List%s.%s", today, fileType);
      } else if (fileType.equals("xlsx")) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        String today = sdf.format(new Date());
        fileName = String.format("%s.%s", today, fileType);
      }
    }

    return fileName;
  }
}
