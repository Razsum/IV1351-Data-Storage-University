-- Clean up existing data
TRUNCATE TABLE 
shift, calendar_activities, course_employee, course_activity, 
course_instance_period, course_instance, course_layout, 
skills, defined_skills, interests, defined_interests, 
salary_history, job, department_manager, department, email, telephone, 
employee, activity_type CASCADE;

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
(3, 'Mathematics'),

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
(1, 1, 'Administrator',      1, 51532.00, NULL),
(2, 2, 'Professor',          1, 42987.00, 1),
(3, 3, 'Lecturer',           1, 43922.00, 1),
(4, 4, 'Teaching Assistant', 1, 500.00,   1),

(7, 7, 'Professor',          2, 42104.00, NULL),
(5, 5, 'Senior Lecturer',    2, 27355.00, 7),
(6, 6, 'Administrator',      2, 50981.00, 7),

(10, 10, 'Administrator',    3, 31544.00, NULL);
(8, 8, 'Lecturer',           3, 39788.00, 10),
(9, 9, 'Teaching Assistant', 3, 500.00,   10),

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
INSERT INTO defined_skills (defined_skill_id, skill) VALUES
(1, 'Teaching'),
(2, 'Budgeting'), 
(3, 'Research'),
(4, 'Python'), 
(5, 'C++'), 
(6, 'Matlab'),
(7, 'Architecture'),
(8, 'Administration'),
(9, 'SQL'),
(10, 'Chemistry'),
(11, 'Mathematics'),
(12, 'Physics');

INSERT INTO skills (employee_id, defined_skill_id) VALUES
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

-- Interests
INSERT INTO defined_interests (defined_interest_id, interest) VALUES
(1, 'Artificial Intelligence'),
(2, 'Data Analysis'),
(3, 'Machine Learning'),
(4, 'Cybersecurity'),
(5, 'Project Management'),
(6, 'Software Engineering'),
(7, 'Environmental Science'),
(8, 'Electronics'),
(9, 'Mechanical Design'),
(10, 'Statistics'),
(11, 'Biology'),
(12, 'Networking & Systems');

INSERT INTO interests (employee_id, defined_interest_id) VALUES
(1, 1), (1, 2),
(2, 3), (2, 4),
(3, 5), (3, 6),
(4, 2), (4, 10),
(5, 7), (5, 11),
(6, 5), (6, 12),
(7, 8), (7, 9),
(8, 10), (8, 4),
(9, 1), (9, 3),
(10, 6), (10, 12);

-- 7. SALARY HISTORY

INSERT INTO salary_history (employee_id, salary, payment_date) VALUES
(1, 50312.00, '2023-04-12'),
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
INSERT INTO course_layout (course_layout_id, course_code, course_name, min_students, max_students, hp) VALUES
(1, 'IV1351', 'Data Storage Paradigms', 50, 150, 7.5),
(2, 'IX1500', 'Discrete Mathematics', 70, 125, 7.5),
(3, 'IV1350', 'Object-oriented Design', 50, 150, 7.5),
(4, 'DH2642', 'Interaction Programming and the Dynamic Web', 70, 150, 7.5);

-- Course Instances
INSERT INTO course_instance (course_instance_id, course_layout_id, amount_of_students, year) VALUES
(1, 1, 120, 2025),
(2, 1, 103, 2025),
(3, 2, 118, 2025),
(4, 3, 125, 2025), 
(5, 4, 120, 2025);

-- Course Instance Periods
INSERT INTO course_instance_period (course_instance_id, study_period, hp) VALUES
(1, 'P1', 7.5),
(2, 'P3', 7.5),
(3, 'P1', 7.5);
(4, 'P2', 7.5);
(5, 'P4', 7.5);

-- 9. COURSE ACTIVITIES

INSERT INTO course_activity (course_activity_id, course_instance_id, hp, activity_type) VALUES
(1, 1, 1.5, 'Lecture'),
(2, 1, 3.0, 'Lab'),
(3, 1, 3.0, 'Examination'),
(4, 3, 1.5, 'Lecture'),
(5, 3, 6.0, 'Seminar'),
(6, 4, 3.0, 'Seminar'),
(7, 4, 4.5, 'Examination'),
(8, 5, 2.0, 'Lecture'),
(9, 5, 5.5, 'Lab'),
(10, 2, 4.5, 'Lab'),
(11, 2, 3.0, 'Examination');

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