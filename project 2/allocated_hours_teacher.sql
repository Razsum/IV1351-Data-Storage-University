DROP VIEW IF EXISTS allocated_hours_teacher;

CREATE VIEW allocated_hours_teacher AS 
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
    cip.study_period AS "Period",
    ci.year AS "Year",
    CONCAT(e.first_name, ' ', e.last_name) AS "Teacher",

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


FROM employee as e
JOIN work_allocation AS wa ON wa.employee_id = e.employee_id
JOIN course_instance AS ci ON wa.course_instance_id = ci.course_instance_id
JOIN course_layout AS cl ON ci.course_layout_id = cl.course_layout_id
JOIN activity_type AS act ON act.activity_id = wa.activity_id
JOIN course_instance_period AS cip ON cip.course_instance_id = ci.course_instance_id
JOIN teacher_per_instance AS tpi ON tpi.course_instance_id = ci.course_instance_id


WHERE ci.year = 2025

GROUP BY 
    cl.course_code, 
    ci.course_instance_id, 
    cl.hp,
    cip.study_period,
    e.first_name, 
    e.last_name,
    e.employee_id,
    ci.amount_of_students,
    tpi.num_teachers
    
ORDER BY 
    cl.course_code,
    ci.course_instance_id;

-- Choose which course instance by changing the number
SELECT * 
FROM allocated_hours_teacher
WHERE "Teacher" = 'Ian Malcolm';
