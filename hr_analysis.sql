create database hr_analysis;

SELECT COUNT(*) FROM employee_data;

SELECT COUNT(*) FROM employee_engagement_survey_data;

SELECT COUNT(*) FROM recruitment_data;

SELECT COUNT(*) FROM training_and_development_data;

SELECT * FROM employee_data limit 5;

SELECT * FROM employee_engagement_survey_data LIMIT 5;

SELECT * FROM recruitment_data LIMIT 5;

SELECT * FROM training_and_development_data LIMIT 5;

DESCRIBE employee_data;

DESCRIBE employee_engagement_survey_data;

DESCRIBE recruitment_data;

DESCRIBE training_and_development_data;

SELECT `ï»¿EmpID` FROM employee_data LIMIT 5;
SELECT `Employee ID` FROM employee_engagement_survey_data LIMIT 5;

SELECT MIN(`ï»¿EmpID`), MAX(`ï»¿EmpID`) FROM employee_data;
SELECT MIN(`Employee ID`), MAX(`Employee ID`) FROM employee_engagement_survey_data;
SELECT MIN(`Employee ID`), MAX(`Employee ID`) FROM training_and_development_data;
SELECT MIN(`Applicant ID`), MAX(`Applicant ID`) FROM recruitment_data;

-- joining tables together--
SELECT 
    e.`ï»¿EmpID`,
    e.FirstName,
    e.LastName,
    e.DepartmentType,
    e.`Performance Score`,
    s.`Engagement Score`,
    s.`Satisfaction Score`,
    s.`Work-Life Balance Score`
FROM employee_data e
JOIN employee_engagement_survey_data s
    ON e.`ï»¿EmpID` = s.`Employee ID`
LIMIT 10;


-- Which department has the highest average engagement score?--
SELECT 
    e.DepartmentType,
    ROUND(AVG(s.`Engagement Score`), 1) AS avg_engagement,
    ROUND(AVG(s.`Satisfaction Score`), 1) AS avg_satisfaction,
    ROUND(AVG(s.`Work-Life Balance Score`), 1) AS avg_work_life_balance,
    COUNT(*) AS total_employees
FROM employee_data e
JOIN employee_engagement_survey_data s
    ON e.`ï»¿EmpID` = s.`Employee ID`
GROUP BY e.DepartmentType
ORDER BY avg_engagement DESC;

-- Does training improve employee performance scores?--
SELECT 
    e.DepartmentType,
    e.`Performance Score`,
    t.`Training Program Name`,
    t.`Training Outcome`,
    t.`Training Duration(Days)`,
    ROUND(AVG(s.`Engagement Score`), 1) AS avg_engagement
FROM employee_data e
JOIN training_and_development_data t
    ON e.`ï»¿EmpID` = t.`Employee ID`
JOIN employee_engagement_survey_data s
    ON e.`ï»¿EmpID` = s.`Employee ID`
GROUP BY 
    e.DepartmentType,
    e.`Performance Score`,
    t.`Training Program Name`,
    t.`Training Outcome`,
    t.`Training Duration(Days)`
ORDER BY avg_engagement DESC
LIMIT 10;

SELECT 
    t.`Training Outcome`,
    e.`Performance Score`,
    COUNT(*) AS total_employees,
    ROUND(AVG(s.`Engagement Score`), 1) AS avg_engagement
FROM employee_data e
JOIN training_and_development_data t
    ON e.`ï»¿EmpID` = t.`Employee ID`
JOIN employee_engagement_survey_data s
    ON e.`ï»¿EmpID` = s.`Employee ID`
GROUP BY 
    t.`Training Outcome`,
    e.`Performance Score`
ORDER BY 
    t.`Training Outcome`,
    avg_engagement DESC;
    
-- Check for missing values in employee_data:--
SELECT 
    SUM(CASE WHEN FirstName IS NULL OR FirstName = '' THEN 1 ELSE 0 END) AS missing_firstname,
    SUM(CASE WHEN DepartmentType IS NULL OR DepartmentType = '' THEN 1 ELSE 0 END) AS missing_department,
    SUM(CASE WHEN `Performance Score` IS NULL OR `Performance Score` = '' THEN 1 ELSE 0 END) AS missing_performance,
    SUM(CASE WHEN ExitDate IS NULL OR ExitDate = '' THEN 1 ELSE 0 END) AS missing_exitdate,
    SUM(CASE WHEN EmployeeStatus IS NULL OR EmployeeStatus = '' THEN 1 ELSE 0 END) AS missing_status
