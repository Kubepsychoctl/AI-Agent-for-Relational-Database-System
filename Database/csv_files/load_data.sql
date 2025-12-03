USE hr_analytics;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE satisfaction;
TRUNCATE TABLE job_history;
TRUNCATE TABLE compensation;
TRUNCATE TABLE employee;
TRUNCATE TABLE education;
TRUNCATE TABLE job_role;
TRUNCATE TABLE department;
SET FOREIGN_KEY_CHECKS = 1;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/departments.csv'
INTO TABLE department
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(department_id, department_name);

SELECT 'department' AS table_name, COUNT(*) AS rows_loaded FROM department;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/job_roles.csv'
INTO TABLE job_role
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(job_role_id, job_role_name);

SELECT 'job_role' AS table_name, COUNT(*) AS rows_loaded FROM job_role;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/education.csv'
INTO TABLE education
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(education_id, @education_name)
SET education_level = 1,
    education_field = @education_name;

SELECT 'education' AS table_name, COUNT(*) AS rows_loaded FROM education;


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/employees.csv'
INTO TABLE employee
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(employee_id, @full_name, age, @gender, department_id, job_role_id, education_id,
 @years_at_company, @attrition, @over_time, @job_level, @business_travel)
SET gender = CASE WHEN @gender = 'Male' THEN 'Male' ELSE 'Female' END,
    attrition = CASE WHEN @attrition = 'Yes' THEN 1 ELSE 0 END,
    over_time = CASE WHEN @over_time = 'Yes' THEN 1 ELSE 0 END,
    business_travel = CASE 
        WHEN @business_travel = 'Rarely' THEN 'Travel_Rarely'
        WHEN @business_travel = 'Frequently' THEN 'Travel_Frequently'
        ELSE 'Non-Travel'
    END,
    marital_status = 'Single',  -- Default значение (нет в CSV)
    distance_from_home = 10,    -- Default значение (нет в CSV)
    num_companies_worked = 1;   -- Default значение (будет из job_history)

SELECT 'employee' AS table_name, COUNT(*) AS rows_loaded FROM employee;


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/compensation.csv'
INTO TABLE compensation
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(compensation_id, employee_id, monthly_income, percent_salary_hike)
SET daily_rate = ROUND(monthly_income / 22),
    hourly_rate = ROUND(monthly_income / 176),
    stock_option_level = 0;

SELECT 'compensation' AS table_name, COUNT(*) AS rows_loaded FROM compensation;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/jobhistory.csv'
INTO TABLE job_history
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(job_history_id, employee_id, @num_companies, years_in_current_role, years_since_promotion)
SET years_at_company = years_in_current_role,  
    years_with_manager = ROUND(years_in_current_role / 2),
    job_level = 1;

UPDATE employee e
JOIN (
    SELECT employee_id, @num_companies as num_comp 
    FROM job_history
) jh ON e.employee_id = jh.employee_id
SET e.num_companies_worked = COALESCE(jh.num_comp, 1);

-- Проверка
SELECT 'job_history' AS table_name, COUNT(*) AS rows_loaded FROM job_history;


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/satisfaction.csv'
INTO TABLE satisfaction
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(satisfaction_id, employee_id, environment_satisfaction, job_satisfaction,
 relationship_satisfaction, work_life_balance)
SET performance_rating = 3; 

-- Проверка
SELECT 'satisfaction' AS table_name, COUNT(*) AS rows_loaded FROM satisfaction;

SELECT 'ИТОГО' AS summary;
SELECT 
    (SELECT COUNT(*) FROM department) AS departments,
    (SELECT COUNT(*) FROM job_role) AS job_roles,
    (SELECT COUNT(*) FROM education) AS education,
    (SELECT COUNT(*) FROM employee) AS employees,
    (SELECT COUNT(*) FROM compensation) AS compensation,
    (SELECT COUNT(*) FROM job_history) AS job_history,
    (SELECT COUNT(*) FROM satisfaction) AS satisfaction;
