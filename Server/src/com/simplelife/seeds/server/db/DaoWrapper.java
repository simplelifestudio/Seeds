/**
 * DaoWrapper.java 
 * 
 * History:
 *     2013-06-09: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */

package com.simplelife.seeds.server.db;

import org.hibernate.SQLQuery;
import org.hibernate.Session;

import com.simplelife.seeds.server.util.LogUtil;

import java.util.List;


public class DaoWrapper {
	public DaoWrapper()
	{
	}
	
	
	public static void executeSql(String sql)
	{
		if (sql == null || sql.length() == 0)
		{
			LogUtil.severe("Invalid SQL string: " + sql);
			return;
		}
		
		try
		{
			Session _session = HibernateSessionFactory.getCurrentSession();
			SQLQuery query = _session.createSQLQuery(sql); 
			query.executeUpdate();
		}
		catch(Exception e)
		{
			LogUtil.printStackTrace(e);
			//_logger.log(Level.SEVERE, "Error occurred when execute sql, error: " + e.getMessage() + ", sql: " + sql);
		}
	}
	
	public static boolean exists(String sql)
	{
		if (sql == null || sql.length() == 0)
		{
			LogUtil.severe("Invalid SQL string: " + sql);
			return false;
		}
		
		try
		{
			Session _session = HibernateSessionFactory.getCurrentSession();
			SQLQuery query = _session.createSQLQuery(sql); 
			return query.list().size() > 0;
		}
		catch(Exception e)
		{
			LogUtil.printStackTrace(e);
			//_logger.log(Level.SEVERE, "Error occurred when execute sql, error: " + e.getMessage() + ", sql: " + sql);
			return false;
		}

	}
	
	public static List query(String sql, Class objClass)
	{
		if (sql == null || sql.length() == 0)
		{
			LogUtil.severe("Invalid SQL string: " + sql);
			return null;
		}
		
	    try
	    {
		    Session _session = HibernateSessionFactory.getCurrentSession();
		    SQLQuery query = _session.createSQLQuery(sql).addEntity(objClass); 
	    	return query.list();
		}
		catch(Exception e)
		{
			LogUtil.printStackTrace(e);
			//_logger.log(Level.SEVERE, "Error occurred when execute sql, error: " + e.getMessage() + ", sql: " + sql);
			return null;
		}
	}
	
	public static void delete(Object obj)
	{
		try
		{
			Session _session = HibernateSessionFactory.getCurrentSession();
			_session.beginTransaction();
			_session.delete(obj);
			_session.getTransaction().commit();
		}
		catch(Exception e)
		{
			LogUtil.printStackTrace(e);
			//_logger.log(Level.SEVERE, "Error occurred when delete object from DB, error: " + e.getMessage() + ", obj: " + obj.toString());
		}

	}
	
	public static void save(Object obj)
	{
		try
		{
			Session _session = HibernateSessionFactory.getCurrentSession();	
			LogUtil.info("Start to save data to DB");
			_session.beginTransaction();
			_session.save(obj);
			_session.getTransaction().commit();
			LogUtil.info("Save data succeed");
		}
		catch(Exception e)
		{
			Session _session = HibernateSessionFactory.getCurrentSession();		
			_session.getTransaction().rollback();
			LogUtil.printStackTrace(e);
			//_logger.log(Level.SEVERE, "Error occurred when saving data to DB: " + e.getMessage());
			//_logger.log(Level.SEVERE, obj.toString());
		}
	}
}
