package com.lantanagroup.link.cli;

import com.jcraft.jsch.*;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Path;
import java.nio.file.Paths;

public class SftpDownloader {
  private final String username;
  private final String password;
  private final String host;
  private final int port;
  private final String knownHostsFilePath;
  private final String knownHostsString;
  private final String downloadFilePath;

  public SftpDownloader(SftpDownloaderConfig config) {
    username = config.getUsername();
    password = config.getPassword();
    host = config.getHost();
    port = config.getPort();
    knownHostsFilePath = config.getKnownHosts();
    downloadFilePath = SetPath(config.getPath(), config.getFileName());
    knownHostsString = null;
  }

  public SftpDownloader(SftpDownloaderConfig config, String knownHostsString) {
    this(config);
    knownHostsString = knownHostsString;
  }

  public byte[] download() throws IOException, JSchException, SftpException {
    JSch jSch = new JSch();

    // If knownHostsString contains data use that.  Otherwise, rely on
    // knownHostsFilePath to read in from a file.
    if (!(knownHostsString == null) && !knownHostsString.isEmpty() && !knownHostsString.isBlank()) {
      jSch.setKnownHosts(new ByteArrayInputStream(knownHostsString.getBytes()));
    } else {
      jSch.setKnownHosts(knownHostsFilePath);
    }

    Session session = jSch.getSession(username, host, port);
    session.setPassword(password);
    session.connect();
    try {
      ChannelSftp channel = (ChannelSftp) session.openChannel("sftp");
      channel.connect();
      try (InputStream stream = channel.get(downloadFilePath)) {
        return stream.readAllBytes();
      } finally {
        channel.exit();
      }
    } finally {
      session.disconnect();
    }
  }

  private String SetPath(String path, String fileName) {
    Path filePath = Paths.get(path);

    return String.valueOf(filePath.resolve(fileName));
  }
}
