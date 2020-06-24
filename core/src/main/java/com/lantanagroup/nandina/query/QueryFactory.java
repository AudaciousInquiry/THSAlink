package com.lantanagroup.nandina.query;

import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;

import com.lantanagroup.nandina.JsonProperties;
import com.lantanagroup.nandina.query.fhir.r4.AbstractQuery;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.lantanagroup.nandina.IConfig;

import ca.uhn.fhir.rest.client.api.IGenericClient;

public class QueryFactory {
	
	protected static HashMap<String, AbstractQuery> existingInstances = new HashMap<String,AbstractQuery>();
	protected static final Logger logger = LoggerFactory.getLogger(QueryFactory.class);
	protected static final int CACHE_MINUTES = 1; // TODO: move this to the config file at some point
	
	public static AbstractQuery newInstance(String className, JsonProperties jsonProperties, IGenericClient fhirClient, Map<String, String> criteria) throws ClassNotFoundException, NoSuchMethodException, SecurityException, InstantiationException, IllegalAccessException, IllegalArgumentException, InvocationTargetException {
		AbstractQuery query = null;
		if (existingInstances.containsKey(className)) {
			query = getCachedQuery(className, jsonProperties, fhirClient, criteria);
		} else {
			query = createNewQueryInstance(className, jsonProperties, fhirClient, criteria);
		}
		return query;
	}

	private static AbstractQuery getCachedQuery(String className, JsonProperties jsonProperties, IGenericClient fhirClient, Map<String, String> criteria) throws ClassNotFoundException, NoSuchMethodException, InstantiationException, IllegalAccessException, InvocationTargetException {
		AbstractQuery query;
		query = existingInstances.get(className + criteria.toString());
		Calendar expired = Calendar.getInstance();
		expired.setTime(query.dateCreated.getTime());
		expired.roll(Calendar.MINUTE, CACHE_MINUTES);
		Calendar now = Calendar.getInstance();
		if (now.after(expired)) {
			query = createNewQueryInstance(className, jsonProperties, fhirClient, criteria);
		} else {
			logger.info("Returning cached query object: " + className);
		}
		return query;
	}

	private static AbstractQuery createNewQueryInstance(String className, JsonProperties jsonProperties, IGenericClient fhirClient, Map<String, String> criteria)
			throws ClassNotFoundException, NoSuchMethodException, InstantiationException, IllegalAccessException,
			InvocationTargetException {
		AbstractQuery query;
		logger.info("Creating new query object: " + className);
		Class<?> queryClass = Class.forName(className);
		Constructor<?> queryConstructor = queryClass.getConstructor(JsonProperties.class, IGenericClient.class, HashMap.class);
		query = (AbstractQuery) queryConstructor.newInstance(jsonProperties, fhirClient, criteria);
		existingInstances.put(className+criteria.toString(), query);
		return query;
	}

}
