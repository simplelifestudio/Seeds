package com.simplelife.seeds.server;

public class User {
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
	 * @return the userName
	 */
	public String getUserName() {
		return userName;
	}
	/**
	 * @param userName the userName to set
	 */
	public void setUserName(String userName) {
		this.userName = userName;
	}
	/**
	 * @return the password
	 */
	public String getPassword() {
		return password;
	}
	/**
	 * @param password the password to set
	 */
	public void setPassword(String password) {
		this.password = password;
	}
	/**
	 * @return the nickName
	 */
	public String getNickName() {
		return nickName;
	}
	/**
	 * @param nickName the nickName to set
	 */
	public void setNickName(String nickName) {
		this.nickName = nickName;
	}
	/**
	 * @return the email
	 */
	public String getEmail() {
		return email;
	}
	/**
	 * @param email the email to set
	 */
	public void setEmail(String email) {
		this.email = email;
	}
	/**
	 * @return the status
	 */
	public int getStatus() {
		return status;
	}
	/**
	 * @param status the status to set
	 */
	public void setStatus(int status) {
		this.status = status;
	}
	/**
	 * @return the role
	 */
	public int getRole() {
		return role;
	}
	/**
	 * @param role the role to set
	 */
	public void setRole(int role) {
		this.role = role;
	}
	/**
	 * @return the registerTime
	 */
	public String getRegisterTime() {
		return registerTime;
	}
	/**
	 * @param registerTime the registerTime to set
	 */
	public void setRegisterTime(String registerTime) {
		this.registerTime = registerTime;
	}
	/**
	 * @return the lastPhone
	 */
	public int getLastPhone() {
		return lastPhone;
	}
	/**
	 * @param lastPhone the lastPhone to set
	 */
	public void setLastPhone(int lastPhone) {
		this.lastPhone = lastPhone;
	}
	/**
	 * @return the lastActivity
	 */
	public int getLastActivity() {
		return lastActivity;
	}
	/**
	 * @param lastActivity the lastActivity to set
	 */
	public void setLastActivity(int lastActivity) {
		this.lastActivity = lastActivity;
	}
	
	
	private long id;
	private String userName;
	private String password;
	private String nickName;
	private String email;
	private int status;
	private int role;
	private String registerTime;
	private int lastPhone;
	private int lastActivity;

}
