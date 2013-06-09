package com.simplelife.seeds.server;

import java.util.logging.Level;
import java.util.logging.Logger;

public class OperationLog {
	/**
	 * @return the id
	 */
	public long getId() {
		return id;
	}
	/**
	 * @param id the id to set
	 */
	public void setId(long id) {
		this.id = id;
	}
	/**
	 * @return the logDate
	 */
	public String getLogDate() {
		return logDate;
	}
	/**
	 * @param logDate the logDate to set
	 */
	public void setLogDate(String logDate) {
		this.logDate = logDate;
	}
	/**
	 * @return the logId
	 */
	public long getLogId() {
		return logId;
	}
	/**
	 * @param logId the logId to set
	 */
	public void setLogId(long logId) {
		this.logId = logId;
	}
	/**
	 * @return the logInfo
	 */
	public String getLogInfo() {
		return logInfo;
	}
	/**
	 * @param logInfo the logInfo to set
	 */
	public void setLogInfo(String logInfo) {
		this.logInfo = logInfo;
	}
	/**
	 * @return the memo
	 */
	public String getMemo() {
		return memo;
	}
	/**
	 * @param memo the memo to set
	 */
	public void setMemo(String memo) {
		this.memo = memo;
	}
	
	public OperationLog()
	{
		
	}
	
	public OperationLog(long logId, String logInfo)
	{
		this.setLogId(logId);
		this.setLogInfo(logInfo);
		this.Save();
	}
	
	public void Save()
	{
		if (logId == 0)
		{
			logger.log(Level.SEVERE, "logId can't be 0.");
			return;
		}
		
		this.setLogDate(DateUtil.getNow());
		DaoWrapper.getInstance().save(this);
	}
	
	private long id;
	private String logDate;
	private long logId;
	private String logInfo;
	private String memo;
	private Logger logger = Logger.getLogger("OperationLog");
}