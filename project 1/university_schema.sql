--------------------------------------------------------------------------------------------------------
-- TRIGGER FUNCTION: MAX 4 COURSES PER PERIOD
CREATE OR REPLACE FUNCTION "max_course_allocation"()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    max_limit INT := 4;
    current_count INT;
    rec_period RECORD;
    target_year INT;
BEGIN
    SELECT "year" INTO target_year
    FROM "course_instance"
    WHERE "course_instance_id" = NEW."course_instance_id";

    FOR rec_period IN 
        SELECT "study_period" 
        FROM "course_instance_period" 
        WHERE "course_instance_id" = NEW."course_instance_id"
    LOOP
        SELECT COUNT(DISTINCT wa."course_instance_id") INTO current_count
        FROM "work_allocation" wa
        JOIN "course_instance" ci ON wa."course_instance_id" = ci."course_instance_id"
        JOIN "course_instance_period" cip ON ci."course_instance_id" = cip."course_instance_id"
        WHERE wa."employee_id" = NEW."employee_id"
          AND ci."year" = target_year
          AND cip."study_period" = rec_period."study_period"
          AND wa."course_instance_id" != NEW."course_instance_id"; 

        IF current_count >= max_limit THEN
            RAISE EXCEPTION 'Teacher % is already assigned to % courses in period % (Max allowed: %).', 
                NEW."employee_id", current_count, rec_period."study_period", max_limit;
        END IF;
    END LOOP;

    RETURN NEW;
END;
$$;

-- TRIGGER CREATION
CREATE TRIGGER "enforce_max_course_allocation"
BEFORE INSERT OR UPDATE ON "work_allocation"
FOR EACH ROW EXECUTE FUNCTION "max_course_allocation"();
--------------------------------------------------------------------------------------------------------

--Create the custom type for study periods
CREATE TYPE "study_period" AS ENUM ('P1', 'P2', 'P3', 'P4');

--Create Department (Without the Manager FK yet)
CREATE TABLE "department" (
  "department_id" SERIAL,
  "department_name" VARCHAR(100) NOT NULL UNIQUE,
  "manager_id" INT UNIQUE,
  PRIMARY KEY ("department_id")
);

--Create Job Title
CREATE TABLE "job_title" (
  "job_title_id" SERIAL,
  "job_title" VARCHAR(100) NOT NULL UNIQUE,
  PRIMARY KEY ("job_title_id")
);

--Create Employee
CREATE TABLE "employee" (
  "employee_id" SERIAL,
  "person_number" CHAR(10) UNIQUE,
  "first_name" VARCHAR(50) NOT NULL,
  "last_name" VARCHAR(50) NOT NULL,
  "department_id" INT NOT NULL,
  "job_title_id" INT NOT NULL,
  PRIMARY KEY ("employee_id"),
  CONSTRAINT "FK_employee_department_id"
    FOREIGN KEY ("department_id")
      REFERENCES "department"("department_id")
      ON DELETE RESTRICT
      ON UPDATE CASCADE,
  CONSTRAINT "FK_employee_job_title_id"
    FOREIGN KEY ("job_title_id")
      REFERENCES "job_title"("job_title_id")
      ON DELETE RESTRICT
      ON UPDATE CASCADE
);

--Telephone
CREATE TABLE "telephone" (
  "phone_number" VARCHAR(16),
  "employee_id" INT NOT NULL,
  "phone_type" VARCHAR(32) DEFAULT 'Mobile',
  PRIMARY KEY ("phone_number"),
  CONSTRAINT "UQ_employee_phone_type" UNIQUE ("employee_id", "phone_type"),
  CONSTRAINT "FK_telephone_employee_id"
    FOREIGN KEY ("employee_id")
      REFERENCES "employee"("employee_id")
      ON DELETE CASCADE
      ON UPDATE CASCADE
);

--Defined Skills
CREATE TABLE "defined_skills" (
  "skill_id" SERIAL,
  "skill" VARCHAR(100),
  PRIMARY KEY ("skill_id")
);

--Skills
CREATE TABLE "skills" (
  "skill_id" INT,
  "employee_id" INT,
  PRIMARY KEY ("skill_id", "employee_id"),
  CONSTRAINT "FK_skills_skill_id"
    FOREIGN KEY ("skill_id")
      REFERENCES "defined_skills"("skill_id")
      ON DELETE CASCADE
      ON UPDATE CASCADE,
  CONSTRAINT "FK_skills_employee_id"
    FOREIGN KEY ("employee_id")
      REFERENCES "employee"("employee_id")
      ON DELETE CASCADE
      ON UPDATE CASCADE
);

--Activity Type
CREATE TABLE "activity_type" (
  "activity_id" SERIAL,
  "activity_name" VARCHAR(30) NOT NULL UNIQUE,
  "time_factor" DECIMAL(4, 2) NOT NULL DEFAULT 1.00,
  PRIMARY KEY ("activity_id")
);

--Course Layout
CREATE TABLE "course_layout" (
  "course_layout_id" SERIAL,
  "course_code" CHAR(6) UNIQUE,
  "course_name" VARCHAR(64) NOT NULL,
  "hp" DECIMAL(4, 2) NOT NULL,
  "min_students" INT DEFAULT 0,
  "max_students" INT,
  PRIMARY KEY ("course_layout_id")
);