FROM employee_data;

SELECT 
    SUM(CASE WHEN `Engagement Score` IS NULL THEN 1 ELSE 0 END) AS missing_engagement,
    SUM(CASE WHEN `Satisfaction Score` IS NULL THEN 1 ELSE 0 END) AS missing_satisfaction,
    SUM(CASE WHEN `Work-Life Balance Score` IS NULL THEN 1 ELSE 0 END) AS missing_worklife
FROM employee_engagement_survey_data;

SELECT 
    SUM(CASE WHEN `Training Outcome` IS NULL OR `Training Outcome` = '' THEN 1 ELSE 0 END) AS missing_outcome,
    SUM(CASE WHEN `Training Cost` IS NULL THEN 1 ELSE 0 END) AS missing_cost,
    SUM(CASE WHEN `Training Duration(Days)` IS NULL THEN 1 ELSE 0 END) AS missing_duration
FROM training_and_development_data;

SELECT 
    SUM(CASE WHEN Status IS NULL OR Status = '' THEN 1 ELSE 0 END) AS missing_status,
    SUM(CASE WHEN `Years of Experience` IS NULL THEN 1 ELSE 0 END) AS missing_experience,
    SUM(CASE WHEN `Desired Salary` IS NULL THEN 1 ELSE 0 END) AS missing_salary
FROM recruitment_data;

-- 1. Employment Status — Active or Terminated

ALTER TABLE employee_data
ADD COLUMN Employment_Status TEXT;

UPDATE employee_data
SET Employment_Status = 
    CASE
        WHEN ExitDate IS NULL OR ExitDate = '' THEN 'Active'
        ELSE 'Terminated'
    END;
    
SELECT Employment_Status, COUNT(*) AS total
FROM employee_data
GROUP BY Employment_Status;    

-- Tenure column — how many years each employee worked at the company:

UPDATE employee_data
SET Tenure_Years = 
    CASE
        WHEN ExitDate IS NULL OR ExitDate = '' 
        THEN TIMESTAMPDIFF(YEAR, STR_TO_DATE(StartDate, '%d-%b-%y'), CURDATE())
        ELSE TIMESTAMPDIFF(YEAR, STR_TO_DATE(StartDate, '%d-%b-%y'), STR_TO_DATE(ExitDate, '%d-%b-%y'))
    END;
    
SELECT 
    MIN(Tenure_Years) AS min_tenure,
    MAX(Tenure_Years) AS max_tenure,
    ROUND(AVG(Tenure_Years), 1) AS avg_tenure
FROM employee_data; 

-- 3. Age — calculated from date of birth
UPDATE employee_data
SET Age = TIMESTAMPDIFF(YEAR, STR_TO_DATE(DOB, '%d-%m-%Y'), CURDATE());

SELECT 
    MIN(Age) AS youngest,
    MAX(Age) AS oldest,
    ROUND(AVG(Age), 1) AS avg_age
FROM employee_data;

--  Performance Tier --
ALTER TABLE employee_data
ADD COLUMN Performance_Tier TEXT;

UPDATE employee_data
SET Performance_Tier = 
    CASE
        WHEN `Performance Score` = 'Exceeds' THEN 'High'
        WHEN `Performance Score` = 'Fully Meets' THEN 'Medium'
        WHEN `Performance Score` = 'Needs Improvement' THEN 'Low'
        WHEN `Performance Score` = 'PIP' THEN 'Critical'
        ELSE 'Unknown'
    END;
    
SELECT Performance_Tier, COUNT(*) AS total
FROM employee_data
GROUP BY Performance_Tier
ORDER BY total DESC;


SELECT DISTINCT Employment_Status 
FROM employee_data;

SELECT 
    DepartmentType,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN Employment_Status = 'Terminated' THEN 1 ELSE 0 END) AS total_terminated,
    ROUND(
        SUM(CASE WHEN Employment_Status = 'Terminated' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1
    ) AS turnover_rate
FROM employee_data
GROUP BY DepartmentType