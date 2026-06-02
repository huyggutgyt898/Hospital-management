package com.hospital.model;

import java.sql.Date;
import java.sql.Time;

public class Report {
    private int reportId;
    private String reportType;
    private String title;
    private String content;
    private Date periodStart;
    private Date periodEnd;
    private Time createdAt;
    private String createdBy;
    private int accountId;
    
    // Constructors
    public Report() {}
    
    public Report(int reportId, String reportType, String title, String content, 
                  Date periodStart, Date periodEnd, Time createdAt, 
                  String createdBy, int accountId) {
        this.reportId = reportId;
        this.reportType = reportType;
        this.title = title;
        this.content = content;
        this.periodStart = periodStart;
        this.periodEnd = periodEnd;
        this.createdAt = createdAt;
        this.createdBy = createdBy;
        this.accountId = accountId;
    }
    
    // Getters and Setters
    public int getReportId() { return reportId; }
    public void setReportId(int reportId) { this.reportId = reportId; }
    
    public String getReportType() { return reportType; }
    public void setReportType(String reportType) { this.reportType = reportType; }
    
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    
    public Date getPeriodStart() { return periodStart; }
    public void setPeriodStart(Date periodStart) { this.periodStart = periodStart; }
    
    public Date getPeriodEnd() { return periodEnd; }
    public void setPeriodEnd(Date periodEnd) { this.periodEnd = periodEnd; }
    
    public Time getCreatedAt() { return createdAt; }
    public void setCreatedAt(Time createdAt) { this.createdAt = createdAt; }
    
    public String getCreatedBy() { return createdBy; }
    public void setCreatedBy(String createdBy) { this.createdBy = createdBy; }
    
    public int getAccountId() { return accountId; }
    public void setAccountId(int accountId) { this.accountId = accountId; }
}