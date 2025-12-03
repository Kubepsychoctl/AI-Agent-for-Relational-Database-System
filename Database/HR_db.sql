CREATE DATABASE hr_analytics;
USE hr_analytics;

CREATE TABLE department (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(50)
);

CREATE TABLE job_role (
    job_role_id INT PRIMARY KEY,
    job_role_name VARCHAR(50)
);

CREATE TABLE education (
    education_id INT PRIMARY KEY,
    education_level TINYINT,
    education_field VARCHAR(30)
);

CREATE TABLE employee (
    employee_id INT PRIMARY KEY,
    department_id INT,
    job_role_id INT,
    education_id INT,
    age TINYINT,
    gender ENUM('Male','Female'),
    marital_status ENUM('Single','Married','Divorced'),
    distance_from_home TINYINT,
    over_time BOOLEAN,
    attrition BOOLEAN,
    business_travel ENUM('Travel_Rarely','Travel_Frequently','Non-Travel'),
    num_companies_worked TINYINT,
    FOREIGN KEY (department_id) REFERENCES department(department_id),
    FOREIGN KEY (job_role_id) REFERENCES job_role(job_role_id),
    FOREIGN KEY (education_id) REFERENCES education(education_id)
);

CREATE TABLE compensation (
    compensation_id INT PRIMARY KEY,
    employee_id INT,
    monthly_income INT,
    daily_rate SMALLINT,
    hourly_rate SMALLINT,
    percent_salary_hike TINYINT,
    stock_option_level TINYINT,
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
);

CREATE TABLE job_history (
    job_history_id INT PRIMARY KEY,
    employee_id INT,
    years_at_company TINYINT,
    years_in_current_role TINYINT,
    years_since_promotion TINYINT,
    years_with_manager TINYINT,
    job_level TINYINT,
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
);

CREATE TABLE satisfaction (
    satisfaction_id INT PRIMARY KEY,
    employee_id INT,
    environment_satisfaction TINYINT,
    job_satisfaction TINYINT,
    relationship_satisfaction TINYINT,
    work_life_balance TINYINT,
    performance_rating TINYINT,
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
);
