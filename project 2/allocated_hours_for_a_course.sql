-- Calculate the total allocated hours with the multiplication factor 
-- along with the break-ups for each activity and for each teacher,
-- for a current years’ course instance.

--We want to extract all allocated hours calculations from the database 
--To do this we need:
-- course layout for course code 
-- course instance for course instance id 
-- course layout for hp 
-- employee for employee first and last name
-- job title for job title
-- activity type for activity name 
-- We'll sum up total the amount of hours spent on each acitivty 
-- Using the formula given we can calculate the total Admin and Exam hours 
-- Summing it up together we can get a Total Hours spent
-- We create a temporary table to keep track of the total amount of teachers per course instance
-- This will help us to equally distribute the total amount of exam and admin work

DROP VIEW IF EXISTS allocated_hours_for_a_course;

CREATE VIEW allocated_hours_for_a_course AS 
WITH teacher_per_instance AS (
    SELECT 
        course_instance_id,
        COUNT(*) AS num_teachers
    FROM work_allocation
    GROUP BY course_instance_id
)

SELECT 
    cl.course_code AS "Course Code",
    ci.course_instance_id AS "Course Instance ID",
    cl.hp AS "HP",
    CONCAT(e.first_name, ' ', e.last_name) AS "Teacher",
    jt.job_title AS "Designation",

-- Summing up the individual hours for all activity types
    SUM(CASE WHEN act.activity_name = 'Lecture'  THEN ROUND(wa.allocated_hours * act.time_factor) ELSE 0 END) AS "Lecture Hours",
    SUM(CASE WHEN act.activity_name = 'Tutorial' THEN ROUND(wa.allocated_hours * act.time_factor) ELSE 0 END) AS "Tutorial Hours",
    SUM(CASE WHEN act.activity_name = 'Lab'      THEN ROUND(wa.allocated_hours * act.time_factor) ELSE 0 END) AS "Lab Hours",
    SUM(CASE WHEN act.activity_name = 'Seminar'  THEN ROUND(wa.allocated_hours * act.time_factor) ELSE 0 END) AS "Seminar Hours",
    SUM(CASE WHEN act.activity_name = 'Other'    THEN ROUND(wa.allocated_hours * act.time_factor) ELSE 0 END) AS "Other Overhead Hours",

-- Summing up the hours spent on Admin and Exam work, equally divided between the teachers
    ROUND((2 * cl.hp + 28 + 0.2 * ci.amount_of_students) / tpi.num_teachers) AS "Admin",
    ROUND((32 + 0.725 * ci.amount_of_students) / tpi.num_teachers) AS "Exam",

-- Summing up the allocated hours for the activities, as well as admin and exam
(SUM(wa.allocated_hours * act.time_factor) +
    ROUND((2 * cl.hp + 28 + 0.2 * ci.amount_of_students) / tpi.num_teachers) +
    ROUND((32 + 0.725 * ci.amount_of_students) / tpi.num_teachers)
)::INT AS "Total"


FROM course_instance AS ci
JOIN course_layout AS cl ON cl.course_layout_id = ci.course_layout_id
JOIN work_allocation AS wa ON wa.course_instance_id = ci.course_instance_id
JOIN activity_type AS act ON act.activity_id = wa.activity_id
JOIN employee AS e ON e.employee_id = wa.employee_id
JOIN job_title AS jt ON jt.job_title_id = e.job_title_id
JOIN teacher_per_instance AS tpi ON tpi.course_instance_id = ci.course_instance_id

WHERE ci.year = 2025

GROUP BY 
    cl.course_code, 
    ci.course_instance_id, 
    cl.hp, 
    e.first_name, 
    e.last_name,
    jt.job_title,
    ci.amount_of_students,
    tpi.num_teachers
    
ORDER BY 
    cl.course_code,
    ci.course_instance_id;

-- Choose which course instance by changing the number
SELECT * 
FROM allocated_hours_for_a_course
WHERE "Course Instance ID" = 1;