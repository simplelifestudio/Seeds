package com.simplelife.seeds.server;

import org.hibernate.Session;

import java.util.List;
import java.util.logging.*;


public class DaoWrapper {
	private Logger _logger = Logger.getLogger("HtmlParser");
	private static DaoWrapper _instance;
	private static Session _session;
	
	public DaoWrapper()
	{
		InitSession();
	}
	
	private void InitSession()
	{
		_session = HibernateSessionFactory.getCurrentSession();
		if (_session == null)
		{
			_logger.log(Level.SEVERE, "Severe error: DB connect failed, please check configuration of Hibernate");
		}
	}
	
	public void executeSql(String sql)
	{
		if (_session == null)
		{
		    _logger.log(Level.SEVERE, "_session == null, check DB configuration!");
			return;
		}
		
		try
		{
			_session.createSQLQuery(sql).executeUpdate();
		}
		catch(Exception e)
		{
			_logger.log(Level.SEVERE, "Error occurred when execute sql, error: " + e.getMessage() + ", sql: " + sql);
		}
	}
	
	public boolean exists(String sql)
	{
		if (_session == null)
		{
		    _logger.log(Level.SEVERE, "_session == null, check DB configuration!");
			return false;
		}

		try
		{
			return _session.createSQLQuery(sql).list().size() > 0;
		}
		catch(Exception e)
		{
			_logger.log(Level.SEVERE, "Error occurred when execute sql, error: " + e.getMessage() + ", sql: " + sql);
			return false;
		}

	}
	
	public List query(String sql, Class objClass)
	{
	    if (_session == null)
		{
		    _logger.log(Level.SEVERE, "_session == null, check DB configuration!");
			return null;
		}
		
	    try
	    {
	    	return _session.createSQLQuery(sql).addEntity(objClass).list();
		}
		catch(Exception e)
		{
			_logger.log(Level.SEVERE, "Error occurred when execute sql, error: " + e.getMessage() + ", sql: " + sql);
			return null;
		}
	}
	
	public void delete(Object obj)
	{
		if (_session == null)
		{
			return;
		}
		
		try
		{
			_session.beginTransaction();
			_session.delete(obj);
			_session.getTransaction().commit();
		}
		catch(Exception e)
		{
			_logger.log(Level.SEVERE, "Error occurred when delete object from DB, error: " + e.getMessage() + ", obj: " + obj.toString());
		}

	}
	
	public void save(Object obj)
	{
		if (_session == null)
		{
			_logger.log(Level.SEVERE, "_session == null, check DB configuration!");
			return;
		}
		
		try
		{
			_logger.log(Level.INFO, "Start to save data to DB");
			_session.beginTransaction();
			_session.save(obj);
			_session.getTransaction().commit();
			_logger.log(Level.INFO, "Save data succeed");
		}
		catch(Exception e)
		{
			_session.getTransaction().rollback();
			_logger.log(Level.SEVERE, "Error occurred when saving data to DB: " + e.getMessage());
			_logger.log(Level.SEVERE, obj.toString());
		}
	}

	/**
	 * @return the _instance
	 */
	public static DaoWrapper getInstance() {
		if (_instance == null)
		{
			_instance = new DaoWrapper();
		}
		return _instance;
	}
}
