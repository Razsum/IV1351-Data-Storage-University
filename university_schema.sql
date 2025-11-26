--
-- PostgreSQL database dump
--

\restrict zsipgWgdpSsweQ0LZhB6PshR8ahySUAEHXrk8MA5gPhPtUOvynIeCk03tyNuKzb

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: study_period; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.study_period AS ENUM (
    'P1',
    'P2',
    'P3',
    'P4'
);


ALTER TYPE public.study_period OWNER TO postgres;

--
-- Name: check_employee_course_for_shift(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_employee_course_for_shift() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    assigned BOOLEAN;
BEGIN
SELECT EXISTS (
        SELECT 1
        FROM shift s
        JOIN calendar_activities ca ON s.calendared_activity_id = ca.calendar_activities_id
        JOIN course_activity cact ON ca.course_activity_id = cact.course_activity_id
        JOIN course_employee ce ON cact.course_instance_id = ce.course_instance_id
        WHERE ce.job_id = NEW.job_id
          AND s.calendared_activity_id = NEW.calendared_activity_id
    ) INTO assigned;

    IF NOT assigned THEN
        RAISE EXCEPTION 'Job (job_id %) is not assigned to this course, cannot create shift', NEW.job_id;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.check_employee_course_for_shift() OWNER TO postgres;

--
-- Name: check_max_courses_per_employee(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_max_courses_per_employee() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    course_count INT;
    emp_id INT;
    course_period study_period;
    course_year INT;
BEGIN
    -- Get the employee_id from the job
    SELECT employee_id INTO emp_id
    FROM job
    WHERE job_id = NEW.job_id;

    -- Get the study period and year of the course instance
    SELECT cip.study_period, ci.year INTO course_period, course_year
    FROM course_instance ci
    JOIN course_instance_period cip ON ci.course_instance_id = cip.course_instance_id
    WHERE ci.course_instance_id = NEW.course_instance_id;

    -- Count how many courses this employee already has in the same period and year
    SELECT COUNT(*) INTO course_count
    FROM course_employee ce
    JOIN job j ON ce.job_id = j.job_id
    JOIN course_instance ci ON ce.course_instance_id = ci.course_instance_id
    JOIN course_instance_period cip ON ci.course_instance_id = cip.course_instance_id
    WHERE j.employee_id = emp_id
      AND cip.study_period = course_period
      AND ci.year = course_year;

    IF course_count >= 4 THEN
        RAISE EXCEPTION 'Employee (employee_id %) cannot have more than 4 courses in period % and year %', emp_id, course_period, course_year;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.check_max_courses_per_employee() OWNER TO postgres;

--
-- Name: check_total_hp_for_course(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_total_hp_for_course() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    total_hp numeric(6,2);
    max_hp numeric(6,2);
BEGIN
    -- Get max HP from course_layout
    SELECT cl.hp INTO max_hp
    FROM course_instance ci
    JOIN course_layout cl ON ci.course_layout_id = cl.course_layout_id
    WHERE ci.course_instance_id = NEW.course_instance_id;

    -- Calculate total HP for that course_instance
    SELECT COALESCE(SUM(hp), 0) INTO total_hp
    FROM course_instance_period
    WHERE course_instance_id = NEW.course_instance_id
      AND (study_period <> NEW.study_period OR TG_OP = 'INSERT');

    -- Add NEW.hp to total
    total_hp := total_hp + NEW.hp;

    IF total_hp > max_hp THEN
        RAISE EXCEPTION
            'Total HP for course_instance % exceeds course layout HP (total %, max %)',
            NEW.course_instance_id, total_hp, max_hp;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.check_total_hp_for_course() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: activity_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.activity_type (
    activity_type character varying(100) NOT NULL,
    time_factor numeric(2,1) DEFAULT 1
);


ALTER TABLE public.activity_type OWNER TO postgres;

--
-- Name: calendar_activities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.calendar_activities (
    calendar_activities_id integer NOT NULL,
    course_activity_id integer NOT NULL,
    room character varying(50),
    activity_start timestamp without time zone NOT NULL,
    activity_duration numeric(5,2) NOT NULL,
    CONSTRAINT activity_duration_positive CHECK (((activity_duration IS NULL) OR (activity_duration >= (0)::numeric)))
);


ALTER TABLE public.calendar_activities OWNER TO postgres;

--
-- Name: calendar_activities_calendar_activities_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.calendar_activities_calendar_activities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.calendar_activities_calendar_activities_id_seq OWNER TO postgres;

--
-- Name: calendar_activities_calendar_activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.calendar_activities_calendar_activities_id_seq OWNED BY public.calendar_activities.calendar_activities_id;


--
-- Name: course_activity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.course_activity (
    course_activity_id integer NOT NULL,
    course_instance_id integer NOT NULL,
    activity_type character varying(100) NOT NULL
);


ALTER TABLE public.course_activity OWNER TO postgres;

--
-- Name: course_activity_course_activity_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.course_activity_course_activity_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.course_activity_course_activity_id_seq OWNER TO postgres;

--
-- Name: course_activity_course_activity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.course_activity_course_activity_id_seq OWNED BY public.course_activity.course_activity_id;


--
-- Name: course_employee; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.course_employee (
    job_id integer NOT NULL,
    course_instance_id integer NOT NULL
);


ALTER TABLE public.course_employee OWNER TO postgres;

--
-- Name: course_instance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.course_instance (
    course_instance_id integer NOT NULL,
    course_layout_id integer NOT NULL,
    amount_of_students smallint DEFAULT 0,
    year integer NOT NULL
);


ALTER TABLE public.course_instance OWNER TO postgres;

--
-- Name: course_instance_course_instance_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.course_instance_course_instance_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.course_instance_course_instance_id_seq OWNER TO postgres;

--
-- Name: course_instance_course_instance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.course_instance_course_instance_id_seq OWNED BY public.course_instance.course_instance_id;


--
-- Name: course_instance_period; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.course_instance_period (
    course_instance_id integer NOT NULL,
    study_period public.study_period NOT NULL,
    course_instance_period_hp numeric(4,2) CONSTRAINT course_instance_period_hp_not_null NOT NULL
);


ALTER TABLE public.course_instance_period OWNER TO postgres;

--
-- Name: course_layout; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.course_layout (
    course_layout_id integer NOT NULL,
    course_code character(6),
    course_name character varying(64) NOT NULL,
    min_students integer DEFAULT 0,
    max_students integer,
    hp numeric(4,2) NOT NULL
);


ALTER TABLE public.course_layout OWNER TO postgres;

--
-- Name: course_layout_course_layout_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.course_layout_course_layout_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.course_layout_course_layout_id_seq OWNER TO postgres;

--
-- Name: course_layout_course_layout_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.course_layout_course_layout_id_seq OWNED BY public.course_layout.course_layout_id;


--
-- Name: defined_interests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.defined_interests (
    defined_interest_id integer NOT NULL,
    interest character varying(100) NOT NULL
);


ALTER TABLE public.defined_interests OWNER TO postgres;

--
-- Name: defined_interests_defined_interest_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.defined_interests_defined_interest_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.defined_interests_defined_interest_id_seq OWNER TO postgres;

--
-- Name: defined_interests_defined_interest_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.defined_interests_defined_interest_id_seq OWNED BY public.defined_interests.defined_interest_id;


--
-- Name: defined_skills; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.defined_skills (
    defined_skill_id integer NOT NULL,
    skill character varying(100) NOT NULL
);


ALTER TABLE public.defined_skills OWNER TO postgres;

--
-- Name: defined_skills_defined_skill_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.defined_skills_defined_skill_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.defined_skills_defined_skill_id_seq OWNER TO postgres;

--
-- Name: defined_skills_defined_skill_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.defined_skills_defined_skill_id_seq OWNED BY public.defined_skills.defined_skill_id;


--
-- Name: department; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.department (
    department_id integer NOT NULL,
    department_name character varying(100) NOT NULL
);


ALTER TABLE public.department OWNER TO postgres;

--
-- Name: department_department_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.department_department_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.department_department_id_seq OWNER TO postgres;

--
-- Name: department_department_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.department_department_id_seq OWNED BY public.department.department_id;


--
-- Name: department_manager; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.department_manager (
    department_id integer NOT NULL,
    manager_id integer NOT NULL
);


ALTER TABLE public.department_manager OWNER TO postgres;

--
-- Name: email; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.email (
    email character varying(256) NOT NULL,
    employee_id integer NOT NULL,
    email_type character varying(32) DEFAULT 'Work'::character varying
);


ALTER TABLE public.email OWNER TO postgres;

--
-- Name: employee; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employee (
    employee_id integer NOT NULL,
    person_number character(10),
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    street character varying(100),
    zip character varying(5),
    city character varying(50)
);


ALTER TABLE public.employee OWNER TO postgres;

--
-- Name: employee_employee_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.employee_employee_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.employee_employee_id_seq OWNER TO postgres;

--
-- Name: employee_employee_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.employee_employee_id_seq OWNED BY public.employee.employee_id;


--
-- Name: interests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.interests (
    employee_id integer NOT NULL,
    defined_interest_id integer NOT NULL
);


ALTER TABLE public.interests OWNER TO postgres;

--
-- Name: job; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.job (
    job_id integer NOT NULL,
    employee_id integer NOT NULL,
    job_title character varying(32) NOT NULL,
    department_id integer NOT NULL,
    salary numeric(8,2) DEFAULT 0,
    supervisor_id integer
);


ALTER TABLE public.job OWNER TO postgres;

--
-- Name: job_job_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.job_job_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.job_job_id_seq OWNER TO postgres;

--
-- Name: job_job_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.job_job_id_seq OWNED BY public.job.job_id;


--
-- Name: salary_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.salary_history (
    employee_id integer NOT NULL,
    salary numeric(12,2) NOT NULL,
    payment_date date NOT NULL
);


ALTER TABLE public.salary_history OWNER TO postgres;

--
-- Name: shift; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shift (
    job_id integer NOT NULL,
    calendared_activity_id integer NOT NULL
);


ALTER TABLE public.shift OWNER TO postgres;

--
-- Name: skills; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.skills (
    employee_id integer NOT NULL,
    defined_skill_id integer NOT NULL
);


ALTER TABLE public.skills OWNER TO postgres;

--
-- Name: telephone; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.telephone (
    phone_number character varying(16) NOT NULL,
    employee_id integer NOT NULL,
    phone_type character varying(32) DEFAULT 'Mobile'::character varying
);


ALTER TABLE public.telephone OWNER TO postgres;

--
-- Name: calendar_activities calendar_activities_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calendar_activities ALTER COLUMN calendar_activities_id SET DEFAULT nextval('public.calendar_activities_calendar_activities_id_seq'::regclass);


--
-- Name: course_activity course_activity_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course_activity ALTER COLUMN course_activity_id SET DEFAULT nextval('public.course_activity_course_activity_id_seq'::regclass);


--
-- Name: course_instance course_instance_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course_instance ALTER COLUMN course_instance_id SET DEFAULT nextval('public.course_instance_course_instance_id_seq'::regclass);


--
-- Name: course_layout course_layout_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course_layout ALTER COLUMN course_layout_id SET DEFAULT nextval('public.course_layout_course_layout_id_seq'::regclass);


--
-- Name: defined_interests defined_interest_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.defined_interests ALTER COLUMN defined_interest_id SET DEFAULT nextval('public.defined_interests_defined_interest_id_seq'::regclass);


--
-- Name: defined_skills defined_skill_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.defined_skills ALTER COLUMN defined_skill_id SET DEFAULT nextval('public.defined_skills_defined_skill_id_seq'::regclass);


--
-- Name: department department_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department ALTER COLUMN department_id SET DEFAULT nextval('public.department_department_id_seq'::regclass);


--
-- Name: employee employee_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee ALTER COLUMN employee_id SET DEFAULT nextval('public.employee_employee_id_seq'::regclass);


--
-- Name: job job_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job ALTER COLUMN job_id SET DEFAULT nextval('public.job_job_id_seq'::regclass);


--
-- Name: activity_type activity_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_type
    ADD CONSTRAINT activity_type_pkey PRIMARY KEY (activity_type);


--
-- Name: calendar_activities calendar_activities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calendar_activities
    ADD CONSTRAINT calendar_activities_pkey PRIMARY KEY (calendar_activities_id);


--
-- Name: course_activity course_activity_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course_activity
    ADD CONSTRAINT course_activity_pkey PRIMARY KEY (course_activity_id);


--
-- Name: course_employee course_employee_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course_employee
    ADD CONSTRAINT course_employee_pkey PRIMARY KEY (job_id, course_instance_id);


--
-- Name: course_instance_period course_instance_period_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course_instance_period
    ADD CONSTRAINT course_instance_period_pkey PRIMARY KEY (course_instance_id, study_period);


--
-- Name: course_instance course_instance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course_instance
    ADD CONSTRAINT course_instance_pkey PRIMARY KEY (course_instance_id);


--
-- Name: course_layout course_layout_course_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course_layout
    ADD CONSTRAINT course_layout_course_code_key UNIQUE (course_code);


--
-- Name: course_layout course_layout_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course_layout
    ADD CONSTRAINT course_layout_pkey PRIMARY KEY (course_layout_id);


--
-- Name: defined_interests defined_interests_interest_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.defined_interests
    ADD CONSTRAINT defined_interests_interest_key UNIQUE (interest);


--
-- Name: defined_interests defined_interests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.defined_interests
    ADD CONSTRAINT defined_interests_pkey PRIMARY KEY (defined_interest_id);


--
-- Name: defined_skills defined_skills_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.defined_skills
    ADD CONSTRAINT defined_skills_pkey PRIMARY KEY (defined_skill_id);


--
-- Name: defined_skills defined_skills_skill_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.defined_skills
    ADD CONSTRAINT defined_skills_skill_key UNIQUE (skill);


--
-- Name: department department_department_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department
    ADD CONSTRAINT department_department_name_key UNIQUE (department_name);


--
-- Name: department_manager department_manager_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department_manager
    ADD CONSTRAINT department_manager_pkey PRIMARY KEY (department_id, manager_id);


--
-- Name: department department_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department
    ADD CONSTRAINT department_pkey PRIMARY KEY (department_id);


--
-- Name: email email_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email
    ADD CONSTRAINT email_pkey PRIMARY KEY (email);


--
-- Name: employee employee_person_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_person_number_key UNIQUE (person_number);


--
-- Name: employee employee_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (employee_id);


--
-- Name: interests interests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interests
    ADD CONSTRAINT interests_pkey PRIMARY KEY (employee_id, defined_interest_id);


--
-- Name: job job_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job
    ADD CONSTRAINT job_pkey PRIMARY KEY (job_id);


--
-- Name: salary_history salary_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salary_history
    ADD CONSTRAINT salary_history_pkey PRIMARY KEY (employee_id, payment_date);


--
-- Name: shift shift_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shift
    ADD CONSTRAINT shift_pkey PRIMARY KEY (job_id, calendared_activity_id);


--
-- Name: skills skills_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.skills
    ADD CONSTRAINT skills_pkey PRIMARY KEY (employee_id, defined_skill_id);


--
-- Name: telephone telephone_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telephone
    ADD CONSTRAINT telephone_pkey PRIMARY KEY (phone_number);


--
-- Name: email uq_employee_emailtype; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email
    ADD CONSTRAINT uq_employee_emailtype UNIQUE (employee_id, email_type);


--
-- Name: telephone uq_employee_phonetype; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telephone
    ADD CONSTRAINT uq_employee_phonetype UNIQUE (employee_id, phone_type);


--
-- Name: course_employee max_courses_per_employee; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER max_courses_per_employee BEFORE INSERT ON public.course_employee FOR EACH ROW EXECUTE FUNCTION public.check_max_courses_per_employee();


--
-- Name: shift shift_course_employee_check; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER shift_course_employee_check BEFORE INSERT OR UPDATE ON public.shift FOR EACH ROW EXECUTE FUNCTION public.check_employee_course_for_shift();


--
-- Name: course_instance_period trg_check_hp_limit; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_check_hp_limit BEFORE INSERT OR UPDATE ON public.course_instance_period FOR EACH ROW EXECUTE FUNCTION public.check_total_hp_for_course();


--
-- Name: course_activity fk_ca_ci; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course_activity
    ADD CONSTRAINT fk_ca_ci FOREIGN KEY (course_instance_id) REFERENCES public.course_instance(course_instance_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: course_activity fk_ca_type; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course_activity
    ADD CONSTRAINT fk_ca_type FOREIGN KEY (activity_type) REFERENCES public.activity_type(activity_type) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: calendar_activities fk_cal_ca; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calendar_activities
    ADD CONSTRAINT fk_cal_ca FOREIGN KEY (course_activity_id) REFERENCES public.course_activity(course_activity_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: course_employee fk_ce_ci; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course_employee
    ADD CONSTRAINT fk_ce_ci FOREIGN KEY (course_instance_id) REFERENCES public.course_instance(course_instance_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: course_employee fk_ce_job; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course_employee
    ADD CONSTRAINT fk_ce_job FOREIGN KEY (job_id) REFERENCES public.job(job_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: course_instance fk_ci_layout; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course_instance
    ADD CONSTRAINT fk_ci_layout FOREIGN KEY (course_layout_id) REFERENCES public.course_layout(course_layout_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: course_instance_period fk_cip_ci; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course_instance_period
    ADD CONSTRAINT fk_cip_ci FOREIGN KEY (course_instance_id) REFERENCES public.course_instance(course_instance_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: interests fk_defined_interest; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interests
    ADD CONSTRAINT fk_defined_interest FOREIGN KEY (defined_interest_id) REFERENCES public.defined_interests(defined_interest_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: skills fk_defined_skill; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.skills
    ADD CONSTRAINT fk_defined_skill FOREIGN KEY (defined_skill_id) REFERENCES public.defined_skills(defined_skill_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: department_manager fk_dm_department; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department_manager
    ADD CONSTRAINT fk_dm_department FOREIGN KEY (department_id) REFERENCES public.department(department_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: department_manager fk_dm_manager; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department_manager
    ADD CONSTRAINT fk_dm_manager FOREIGN KEY (manager_id) REFERENCES public.job(job_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: email fk_email_employee; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email
    ADD CONSTRAINT fk_email_employee FOREIGN KEY (employee_id) REFERENCES public.employee(employee_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: interests fk_interest_employee; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interests
    ADD CONSTRAINT fk_interest_employee FOREIGN KEY (employee_id) REFERENCES public.employee(employee_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: job fk_job_department; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job
    ADD CONSTRAINT fk_job_department FOREIGN KEY (department_id) REFERENCES public.department(department_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: job fk_job_employee; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job
    ADD CONSTRAINT fk_job_employee FOREIGN KEY (employee_id) REFERENCES public.employee(employee_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: job fk_job_supervisor; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job
    ADD CONSTRAINT fk_job_supervisor FOREIGN KEY (supervisor_id) REFERENCES public.job(job_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: salary_history fk_salary_employee; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.salary_history
    ADD CONSTRAINT fk_salary_employee FOREIGN KEY (employee_id) REFERENCES public.employee(employee_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: shift fk_shift_cal; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shift
    ADD CONSTRAINT fk_shift_cal FOREIGN KEY (calendared_activity_id) REFERENCES public.calendar_activities(calendar_activities_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: shift fk_shift_job; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shift
    ADD CONSTRAINT fk_shift_job FOREIGN KEY (job_id) REFERENCES public.job(job_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: skills fk_skill_employee; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.skills
    ADD CONSTRAINT fk_skill_employee FOREIGN KEY (employee_id) REFERENCES public.employee(employee_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: telephone fk_tel_employee; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telephone
    ADD CONSTRAINT fk_tel_employee FOREIGN KEY (employee_id) REFERENCES public.employee(employee_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict zsipgWgdpSsweQ0LZhB6PshR8ahySUAEHXrk8MA5gPhPtUOvynIeCk03tyNuKzb

