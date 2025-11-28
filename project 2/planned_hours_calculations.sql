-- Calculate the total hours (with the multiplication factor) 
-- along with the break-ups for each activity, for the current years’ 
-- course instances 

--We want to extract all planned hours calculations from the database 
--To do this we need:
-- course layout for course code 
-- course instance for course instance id 
-- course layout for hp 
-- course instance period for study period 
-- course instance for amount of students 
-- activity type for activity name 
-- We'll sum up total the amount of hours spent on each acitivty 
-- Using the formula given we can calculate the total Admin and Exam hours 
-- Summing it up together we can get a Total Hours spent

-- LOOKUP TABLE for calculating hours 
-- Activity Name    factor 
-- Lecture          3.6
-- Lab              2.4
-- Tutorial         2.4
-- Seminar          1.8
-- Other            1.0
-- Examination      1.0

DROP VIEW IF EXISTS planned_hours_calculations;

CREATE VIEW planned_hours_calculations AS
SELECT
cl.course_code AS "Course Code",
ci.course_instance_id AS "Course Instance ID",
cl.hp AS "HP",
cip.study_period AS "Period",
ci.amount_of_students AS "# Students",

SUM(CASE WHEN act.activity_name = 'Lecture'  THEN ROUND(pa.planned_hours * act.time_factor) ELSE 0 END) AS "Lecture Hours",
SUM(CASE WHEN act.activity_name = 'Tutorial' THEN ROUND(pa.planned_hours * act.time_factor) ELSE 0 END) AS "Tutorial Hours",
SUM(CASE WHEN act.activity_name = 'Lab'      THEN ROUND(pa.planned_hours * act.time_factor) ELSE 0 END) AS "Lab Hours",
SUM(CASE WHEN act.activity_name = 'Seminar'  THEN ROUND(pa.planned_hours * act.time_factor) ELSE 0 END) AS "Seminar Hours",
SUM(CASE WHEN act.activity_name = 'Other'    THEN ROUND(pa.planned_hours * act.time_factor) ELSE 0 END) AS "Other Overhead Hours",

ROUND((2 * cl.hp) + 28 + (0.2 * ci.amount_of_students)) AS "Admin",
ROUND(32 + (0.725 * ci.amount_of_students)) AS "Exam",

ROUND(
        COALESCE(SUM(pa.planned_hours * act.time_factor), 0) + 
        ((2 * cl.hp) + 28 + (0.2 * ci.amount_of_students)) + 
        (32 + (0.725 * ci.amount_of_students))
    ) AS "Total Hours"

FROM course_instance ci
JOIN course_layout cl ON ci.course_layout_id = cl.course_layout_id
JOIN course_instance_period cip ON ci.course_instance_id = cip.course_instance_id
LEFT JOIN planned_activity pa ON ci.course_instance_id = pa.course_instance_id
LEFT JOIN activity_type act ON pa.activity_id = act.activity_id

GROUP BY 
    cl.course_code, 
    ci.course_instance_id, 
    cl.hp, 
    cip.study_period, 
    ci.amount_of_students
ORDER BY 
    cl.course_code, 
    cip.study_period;

SELECT*FROM planned_hours_calculations;