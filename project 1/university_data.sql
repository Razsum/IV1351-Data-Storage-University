-- 0. CLEANUP (TRUNCATE TABLES)
TRUNCATE TABLE 
    "work_allocation", "planned_activity", "course_instance_period", 
    "course_instance", "course_layout", "salary_history", 
    "interests", "defined_interests", "skills", "defined_skills", 
    "telephone", "email", "employee", "job_title", 
    "department", "activity_type" 
    CASCADE;

-- 1. ACTIVITY TYPES
INSERT INTO "activity_type" ("activity_name", "time_factor") VALUES 
('Lecture', 3.60),
('Lab', 2.40),
('Seminar', 1.80),
('Tutorial', 2.40),
('Other', 1.00),
('Examination', 1.00);

-- 2. DEPARTMENTS
INSERT INTO "department" ("department_id", "department_name") VALUES
(1, 'Computer Science'),
(2, 'Electrical Engineering'),
(3, 'Mathematics');

-- 3. JOB TITLES
INSERT INTO "job_title" ("job_title_id", "job_title") VALUES
(1, 'Administrator'),
(2, 'Professor'),
(3, 'Lecturer'),
(4, 'Teaching Assistant'),
(5, 'Senior Lecturer');

-- 4. EMPLOYEES
INSERT INTO "employee" ("employee_id", "person_number", "first_name", "last_name", "department_id", "job_title_id") VALUES
(1, '8501011234', 'Alice', 'Sterling', 1, 1),
(2, '9005122345', 'Bob', 'Vance',      1, 2),
(3, '8211203456', 'Charlie', 'Day',    1, 3),
(4, '7903154567', 'Diana', 'Prince',   1, 4),
(5, '9507075678', 'Evan', 'Wright',    2, 5),
(6, '8809096789', 'Fiona', 'Gallagher',2, 1),
(7, '7512257890', 'George', 'Costanza',2, 2),
(8, '9202148901', 'Hannah', 'Abbott',  3, 3),
(9, '8306309012', 'Ian', 'Malcolm',    3, 4),
(10,'9808080123', 'Julia', 'Roberts',  3, 1);

-- 5. CONTACT INFO
INSERT INTO "email" ("employee_id", "email", "email_type") VALUES
(1, 'alice.sterling@uni.edu', 'Work'),
(2, 'bob.vance@uni.edu', 'Work'),
(3, 'charlie.day@uni.edu', 'Work'),
(4, 'diana.prince@uni.edu', 'Work'),
(5, 'evan.wright@uni.edu', 'Work'),
(6, 'fiona.gallagher@uni.edu', 'Work'),
(7, 'george.costanza@uni.edu', 'Work'),
(8, 'hannah.abbott@uni.edu', 'Work'),
(9, 'ian.malcolm@uni.edu', 'Work'),
(10, 'julia.roberts@uni.edu', 'Work');

INSERT INTO "telephone" ("employee_id", "phone_number", "phone_type") VALUES
(1, '070-1112233', 'Mobile'),
(2, '070-2223344', 'Mobile'),
(3, '070-3334455', 'Mobile'),
(4, '070-4445566', 'Mobile'),
(5, '070-5556677', 'Mobile'),
(6, '070-6667788', 'Mobile'),
(7, '070-7778899', 'Mobile'),
(8, '070-8889900', 'Mobile'),
(9, '070-9990011', 'Mobile'),
(10,'070-0001122', 'Mobile');

-- 6. SKILLS
INSERT INTO "defined_skills" ("skill_id", "skill") VALUES
(1, 'Teaching'), (2, 'Budgeting'), (3, 'Research'), (4, 'Python'), 
(5, 'C++'), (6, 'Matlab'), (7, 'Architecture'), (8, 'Administration'), 
(9, 'SQL'), (10, 'Chemistry'), (11, 'Mathematics'), (12, 'Physics');

INSERT INTO "skills" ("employee_id", "skill_id") VALUES
(1, 1), (1, 2),
(2, 3), (2, 4),
(3, 5), (3, 1),
(4, 6), 
(5, 7), 
(6, 8),
(7, 9), (7, 3),
(8, 10), 
(9, 11), 
(10, 12);

-- 7. INTERESTS
INSERT INTO "defined_interests" ("interest_id", "interest") VALUES
(1, 'Artificial Intelligence'), (2, 'Data Analysis'), (3, 'Machine Learning'),
(4, 'Cybersecurity'), (5, 'Project Management'), (6, 'Software Engineering'),
(7, 'Environmental Science'), (8, 'Electronics'), (9, 'Mechanical Design'),
(10, 'Statistics'), (11, 'Biology'), (12, 'Networking & Systems');

