CREATE OR REPLACE VIEW v_attrition_overview AS
SELECT 
    COUNT(*) AS total_employees,
    SUM(CASE WHEN attrition = 1 THEN 1 ELSE 0 END) AS employees_left,
    SUM(CASE WHEN attrition = 0 THEN 1 ELSE 0 END) AS employees_stayed,
    ROUND(SUM(CASE WHEN attrition = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate_percent
FROM Employee;
CREATE OR REPLACE VIEW v_attrition_demographics AS
SELECT 
    gender,
    marital_status,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN attrition = 1 THEN 1 ELSE 0 END) AS left_count,
    ROUND(SUM(CASE WHEN attrition = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate
FROM Employee
GROUP BY gender, marital_status
ORDER BY attrition_rate DESC;

CREATE OR REPLACE VIEW v_attrition_by_age AS
SELECT 
    CASE 
        WHEN age < 25 THEN '18-24'
        WHEN age < 35 THEN '25-34'
        WHEN age < 45 THEN '35-44'
        WHEN age < 55 THEN '45-54'
        ELSE '55+'
    END AS age_group,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN attrition = 1 THEN 1 ELSE 0 END) AS left_count,
    ROUND(SUM(CASE WHEN attrition = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate
FROM Employee
GROUP BY age_group
ORDER BY age_group;


CREATE OR REPLACE VIEW v_attrition_by_department AS
SELECT 
    d.department_name,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN e.attrition = 1 THEN 1 ELSE 0 END) AS employees_left,
    ROUND(SUM(CASE WHEN e.attrition = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate,
    ROUND(AVG(c.monthly_income), 2) AS avg_salary
FROM Employee e
JOIN Department d ON e.department_id = d.department_id
JOIN Compensation c ON e.employee_id = c.employee_id
GROUP BY d.department_name
ORDER BY attrition_rate DESC;

-- VIEW 2.2: Attrition by Department and Job Role
CREATE OR REPLACE VIEW v_attrition_by_dept_role AS
SELECT 
    d.department_name,
    jr.job_role_name,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN e.attrition = 1 THEN 1 ELSE 0 END) AS employees_left,
    ROUND(SUM(CASE WHEN e.attrition = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate
FROM Employee e
JOIN Department d ON e.department_id = d.department_id
JOIN JobRole jr ON e.job_role_id = jr.job_role_id
GROUP BY d.department_name, jr.job_role_name
HAVING COUNT(*) >= 5
ORDER BY attrition_rate DESC;

CREATE OR REPLACE VIEW v_department_health AS
SELECT 
    d.department_name,
    COUNT(*) AS total_employees,
    ROUND(AVG(s.job_satisfaction), 2) AS avg_job_satisfaction,
    ROUND(AVG(s.environment_satisfaction), 2) AS avg_env_satisfaction,
    ROUND(AVG(s.work_life_balance), 2) AS avg_work_life_balance,
    ROUND(SUM(CASE WHEN e.attrition = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate
FROM Employee e
JOIN Department d ON e.department_id = d.department_id
JOIN Satisfaction s ON e.employee_id = s.employee_id
GROUP BY d.department_name;


CREATE OR REPLACE VIEW v_salary_attrition_comparison AS
SELECT 
    CASE WHEN e.attrition = 1 THEN 'Left' ELSE 'Stayed' END AS status,
    COUNT(*) AS employee_count,
    ROUND(AVG(c.monthly_income), 2) AS avg_monthly_income,
    ROUND(MIN(c.monthly_income), 2) AS min_income,
    ROUND(MAX(c.monthly_income), 2) AS max_income,
    ROUND(AVG(c.percent_salary_hike), 2) AS avg_salary_hike
FROM Employee e
JOIN Compensation c ON e.employee_id = c.employee_id
GROUP BY e.attrition;

CREATE OR REPLACE VIEW v_attrition_by_salary_bracket AS
SELECT 
    CASE 
        WHEN c.monthly_income < 3000 THEN 'Low (<3K)'
        WHEN c.monthly_income < 6000 THEN 'Medium (3K-6K)'
        WHEN c.monthly_income < 10000 THEN 'High (6K-10K)'
        ELSE 'Very High (>10K)'
    END AS salary_bracket,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN e.attrition = 1 THEN 1 ELSE 0 END) AS employees_left,
    ROUND(SUM(CASE WHEN e.attrition = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate
FROM Employee e
JOIN Compensation c ON e.employee_id = c.employee_id
GROUP BY salary_bracket
ORDER BY attrition_rate DESC;

CREATE OR REPLACE VIEW v_stock_options_impact AS
SELECT 
    c.stock_option_level,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN e.attrition = 1 THEN 1 ELSE 0 END) AS employees_left,
    ROUND(SUM(CASE WHEN e.attrition = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate,
    ROUND(AVG(c.monthly_income), 2) AS avg_income
FROM Employee e
JOIN Compensation c ON e.employee_id = c.employee_id
GROUP BY c.stock_option_level
ORDER BY c.stock_option_level;

CREATE OR REPLACE VIEW v_overtime_attrition AS
SELECT 
    CASE WHEN e.over_time = 1 THEN 'Yes' ELSE 'No' END AS works_overtime,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN e.attrition = 1 THEN 1 ELSE 0 END) AS employees_left,
    ROUND(SUM(CASE WHEN e.attrition = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate,
    ROUND(AVG(s.work_life_balance), 2) AS avg_work_life_balance
FROM Employee e
JOIN Satisfaction s ON e.employee_id = s.employee_id
GROUP BY e.over_time;

CREATE OR REPLACE VIEW v_commute_attrition AS
SELECT 
    CASE 
        WHEN e.distance_from_home <= 5 THEN 'Short (0-5 mi)'
        WHEN e.distance_from_home <= 15 THEN 'Medium (6-15 mi)'
        ELSE 'Long (>15 mi)'
    END AS commute_distance,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN e.attrition = 1 THEN 1 ELSE 0 END) AS employees_left,
    ROUND(SUM(CASE WHEN e.attrition = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate
FROM Employee e
GROUP BY commute_distance
ORDER BY attrition_rate DESC;

CREATE OR REPLACE VIEW v_burnout_risk AS
SELECT 
    e.employee_id,
    d.department_name,
    jr.job_role_name,
    e.over_time,
    e.distance_from_home,
    s.work_life_balance,
    s.job_satisfaction,
    jh.years_since_last_promotion,
    (CASE WHEN e.over_time = 1 THEN 2 ELSE 0 END) +
    (CASE WHEN e.distance_from_home > 15 THEN 2 ELSE 0 END) +
    (CASE WHEN s.work_life_balance = 1 THEN 3 WHEN s.work_life_balance = 2 THEN 1 ELSE 0 END) +
    (CASE WHEN s.job_satisfaction = 1 THEN 2 WHEN s.job_satisfaction = 2 THEN 1 ELSE 0 END) +
    (CASE WHEN jh.years_since_last_promotion > 5 THEN 2 ELSE 0 END) AS burnout_risk_score,
    e.attrition
FROM Employee e
JOIN Department d ON e.department_id = d.department_id
JOIN JobRole jr ON e.job_role_id = jr.job_role_id
JOIN Satisfaction s ON e.employee_id = s.employee_id
JOIN JobHistory jh ON e.employee_id = jh.employee_id;

CREATE OR REPLACE VIEW v_high_burnout_risk AS
SELECT 
    burnout_risk_score,
    COUNT(*) AS employee_count,
    SUM(CASE WHEN attrition = 1 THEN 1 ELSE 0 END) AS left_count,
    ROUND(SUM(CASE WHEN attrition = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS attrition_rate
FROM v_burnout_risk
GROUP BY burnout_risk_score
ORDER BY burnout_risk_score DESC;

CREATE OR REPLACE VIEW v_employee_full_analysis AS
SELECT 
    e.employee_id,
    d.department_name,
    jr.job_role_name,
    ed.education_level,
    ed.education_field,
    e.age,
    e.gender,
    e.marital_status,
    e.distance_from_home,
    e.over_time,
    e.business_travel,
    e.num_companies_worked,
    e.total_working_years,
    c.monthly_income,
    c.percent_salary_hike,
    c.stock_option_level,
    jh.years_at_company,
    jh.years_in_current_role,
    jh.years_since_last_promotion,
    jh.job_level,
    jh.training_times_last_year,
    s.environment_satisfaction,
    s.job_satisfaction,
    s.relationship_satisfaction,
    s.work_life_balance,
    s.job_involvement,
    s.performance_rating,
    e.attrition
FROM Employee e
JOIN Department d ON e.department_id = d.department_id
JOIN JobRole jr ON e.job_role_id = jr.job_role_id
JOIN Education ed ON e.education_id = ed.education_id
JOIN Compensation c ON e.employee_id = c.employee_id
JOIN JobHistory jh ON e.employee_id = jh.employee_id
JOIN Satisfaction s ON e.employee_id = s.employee_id;
