/**
 * DaoWrapper.java 
 * 
 * History:
 *     2013-06-09: Tomas Chen, initial version
 * 
 * Copyright (c) 2013 SimpleLife Studio. All rights reserved.
 */

package com.simplelife.seeds.server.util;

import org.hibernate.SQLQuery;
import org.hibernate.Session;
import org.hibernate.Transaction;


import java.util.List;

public class DaoWrapper {
	
	public DaoWrapper()
	{
	}
	
	/**
	 * Execute given SQL string
	 * @param sql: SQL string
	 * @return true normally, else false if any error occurred or invalid SQL string
	 */
	public static boolean executeSql(String sql)
	{
		if (sql == null || sql.length() == 0)
		{
			LogUtil.severe("Invalid SQL string: " + sql);
			return false;
		}
		
		Session session = HibernateSessionFactory.getCurrentSession();
		if (session == null)
		{
			LogUtil.severe("Null hibernate session, check DB parameters");
			return false;
		}
		
		try
		{
			session.beginTransaction();
			SQLQuery query = session.createSQLQuery(sql);
			query.executeUpdate();
			session.getTransaction().commit();
			session.clear();
			return true;
		}
		catch(Exception e)
		{
		    LogUtil.severe(sql);
			LogUtil.printStackTrace(e);
			if (session.getTransaction() != null)
			{
				session.getTransaction().rollback();
			}
			return false;
		}
		finally
		{
			HibernateSessionFactory.closeCurrentSession();
		}
	}
	
	/**
	 * Check if records existent by query of given SQL string
	 * @param sql: SQL string
	 * @return nonExistent, existent or errorOccurred
	 */
	public static int exists(String sql)
	{
		if (sql == null || sql.length() == 0)
		{
			LogUtil.severe("Invalid SQL string: " + sql);
			return DBExistResult.nonExistent;
		}
		
		Session session = HibernateSessionFactory.getCurrentSession();
		if (session == null)
		{
			LogUtil.severe("Null hibernate session, check DB parameters");
			return DBExistResult.errorOccurred;
		}
		
		try
		{
			SQLQuery query = session.createSQLQuery(sql); 
			if (query.list().size() > 0)
			{
				return DBExistResult.existent;
			}
			else
			{
				return DBExistResult.nonExistent;
			}
		}
		catch(Exception e)
		{
		    LogUtil.severe(sql);
			LogUtil.printStackTrace(e);
			return DBExistResult.errorOccurred;
		}
		finally
		{
			HibernateSessionFactory.closeCurrentSession();
		}
	}
	
	/**
	 * Make query by given SQL string
	 * @param sql: SQL string
	 * @param objClass: class definition for mapping of return records
	 * @return List of objects
	 */
	public static List query(String sql, Class objClass)
	{
		if (sql == null || sql.length() == 0)
		{
			LogUtil.severe("Invalid SQL string: " + sql);
			return null;
		}
		
		Session session = HibernateSessionFactory.getCurrentSession();
	    if (session == null)
		{
			LogUtil.severe("Null hibernate session, check DB parameters");
			return null;
		}
	    
	    try
	    {
		    SQLQuery query = session.createSQLQuery(sql).addEntity(objClass); 
	    	return query.list();
		}
		catch(Exception e)
		{
		    LogUtil.severe(sql);
			LogUtil.printStackTrace(e);
			return null;
		}
	    finally
		{
			HibernateSessionFactory.closeCurrentSession();
		}
	}
	
	/**
	 * Delete record in DB by given object
	 * @param obj: object to be deleted
	 */
	public static void delete(Object obj)
	{
		Session session = HibernateSessionFactory.getCurrentSession();
		if (session == null)
		{
			LogUtil.severe("Null hibernate session, check DB parameters");
			return;
		}
		
		try
		{
			session.beginTransaction();
			session.delete(obj);
			session.getTransaction().commit();
		}
		catch(Exception e)
		{
			if (session.getTransaction() != null)
			{
				session.getTransaction().rollback();
			}
			LogUtil.printStackTrace(e);
		}
		finally
		{
			HibernateSessionFactory.closeCurrentSession();
		}
	}
	
	/**
	 * Save object to DB
	 * @param obj: object to be saved
	 */
	public static void save(Object obj)
	{
		Session session = HibernateSessionFactory.getCurrentSession();
		if (session == null)
		{
			LogUtil.severe("Null hibernate session, check DB parameters");
			return;
		}
		
		try
		{
			LogUtil.info("Start to save data to DB");
			session.beginTransaction();
			session.save(obj);
			session.getTransaction().commit();
			LogUtil.info("Save data succeed");
		}
		catch(Exception e)
		{
			if (session.getTransaction() != null)
			{
				session.getTransaction().rollback();
			}
			LogUtil.printStackTrace(e);
		}
		finally
		{
			HibernateSessionFactory.closeCurrentSession();
		}
	}
}