INSERT INTO "interests" ("employee_id", "interest_id") VALUES
(1, 1), (1, 2), (2, 3), (2, 4), (3, 5), (3, 6),
(4, 2), (4, 10), (5, 7), (5, 11), (6, 5), (6, 12),
(7, 8), (7, 9), (8, 10), (8, 4), (9, 1), (9, 3), (10, 6), (10, 12);

-- 8. SALARY HISTORY
INSERT INTO "salary_history" ("payment_date", "employee_id", "salary") VALUES
('2023-04-12', 1, 50312.00),
('2022-11-03', 2, 42987.00),
('2023-06-28', 3, 43922.00),
('2024-02-14', 4, 37411.00),
('2022-12-19', 5, 27355.00),
('2024-07-01', 6, 50981.00),
('2023-08-11', 7, 42104.00),
('2024-01-07', 8, 39788.00),
('2022-10-22', 9, 38555.00),
('2023-03-18', 10, 31544.00);

-- 9. COURSEWARE
INSERT INTO "course_layout" ("course_layout_id", "course_code", "course_name", "min_students", "max_students", "hp") VALUES
(1, 'IV1351', 'Data Storage Paradigms', 50, 150, 7.5),
(2, 'IX1500', 'Discrete Mathematics', 70, 125, 7.5),
(3, 'IV1350', 'Object-oriented Design', 50, 150, 7.5),
(4, 'DH2642', 'Dynamic Web', 70, 150, 7.5);

INSERT INTO "course_instance" ("course_instance_id", "course_layout_id", "amount_of_students", "year") VALUES
(1, 1, 120, 2025),
(2, 1, 103, 2025),
(3, 2, 118, 2025),
(4, 3, 125, 2025), 
(5, 4, 120, 2025);

INSERT INTO "course_instance_period" ("course_instance_id", "study_period", "course_instance_period_hp") VALUES
(1, 'P1', 7.5),
(2, 'P3', 7.5),
(3, 'P1', 7.5),
(4, 'P2', 7.5),
(5, 'P4', 7.5);

-- 10. PLANNED ACTIVITIES
-- Mapped Activity names IDs (1=Lecture, 2=Lab, 3=Seminar, 4=Tutorial, 5=Other)
INSERT INTO "planned_activity" ("course_instance_id", "activity_id", "planned_hours") VALUES
(1, 1, 20.00),
(1, 2, 40.00),
(1, 3, 10.00),
(1, 5, 10.00),
(2, 1, 20.00),
(2, 2, 40.00),
(2, 5, 10.00),
(3, 1, 30.00),
(3, 4, 20.00),
(3, 5, 15.00),
(4, 1, 15.00),
(4, 2, 20.00),
(4, 3, 20.00),
(5, 1, 20.00),
(5, 2, 60.00),
(5, 5, 20.00);

-- 11. WORK ALLOCATION
INSERT INTO "work_allocation" ("employee_id", "course_instance_id", "activity_id", "allocated_hours") VALUES
(3, 1, 1, 20.00),
(4, 1, 2, 20.00),
(9, 1, 2, 20.00),
(8, 1, 3, 10.00),
(1, 1, 5, 10.00),
(3, 1, 6, 12.00),
(8, 2, 1, 20.00),
(9, 2, 2, 40.00),
(1, 2, 5, 10.00),
(8, 2, 6, 10.00),
(2, 3, 1, 15.00),
(7, 3, 1, 15.00),
(4, 3, 4, 10.00),
(9, 3, 4, 10.00),
(2, 3, 6, 15.00),
(5, 4, 1, 15.00),
(4, 4, 2, 20.00),
(5, 4, 3, 10.00),
(8, 4, 3, 10.00),
(5, 4, 6, 8.00),
(5, 5, 1, 20.00),
(4, 5, 2, 30.00),
(9, 5, 2, 30.00),
(5, 5, 5, 20.00),
(5, 5, 6, 10.00);

-- 12. UPDATE MANAGERS (Avoids Circular Logic)
UPDATE "department" SET "manager_id" = 1 WHERE "department_id" = 1;
UPDATE "department" SET "manager_id" = 6 WHERE "department_id" = 2; 
UPDATE "department" SET "manager_id" = 10 WHERE "department_id" = 3; 

-- 13. RESET SEQUENCES
SELECT setval('department_department_id_seq', (SELECT MAX(department_id) FROM department));
SELECT setval('job_title_job_title_id_seq', (SELECT MAX(job_title_id) FROM job_title));
SELECT setval('employee_employee_id_seq', (SELECT MAX(employee_id) FROM employee));
SELECT setval('activity_type_activity_id_seq', (SELECT MAX(activity_id) FROM activity_type));
SELECT setval('course_layout_course_layout_id_seq', (SELECT MAX(course_layout_id) FROM course_layout));
SELECT setval('course_instance_course_instance_id_seq', (SELECT MAX(course_instance_id) FROM course_instance));