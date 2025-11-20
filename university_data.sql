-- Clean up existing data
TRUNCATE TABLE shift, calendar_activities, course_employee, course_activity, 
course_instance_period, course_instance, course_layout, skills, 
salary_history, job, department_manager, department, email, telephone, 
interests, employee, activity_type CASCADE;

-- 1. ACTIVITY TYPES

INSERT INTO activity_type (activity_type, time_factor) VALUES 
('Lecture', 3.60),
('Lab', 2.40),
('Seminar', 1.80),
('Tutorial', 2.40),
('Other', 1.00),
('Examination', 1.50);

-- 2. DEPARTMENTS

INSERT INTO department (department_id, department_name) VALUES
(1, 'Computer Science'),
(2, 'Electrical Engineering'),
(3, 'Human Centered Technology'),
(4, 'Intelligent Systems'),
(5, 'Architecture'),
(6, 'Real Estate and Construction Management'),
(7, 'Engineering Design'),
(8, 'Materials Science and Engineering'),
(9, 'Mathematics'),
(10, 'Applied Physics');

-- 3. EMPLOYEES

INSERT INTO employee (employee_id, person_number, first_name, last_name, street, zip, city) VALUES
(1, '8501011234', 'Alice', 'Sterling', 'Maple Avenue 10', '10001', 'Stockholm'),
(2, '9005122345', 'Bob', 'Vance', 'Refrigeration Rd 5', '10002', 'Stockholm'),
(3, '8211203456', 'Charlie', 'Day', 'Paddy Pub Lane 3', '10003', 'Solna'),
(4, '7903154567', 'Diana', 'Prince', 'Themyscira Way 1', '10004', 'Kista'),
(5, '9507075678', 'Evan', 'Wright', 'Journalist St 44', '10005', 'Täby'),
(6, '8809096789', 'Fiona', 'Gallagher', 'South Side 2', '10006', 'Sollentuna'),
(7, '7512257890', 'George', 'Costanza', 'Vandelay Dr 9', '10007', 'Stockholm'),
(8, '9202148901', 'Hannah', 'Abbott', 'Hufflepuff St 7', '10008', 'Solna'),
(9, '8306309012', 'Ian', 'Malcolm', 'Chaos Theory Blvd', '10009', 'Kista'),
(10, '9808080123', 'Julia', 'Roberts', 'Notting Hill 10', '10010', 'Stockholm');

-- 4. JOBS

INSERT INTO job (job_id, employee_id, job_title, department_id, salary, supervisor_id) VALUES
(1, 1, 'Administrator', 1, 51532.00, NULL),
(2, 2, 'Professor', 2, 42987.00, NULL),
(3, 3, 'Lecturer', 3, 43922.00, 2),
(4, 4, 'Teaching Assistant', 4, 37411.00, 2),
(5, 5, 'Senior Lecturer', 5, 27355.00, 2),
(6, 6, 'Administrator', 6, 50981.00, 1),
(7, 7, 'Professor', 7, 42104.00, NULL),
(8, 8, 'Lecturer', 8, 39788.00, 7),
(9, 9, 'Teaching Assistant', 9, 38555.00, 7),
(10, 10, 'Senior Lecturer', 10, 31544.00, 7);

-- 5. DEPARTMENT MANAGERS

INSERT INTO department_manager (department_id, manager_id) VALUES
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5),
(6, 6), (7, 7), (8, 8), (9, 9), (10, 10);

-- 6. CONTACT INFO & SKILLS

-- Emails
INSERT INTO email (employee_id, email, email_type) VALUES
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

-- Telephones
INSERT INTO telephone (employee_id, phone_number, phone_type) VALUES
(1, '070-1112233', 'Mobile'),
(2, '070-2223344', 'Mobile'),
(3, '070-3334455', 'Mobile'),
(4, '070-4445566', 'Mobile'),
(5, '070-5556677', 'Mobile'),
(6, '070-6667788', 'Mobile'),
(7, '070-7778899', 'Mobile'),
(8, '070-8889900', 'Mobile'),
(9, '070-9990011', 'Mobile'),
(10, '070-0001122', 'Mobile');

-- Skills
INSERT INTO skills (employee_id, skill) VALUES
(1, 'Teaching'), (1, 'Budgeting'),
(2, 'Research'), (2, 'Python'),
(3, 'C++'), (3, 'Teaching'),
(4, 'Matlab'),
(5, 'Architecture'),
(6, 'Administration'),
(7, 'SQL'), (7, 'Research'),
(8, 'Chemistry'),
(9, 'Mathematics'),
(10, 'Physics');

-- 7. SALARY HISTORY

INSERT INTO salary_history (employee_id, salary, payment_date) VALUES
(1, 50312.00, '2023-04-12'), (1, 51532.00, '2024-02-23'),
(2, 42987.00, '2022-11-03'),
(3, 43922.00, '2023-06-28'),
(4, 37411.00, '2024-02-14'),
(5, 27355.00, '2022-12-19'),
(6, 50981.00, '2024-07-01'),
(7, 42104.00, '2023-08-11'),
(8, 39788.00, '2024-01-07'),
(9, 38555.00, '2022-10-22'),
(10, 31544.00, '2023-03-18');

-- 8. COURSEWARE

-- Course Layouts
INSERT INTO course_layout (course_layout_id, course_code, course_name, min_students, max_students) VALUES
(1, 'IV1351', 'Data Storage Paradigms', 50, 150),
(2, 'IX1500', 'Discrete Mathematics', 70, 125);

-- Course Instances
INSERT INTO course_instance (course_instance_id, course_layout_id, amount_of_students, year) VALUES
(1, 1, 120, 2025),
(2, 1, 103, 2025),
(3, 2, 118, 2025);

-- Course Instance Periods
INSERT INTO course_instance_period (course_instance_id, study_period, hp) VALUES
(1, 'P1', 7.5),
(2, 'P3', 7.5),
(3, 'P1', 7.5);

-- 9. COURSE ACTIVITIES

INSERT INTO course_activity (course_activity_id, course_instance_id, hp, activity_type) VALUES
(1, 1, 1.5, 'Lecture'),
(2, 1, 3.0, 'Lab'),
(3, 1, 3.0, 'Examination'),
(4, 3, 2.0, 'Lecture'),
(5, 3, 5.5, 'Seminar');

-- 10. COURSE EMPLOYEE

INSERT INTO course_employee (job_id, course_instance_id) VALUES
(3, 1),
(8, 1),
(4, 1),
(2, 3),
(9, 3);

-- 11. RESET SEQUENCES

SELECT setval('department_department_id_seq', (SELECT MAX(department_id) FROM department));
SELECT setval('employee_employee_id_seq', (SELECT MAX(employee_id) FROM employee));
SELECT setval('job_job_id_seq', (SELECT MAX(job_id) FROM job));
SELECT setval('course_layout_course_layout_id_seq', (SELECT MAX(course_layout_id) FROM course_layout));
SELECT setval('course_instance_course_instance_id_seq', (SELECT MAX(course_instance_id) FROM course_instance));
SELECT setval('course_activity_course_activity_id_seq', (SELECT MAX(course_activity_id) FROM course_activity));