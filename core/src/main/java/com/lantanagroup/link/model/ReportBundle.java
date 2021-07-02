package com.lantanagroup.link.model;

import com.lantanagroup.link.model.Report;
import lombok.Getter;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
public class ReportBundle {

  String bundleId;
  List<Report> list = new ArrayList<>();

}