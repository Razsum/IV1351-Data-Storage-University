
--List employee ids and names of all teachers who are allocated in more than 
--a specific number of course instances during the current period.
--Table 7 below is an example result of such a query,
--illustrating the expected output.

--We want to know which courses that teachers are teaching at, to do this:
--  Identify the current study period
--  Find all the courses in that period
--  We need to take every teacher that has allocated work at that course
--  Then we count how many course instances each teacher is allocated to
--  Filter out teachers who teach less than the given threshold


--Here we create the view
DROP VIEW IF EXISTS allocated_no_of_courses_for_teacher_per_period;

CREATE VIEW allocated_no_of_courses_for_teacher_per_period AS
SELECT
    e.employee_id AS "Employment ID",
    CONCAT(e.first_name, ' ', e.last_name) AS "Teacher's Name",
    cip.study_period AS "Period",
    COUNT(DISTINCT wa.course_instance_id) AS number_of_courses

FROM employee e
JOIN work_allocation wa ON e.employee_id = wa.employee_id
JOIN course_instance_period cip ON wa.course_instance_id = cip.course_instance_id

GROUP BY 
    e.employee_id, 
    cip.study_period;

--Here we select from the view with the required parameters (specify Period and minimum courses taken)
SELECT *
FROM allocated_no_of_courses_for_teacher_per_period
WHERE "Period" = 'P1' --give a period (P1,P2,P3,P4)
  AND number_of_courses >= 1 --give the minimum of courses allocated
ORDER BY number_of_courses DESC;