package com.lantanagroup.link.tasks;

import com.opencsv.CSVReaderHeaderAware;
import com.opencsv.CSVWriter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

public class ParklandBedCountCsvConverter {

    private static final Logger logger = LoggerFactory.getLogger(ParklandBedCountCsvConverter.class);

    private static byte[] CreateBedInventoryCsv(int totalBeds, int icuBeds) throws Exception {
        /*
            The headers for the file that the /api/data/csv API endpoint accepts:

            numTotBedsOcc,numTotBedsAvail,numTotBeds,numICUBedsOcc,numICUBedsAvail,numICUBeds,numVentUse,numVentAvail,numVent

            This is what we are going to re-create.
        */

        logger.info("Creating Bed Inventory CSV - Total Beds: {}, Total ICU Beds: {}", totalBeds, icuBeds);

        StringWriter stringWriter = new StringWriter();

        try (CSVWriter writer = new CSVWriter(stringWriter)) {

            //Array of header
            String[] header = { "numTotBedsOcc",
                    "numTotBedsAvail",
                    "numTotBeds",
                    "numICUBedsOcc",
                    "numICUBedsAvail",
                    "numICUBeds",
                    "numVentUse",
                    "numVentAvail",
                    "numVent" };
            writer.writeNext(header);

            //Array of data
            String[] data = { "0", "0", String.valueOf(totalBeds), "0", "0", String.valueOf(icuBeds), "0", "0", "0" };

            //Writing data
            writer.writeNext(data);

            String csvContent = stringWriter.toString();
            ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
            byteArrayOutputStream.writeBytes(csvContent.getBytes());

            return byteArrayOutputStream.toByteArray();

        } catch (IOException ex) {
            logger.error("Issue creating Bed Inventory CSV: {}", ex.getMessage());
            throw ex;
        }
    }

    public static byte[] ConvertParklandBedCsv(byte[] csvData, String[] icuSpecialFacs) throws Exception {
        try {
            logger.info("Parkland Bed CSV Conversion - Started");
            InputStream contentStream = new ByteArrayInputStream(csvData);
            Reader reader = new InputStreamReader(contentStream);
            CSVReaderHeaderAware csvReader = new CSVReaderHeaderAware(reader);

            logger.info("ICU Facility Identifiers: {}", String.join(",", icuSpecialFacs));
            List<String> icuIdentifiersList = new ArrayList<>();
            if (icuSpecialFacs.length > 0) {
                icuIdentifiersList = Arrays.asList(icuSpecialFacs);
            }

            int totalRecords=0;
            int icuRecords=0;

            Map<String,String> record;
            while ( (record = csvReader.readMap()) != null) {
                totalRecords++;
                if (icuIdentifiersList.contains(record.get("Special Facs"))) {
                    icuRecords++;
                }
            }

            logger.info("Total Records: {}", totalRecords);
            logger.info("Total ICU Records: {}", icuRecords);

            logger.info("Parkland Bed CSV Conversion - Completed");

            return CreateBedInventoryCsv( (totalRecords - icuRecords), icuRecords);
        } catch (Exception ex) {
            logger.error("Issue converting Parkland bed CSV file: {}", ex.getMessage());
            throw ex;
        }
    }
}