--Course Instance
CREATE TABLE "course_instance" (
  "course_instance_id" SERIAL,
  "course_layout_id" INT NOT NULL,
  "amount_of_students" INT NOT NULL DEFAULT 0,
  "year" INT NOT NULL,
  PRIMARY KEY ("course_instance_id"),
  CONSTRAINT "FK_course_instance_course_layout_id"
    FOREIGN KEY ("course_layout_id")
      REFERENCES "course_layout"("course_layout_id")
      ON DELETE RESTRICT
      ON UPDATE CASCADE
);

--Work Allocation
CREATE TABLE "work_allocation" (
  "employee_id" INT NOT NULL,
  "course_instance_id" INT NOT NULL,
  "activity_id" INT NOT NULL,
  "allocated_hours" DECIMAL(6, 2) NOT NULL DEFAULT 0,
  PRIMARY KEY ("employee_id", "course_instance_id", "activity_id"),
  CONSTRAINT "FK_work_allocation_employee_id"
    FOREIGN KEY ("employee_id")
      REFERENCES "employee"("employee_id")
      ON DELETE CASCADE
      ON UPDATE CASCADE,
  CONSTRAINT "FK_work_allocation_course_instance_id"
    FOREIGN KEY ("course_instance_id")
      REFERENCES "course_instance"("course_instance_id")
      ON DELETE CASCADE
      ON UPDATE CASCADE,
  CONSTRAINT "FK_work_allocation_activity_id"
    FOREIGN KEY ("activity_id")
      REFERENCES "activity_type"("activity_id")
      ON DELETE RESTRICT
      ON UPDATE CASCADE
);

--Planned Activity
CREATE TABLE "planned_activity" (
  "course_instance_id" INT NOT NULL,
  "activity_id" INT NOT NULL,
  "planned_hours" DECIMAL(6, 2) NOT NULL,
  PRIMARY KEY ("course_instance_id", "activity_id"),
  CONSTRAINT "FK_planned_activity_course_instance_id"
    FOREIGN KEY ("course_instance_id")
      REFERENCES "course_instance"("course_instance_id")
      ON DELETE CASCADE
      ON UPDATE CASCADE,
  CONSTRAINT "FK_planned_activity_activity_id"
    FOREIGN KEY ("activity_id")
      REFERENCES "activity_type"("activity_id")
      ON DELETE RESTRICT
      ON UPDATE CASCADE
);

--Defined Interests
CREATE TABLE "defined_interests" (
  "interest_id" SERIAL,
  "interest" VARCHAR(100),
  PRIMARY KEY ("interest_id")
);

--Interests
CREATE TABLE "interests" (
  "interest_id" INT,
  "employee_id" INT,
  PRIMARY KEY ("interest_id", "employee_id"),
  CONSTRAINT "FK_interests_interest_id"
    FOREIGN KEY ("interest_id")
      REFERENCES "defined_interests"("interest_id")
      ON DELETE CASCADE
      ON UPDATE CASCADE,
  CONSTRAINT "FK_interests_employee_id"
    FOREIGN KEY ("employee_id")
      REFERENCES "employee"("employee_id")
      ON DELETE CASCADE
      ON UPDATE CASCADE
);

--Course Instance Period
CREATE TABLE "course_instance_period" (
  "course_instance_id" INT,
  "study_period" "study_period",
  "course_instance_period_hp" DECIMAL(4, 2) NOT NULL,
  PRIMARY KEY ("course_instance_id", "study_period"),
  CONSTRAINT "FK_course_instance_period_course_instance_id"
    FOREIGN KEY ("course_instance_id")
      REFERENCES "course_instance"("course_instance_id")
      ON DELETE CASCADE
      ON UPDATE CASCADE
);

--Salary History
CREATE TABLE "salary_history" (
  "payment_date" DATE NOT NULL,
  "employee_id" INT NOT NULL,
  "salary" DECIMAL(12, 2) NOT NULL,
  PRIMARY KEY ("payment_date", "employee_id"),
  CONSTRAINT "FK_salary_history_employee_id"
    FOREIGN KEY ("employee_id")
      REFERENCES "employee"("employee_id")
      ON DELETE CASCADE
      ON UPDATE CASCADE
);

--Email
CREATE TABLE "email" (
  "email" VARCHAR(256),
  "employee_id" INT NOT NULL,
  "email_type" VARCHAR(32) DEFAULT 'Work',
  PRIMARY KEY ("email"),
  CONSTRAINT "UQ_employee_email_type" UNIQUE ("employee_id", "email_type"),
  CONSTRAINT "FK_email_employee_id"
    FOREIGN KEY ("employee_id")
      REFERENCES "employee"("employee_id")
      ON DELETE CASCADE
      ON UPDATE CASCADE
);

--Add the Manager FK
ALTER TABLE "department"
  ADD CONSTRAINT "FK_department_manager"
    FOREIGN KEY ("manager_id")
      REFERENCES "employee"("employee_id")
      ON DELETE RESTRICT
      ON UPDATE CASCADE;