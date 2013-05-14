package com.simplelife.seeds.server;

import java.sql.SQLException;  
import java.util.logging.Level;
import java.util.logging.Logger;

import org.hibernate.HibernateException;  
import org.hibernate.Session;  
import org.hibernate.SessionFactory;  
import org.hibernate.cfg.Configuration;  
import org.hibernate.service.ServiceRegistry;
import org.hibernate.service.ServiceRegistryBuilder;
  
/** 
 * Configures and provides access to Hibernate sessions, tied to the 
 * current thread of execution.  Follows the Thread Local Session 
 * pattern, see {@link http://hibernate.org/42.html}. 
 */  
public class HibernateSessionFactory {  
  
    /**  
     * Location of hibernate.cfg.xml file. 
     * NOTICE: Location should be on the class path as Hibernate uses 
     * #resourceAsStream style lookup for its configuration file. That 
     * is place the config file in a Java package - the default location 
     * is the default Java package.<br><br> 
     * Defaults: <br> 
     * <code>CONFIG_FILE_LOCATION = "/hibernate.conf.xml"</code>  
     * You can change location with setConfigFile method 
     * session will be rebuilded after change of config file 
     */  
    private static String CONFIG_FILE_LOCATION = "/com/simplelife/seeds/server/hibernate.cfg.xml";
    private static final ThreadLocal threadLocal = new ThreadLocal();  
    private static Configuration configuration = new Configuration();  
    private static SessionFactory sessionFactory;  
    private static String configFile = CONFIG_FILE_LOCATION;  
    private static Logger _logger = Logger.getLogger("HtmlParser");
    
    private HibernateSessionFactory() {  
    }  
      
    /** 
     * Returns the ThreadLocal Session instance.  Lazy initialize 
     * the <code>SessionFactory</code> if needed. 
     * 
     *  @return Session 
     *  @throws HibernateException 
     */  
    public static Session getCurrentSession() throws HibernateException {  
        Session session = (Session) threadLocal.get();  
  
        try {  
            if (session == null || !session.isOpen()) {  
                if (sessionFactory == null) {  
                    rebuildSessionFactory();  
                }  
                session = (sessionFactory != null) ? sessionFactory.openSession()  
                        : null;  
                threadLocal.set(session);  
            }  
        } catch (Exception e) {  
            _logger.log(Level.SEVERE, "Failed to get hibernate session: " + e.getMessage());
        }  
        return session;  
    }  
  
    /** 
     *  Rebuild hibernate session factory 
     * 
     */  
    public static void rebuildSessionFactory() {  
        try {  
        	configuration.configure(configFile);  
        	ServiceRegistry  sr = new ServiceRegistryBuilder().applySettings(configuration.getProperties()).buildServiceRegistry(); 
        	sessionFactory = configuration.buildSessionFactory(sr);  
        } catch (Exception e) {  
        	_logger.log(Level.SEVERE, "Failed to rebuild hibernate session factory: " + e.getMessage());
        	e.printStackTrace();
        }  
    }  
  
    /** 
     *  Close the single hibernate session instance. 
     * 
     *  @throws HibernateException 
     */  
    public static void closeCurrentSession() throws HibernateException {  
        Session session = (Session) threadLocal.get();  
        threadLocal.set(null);  
  
        if (session != null) {  
            session.close();  
        }  
    }  
  
    /** 
     *  return session factory 
     * 
     */  
    public static SessionFactory getSessionFactory() {  
    	if (sessionFactory == null)
    	{
    		rebuildSessionFactory();
    	}
    	return sessionFactory;
    }  
  
    /** 
     *  return session factory 
     * 
     *  session factory will be rebuilt in the next call 
     */  
    public static void setConfigFile(String configFile) {  
        HibernateSessionFactory.configFile = configFile;  
        sessionFactory = null;  
    }  
  
    /** 
     *  return hibernate configuration 
     * 
     */  
    public static Configuration getConfiguration() {  
        return configuration;  
    }  
} 