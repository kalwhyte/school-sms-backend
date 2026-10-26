--
-- PostgreSQL database dump
--

\restrict N2617auEcNwoEykGS7YbN73qAU5yFRRa6FHy3RgKbUVW3CUgjhb91iUQDHsZLJj

-- Dumped from database version 16.14
-- Dumped by pg_dump version 16.14

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: announcement_audiences; Type: TYPE; Schema: public; Owner: school_user
--

CREATE TYPE public.announcement_audiences AS ENUM (
    'all',
    'parents',
    'teachers',
    'class'
);


ALTER TYPE public.announcement_audiences OWNER TO school_user;

--
-- Name: assessment_types; Type: TYPE; Schema: public; Owner: school_user
--

CREATE TYPE public.assessment_types AS ENUM (
    'CA',
    'midterm',
    'exam'
);


ALTER TYPE public.assessment_types OWNER TO school_user;

--
-- Name: attendance_statuses; Type: TYPE; Schema: public; Owner: school_user
--

CREATE TYPE public.attendance_statuses AS ENUM (
    'present',
    'absent',
    'late',
    'excused',
    'sick',
    'suspended',
    'withdrawn'
);


ALTER TYPE public.attendance_statuses OWNER TO school_user;

--
-- Name: class_levels; Type: TYPE; Schema: public; Owner: school_user
--

CREATE TYPE public.class_levels AS ENUM (
    'jss1',
    'jss2',
    'jss3',
    'ss1',
    'ss2',
    'ss3',
    'preNursery',
    'nursery1',
    'nursery2',
    'nursery3',
    'primary1',
    'primary2',
    'primary3',
    'primary4',
    'primary5',
    'primary6'
);


ALTER TYPE public.class_levels OWNER TO school_user;

--
-- Name: class_streams; Type: TYPE; Schema: public; Owner: school_user
--

CREATE TYPE public.class_streams AS ENUM (
    'science',
    'commercial',
    'arts',
    'general'
);


ALTER TYPE public.class_streams OWNER TO school_user;

--
-- Name: days_of_week; Type: TYPE; Schema: public; Owner: school_user
--

CREATE TYPE public.days_of_week AS ENUM (
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday'
);


ALTER TYPE public.days_of_week OWNER TO school_user;

--
-- Name: document_types; Type: TYPE; Schema: public; Owner: school_user
--

CREATE TYPE public.document_types AS ENUM (
    'certificate',
    'transcript',
    'id_card',
    'other'
);


ALTER TYPE public.document_types OWNER TO school_user;

--
-- Name: expense_categories; Type: TYPE; Schema: public; Owner: school_user
--

CREATE TYPE public.expense_categories AS ENUM (
    'salary',
    'utilities',
    'supplies',
    'maintenance',
    'transport',
    'other'
);


ALTER TYPE public.expense_categories OWNER TO school_user;

--
-- Name: genders; Type: TYPE; Schema: public; Owner: school_user
--

CREATE TYPE public.genders AS ENUM (
    'male',
    'female'
);


ALTER TYPE public.genders OWNER TO school_user;

--
-- Name: leave_statuses; Type: TYPE; Schema: public; Owner: school_user
--

CREATE TYPE public.leave_statuses AS ENUM (
    'pending',
    'approved',
    'rejected'
);


ALTER TYPE public.leave_statuses OWNER TO school_user;

--
-- Name: payment_statuses; Type: TYPE; Schema: public; Owner: school_user
--

CREATE TYPE public.payment_statuses AS ENUM (
    'pending',
    'success',
    'failed'
);


ALTER TYPE public.payment_statuses OWNER TO school_user;

--
-- Name: platforms; Type: TYPE; Schema: public; Owner: school_user
--

CREATE TYPE public.platforms AS ENUM (
    'ios',
    'android'
);


ALTER TYPE public.platforms OWNER TO school_user;

--
-- Name: subscription_tiers; Type: TYPE; Schema: public; Owner: school_user
--

CREATE TYPE public.subscription_tiers AS ENUM (
    'free',
    'starter',
    'pro',
    'enterprise'
);


ALTER TYPE public.subscription_tiers OWNER TO school_user;

--
-- Name: terms; Type: TYPE; Schema: public; Owner: school_user
--

CREATE TYPE public.terms AS ENUM (
    'first',
    'second',
    'third'
);


ALTER TYPE public.terms OWNER TO school_user;

--
-- Name: user_roles; Type: TYPE; Schema: public; Owner: school_user
--

CREATE TYPE public.user_roles AS ENUM (
    'admin',
    'class_teacher',
    'subject_teacher',
    'parent',
    'student',
    'principal',
    'vice_principal'
);


ALTER TYPE public.user_roles OWNER TO school_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: school_user
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public._prisma_migrations OWNER TO school_user;

--
-- Name: announcements; Type: TABLE; Schema: public; Owner: school_user
--

CREATE TABLE public.announcements (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    school_id uuid NOT NULL,
    author_id uuid,
    title text NOT NULL,
    body text NOT NULL,
    audience public.announcement_audiences NOT NULL,
    class_id uuid,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.announcements OWNER TO school_user;

--
-- Name: assessments; Type: TABLE; Schema: public; Owner: school_user
--

CREATE TABLE public.assessments (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    subject_id uuid NOT NULL,
    title text NOT NULL,
    type public.assessment_types NOT NULL,
    max_score numeric NOT NULL,
    passing_score numeric,
    date date NOT NULL,
    is_published boolean DEFAULT false NOT NULL,
    created_by uuid,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    academic_year text,
    term public.terms
);


ALTER TABLE public.assessments OWNER TO school_user;

--
-- Name: attendance; Type: TABLE; Schema: public; Owner: school_user
--

CREATE TABLE public.attendance (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_id uuid NOT NULL,
    class_id uuid NOT NULL,
    date date NOT NULL,
    status public.attendance_statuses NOT NULL,
    recorded_by uuid,
    recorded_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    reason text
);


ALTER TABLE public.attendance OWNER TO school_user;

--
-- Name: bursary_approvals; Type: TABLE; Schema: public; Owner: school_user
--

CREATE TABLE public.bursary_approvals (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_id uuid NOT NULL,
    school_id uuid NOT NULL,
    discount_amount numeric NOT NULL,
    reason text NOT NULL,
    approved_by uuid,
    term public.terms,
    academic_year text,
    approved_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.bursary_approvals OWNER TO school_user;

--
-- Name: class_enrollments; Type: TABLE; Schema: public; Owner: school_user
--

CREATE TABLE public.class_enrollments (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    class_id uuid NOT NULL,
    student_id uuid NOT NULL,
    enrolled_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.class_enrollments OWNER TO school_user;

--
-- Name: classes; Type: TABLE; Schema: public; Owner: school_user
--

CREATE TABLE public.classes (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    school_id uuid NOT NULL,
    name text NOT NULL,
    arm text NOT NULL,
    teacher_id uuid,
    academic_year text NOT NULL,
    term public.terms NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    level public.class_levels,
    stream public.class_streams
);


ALTER TABLE public.classes OWNER TO school_user;

--
-- Name: documents; Type: TABLE; Schema: public; Owner: school_user
--

CREATE TABLE public.documents (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_id uuid NOT NULL,
    school_id uuid NOT NULL,
    type public.document_types NOT NULL,
    file_url text NOT NULL,
    filename text NOT NULL,
    uploaded_by uuid,
    uploaded_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.documents OWNER TO school_user;

--
-- Name: expense_records; Type: TABLE; Schema: public; Owner: school_user
--

CREATE TABLE public.expense_records (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    school_id uuid NOT NULL,
    description text NOT NULL,
    amount numeric NOT NULL,
    category public.expense_categories NOT NULL,
    recorded_by uuid,
    date date NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.expense_records OWNER TO school_user;

--
-- Name: fee_structures; Type: TABLE; Schema: public; Owner: school_user
--

CREATE TABLE public.fee_structures (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    school_id uuid NOT NULL,
    class_id uuid NOT NULL,
    term public.terms NOT NULL,
    academic_year text NOT NULL,
    amount numeric NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.fee_structures OWNER TO school_user;

--
-- Name: leave_requests; Type: TABLE; Schema: public; Owner: school_user
--

CREATE TABLE public.leave_requests (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_id uuid NOT NULL,
    school_id uuid NOT NULL,
    submitted_by uuid,
    reason text NOT NULL,
    from_date date NOT NULL,
    to_date date NOT NULL,
    status public.leave_statuses DEFAULT 'pending'::public.leave_statuses NOT NULL,
    decision_note text,
    decided_by uuid,
    decided_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.leave_requests OWNER TO school_user;

--
-- Name: message_threads; Type: TABLE; Schema: public; Owner: school_user
--

CREATE TABLE public.message_threads (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    school_id uuid NOT NULL,
    parent_id uuid NOT NULL,
    teacher_id uuid NOT NULL,
    student_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.message_threads OWNER TO school_user;

--
-- Name: messages; Type: TABLE; Schema: public; Owner: school_user
--

CREATE TABLE public.messages (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    thread_id uuid NOT NULL,
    sender_id uuid NOT NULL,
    body text NOT NULL,
    sent_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    read_at timestamp with time zone
);


ALTER TABLE public.messages OWNER TO school_user;

--
-- Name: notifications; Type: TABLE; Schema: public; Owner: school_user
--

CREATE TABLE public.notifications (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    school_id uuid NOT NULL,
    title text NOT NULL,
    body text NOT NULL,
    type text NOT NULL,
    data jsonb,
    is_system boolean DEFAULT false NOT NULL,
    is_read boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.notifications OWNER TO school_user;

--
-- Name: otp_codes; Type: TABLE; Schema: public; Owner: school_user
--

CREATE TABLE public.otp_codes (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    phone text NOT NULL,
    code text NOT NULL,
    school_code text NOT NULL,
    is_used boolean DEFAULT false NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.otp_codes OWNER TO school_user;

--
-- Name: parent_student; Type: TABLE; Schema: public; Owner: school_user
--

CREATE TABLE public.parent_student (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    parent_id uuid NOT NULL,
    student_id uuid NOT NULL,
    relationship text DEFAULT 'guardian'::text NOT NULL
);


ALTER TABLE public.parent_student OWNER TO school_user;

--
-- Name: parents; Type: TABLE; Schema: public; Owner: school_user
--

CREATE TABLE public.parents (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    school_id uuid NOT NULL,
    full_name text NOT NULL,
    phone text NOT NULL,
    email text,
    occupation text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.parents OWNER TO school_user;

--
-- Name: payment_receipts; Type: TABLE; Schema: public; Owner: school_user
--

CREATE TABLE public.payment_receipts (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    payment_id uuid NOT NULL,
    pdf_url text NOT NULL,
    generated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.payment_receipts OWNER TO school_user;

--
-- Name: payments; Type: TABLE; Schema: public; Owner: school_user
--

CREATE TABLE public.payments (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_id uuid NOT NULL,
    school_id uuid NOT NULL,
    amount numeric NOT NULL,
    paystack_reference text,
    paystack_access_code text,
    payment_method text DEFAULT 'paystack'::text NOT NULL,
    status public.payment_statuses DEFAULT 'pending'::public.payment_statuses NOT NULL,
    term public.terms,
    academic_year text,
    paid_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.payments OWNER TO school_user;

--
-- Name: push_tokens; Type: TABLE; Schema: public; Owner: school_user
--

CREATE TABLE public.push_tokens (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    token text NOT NULL,
    platform public.platforms NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.push_tokens OWNER TO school_user;

--
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: school_user
--

CREATE TABLE public.refresh_tokens (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    token_hash text NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    revoked_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.refresh_tokens OWNER TO school_user;

--
-- Name: report_cards; Type: TABLE; Schema: public; Owner: school_user
--

CREATE TABLE public.report_cards (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_id uuid NOT NULL,
    class_id uuid NOT NULL,
    term public.terms NOT NULL,
    academic_year text NOT NULL,
    pdf_url text,
    is_published boolean DEFAULT false NOT NULL,
    published_at timestamp with time zone,
    generated_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    attendance_days_absent integer,
    attendance_days_present integer,
    attendance_percentage numeric,
    average_score numeric,
    class_position integer,
    class_teacher_remark text,
    next_term_begins date,
    principal_remark text,
    total_score numeric,
    total_students_in_class integer
);


ALTER TABLE public.report_cards OWNER TO school_user;

--
-- Name: schools; Type: TABLE; Schema: public; Owner: school_user
--

CREATE TABLE public.schools (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name text NOT NULL,
    address text NOT NULL,
    logo_url text,
    school_code text NOT NULL,
    subscription_tier public.subscription_tiers DEFAULT 'free'::public.subscription_tiers NOT NULL,
    currency text DEFAULT 'NGN'::text NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.schools OWNER TO school_user;

--
-- Name: scores; Type: TABLE; Schema: public; Owner: school_user
--

CREATE TABLE public.scores (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    assessment_id uuid NOT NULL,
    student_id uuid NOT NULL,
    score numeric NOT NULL,
    graded_by uuid,
    graded_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.scores OWNER TO school_user;

--
-- Name: staff; Type: TABLE; Schema: public; Owner: school_user
--

CREATE TABLE public.staff (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid NOT NULL,
    school_id uuid NOT NULL,
    full_name text NOT NULL,
    role_title text NOT NULL,
    subject_specialty text,
    photo_url text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.staff OWNER TO school_user;

--
-- Name: student_fee_ledger; Type: TABLE; Schema: public; Owner: school_user
--

CREATE TABLE public.student_fee_ledger (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    student_id uuid NOT NULL,
    school_id uuid NOT NULL,
    term public.terms NOT NULL,
    academic_year text NOT NULL,
    total_owed numeric DEFAULT 0 NOT NULL,
    total_paid numeric DEFAULT 0 NOT NULL,
    balance numeric DEFAULT 0 NOT NULL,
    last_updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.student_fee_ledger OWNER TO school_user;

--
-- Name: students; Type: TABLE; Schema: public; Owner: school_user
--

CREATE TABLE public.students (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid,
    school_id uuid NOT NULL,
    admission_number text NOT NULL,
    full_name text NOT NULL,
    dob date,
    gender public.genders,
    class_id uuid,
    guardian_name text,
    photo_url text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.students OWNER TO school_user;

--
-- Name: subjects; Type: TABLE; Schema: public; Owner: school_user
--

CREATE TABLE public.subjects (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    school_id uuid NOT NULL,
    name text NOT NULL,
    class_id uuid NOT NULL,
    is_core boolean DEFAULT true NOT NULL,
    teacher_id uuid,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.subjects OWNER TO school_user;

--
-- Name: timetable_periods; Type: TABLE; Schema: public; Owner: school_user
--

CREATE TABLE public.timetable_periods (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    class_id uuid NOT NULL,
    subject_id uuid NOT NULL,
    day_of_week public.days_of_week NOT NULL,
    start_time time without time zone NOT NULL,
    end_time time without time zone NOT NULL
);


ALTER TABLE public.timetable_periods OWNER TO school_user;

--
-- Name: users; Type: TABLE; Schema: public; Owner: school_user
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    school_id uuid NOT NULL,
    phone text NOT NULL,
    email text,
    password_ text,
    role public.user_roles NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    last_login timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    email_verified_at timestamp(6) with time zone,
    phone_verified_at timestamp(6) with time zone
);


ALTER TABLE public.users OWNER TO school_user;

--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: school_user
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
b9c40512-2339-4107-93f8-5649a0ae1d38	6babf0286f52434787ac50dfc5e46716b8cfd8a30bc594369e7a0f5ecfef4703	2026-10-21 08:23:14.449083+00	20261019233958_update	\N	\N	2026-10-21 08:23:14.437771+00	1
eaab4e73-fb8e-42d6-9b83-7b13aacad083	f2fe1188d8cf33de5154ec10784060d702a6e9cec0ba55a827feb433b1ed80cc	2026-10-21 08:23:14.363894+00	20260519201930_init	\N	\N	2026-10-21 08:23:13.733466+00	1
7a719dce-2e74-4e02-ab61-030f039e63c2	6e0c877699fcfb5b4d4b049589fc64008927ab9d2c0d060b7b3ceb1846f6b43e	2026-10-21 08:23:14.374457+00	20260520125429_add_excused_status_sick_suspended_and_reason_to_attendance	\N	\N	2026-10-21 08:23:14.364938+00	1
7555ad53-ce30-4597-b3ec-9a39fa0490ec	182e1c344f59f962a3e5aa2b829120318656a5ce60dc46f83c2a4368d6a4235a	2026-10-21 08:23:14.379978+00	20260520125600_add_withdrawn_to_attendance	\N	\N	2026-10-21 08:23:14.375844+00	1
1b69e401-c502-4299-9474-5e167b8075b0	3312642bc2084e2b1fd85e94adea1a3acaed76bc7975121b3d68257848792ff0	2026-10-21 08:23:14.467006+00	20261021033735_add_contact_verification	\N	\N	2026-10-21 08:23:14.450126+00	1
c22bace1-adbc-4c10-a334-c66539cb3118	55d2a2618336cebe09d92c4d658065e6a43206f296baeecc5396e96a1f2a35f7	2026-10-21 08:23:14.387152+00	20260521074438_add_term_academicyear_to_assessment	\N	\N	2026-10-21 08:23:14.381468+00	1
c19cafdb-f6c7-42f3-8116-9e2a58e4e2b4	bad0159d78fcfdc2ed92a7077213f88659db984b169e1fd9343adbd5e8a19189	\N	20261025151237_add_subject_assignments_resources	\N	\N	2026-10-25 15:12:37.077764+00	0
69553662-6e9a-4aad-9ebd-6f549cadba3e	e1bae112ae7eb2fcefb7db0d3cb92f70057ecaa22c237df58fd65a23daa519e8	2026-10-21 08:23:14.392211+00	20260523125646_add_principal_vice_principal_to_user_roles	\N	\N	2026-10-21 08:23:14.388284+00	1
de735b9b-b668-4b68-8524-948b8ca2bfdb	c1fee898b13bc0fd39cdd0f890f2b22ecea10d1c2767aab08be4f631dbf64f7b	2026-10-21 08:23:14.402495+00	20260524222729_add_level_stream_to_class	\N	\N	2026-10-21 08:23:14.393171+00	1
1072a0d6-58d3-4e0f-90b7-37179c5395a9	950402ccb836e19b35a62efb90b48a119cb91836c3b2f6758f4b90fa5921cab7	2026-10-21 08:23:14.407207+00	20260524222817_make_class_level_required	\N	\N	2026-10-21 08:23:14.403421+00	1
f27cd27b-cf40-4d5c-af23-336af6f262fa	43212374b4cbcfa5e855961bea0f882550f398119e4539d3313718216864bded	2026-10-21 08:23:14.412578+00	20260525001453_add_level_stream_to_class_and_report_card_fields	\N	\N	2026-10-21 08:23:14.408081+00	1
1b053884-076c-4d10-b0aa-cab835193a5b	950402ccb836e19b35a62efb90b48a119cb91836c3b2f6758f4b90fa5921cab7	2026-10-21 08:23:14.418435+00	20260525001704_add_level_stream_to_class	\N	\N	2026-10-21 08:23:14.413848+00	1
1d6cb1cd-4eba-4873-a6d1-81d62b4dd8c7	43212374b4cbcfa5e855961bea0f882550f398119e4539d3313718216864bded	2026-10-21 08:23:14.423051+00	20260525002230_add_level_stream_to_class	\N	\N	2026-10-21 08:23:14.419475+00	1
b1a7a0d5-2207-47f5-a1f1-d8381d69144c	950402ccb836e19b35a62efb90b48a119cb91836c3b2f6758f4b90fa5921cab7	2026-10-21 08:23:14.430208+00	20260525002307_make_class_level_required	\N	\N	2026-10-21 08:23:14.424668+00	1
611487ac-e1fb-43e2-8b89-ad1edcd9a943	43212374b4cbcfa5e855961bea0f882550f398119e4539d3313718216864bded	2026-10-21 08:23:14.436399+00	20260526155551_add_level_stream_to_class	\N	\N	2026-10-21 08:23:14.431683+00	1
\.


--
-- Data for Name: announcements; Type: TABLE DATA; Schema: public; Owner: school_user
--

COPY public.announcements (id, school_id, author_id, title, body, audience, class_id, created_at) FROM stdin;
\.


--
-- Data for Name: assessments; Type: TABLE DATA; Schema: public; Owner: school_user
--

COPY public.assessments (id, subject_id, title, type, max_score, passing_score, date, is_published, created_by, created_at, updated_at, academic_year, term) FROM stdin;
5787c948-3555-4024-b6f9-6eab3a7fffa3	73613eab-a7a0-4905-bf2a-b695d68e8d6d	Mathematics Test	CA	100	40	2026-10-22	f	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-22 19:10:42.521+00	2026-10-22 19:10:42.521+00	\N	\N
3b5b840d-ed4a-44dc-a634-8db1724cf1f1	2d501155-60aa-4aae-824d-b085d90b6201	Animal Farm	CA	100	40	2026-10-27	f	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-22 19:38:32.204+00	2026-10-22 19:38:32.204+00	\N	\N
\.


--
-- Data for Name: attendance; Type: TABLE DATA; Schema: public; Owner: school_user
--

COPY public.attendance (id, student_id, class_id, date, status, recorded_by, recorded_at, reason) FROM stdin;
f2505579-8336-4dc3-abec-e6079fdc1147	d6a71905-e404-4dde-8ff2-71a31e718842	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-21	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-22 20:10:17.353+00	\N
4dabf6ce-702b-42ed-9ada-6cf8de59b590	0d1127ea-8d25-4868-9ce5-63259ad922f1	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-21	absent	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-22 20:10:17.362+00	Late
ee666e18-d9df-4136-846e-eb47e6475f6d	95738447-114b-4bfa-8238-1e8ac5880bbb	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-21	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-22 20:10:17.37+00	\N
8895a0ab-ad00-49a2-b25b-b05e361e7fa2	515b9585-847a-421b-8dad-9925fcd7dc7d	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-21	late	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-22 20:10:17.38+00	Late
845e4210-d916-4b77-91d7-35641772c141	9a60a493-84b1-4fd9-911f-01e4b9f23179	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-21	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-22 20:10:17.392+00	\N
3f6c6822-9bab-400d-8a32-a28488a4c025	322cf32a-4a3d-4695-a4c7-df6f804b199b	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-21	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-22 20:10:17.397+00	\N
d52cbe04-32bf-47bb-8b5c-d015c489d771	37d2e835-20ad-4e81-9ffa-35ec3d208df1	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-21	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-22 20:10:17.406+00	\N
840380ba-0942-406a-b37c-8bcac7bbe1a6	6eff2334-1685-437e-917f-0e4d83f976c7	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-21	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-22 20:10:17.412+00	\N
914f7ad7-7c91-402e-bb0b-b0fc718992c5	a0b9674c-b1aa-48d9-b947-bdb94f0744e1	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-21	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-22 20:10:17.417+00	\N
8941b5c4-d6b4-41b9-b680-19ee0289d8e4	545797d7-ec01-4d74-8e49-a0177e267726	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-21	absent	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-22 20:10:17.422+00	Emergency
90864ff5-2b03-45f6-bc1d-4ec4b6167a8f	62390e06-36a4-49f3-8066-658b3ad17e53	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-21	absent	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-22 20:10:17.425+00	Sick
31813afd-7655-4e59-9ef1-887bc5f169a7	5bcba3b8-36d1-4cc3-9e30-73daf68a4bd3	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-21	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-22 20:10:17.428+00	\N
f5fde790-db8a-467f-87fd-9feff138cce9	b3d8af7d-79f3-407d-906a-70f0da75e208	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-21	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-22 20:10:17.431+00	\N
cdadfc56-5ea2-4201-92fa-ccd3d72c765c	4074dadf-6ab8-483e-b36b-a80b0e614893	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-21	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-22 20:10:17.436+00	\N
54592965-5089-4687-9cd6-fe482757d3af	e550f8ef-d6a2-4416-9f23-ab2c48f99abb	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-21	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-22 20:10:17.441+00	\N
0b939c24-6b25-4346-a051-6c9155f323a4	a235802e-195c-46a6-be96-bcbcc4dac04f	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-21	late	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-22 20:10:17.447+00	Arrived late
de20a7bd-9127-469d-8fc4-711c479e629e	d6a71905-e404-4dde-8ff2-71a31e718842	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-22	late	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-22 20:10:46.584+00	Late
072433b0-1b17-47eb-91f6-c1a32bb27663	0d1127ea-8d25-4868-9ce5-63259ad922f1	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-22	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-22 20:10:46.604+00	\N
717d5b39-714c-49ec-9b52-071d25e42606	95738447-114b-4bfa-8238-1e8ac5880bbb	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-22	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-22 20:10:46.613+00	\N
fb3b5038-feca-46bb-9986-58c9aa970564	515b9585-847a-421b-8dad-9925fcd7dc7d	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-22	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-22 20:10:46.628+00	\N
dcabfefd-ed71-4c20-9872-9b06fb941d6d	9a60a493-84b1-4fd9-911f-01e4b9f23179	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-22	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-22 20:10:46.642+00	\N
ba2282b2-6d51-4052-b9f9-58d840a5a9b5	322cf32a-4a3d-4695-a4c7-df6f804b199b	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-22	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-22 20:10:46.646+00	\N
c6a22501-9a2f-43bb-8dc1-565562b9f155	37d2e835-20ad-4e81-9ffa-35ec3d208df1	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-22	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-22 20:10:46.65+00	\N
7fb03291-470b-4662-85a1-c140a0670f3f	6eff2334-1685-437e-917f-0e4d83f976c7	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-22	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-22 20:10:46.661+00	\N
07151bff-d549-4e3a-891f-58f9d6b46f90	a0b9674c-b1aa-48d9-b947-bdb94f0744e1	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-22	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-22 20:10:46.668+00	\N
8c2762c1-1e30-4da9-a70d-a7c6c5b48ddd	545797d7-ec01-4d74-8e49-a0177e267726	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-22	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-22 20:10:46.677+00	\N
5bbf1085-5c8c-4b09-b1a7-71dcb35bb4d4	62390e06-36a4-49f3-8066-658b3ad17e53	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-22	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-22 20:10:46.693+00	\N
056c0946-6a3c-493a-a9f1-0179b3f163d9	5bcba3b8-36d1-4cc3-9e30-73daf68a4bd3	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-22	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-22 20:10:46.711+00	\N
bfd05795-7326-4d9f-92d2-35c970949b3b	b3d8af7d-79f3-407d-906a-70f0da75e208	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-22	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-22 20:10:46.715+00	\N
454b1535-f7e4-4ab1-8131-ceaee897b6a2	4074dadf-6ab8-483e-b36b-a80b0e614893	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-22	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-22 20:10:46.72+00	\N
48b0c227-1dd7-45ff-9d13-ab2c52da484e	e550f8ef-d6a2-4416-9f23-ab2c48f99abb	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-22	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-22 20:10:46.73+00	\N
fc95064c-afe5-4409-9e36-81573c73eef1	a235802e-195c-46a6-be96-bcbcc4dac04f	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-22	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-22 20:10:46.737+00	\N
9564a266-aae8-4500-9cbb-165c4d393e26	efac6ae9-7cee-45cf-a716-93fb9699dba6	8ecbb9ec-466d-4074-8a2b-7f851e3b2505	2026-10-23	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 16:51:28.096+00	\N
f3da84cf-25fb-4f2a-b269-f974fa36dac4	0b273b90-2b52-4e8b-ade8-487fabf301d8	8ecbb9ec-466d-4074-8a2b-7f851e3b2505	2026-10-23	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 16:51:28.114+00	\N
c3709cb8-9c7d-420f-8947-789233490e37	d43c16a1-b717-4386-9be1-afcc82aea84c	8ecbb9ec-466d-4074-8a2b-7f851e3b2505	2026-10-23	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 16:51:28.12+00	\N
8c3d3e45-5634-49d0-9a53-b70bd3b6bc47	0115d7ae-ff97-46c6-a00e-22a2aeaf4bdd	8ecbb9ec-466d-4074-8a2b-7f851e3b2505	2026-10-23	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 16:51:28.129+00	\N
d5029a41-4fbb-445f-99e5-3e4fc15ce4ee	bad94c9b-004e-4e48-bbdc-7c446a1a3968	8ecbb9ec-466d-4074-8a2b-7f851e3b2505	2026-10-23	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 16:51:28.132+00	\N
cd8a0cbd-68ac-4cca-b7b5-d9d3c6be6895	a9390c24-3ed9-4938-a5c3-4f1e51cbdf87	8ecbb9ec-466d-4074-8a2b-7f851e3b2505	2026-10-23	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 16:51:28.134+00	\N
4d575c01-315e-4383-95d2-699183fab60f	751e6e62-eb49-447f-844d-4e9677d649f7	8ecbb9ec-466d-4074-8a2b-7f851e3b2505	2026-10-23	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 16:51:28.136+00	\N
3f14f69c-434d-4304-b6db-9a19f8df7665	607d8984-c66e-4d82-a8b9-2c3dc55850f1	8ecbb9ec-466d-4074-8a2b-7f851e3b2505	2026-10-23	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 16:51:28.138+00	\N
d82d3f6b-089d-4936-b204-1347aa77d1de	ffd5acde-6f6f-4f13-ae34-38be8d30b47a	8ecbb9ec-466d-4074-8a2b-7f851e3b2505	2026-10-23	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 16:51:28.144+00	\N
e3d835d4-9d48-4939-b7a1-0dab65aacc75	27c0237f-3b36-4400-b290-886cdb230f9a	8ecbb9ec-466d-4074-8a2b-7f851e3b2505	2026-10-23	absent	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 16:51:28.148+00	Sick
61b08d0f-2985-4a4c-a529-d032c5cf33be	d6a71905-e404-4dde-8ff2-71a31e718842	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-23	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 16:51:51.334+00	\N
3275f4d6-78ea-4085-b106-4dc5afc75bd7	0d1127ea-8d25-4868-9ce5-63259ad922f1	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-23	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 16:51:51.351+00	\N
2d9c8cf0-0251-45d0-874a-0239c7009f4c	95738447-114b-4bfa-8238-1e8ac5880bbb	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-23	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 16:51:51.357+00	\N
e62c3b1c-4c9c-48ab-b4dc-45c8fc1a5800	515b9585-847a-421b-8dad-9925fcd7dc7d	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-23	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 16:51:51.366+00	\N
630db9b7-af2a-4fb1-a499-2cdb88197cb8	9a60a493-84b1-4fd9-911f-01e4b9f23179	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-23	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 16:51:51.376+00	\N
264724fc-6292-4b8c-8cbc-47bb662546ec	322cf32a-4a3d-4695-a4c7-df6f804b199b	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-23	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 16:51:51.381+00	\N
0e6cac08-2d6a-4f4f-901e-7b21dd4a1d7b	37d2e835-20ad-4e81-9ffa-35ec3d208df1	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-23	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 16:51:51.385+00	\N
76c24644-1b41-4150-bcf7-eee73cd1741c	6eff2334-1685-437e-917f-0e4d83f976c7	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-23	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 16:51:51.394+00	\N
7c131227-aec6-4c6d-8842-94b72cf62edd	a0b9674c-b1aa-48d9-b947-bdb94f0744e1	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-23	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 16:51:51.403+00	\N
4749795d-5013-44db-b50a-a42527e23379	545797d7-ec01-4d74-8e49-a0177e267726	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-23	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 16:51:51.418+00	\N
088ae63a-022c-4dd5-af3e-e52f918b9905	62390e06-36a4-49f3-8066-658b3ad17e53	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-23	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 16:51:51.431+00	\N
3e807ad3-b62f-438b-821d-ff739df1f02a	5bcba3b8-36d1-4cc3-9e30-73daf68a4bd3	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-23	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 16:51:51.435+00	\N
a200ee4e-67e8-47f9-b05c-3e70b524a3e4	76de287c-5dde-4928-9334-624cf116ce77	c1ac00b6-3080-41c6-b4af-19392f8ca82c	2026-10-23	late	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 16:53:47.75+00	late
a2e466bf-11c5-4bc5-bf12-c49bda2e899e	d8b48673-7ee0-4888-966b-2d51f6fd21ea	c1ac00b6-3080-41c6-b4af-19392f8ca82c	2026-10-23	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 16:53:47.751+00	\N
b9250167-f87f-4a2c-9a8c-345b0347485b	9d730237-4270-4a1f-9ee4-c2f3f78255e8	c1ac00b6-3080-41c6-b4af-19392f8ca82c	2026-10-23	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 16:53:47.751+00	\N
adddd61f-1ac1-4aa7-b2d2-287829e2b746	597a8662-2058-461d-ae43-2c0efa9fbc75	c1ac00b6-3080-41c6-b4af-19392f8ca82c	2026-10-23	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 16:53:47.752+00	\N
48616e72-f1be-4b0c-9724-be40eb4a9307	c7aa1a5d-1cdb-4647-a692-d4d8607662c1	c1ac00b6-3080-41c6-b4af-19392f8ca82c	2026-10-23	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 16:53:47.752+00	\N
5a2777f9-2097-4589-b5e3-0a19ed9df2f0	6358fc6e-0d94-4cfd-bbf5-8a6071180e95	c1ac00b6-3080-41c6-b4af-19392f8ca82c	2026-10-23	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 16:53:47.752+00	\N
5bebf757-8ff3-4490-80f4-c8b693f69b90	703ebe18-2305-4066-ac76-00bd7b33ec2d	c1ac00b6-3080-41c6-b4af-19392f8ca82c	2026-10-23	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 16:53:47.753+00	\N
e42d33ff-2fcc-47ac-84ba-046c4f1b216b	0244350c-e7c2-458c-b84a-de3f7a88b696	c1ac00b6-3080-41c6-b4af-19392f8ca82c	2026-10-23	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 16:53:47.753+00	\N
ab0956b0-8d48-4e06-a6e7-d7a95d2f94d0	527716c1-7f99-408f-ae99-27b29fe07e71	c1ac00b6-3080-41c6-b4af-19392f8ca82c	2026-10-23	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 16:53:47.753+00	\N
c3de6cf7-9762-44ca-ac6b-a33cec6528de	e72d4c36-103f-4382-a03e-fe6597d005e4	c1ac00b6-3080-41c6-b4af-19392f8ca82c	2026-10-23	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 16:53:47.753+00	\N
d61012ed-fe56-4507-a842-418d7b21f8b0	b3d8af7d-79f3-407d-906a-70f0da75e208	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-23	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 16:51:51.45+00	\N
eebfa621-46d8-4be2-89ed-0c8f4f85a06c	4074dadf-6ab8-483e-b36b-a80b0e614893	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-23	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 16:51:51.462+00	\N
cff22002-6ae0-480c-823c-656dd1777435	e550f8ef-d6a2-4416-9f23-ab2c48f99abb	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-23	late	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 16:51:51.47+00	late
a7da1ac8-4021-42af-b3b8-5902b546f8f7	a235802e-195c-46a6-be96-bcbcc4dac04f	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-23	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 16:51:51.476+00	\N
7073c48a-9747-439e-9037-2e2b9dcf8fce	76de287c-5dde-4928-9334-624cf116ce77	c1ac00b6-3080-41c6-b4af-19392f8ca82c	2026-10-25	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 06:43:53.749+00	\N
7b200ae7-de8b-4602-8e8d-4284aef3ee37	d8b48673-7ee0-4888-966b-2d51f6fd21ea	c1ac00b6-3080-41c6-b4af-19392f8ca82c	2026-10-25	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 06:43:53.768+00	\N
c3a5bb21-37f4-4d47-a948-55997899bd29	9d730237-4270-4a1f-9ee4-c2f3f78255e8	c1ac00b6-3080-41c6-b4af-19392f8ca82c	2026-10-25	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 06:43:53.778+00	\N
2baf5658-7aad-422c-aedb-52d9312d08c2	597a8662-2058-461d-ae43-2c0efa9fbc75	c1ac00b6-3080-41c6-b4af-19392f8ca82c	2026-10-25	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 06:43:53.787+00	\N
dc0a2999-3298-4e4f-bf35-f40405acc2c4	c7aa1a5d-1cdb-4647-a692-d4d8607662c1	c1ac00b6-3080-41c6-b4af-19392f8ca82c	2026-10-25	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 06:43:53.796+00	\N
944c1154-867d-4833-91c4-4f138cfa4f5c	6358fc6e-0d94-4cfd-bbf5-8a6071180e95	c1ac00b6-3080-41c6-b4af-19392f8ca82c	2026-10-25	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 06:43:53.808+00	\N
db2a66f5-fd12-41a0-84cf-a28eb70e292c	703ebe18-2305-4066-ac76-00bd7b33ec2d	c1ac00b6-3080-41c6-b4af-19392f8ca82c	2026-10-25	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 06:43:53.828+00	\N
c41d2485-1245-4b91-9d36-df0cc6cfa423	0244350c-e7c2-458c-b84a-de3f7a88b696	c1ac00b6-3080-41c6-b4af-19392f8ca82c	2026-10-25	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 06:43:53.846+00	\N
b399c027-6060-4ac6-81f6-bcc64c444fe6	527716c1-7f99-408f-ae99-27b29fe07e71	c1ac00b6-3080-41c6-b4af-19392f8ca82c	2026-10-25	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 06:43:53.853+00	\N
9de1f662-9e5b-46bf-b813-ee68f4fa2363	e72d4c36-103f-4382-a03e-fe6597d005e4	c1ac00b6-3080-41c6-b4af-19392f8ca82c	2026-10-25	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 06:43:53.858+00	\N
54bead8e-5771-4ab3-bab8-e5bb0ce863d2	76de287c-5dde-4928-9334-624cf116ce77	c1ac00b6-3080-41c6-b4af-19392f8ca82c	2026-10-24	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 06:44:04.227+00	\N
00eb10ec-d1f8-466e-9669-c83c2c9d15d2	d8b48673-7ee0-4888-966b-2d51f6fd21ea	c1ac00b6-3080-41c6-b4af-19392f8ca82c	2026-10-24	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 06:44:04.232+00	\N
adff8387-72c8-4888-a8a1-20b52096018a	9d730237-4270-4a1f-9ee4-c2f3f78255e8	c1ac00b6-3080-41c6-b4af-19392f8ca82c	2026-10-24	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 06:44:04.238+00	\N
6267f2fe-4de2-40ca-bb07-9061792e9a26	597a8662-2058-461d-ae43-2c0efa9fbc75	c1ac00b6-3080-41c6-b4af-19392f8ca82c	2026-10-24	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 06:44:04.245+00	\N
976f6136-b558-47f3-9647-9c7b5b7fea86	c7aa1a5d-1cdb-4647-a692-d4d8607662c1	c1ac00b6-3080-41c6-b4af-19392f8ca82c	2026-10-24	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 06:44:04.249+00	\N
6a338abc-9779-4565-8a93-f6932f0c7a75	6358fc6e-0d94-4cfd-bbf5-8a6071180e95	c1ac00b6-3080-41c6-b4af-19392f8ca82c	2026-10-24	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 06:44:04.257+00	\N
aabfa93e-05cc-41b5-bc5f-ed6bed32ae74	703ebe18-2305-4066-ac76-00bd7b33ec2d	c1ac00b6-3080-41c6-b4af-19392f8ca82c	2026-10-24	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 06:44:04.264+00	\N
eeeefccc-cd7b-45aa-8291-4d74e8c96d2b	0244350c-e7c2-458c-b84a-de3f7a88b696	c1ac00b6-3080-41c6-b4af-19392f8ca82c	2026-10-24	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 06:44:04.275+00	\N
bdfc2280-410d-48a1-825b-7898139a2c97	527716c1-7f99-408f-ae99-27b29fe07e71	c1ac00b6-3080-41c6-b4af-19392f8ca82c	2026-10-24	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 06:44:04.285+00	\N
1171544a-fcf9-4316-a4bc-84ee9c0390fe	e72d4c36-103f-4382-a03e-fe6597d005e4	c1ac00b6-3080-41c6-b4af-19392f8ca82c	2026-10-24	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 06:44:04.293+00	\N
323d3dc3-0578-4c12-af4e-2e0666018912	84a29e6b-ed9d-41e8-a1db-8dd582eaf463	619802b8-ed2c-41cf-93e3-52a12dc6218a	2026-10-25	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 06:51:02.666+00	\N
8b1e2ec4-dd9d-4a9f-8b2e-d6ff542c210f	c562efdb-3794-435c-8deb-e9276a54b7a8	619802b8-ed2c-41cf-93e3-52a12dc6218a	2026-10-25	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 06:51:02.673+00	\N
27aed722-db79-4f27-873c-f69e18e5b420	9dbae32d-a3c5-48db-bb8e-1ea82ca1d797	619802b8-ed2c-41cf-93e3-52a12dc6218a	2026-10-25	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 06:51:02.675+00	\N
3c2c9470-a83f-4b0d-aeba-6a35e2f8e6ef	94363c6a-27a7-442d-b4c6-eba893da524f	619802b8-ed2c-41cf-93e3-52a12dc6218a	2026-10-25	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 06:51:02.678+00	\N
964266ae-f4f8-4357-a888-206eeeefd107	8d9a10fd-c0bc-44da-9825-d19da6abb40f	619802b8-ed2c-41cf-93e3-52a12dc6218a	2026-10-25	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 06:51:02.68+00	\N
2dcacb16-b294-4cc2-943f-2a7ba9f81832	80a634d3-ea5f-4b4d-b308-bdedb52e26b5	619802b8-ed2c-41cf-93e3-52a12dc6218a	2026-10-25	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 06:51:02.685+00	\N
396c0c70-3016-4e50-a269-c5f3ec9ae2d1	633b1a04-b4e8-4956-93ce-18b0e4ec5db3	619802b8-ed2c-41cf-93e3-52a12dc6218a	2026-10-25	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 06:51:02.693+00	\N
8d8e90f4-4f96-4fe0-86d1-09b05bd44f64	e9945b50-effa-4bf3-baa9-1d09105034d3	619802b8-ed2c-41cf-93e3-52a12dc6218a	2026-10-25	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 06:51:02.699+00	\N
7fd12f49-09a7-4fb6-863d-bf2170846584	743199b7-7a07-477b-9632-201c3d84c676	619802b8-ed2c-41cf-93e3-52a12dc6218a	2026-10-25	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 06:51:02.706+00	\N
ecdf3aa1-c5ea-46cb-a797-98843d8e3279	2730c092-97ae-438c-a390-b3ef8ff2c79e	619802b8-ed2c-41cf-93e3-52a12dc6218a	2026-10-25	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 06:51:02.712+00	\N
8cdfcbe2-a256-419c-909a-06d4de12ec96	d6a71905-e404-4dde-8ff2-71a31e718842	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-25	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 12:20:16.563+00	\N
fffbb21a-1e61-41e1-b54b-2968b3335b44	0d1127ea-8d25-4868-9ce5-63259ad922f1	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-25	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 12:20:16.563+00	\N
0939980d-cc62-4b02-bc44-1847cb5b65ea	95738447-114b-4bfa-8238-1e8ac5880bbb	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-25	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 12:20:16.563+00	\N
a0631db9-d86a-4c11-b0d8-b94dfbd06f94	515b9585-847a-421b-8dad-9925fcd7dc7d	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-25	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 12:20:16.563+00	\N
3fab7166-fa8c-417a-80c6-9f463ba6a892	9a60a493-84b1-4fd9-911f-01e4b9f23179	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-25	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 12:20:16.563+00	\N
9f7080dd-7c86-4f41-84dd-b39ae54aa75f	322cf32a-4a3d-4695-a4c7-df6f804b199b	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-25	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 12:20:16.564+00	\N
d6533b05-65b4-43f6-aca1-4d3cc67a23ce	37d2e835-20ad-4e81-9ffa-35ec3d208df1	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-25	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 12:20:16.564+00	\N
cefbdd92-e0dd-4618-8b9f-d4ceaf69e604	6eff2334-1685-437e-917f-0e4d83f976c7	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-25	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 12:20:16.564+00	\N
18d96520-c9b3-4088-8599-9283dec5026b	a0b9674c-b1aa-48d9-b947-bdb94f0744e1	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-25	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 12:20:16.564+00	\N
aab8c08a-b256-43be-8c46-982b78eeb3eb	545797d7-ec01-4d74-8e49-a0177e267726	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-25	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 12:20:16.564+00	\N
5b5e0268-5a36-4894-a7fc-74e042b2ba39	62390e06-36a4-49f3-8066-658b3ad17e53	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-25	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 12:20:16.564+00	\N
91e3d684-3d6c-45b3-a06e-413fc5561446	5bcba3b8-36d1-4cc3-9e30-73daf68a4bd3	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-25	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 12:20:16.564+00	\N
0b8e2404-4f4e-4819-a3fb-9491c2a6b5fc	b3d8af7d-79f3-407d-906a-70f0da75e208	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-25	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 12:20:16.564+00	\N
5739152d-e746-4391-8959-ad5bda3f28e7	4074dadf-6ab8-483e-b36b-a80b0e614893	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-25	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 12:20:16.564+00	\N
3fe4df68-5bf4-496d-8813-6043d35a40b8	e550f8ef-d6a2-4416-9f23-ab2c48f99abb	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-25	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 12:20:16.564+00	\N
3896d464-873e-44eb-9037-6b42cddc3536	a235802e-195c-46a6-be96-bcbcc4dac04f	afa8bb8f-12ea-480d-949b-ace41851d9c1	2026-10-25	present	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-25 12:20:16.565+00	Late
\.


--
-- Data for Name: bursary_approvals; Type: TABLE DATA; Schema: public; Owner: school_user
--

COPY public.bursary_approvals (id, student_id, school_id, discount_amount, reason, approved_by, term, academic_year, approved_at) FROM stdin;
\.


--
-- Data for Name: class_enrollments; Type: TABLE DATA; Schema: public; Owner: school_user
--

COPY public.class_enrollments (id, class_id, student_id, enrolled_at) FROM stdin;
57da5b71-afdd-4d6b-882b-245f22a7ccb9	ae782cfd-a7b3-4f1b-bf44-32f9d1afe2e1	8881dc25-0266-4a5a-a1e9-61aa180c4223	2026-10-22 06:14:02.056+00
c1a6402c-5676-469f-9d94-8cc66be37378	20b013c4-742e-4aa4-8ba3-1c6842f81448	473836a4-a8e9-4220-8a45-32ffb61407b7	2026-10-22 08:27:32.179+00
4ad53ef5-f141-4e46-90d5-d65bcd1b4aad	09fa9324-a688-4dbd-b388-9a905d5b017b	473836a4-a8e9-4220-8a45-32ffb61407b7	2026-10-22 09:28:02.281+00
31533da6-fbd8-4b8d-b63e-8faca759a3cc	afa8bb8f-12ea-480d-949b-ace41851d9c1	95738447-114b-4bfa-8238-1e8ac5880bbb	2026-10-22 12:37:53.095+00
fd17529e-5f02-4b9b-af3d-49162c4c4a7e	afa8bb8f-12ea-480d-949b-ace41851d9c1	b3d8af7d-79f3-407d-906a-70f0da75e208	2026-10-22 18:21:13.478+00
ea7c48f4-5dc0-4a9b-93f3-6b03e97b7f9f	afa8bb8f-12ea-480d-949b-ace41851d9c1	0d1127ea-8d25-4868-9ce5-63259ad922f1	2026-10-22 18:21:13.493+00
47e4914c-b075-4595-967d-fc77710ce5fa	afa8bb8f-12ea-480d-949b-ace41851d9c1	37d2e835-20ad-4e81-9ffa-35ec3d208df1	2026-10-22 18:21:13.503+00
4a2d16bb-5478-4c11-ad0c-a99f3ef697fa	afa8bb8f-12ea-480d-949b-ace41851d9c1	545797d7-ec01-4d74-8e49-a0177e267726	2026-10-22 18:21:13.512+00
ef857d28-e53b-4b95-ad30-f7db29cbd397	afa8bb8f-12ea-480d-949b-ace41851d9c1	e550f8ef-d6a2-4416-9f23-ab2c48f99abb	2026-10-22 18:21:13.521+00
f6da9b41-7056-4850-8a6a-a2f7d37eb5c9	8ecbb9ec-466d-4074-8a2b-7f851e3b2505	27c0237f-3b36-4400-b290-886cdb230f9a	2026-10-22 18:21:13.53+00
6106f381-c575-42fc-89b1-df4291c3c2df	8ecbb9ec-466d-4074-8a2b-7f851e3b2505	607d8984-c66e-4d82-a8b9-2c3dc55850f1	2026-10-22 18:21:13.54+00
5588ae19-03c3-429f-97cc-78ac1eed95e8	8ecbb9ec-466d-4074-8a2b-7f851e3b2505	efac6ae9-7cee-45cf-a716-93fb9699dba6	2026-10-22 18:21:13.549+00
37a1e04d-0fa4-4887-9c1a-c58fc331bc48	8ecbb9ec-466d-4074-8a2b-7f851e3b2505	ffd5acde-6f6f-4f13-ae34-38be8d30b47a	2026-10-22 18:21:13.558+00
e8f0f5ce-f143-46a8-8b35-6881bc3fb315	8ecbb9ec-466d-4074-8a2b-7f851e3b2505	0115d7ae-ff97-46c6-a00e-22a2aeaf4bdd	2026-10-22 18:21:13.567+00
fecb5a0f-cdd8-432f-8d09-8f76674033e5	c1ac00b6-3080-41c6-b4af-19392f8ca82c	76de287c-5dde-4928-9334-624cf116ce77	2026-10-22 18:21:13.576+00
3ece9b00-b6d1-42de-8263-18d5d6080485	c1ac00b6-3080-41c6-b4af-19392f8ca82c	0244350c-e7c2-458c-b84a-de3f7a88b696	2026-10-22 18:21:13.589+00
c01c31f9-ee00-4d81-b75c-a50db765e118	c1ac00b6-3080-41c6-b4af-19392f8ca82c	597a8662-2058-461d-ae43-2c0efa9fbc75	2026-10-22 18:21:13.599+00
778743fe-d4a6-4e70-a3b8-651b7172beb8	c1ac00b6-3080-41c6-b4af-19392f8ca82c	d8b48673-7ee0-4888-966b-2d51f6fd21ea	2026-10-22 18:21:13.608+00
5dc9e1f2-86fd-4c88-9af1-8674b3460f32	c1ac00b6-3080-41c6-b4af-19392f8ca82c	527716c1-7f99-408f-ae99-27b29fe07e71	2026-10-22 18:21:13.617+00
35a80842-d3f0-449c-a850-3ff5a0a4934a	df59c19a-8732-42d0-9e7e-31e1334994f7	5eb9a1b2-43d0-436f-8d7f-bc0196c18b01	2026-10-22 18:21:13.627+00
5a2605b4-82d7-4cff-bd86-4d42bbc22072	df59c19a-8732-42d0-9e7e-31e1334994f7	e793e579-a470-4692-abb9-7268a0687449	2026-10-22 18:21:13.637+00
0b87d48d-3dc1-40dc-8e03-81501264aa82	df59c19a-8732-42d0-9e7e-31e1334994f7	444c4cd2-986f-4c64-8291-fa03f9633bba	2026-10-22 18:21:13.647+00
554fbf36-2c28-4636-a3c7-f07e5217380c	df59c19a-8732-42d0-9e7e-31e1334994f7	8c441c4b-7fee-4715-bfdb-4b0d8f9e1396	2026-10-22 18:21:13.657+00
764a18dc-9efd-45b0-9db0-f28f09bfb89b	df59c19a-8732-42d0-9e7e-31e1334994f7	6454b036-3fb7-4d19-a116-a8e0c117cf85	2026-10-22 18:21:13.665+00
4c8af4cc-7b7d-44a9-b4c9-5e0cf00bbca1	d1b0410c-caf9-4e20-a23c-8a1a3bff8d60	27b0fe78-2321-4233-848e-b4420fd9342d	2026-10-22 18:21:13.674+00
d78a81d6-3fe6-430f-81fb-956e6757710d	d1b0410c-caf9-4e20-a23c-8a1a3bff8d60	94a5a018-dd12-4be7-a633-c1e65015e113	2026-10-22 18:21:13.685+00
515eeeb2-1988-427d-9a03-50ab03f346dd	d1b0410c-caf9-4e20-a23c-8a1a3bff8d60	ed9605f1-5a3a-4cca-b3dc-fce06c3ff9b0	2026-10-22 18:21:13.694+00
133ab532-04c2-4d9e-98a3-60a64d2c2911	d1b0410c-caf9-4e20-a23c-8a1a3bff8d60	9ea835f8-b7f7-4b34-9f6d-fff30e5d1dcf	2026-10-22 18:21:13.704+00
f8124669-3166-4192-946f-f85dfea45d60	d1b0410c-caf9-4e20-a23c-8a1a3bff8d60	51dba70c-b611-4b1e-9e2a-d380063645b2	2026-10-22 18:21:13.713+00
997ed7c1-6a10-460e-b725-04871c499956	619802b8-ed2c-41cf-93e3-52a12dc6218a	8d9a10fd-c0bc-44da-9825-d19da6abb40f	2026-10-22 18:21:13.725+00
1d07d88d-fc62-4ad7-b4fc-0ac6bceb25c0	619802b8-ed2c-41cf-93e3-52a12dc6218a	633b1a04-b4e8-4956-93ce-18b0e4ec5db3	2026-10-22 18:21:13.734+00
b32da2fb-de79-4e1d-b66d-724326bb5f7a	619802b8-ed2c-41cf-93e3-52a12dc6218a	84a29e6b-ed9d-41e8-a1db-8dd582eaf463	2026-10-22 18:21:13.744+00
23dbf9e5-2724-455a-8610-8d578f2196b5	619802b8-ed2c-41cf-93e3-52a12dc6218a	9dbae32d-a3c5-48db-bb8e-1ea82ca1d797	2026-10-22 18:21:13.756+00
e5236319-f465-495c-99b5-c7c804284061	619802b8-ed2c-41cf-93e3-52a12dc6218a	e9945b50-effa-4bf3-baa9-1d09105034d3	2026-10-22 18:21:13.766+00
32647bc4-4c93-4ffd-adaf-f7a36baafd3d	1110fe28-558c-485e-a5cd-2e1f879bee90	bc376ebf-aca1-4037-90d1-c263182a6143	2026-10-22 18:21:13.775+00
5bb7d0cd-4500-4fb0-977a-16edbe528f90	1110fe28-558c-485e-a5cd-2e1f879bee90	9cde47f2-7050-4d40-926f-1172ea928193	2026-10-22 18:21:13.783+00
b159cd66-6ff8-4482-ae18-5436643ec57e	1110fe28-558c-485e-a5cd-2e1f879bee90	ab80616e-09ee-4c42-a1ab-1e01fb345950	2026-10-22 18:21:13.793+00
397fd377-3b92-4170-b78b-d1299f5189a2	1110fe28-558c-485e-a5cd-2e1f879bee90	089122a1-3166-4120-8046-fb3c41bd0356	2026-10-22 18:21:13.802+00
4bdebf6c-1564-49c8-bb6b-03d0ce94f139	1110fe28-558c-485e-a5cd-2e1f879bee90	b81b9fdf-b33c-4d9a-a48f-13878cf6cd72	2026-10-22 18:21:13.812+00
cfd9723d-7def-4910-a3fe-15fba632c971	fadaf65c-f7c1-4327-b8e6-c2c361db8176	da4ae721-9f82-41d8-bd4a-f937015dea4f	2026-10-22 18:21:13.82+00
77fa5a71-0144-45c4-8ca4-e39890d33c5d	fadaf65c-f7c1-4327-b8e6-c2c361db8176	6e1f4b8f-b6b9-4985-aa92-00771833e46e	2026-10-22 18:21:13.828+00
80c57935-b491-44c1-8999-d1e55958c15a	fadaf65c-f7c1-4327-b8e6-c2c361db8176	6d80ca30-a7a5-4bd1-8c7e-27450984c219	2026-10-22 18:21:13.837+00
dda5d27d-e474-42e0-8067-62727ad0c33c	fadaf65c-f7c1-4327-b8e6-c2c361db8176	c7fe56ba-4c5f-4e2e-b32c-4c00dcae6424	2026-10-22 18:21:13.847+00
734f4c88-71c9-4ebd-b642-546dad487615	fadaf65c-f7c1-4327-b8e6-c2c361db8176	523175cc-245a-4726-8b06-35ac0c1678ef	2026-10-22 18:21:13.856+00
ecb9d6b9-e031-4d1c-b862-ad82b1bbb89c	8e1a5460-789f-4996-a702-f2d69b402906	e50f57f8-0a71-41ad-8d3b-4613542a230e	2026-10-22 18:21:13.865+00
e3a07ed1-5de9-48d5-8435-f85e98e23bfe	8e1a5460-789f-4996-a702-f2d69b402906	f1e4296c-30b1-42b3-b9c8-27e4ae5dd380	2026-10-22 18:21:13.875+00
da594672-31d4-431f-a080-8170b81790e2	8e1a5460-789f-4996-a702-f2d69b402906	4ed2dbd9-9482-4b25-98e3-dc3e7f510637	2026-10-22 18:21:13.883+00
5af5a5fd-7296-4c78-bb39-eed320391ff7	8e1a5460-789f-4996-a702-f2d69b402906	3a664ee8-3d06-4ac8-b7e8-104f348c41c9	2026-10-22 18:21:13.893+00
c7b81558-534a-441c-878d-55ffd33b23d9	8e1a5460-789f-4996-a702-f2d69b402906	c1f2866d-2a7b-4033-9c23-1db0df1a164d	2026-10-22 18:21:13.902+00
cb5275e1-c1f4-46bd-b835-3d9de29f5c7c	641cf9ab-d2e1-4d5c-9905-36b9d333a875	61e8df6d-c5d1-4274-ade4-0ebc95158b7c	2026-10-22 18:21:13.91+00
b8deacc5-eb0b-4907-ae6f-ebd745172b40	641cf9ab-d2e1-4d5c-9905-36b9d333a875	13687753-7c3d-4402-bcc8-d64f737913ad	2026-10-22 18:21:13.921+00
ac70e588-223c-4516-9147-9aabe0c879aa	641cf9ab-d2e1-4d5c-9905-36b9d333a875	509e5c4f-2c9b-4e68-a2ae-82b69d8dfccb	2026-10-22 18:21:13.93+00
332437c2-14d0-4305-83a5-488d8cfd0211	641cf9ab-d2e1-4d5c-9905-36b9d333a875	ed61cec4-30af-4cd3-9e7e-6646d503896f	2026-10-22 18:21:13.939+00
69bdadce-7e77-4ea0-9358-6a94a75e50c8	641cf9ab-d2e1-4d5c-9905-36b9d333a875	fcb217a6-c2cc-4414-9579-eb7e50a4215b	2026-10-22 18:21:13.946+00
d5bcae4d-16ae-49d8-aaa7-d8a26c18c3eb	51a30184-8995-47bd-8bf8-79eed7049a0d	1c584944-dcb0-4957-be59-29457edfb668	2026-10-22 18:21:13.955+00
714c8670-6852-4294-a00a-07f72c1298e3	51a30184-8995-47bd-8bf8-79eed7049a0d	360c897c-f6e3-42b2-930e-b07843b5eca6	2026-10-22 18:21:13.963+00
1bad88ec-bd46-477f-80cb-08883d6a38f4	51a30184-8995-47bd-8bf8-79eed7049a0d	2fa81157-a706-48d8-81ac-a3d3bc6d2de9	2026-10-22 18:21:13.973+00
01bf1861-c3c9-44e1-8b20-029ba97e4d19	51a30184-8995-47bd-8bf8-79eed7049a0d	3b4ec356-c0af-4476-8892-46a3e3804771	2026-10-22 18:21:13.981+00
05bca3cf-460f-43c3-b9f8-8ca7933ced2b	51a30184-8995-47bd-8bf8-79eed7049a0d	6d500d17-e4e9-4a7b-a30d-32df39200173	2026-10-22 18:21:13.99+00
e2a48923-09c3-4dd0-bca7-7f18e814d94c	48a13b05-d5e3-4039-bd26-24dea4f9bde7	0f7407c8-0a1a-44f4-9e69-6a5fac874d56	2026-10-22 18:21:13.999+00
25c68b5f-1af4-4670-a21b-221e4e7a86cc	48a13b05-d5e3-4039-bd26-24dea4f9bde7	5ed584ad-a964-4c41-800e-11173b29efed	2026-10-22 18:21:14.008+00
8bbdd2de-9b2f-49e0-8daf-7e9aa3c2ba1d	48a13b05-d5e3-4039-bd26-24dea4f9bde7	15731351-7f9d-40ff-8d62-189cd21ce53b	2026-10-22 18:21:14.016+00
ed8a6925-cc74-4695-9063-4e897e2bcdf1	48a13b05-d5e3-4039-bd26-24dea4f9bde7	08c8f58b-96f8-4744-8130-a9c405d455e1	2026-10-22 18:21:14.026+00
b946fe9a-8be0-45ea-8538-3c8d53f3b6bd	48a13b05-d5e3-4039-bd26-24dea4f9bde7	1ecb9355-5c52-4e62-a420-84209ad57978	2026-10-22 18:21:14.035+00
5f453a40-867c-454e-bb85-6ac68fce0d4a	afa8bb8f-12ea-480d-949b-ace41851d9c1	a0b9674c-b1aa-48d9-b947-bdb94f0744e1	2026-10-22 18:24:39.688+00
2d7f913d-bd44-47d3-ac1c-688d19267e50	afa8bb8f-12ea-480d-949b-ace41851d9c1	322cf32a-4a3d-4695-a4c7-df6f804b199b	2026-10-22 18:24:39.707+00
3ec75421-ab4b-4926-946a-8409f5ee272b	afa8bb8f-12ea-480d-949b-ace41851d9c1	5bcba3b8-36d1-4cc3-9e30-73daf68a4bd3	2026-10-22 18:24:39.722+00
c4843bea-b599-4e3e-8041-cf94959fea08	afa8bb8f-12ea-480d-949b-ace41851d9c1	515b9585-847a-421b-8dad-9925fcd7dc7d	2026-10-22 18:24:39.735+00
bf613c57-8005-4b78-a5af-9d44afb55f61	afa8bb8f-12ea-480d-949b-ace41851d9c1	a235802e-195c-46a6-be96-bcbcc4dac04f	2026-10-22 18:24:39.745+00
037e93e5-1856-46dd-9e20-511dbd6b05c7	8ecbb9ec-466d-4074-8a2b-7f851e3b2505	0b273b90-2b52-4e8b-ade8-487fabf301d8	2026-10-22 18:24:39.756+00
ec757ca1-b88d-426a-9ed9-f9c54146ad38	8ecbb9ec-466d-4074-8a2b-7f851e3b2505	bad94c9b-004e-4e48-bbdc-7c446a1a3968	2026-10-22 18:24:39.768+00
9fc8e0ab-3b8c-4b6a-984a-ec664685da60	8ecbb9ec-466d-4074-8a2b-7f851e3b2505	751e6e62-eb49-447f-844d-4e9677d649f7	2026-10-22 18:24:39.781+00
d010eb2b-8e8a-4254-b46c-cf4055fd3ae5	8ecbb9ec-466d-4074-8a2b-7f851e3b2505	a9390c24-3ed9-4938-a5c3-4f1e51cbdf87	2026-10-22 18:24:39.79+00
f5a4d25b-4fa4-4efb-8f4b-c61969926060	8ecbb9ec-466d-4074-8a2b-7f851e3b2505	d43c16a1-b717-4386-9be1-afcc82aea84c	2026-10-22 18:24:39.8+00
971494ca-7117-4c5a-bf56-07310edf2f8f	c1ac00b6-3080-41c6-b4af-19392f8ca82c	9d730237-4270-4a1f-9ee4-c2f3f78255e8	2026-10-22 18:24:39.81+00
a428f719-e51b-4406-8d73-d75858f90b60	c1ac00b6-3080-41c6-b4af-19392f8ca82c	703ebe18-2305-4066-ac76-00bd7b33ec2d	2026-10-22 18:24:39.822+00
f741246f-7d0d-4907-b622-b53094104c11	c1ac00b6-3080-41c6-b4af-19392f8ca82c	e72d4c36-103f-4382-a03e-fe6597d005e4	2026-10-22 18:24:39.832+00
dc716b06-40a4-465a-a1de-2cc6b4552f26	c1ac00b6-3080-41c6-b4af-19392f8ca82c	c7aa1a5d-1cdb-4647-a692-d4d8607662c1	2026-10-22 18:24:39.841+00
7bb3396d-aadc-4d93-a2f7-e8515fc4db12	c1ac00b6-3080-41c6-b4af-19392f8ca82c	6358fc6e-0d94-4cfd-bbf5-8a6071180e95	2026-10-22 18:24:39.851+00
4a588401-83c3-4d7e-9491-356568cb5a80	df59c19a-8732-42d0-9e7e-31e1334994f7	91d18ab9-8157-4c68-bb6a-2e7ebc933f7d	2026-10-22 18:24:39.862+00
d1776ec6-653a-4758-aed9-f1e05e1af102	df59c19a-8732-42d0-9e7e-31e1334994f7	f2a6f2f4-7207-46f5-9a1f-0c350fc22980	2026-10-22 18:24:39.872+00
10678620-14df-4528-b53a-e5c32b1791ca	df59c19a-8732-42d0-9e7e-31e1334994f7	9e0f0cc6-4863-4004-a5c6-00ac449cd091	2026-10-22 18:24:39.88+00
5b94d799-a792-48d1-af4f-071d0ce9f1b7	df59c19a-8732-42d0-9e7e-31e1334994f7	ea42d6a2-8d01-4bbb-b002-90e73f52e32a	2026-10-22 18:24:39.891+00
d2cc0067-081c-4df8-8c8c-d52b64c38419	df59c19a-8732-42d0-9e7e-31e1334994f7	c24bb4b5-c13e-408b-9843-837c12eb3e07	2026-10-22 18:24:39.899+00
f26e5574-b232-4e89-8032-02d8a510a915	d1b0410c-caf9-4e20-a23c-8a1a3bff8d60	7026d6f0-27a1-402d-8ea6-66a49f872ecc	2026-10-22 18:24:39.91+00
3991d0d1-d958-4493-b510-df0455734044	d1b0410c-caf9-4e20-a23c-8a1a3bff8d60	f3c89c02-b040-467f-b19f-8e87b3f02d72	2026-10-22 18:24:39.918+00
0e1a2556-ba4c-4d1b-91d6-10011463f63f	d1b0410c-caf9-4e20-a23c-8a1a3bff8d60	0ecbedeb-df5b-46c2-885e-0502d1ccae26	2026-10-22 18:24:39.926+00
3dab6c39-bcf1-476a-b8aa-a6087124d839	d1b0410c-caf9-4e20-a23c-8a1a3bff8d60	966a6342-6593-4cd0-9c79-9e70c3953bee	2026-10-22 18:24:39.936+00
14b8af50-a62d-4d57-9346-cf3f43eccd31	d1b0410c-caf9-4e20-a23c-8a1a3bff8d60	edbfaf78-e4f4-4e35-9baa-c073f088cad4	2026-10-22 18:24:39.946+00
f9a5ac9a-7aa0-4fac-9f83-88f6a25965d6	619802b8-ed2c-41cf-93e3-52a12dc6218a	80a634d3-ea5f-4b4d-b308-bdedb52e26b5	2026-10-22 18:24:39.955+00
1e87adfd-8a49-4f39-825e-921d3833c854	619802b8-ed2c-41cf-93e3-52a12dc6218a	743199b7-7a07-477b-9632-201c3d84c676	2026-10-22 18:24:39.965+00
32614070-20bd-48a7-aa2a-57076abe00b6	619802b8-ed2c-41cf-93e3-52a12dc6218a	94363c6a-27a7-442d-b4c6-eba893da524f	2026-10-22 18:24:39.973+00
96b32ae1-be5b-418c-964a-4094f385d549	619802b8-ed2c-41cf-93e3-52a12dc6218a	c562efdb-3794-435c-8deb-e9276a54b7a8	2026-10-22 18:24:39.984+00
b075c0a2-118a-41b1-8b11-d138e8c0f7ca	619802b8-ed2c-41cf-93e3-52a12dc6218a	2730c092-97ae-438c-a390-b3ef8ff2c79e	2026-10-22 18:24:39.992+00
41ff35b4-67dd-482e-9c15-ac16e9e0175d	1110fe28-558c-485e-a5cd-2e1f879bee90	57629a2c-1f0c-4ee5-9d89-4669a88a6ae5	2026-10-22 18:24:40.001+00
a49f357f-a26f-4f2f-8e12-59a0d84fa0dc	1110fe28-558c-485e-a5cd-2e1f879bee90	e8485d65-9e56-4235-867d-dce86808fc54	2026-10-22 18:24:40.012+00
6d3b5600-be91-4070-beac-55c1376d290d	1110fe28-558c-485e-a5cd-2e1f879bee90	32bd5ecb-1470-4fac-97cb-1ca8ae1cd60b	2026-10-22 18:24:40.022+00
ebe2c692-e19a-4f51-be71-a3294c7e8edb	1110fe28-558c-485e-a5cd-2e1f879bee90	be034844-d496-41fb-8289-68d35cca723b	2026-10-22 18:24:40.03+00
855547ad-83c1-4362-be71-5d212ef30473	1110fe28-558c-485e-a5cd-2e1f879bee90	e254ecf5-cd09-4c7d-9ff6-1bae9158520f	2026-10-22 18:24:40.038+00
c7b9edc7-5447-40ce-8624-381ca2259baf	fadaf65c-f7c1-4327-b8e6-c2c361db8176	d5045f23-a317-4ecf-be08-5aab7c52a4b9	2026-10-22 18:24:40.048+00
a3bca00c-8adb-4fca-8370-35273b1dc8e2	fadaf65c-f7c1-4327-b8e6-c2c361db8176	bf28e619-eded-40f5-9e2d-11b459763294	2026-10-22 18:24:40.056+00
81e40ab9-276b-4965-a885-f42a79b19cf5	fadaf65c-f7c1-4327-b8e6-c2c361db8176	7f801ce1-0843-49c6-a3fb-a1b61c474744	2026-10-22 18:24:40.065+00
1c1035da-0d06-44fb-8632-66c36aeacc96	fadaf65c-f7c1-4327-b8e6-c2c361db8176	b76fe21d-285f-402f-830b-cbadcc5c7dd7	2026-10-22 18:24:40.074+00
e3c94d29-3c56-45b9-8fb8-b30fe5dd7a6a	fadaf65c-f7c1-4327-b8e6-c2c361db8176	ed69c76a-0f9b-41ef-82a1-414ee8685f13	2026-10-22 18:24:40.084+00
bba88e56-94b9-4eec-a4f1-1609ed2bbfec	8e1a5460-789f-4996-a702-f2d69b402906	22cb0dc4-cccf-4035-90d8-7d20dd252901	2026-10-22 18:24:40.093+00
c117bb17-824c-4d65-8a58-d5dec5835fba	8e1a5460-789f-4996-a702-f2d69b402906	9a5db877-fc4a-46f4-934e-00260c929919	2026-10-22 18:24:40.103+00
a9caa689-d34f-4f94-b25f-5063e9176116	8e1a5460-789f-4996-a702-f2d69b402906	79972a56-dfcd-4663-b64b-16610b7d85ae	2026-10-22 18:24:40.114+00
8af42553-f84a-4ce7-81aa-f6d26a82ef6a	8e1a5460-789f-4996-a702-f2d69b402906	da94c1a3-3404-4173-b9f2-2767d869195a	2026-10-22 18:24:40.122+00
ab20b316-d759-465c-a4e4-333ab78d0684	8e1a5460-789f-4996-a702-f2d69b402906	3be96f1e-d961-42e5-91e7-86eb998f76bd	2026-10-22 18:24:40.131+00
cb5de3d8-9f39-4661-ab9f-facb62d85138	641cf9ab-d2e1-4d5c-9905-36b9d333a875	01b180b3-5ffd-408c-b0e9-c203b313309a	2026-10-22 18:24:40.141+00
3da9b0b7-fdb0-4487-9606-85d3aa7de492	641cf9ab-d2e1-4d5c-9905-36b9d333a875	6008f810-ed53-4b3f-a0d0-5d975351f4e5	2026-10-22 18:24:40.151+00
6dd97bfd-6ce3-41ce-9132-469094315fcd	641cf9ab-d2e1-4d5c-9905-36b9d333a875	ce461b29-1b7f-4a37-b711-908aa19deaa5	2026-10-22 18:24:40.163+00
399141aa-cc02-47ed-a018-06ef27a7db5f	641cf9ab-d2e1-4d5c-9905-36b9d333a875	a3c86f1c-57c2-49a5-ba06-191b5bbb9bd0	2026-10-22 18:24:40.171+00
4b748f53-bd14-4538-8ed4-503c5af4fc3a	641cf9ab-d2e1-4d5c-9905-36b9d333a875	4f4970a2-c969-4b3f-a292-a4b8cfd3efe3	2026-10-22 18:24:40.182+00
60b3a9bb-15ad-43c0-9a96-0a509af41f75	51a30184-8995-47bd-8bf8-79eed7049a0d	859667a9-e311-4490-b69f-b7653a667320	2026-10-22 18:24:40.191+00
2ccc3e47-9c9b-4878-af12-98272d899b7b	51a30184-8995-47bd-8bf8-79eed7049a0d	4edaa322-5e9d-4605-9c08-16e862bfcef2	2026-10-22 18:24:40.203+00
2e7a6140-8741-42b4-98e1-4e645ed12fe0	51a30184-8995-47bd-8bf8-79eed7049a0d	3bb370c0-89b0-4a36-ba0e-fb10f413de26	2026-10-22 18:24:40.215+00
7dcdbab2-fb3d-470a-82e6-049b753fd159	51a30184-8995-47bd-8bf8-79eed7049a0d	a6397c80-f8e4-43ba-9d7d-d823f3511765	2026-10-22 18:24:40.224+00
fdf653ee-65e8-4ec7-ba1f-a981dec5d816	51a30184-8995-47bd-8bf8-79eed7049a0d	40dd129a-af25-4ea6-bbb6-8a69d1e88c99	2026-10-22 18:24:40.234+00
249935c3-2341-4a37-92bd-f2b7a09f423b	48a13b05-d5e3-4039-bd26-24dea4f9bde7	28e106e1-896a-44da-bdee-24a70efe3c96	2026-10-22 18:24:40.242+00
c0525777-e39d-46a6-9895-4e8bb6aa35a1	48a13b05-d5e3-4039-bd26-24dea4f9bde7	f0be106a-3baa-4f96-96c5-d8a4f15d3741	2026-10-22 18:24:40.253+00
f3c462a4-6d31-43c1-9055-c4c1064b6f73	48a13b05-d5e3-4039-bd26-24dea4f9bde7	e3cc99ba-e75f-4c37-9ef8-016302063f3b	2026-10-22 18:24:40.261+00
5c97c9ba-e17e-4598-b9f2-05cdc97c32cc	48a13b05-d5e3-4039-bd26-24dea4f9bde7	90b6d714-1da5-43c1-bb8e-253f5bdbe9aa	2026-10-22 18:24:40.271+00
99793687-3cec-46ff-93b1-7ba2cbb4fdf0	48a13b05-d5e3-4039-bd26-24dea4f9bde7	e15fce23-0f4c-4348-8c4e-c29e4a3a384f	2026-10-22 18:24:40.281+00
559d8f8e-1e2a-4ecf-a509-8a0731292913	afa8bb8f-12ea-480d-949b-ace41851d9c1	9a60a493-84b1-4fd9-911f-01e4b9f23179	2026-10-22 19:00:35.163+00
82c0cdee-cd6d-4893-a1ca-c837bb67a6e5	afa8bb8f-12ea-480d-949b-ace41851d9c1	d6a71905-e404-4dde-8ff2-71a31e718842	2026-10-22 19:00:35.178+00
51266b15-7847-4229-874c-e05fce33ba71	afa8bb8f-12ea-480d-949b-ace41851d9c1	6eff2334-1685-437e-917f-0e4d83f976c7	2026-10-22 19:00:35.195+00
61ee06f1-18f4-46cb-be79-603cb0f5ebe2	afa8bb8f-12ea-480d-949b-ace41851d9c1	62390e06-36a4-49f3-8066-658b3ad17e53	2026-10-22 19:00:35.21+00
d60a9b68-4ebe-4160-b424-d1483d267861	afa8bb8f-12ea-480d-949b-ace41851d9c1	4074dadf-6ab8-483e-b36b-a80b0e614893	2026-10-22 19:00:35.225+00
608ff7e4-7f21-466a-99f2-a8a4211f8c64	715217da-e2e4-45bc-a7d8-30e3c4fbb152	2976633c-8afe-4163-a698-f2c580cd825f	2026-10-22 19:00:35.235+00
86c47eea-9bb0-4b59-b75a-4dd209ec67d5	715217da-e2e4-45bc-a7d8-30e3c4fbb152	210c3f3d-2414-4e9c-9859-5dd350a06508	2026-10-22 19:00:35.245+00
3cd625e9-cc7f-4fa3-aa71-38fda3976a26	715217da-e2e4-45bc-a7d8-30e3c4fbb152	f2abe492-be63-4ad8-9da9-005808a39082	2026-10-22 19:00:35.255+00
bb8ca998-59d6-4053-9f01-8efe03472b18	715217da-e2e4-45bc-a7d8-30e3c4fbb152	a2b862d5-4f7c-445c-bbf0-14775f6724ab	2026-10-22 19:00:35.265+00
35b58495-98fa-4953-adc9-3341fb1bd0d4	715217da-e2e4-45bc-a7d8-30e3c4fbb152	df05d1f5-c7c0-4730-86e7-4e939c61e846	2026-10-22 19:00:35.273+00
9d4ba8f5-e2fd-4a33-a3c9-37677609eee1	306db6c9-cfbf-43f3-a90a-d3fae6a28e56	47522dd8-0839-4b85-9ed4-7763b0fc3de9	2026-10-22 19:00:35.282+00
30823352-30e4-4091-b993-37aecd9a35f6	306db6c9-cfbf-43f3-a90a-d3fae6a28e56	e9431c72-19f4-4944-9495-9c7a4ffbb954	2026-10-22 19:00:35.293+00
8cea3071-97fd-4d9f-8bba-fd451081d491	306db6c9-cfbf-43f3-a90a-d3fae6a28e56	89bc033a-236d-4966-b90f-3bc87858506f	2026-10-22 19:00:35.302+00
b3d85836-8788-4821-bf35-101ed8260c7a	306db6c9-cfbf-43f3-a90a-d3fae6a28e56	d87ffb79-4f02-4e0e-85f0-f083ae4ba026	2026-10-22 19:00:35.311+00
6946f4f4-99e5-4709-b394-a4fece4fbda1	306db6c9-cfbf-43f3-a90a-d3fae6a28e56	b7634f78-cec5-4a8f-9a83-e36fe7f3091b	2026-10-22 19:00:35.32+00
3b6e5365-e0bc-419c-a5b6-2a91facf4beb	b674150e-ecf1-4406-a813-67dd02768555	ce7a88f1-e4fb-4ba4-afda-543893324dd9	2026-10-22 19:00:35.33+00
92776603-6daf-41cb-a792-98865de46446	b674150e-ecf1-4406-a813-67dd02768555	9b40a4b7-97ff-4ea4-aa39-5d98bea45410	2026-10-22 19:00:35.338+00
20049acc-4766-459c-bae1-e09d76e45e5c	b674150e-ecf1-4406-a813-67dd02768555	0ab7c5a8-99bf-47b0-9aa9-e6d1e2743205	2026-10-22 19:00:35.348+00
dc6c0fca-9719-48dd-b7f8-1e28f134041f	b674150e-ecf1-4406-a813-67dd02768555	e3f87aad-8b13-420f-9458-9b135138322a	2026-10-22 19:00:35.358+00
938f7b88-7536-4787-9376-3cbe3aeccd91	b674150e-ecf1-4406-a813-67dd02768555	e2fa1e09-18c1-4953-a823-d98d10a3649a	2026-10-22 19:00:35.367+00
a4f71e5c-647a-47d9-ab62-f91df1b996a1	0be7a4f6-1619-40a3-9f72-a7c262f0b863	8764b6b0-7a20-4c47-a772-60533f761621	2026-10-22 19:00:35.376+00
f13da89b-feca-4792-b1ac-4548b352f86c	0be7a4f6-1619-40a3-9f72-a7c262f0b863	9e47e86d-7ce6-49ca-89db-1090dd814ce3	2026-10-22 19:00:35.385+00
8dbffe0c-e0df-4608-8d0a-a9ee38ff73dc	0be7a4f6-1619-40a3-9f72-a7c262f0b863	f46cd806-9d6c-4520-87f6-1a1b85a165a6	2026-10-22 19:00:35.395+00
a1f9aeae-acdd-415c-90bb-6d9e0ac6be37	0be7a4f6-1619-40a3-9f72-a7c262f0b863	2a611d56-1b19-420e-a5ad-be81c19d3d92	2026-10-22 19:00:35.403+00
3eebe408-abf9-42d3-ba66-bb71cbcbe01e	0be7a4f6-1619-40a3-9f72-a7c262f0b863	0fe291b8-0ba7-43db-a904-84ed76a781ca	2026-10-22 19:00:35.411+00
cef3ad56-bada-47ac-bd45-3c91bdde850b	801ac4fb-14ed-49a0-ac4c-4835ff28549f	d610a498-f319-44f2-82bf-727c8c96b910	2026-10-22 19:00:35.419+00
e9893ce8-c1ee-4df6-b311-6478a7dc0714	801ac4fb-14ed-49a0-ac4c-4835ff28549f	ed291d93-2c97-41b9-bc8e-d2617b3bf9e3	2026-10-22 19:00:35.43+00
78ae805d-827a-42aa-96d7-475c2bdb3e93	801ac4fb-14ed-49a0-ac4c-4835ff28549f	a8461518-342a-46ca-a62e-6adafacf7baa	2026-10-22 19:00:35.439+00
958cdb0d-38d6-44ca-b64b-06524690deda	801ac4fb-14ed-49a0-ac4c-4835ff28549f	335cd6c0-81df-4af9-9903-8d4c7c69e25f	2026-10-22 19:00:35.448+00
8cf70fd1-255d-4306-9f04-bc753ccfa880	801ac4fb-14ed-49a0-ac4c-4835ff28549f	fe4d2e1f-b581-441d-bace-f1c7ad78713a	2026-10-22 19:00:35.458+00
c41c31e9-1367-444e-a758-9dc8c8b281b9	d08e9e53-f7bd-4d0e-80ad-b22f29d0daab	2423d3f3-53e6-40ab-90cc-1cdc62d91d5a	2026-10-22 19:00:35.47+00
e12a8544-bfd5-434b-80b7-af7dcdca9227	d08e9e53-f7bd-4d0e-80ad-b22f29d0daab	e3fdfc37-0349-4519-b2e9-9eea8adf6300	2026-10-22 19:00:35.481+00
30c77381-be81-4f1e-8763-ffdfe54f4dec	d08e9e53-f7bd-4d0e-80ad-b22f29d0daab	8f84b489-1ac2-4c34-a015-2f544115600a	2026-10-22 19:00:35.492+00
328d4597-7b94-4089-812b-1d6b1047fa29	d08e9e53-f7bd-4d0e-80ad-b22f29d0daab	0f78055b-9eff-4fbb-bdbb-428a2ed6b159	2026-10-22 19:00:35.504+00
72e7bff9-7c96-4ecc-affa-bdea38eb1422	d08e9e53-f7bd-4d0e-80ad-b22f29d0daab	3e96b8b5-87bf-4fe1-a659-79931c3ab15d	2026-10-22 19:00:35.513+00
8699bcae-6059-4c82-b55c-3dc38872cb8a	d01fc901-3ad1-42b9-a782-8408060e4890	a89f9c2f-ab94-4ee9-b6ff-72995a338744	2026-10-22 19:00:35.524+00
c90239fa-4926-4104-a3f8-1c235b514a1b	d01fc901-3ad1-42b9-a782-8408060e4890	0bcadfff-ef0d-4bca-b663-6fbdb063fe8e	2026-10-22 19:00:35.535+00
8e528fdd-f122-4e53-aed7-c2430a5ca1d1	d01fc901-3ad1-42b9-a782-8408060e4890	e4606f92-2c72-4971-a41a-cb6de108fd8a	2026-10-22 19:00:35.545+00
7777b4ea-9d7b-499d-922a-3b224f2d0b03	d01fc901-3ad1-42b9-a782-8408060e4890	037bc517-d21b-4ea4-8922-119e2e3027ed	2026-10-22 19:00:35.554+00
3c8b8b64-00b2-4ed0-8d92-c5ac9e9a9439	d01fc901-3ad1-42b9-a782-8408060e4890	63870548-2613-4542-b5db-e6a2e196bfa9	2026-10-22 19:00:35.565+00
2317e009-f486-4b29-a83d-92d481e02092	7a748658-0722-462b-a6a5-c8d8e3916b5e	4a584da0-ef3b-4ebd-8420-77b4dd38615b	2026-10-22 19:00:35.575+00
751e9cd8-5c78-4264-9fc3-468ce308c923	7a748658-0722-462b-a6a5-c8d8e3916b5e	a12c3526-77ae-4129-b51a-e647ef801052	2026-10-22 19:00:35.585+00
285e1475-1604-4d26-8a92-6b7757df288b	7a748658-0722-462b-a6a5-c8d8e3916b5e	66d8885f-dcfd-4d2c-b646-cbec8cc3be0d	2026-10-22 19:00:35.596+00
dc51d07f-2ea9-493e-b44d-f73bbb28a03e	7a748658-0722-462b-a6a5-c8d8e3916b5e	7a6d10d6-a836-4407-b3b2-350d006f3300	2026-10-22 19:00:35.605+00
40da999e-2134-436e-b36f-3011aac50d6e	7a748658-0722-462b-a6a5-c8d8e3916b5e	6ed8f717-fd1b-4fd8-b832-30e86f7220dd	2026-10-22 19:00:35.616+00
c1c2a231-1864-4269-8ad6-e13ddfb4779b	e3476888-76e0-4a42-bad8-3678c5e7f311	83661cc8-996c-405a-b4e8-2cf5de3022b8	2026-10-22 19:00:35.625+00
d75a3e0c-4238-4bf0-ab7e-2b12789a7e57	e3476888-76e0-4a42-bad8-3678c5e7f311	64f65b30-cbc2-4fff-b408-f9c517fee3d0	2026-10-22 19:00:35.636+00
3d8fa897-3fc2-4f92-bb84-5d303ce9269f	e3476888-76e0-4a42-bad8-3678c5e7f311	b116a67c-4049-4e1a-938a-dd73c923cb01	2026-10-22 19:00:35.645+00
1d838017-5adc-4453-aee3-4bc95579bd59	e3476888-76e0-4a42-bad8-3678c5e7f311	fb85cd15-4cce-4844-99d4-efffa7c04aea	2026-10-22 19:00:35.654+00
5ebbf20c-1253-45e6-ae60-69dd14f6e56b	e3476888-76e0-4a42-bad8-3678c5e7f311	a99f9d58-468b-445b-9dbc-7373754bb09c	2026-10-22 19:00:35.665+00
9e6d439f-cc5c-4855-961e-c3b9b54531a7	5252a0ab-36c6-4823-87ec-632a339c4dc0	ec206e55-efa4-405c-b631-94987b6bbc2e	2026-10-22 19:00:35.673+00
32c9fb64-a4f5-4a77-9e50-083bee3f5507	5252a0ab-36c6-4823-87ec-632a339c4dc0	2d4aa346-1580-46ef-96e2-7e7e536334b6	2026-10-22 19:00:35.683+00
0dd36245-221a-41eb-a7ef-76b64693b852	5252a0ab-36c6-4823-87ec-632a339c4dc0	d27f8a9e-1f2a-40fc-83e7-f2392f8d6052	2026-10-22 19:00:35.693+00
2ed01326-13d0-4367-b980-4378bd5d9f93	5252a0ab-36c6-4823-87ec-632a339c4dc0	48601f36-e5c5-44d2-91a5-3e7914fbf26d	2026-10-22 19:00:35.701+00
039164c1-297b-4a18-93f7-a2e517fad023	5252a0ab-36c6-4823-87ec-632a339c4dc0	49c86f27-1113-4c53-a96e-486b7fe82bee	2026-10-22 19:00:35.71+00
b3893822-763b-4656-9365-c13579f455bb	65961c57-bdba-4f4d-9956-791f065f8a43	d4561be5-987e-4414-ac3d-9a6464e670e2	2026-10-22 19:00:35.72+00
3525af0d-adc3-49f1-aa57-2a9077e171a0	65961c57-bdba-4f4d-9956-791f065f8a43	2da21d60-17af-4e41-a663-1895404202d0	2026-10-22 19:00:35.73+00
ef53ba07-be81-44eb-b782-28253ef43612	65961c57-bdba-4f4d-9956-791f065f8a43	ea0358f4-8508-49f6-b565-9b82fdf1e4f7	2026-10-22 19:00:35.738+00
6b721329-94d2-4e31-a688-f9a8bb26453b	65961c57-bdba-4f4d-9956-791f065f8a43	d245f31d-83d3-44e5-8fa1-8ced0f90575d	2026-10-22 19:00:35.749+00
73dc73cd-50f4-4929-9935-4a857da31082	65961c57-bdba-4f4d-9956-791f065f8a43	44004eaf-ee1d-45be-90de-076a2e1c3d81	2026-10-22 19:00:35.758+00
\.


--
-- Data for Name: classes; Type: TABLE DATA; Schema: public; Owner: school_user
--

COPY public.classes (id, school_id, name, arm, teacher_id, academic_year, term, created_at, level, stream) FROM stdin;
9b2ab9b7-cb2d-4929-9028-76048c293eb1	55473dfa-dd2b-41e5-b85e-8da87261fa12	Pre-Nursery	A	\N	2026/2027	first	2026-10-21 12:30:01.05+00	preNursery	\N
9dc63c0d-ec93-4fad-9212-fc76c130c5f6	55473dfa-dd2b-41e5-b85e-8da87261fa12	Nursery 1	A	\N	2026/2027	first	2026-10-21 12:30:01.05+00	nursery1	\N
f64008f0-bf1c-4747-9425-b6e7b3a92441	55473dfa-dd2b-41e5-b85e-8da87261fa12	Nursery 2	A	\N	2026/2027	first	2026-10-21 12:30:01.05+00	nursery2	\N
54217571-ae81-4326-8977-de8d489cc123	55473dfa-dd2b-41e5-b85e-8da87261fa12	Nursery 3	A	\N	2026/2027	first	2026-10-21 12:30:01.05+00	nursery3	\N
5c9074c4-40e4-45c4-b6c4-7f9ea5dfaf58	55473dfa-dd2b-41e5-b85e-8da87261fa12	Primary 1	A	\N	2026/2027	first	2026-10-21 12:30:01.05+00	primary1	\N
564cc3ef-216c-460e-b9a2-e5acca13f8f3	55473dfa-dd2b-41e5-b85e-8da87261fa12	Primary 2	A	\N	2026/2027	first	2026-10-21 12:30:01.05+00	primary2	\N
0cfbff78-ad69-4b5a-b7a9-6e8445304e2e	55473dfa-dd2b-41e5-b85e-8da87261fa12	Primary 3	A	\N	2026/2027	first	2026-10-21 12:30:01.05+00	primary3	\N
205da335-77b1-4b2a-a28d-c29d486fdfa2	55473dfa-dd2b-41e5-b85e-8da87261fa12	Primary 4	A	\N	2026/2027	first	2026-10-21 12:30:01.05+00	primary4	\N
348762c6-f218-4ab6-beae-24b6380d49ee	55473dfa-dd2b-41e5-b85e-8da87261fa12	Primary 5	A	\N	2026/2027	first	2026-10-21 12:30:01.05+00	primary5	\N
2faded24-928f-47ff-aed9-0f93f037bfc4	55473dfa-dd2b-41e5-b85e-8da87261fa12	Primary 6	A	\N	2026/2027	first	2026-10-21 12:30:01.05+00	primary6	\N
af1920d1-c4a1-48e6-99e7-209d1924af7b	55473dfa-dd2b-41e5-b85e-8da87261fa12	SS 3	A	\N	2026/2027	first	2026-10-21 12:30:01.05+00	ss3	\N
ae6f04b8-2fac-43e8-beff-bf0cdfdddf68	9c2566ca-8f8a-4c9f-86fe-8e89181b5c60	Pre-Nursery	A	\N	2026/2027	first	2026-10-22 05:26:59.723+00	preNursery	\N
9ab2331f-ef83-4b84-b75a-3982be178525	9c2566ca-8f8a-4c9f-86fe-8e89181b5c60	Nursery 1	A	\N	2026/2027	first	2026-10-22 05:26:59.723+00	nursery1	\N
4e624e16-c370-45ee-a0a8-c881e6b1225b	9c2566ca-8f8a-4c9f-86fe-8e89181b5c60	Nursery 2	A	\N	2026/2027	first	2026-10-22 05:26:59.723+00	nursery2	\N
d60360b3-8d81-468d-84a2-e1bb3b90103a	9c2566ca-8f8a-4c9f-86fe-8e89181b5c60	Nursery 3	A	\N	2026/2027	first	2026-10-22 05:26:59.723+00	nursery3	\N
a7c57f11-9f28-4bdb-a1f4-9fddac1e7883	9c2566ca-8f8a-4c9f-86fe-8e89181b5c60	Primary 1	A	\N	2026/2027	first	2026-10-22 05:26:59.723+00	primary1	\N
cdbfe8ed-66d9-4883-af88-93cc401f93b6	9c2566ca-8f8a-4c9f-86fe-8e89181b5c60	Primary 2	A	\N	2026/2027	first	2026-10-22 05:26:59.723+00	primary2	\N
406f235c-7d2d-4a73-ab30-79ba15bc1877	9c2566ca-8f8a-4c9f-86fe-8e89181b5c60	Primary 3	A	\N	2026/2027	first	2026-10-22 05:26:59.723+00	primary3	\N
a6e92513-f78f-4288-a167-c72d2ac2a873	9c2566ca-8f8a-4c9f-86fe-8e89181b5c60	Primary 4	A	\N	2026/2027	first	2026-10-22 05:26:59.723+00	primary4	\N
d429b940-7324-42ef-820b-7c4e36509e5e	9c2566ca-8f8a-4c9f-86fe-8e89181b5c60	Primary 5	A	\N	2026/2027	first	2026-10-22 05:26:59.723+00	primary5	\N
08b1324a-876f-4aeb-b5be-895c2476d240	9c2566ca-8f8a-4c9f-86fe-8e89181b5c60	Primary 6	A	\N	2026/2027	first	2026-10-22 05:26:59.723+00	primary6	\N
b1c3b05e-1cfc-4a6b-9ec9-5aeac0b5c8bf	9c2566ca-8f8a-4c9f-86fe-8e89181b5c60	JSS 1	A	\N	2026/2027	first	2026-10-22 05:26:59.723+00	jss1	\N
1ada7c9d-57d9-4a53-87df-e96014002db9	9c2566ca-8f8a-4c9f-86fe-8e89181b5c60	JSS 2	A	\N	2026/2027	first	2026-10-22 05:26:59.723+00	jss2	\N
09fa9324-a688-4dbd-b388-9a905d5b017b	9c2566ca-8f8a-4c9f-86fe-8e89181b5c60	JSS 3	A	\N	2026/2027	first	2026-10-22 05:26:59.723+00	jss3	\N
20b013c4-742e-4aa4-8ba3-1c6842f81448	9c2566ca-8f8a-4c9f-86fe-8e89181b5c60	SS 1	A	\N	2026/2027	first	2026-10-22 05:26:59.723+00	ss1	\N
d20307ce-9d81-4cba-aad9-9f0a4f920d57	9c2566ca-8f8a-4c9f-86fe-8e89181b5c60	SS 2	A	\N	2026/2027	first	2026-10-22 05:26:59.723+00	ss2	\N
ae782cfd-a7b3-4f1b-bf44-32f9d1afe2e1	9c2566ca-8f8a-4c9f-86fe-8e89181b5c60	SS 3	A	\N	2026/2027	first	2026-10-22 05:26:59.723+00	ss3	science
641cf9ab-d2e1-4d5c-9905-36b9d333a875	55473dfa-dd2b-41e5-b85e-8da87261fa12	SS 2	B	cf187dd4-10a9-4290-a094-3e1501500532	2026/2027	second	2026-10-22 18:21:12.96+00	ss2	commercial
51a30184-8995-47bd-8bf8-79eed7049a0d	55473dfa-dd2b-41e5-b85e-8da87261fa12	SS 3	A	eb404c46-6936-4437-83f1-32ad565a36c0	2026/2027	second	2026-10-22 18:21:12.973+00	ss3	science
48a13b05-d5e3-4039-bd26-24dea4f9bde7	55473dfa-dd2b-41e5-b85e-8da87261fa12	SS 3	B	3c88d824-0a9c-4ab1-b670-63e07d753573	2026/2027	second	2026-10-22 18:21:12.981+00	ss3	arts
7a748658-0722-462b-a6a5-c8d8e3916b5e	55473dfa-dd2b-41e5-b85e-8da87261fa12	SS 2	C	47694af3-44f4-44fd-8535-6814b5d7b674	2026/2027	third	2026-10-22 19:00:34.609+00	ss2	science
e3476888-76e0-4a42-bad8-3678c5e7f311	55473dfa-dd2b-41e5-b85e-8da87261fa12	SS 2	D	9b167351-c1ea-4a4e-8780-c2b4a2a05ae0	2026/2027	third	2026-10-22 19:00:34.618+00	ss2	commercial
5252a0ab-36c6-4823-87ec-632a339c4dc0	55473dfa-dd2b-41e5-b85e-8da87261fa12	SS 3	C	c8dba8bf-d946-45a3-a8e2-6759e9c2ec88	2026/2027	third	2026-10-22 19:00:34.629+00	ss3	science
65961c57-bdba-4f4d-9956-791f065f8a43	55473dfa-dd2b-41e5-b85e-8da87261fa12	SS 3	D	f13e2c8c-50e4-4a44-8871-70471e7cbf0b	2026/2027	third	2026-10-22 19:00:34.637+00	ss3	arts
8ecbb9ec-466d-4074-8a2b-7f851e3b2505	55473dfa-dd2b-41e5-b85e-8da87261fa12	JSS 1	A	07854791-ba8b-40f1-a736-e8a1aeb92e99	2026/2027	second	2026-10-22 18:21:12.772+00	jss1	science
c1ac00b6-3080-41c6-b4af-19392f8ca82c	55473dfa-dd2b-41e5-b85e-8da87261fa12	JSS 1	B	aa44e78c-9c08-4fbe-90d1-fc42710311c4	2026/2027	second	2026-10-22 18:21:12.865+00	jss1	arts
df59c19a-8732-42d0-9e7e-31e1334994f7	55473dfa-dd2b-41e5-b85e-8da87261fa12	JSS 2	A	b5c1e55c-7604-4412-8fda-c018b7052744	2026/2027	second	2026-10-22 18:21:12.875+00	jss2	science
d1b0410c-caf9-4e20-a23c-8a1a3bff8d60	55473dfa-dd2b-41e5-b85e-8da87261fa12	JSS 3	A	1c912992-2c6b-4b91-8bd6-27f1823b31cd	2026/2027	second	2026-10-22 18:21:12.892+00	jss3	science
619802b8-ed2c-41cf-93e3-52a12dc6218a	55473dfa-dd2b-41e5-b85e-8da87261fa12	JSS 3	B	0deff77b-f13b-47c8-9e95-a5cdcce8130b	2026/2027	second	2026-10-22 18:21:12.909+00	jss3	arts
1110fe28-558c-485e-a5cd-2e1f879bee90	55473dfa-dd2b-41e5-b85e-8da87261fa12	SS 1	A	0f3d8137-c7ea-4d2b-b86f-8b258b8dcf2b	2026/2027	second	2026-10-22 18:21:12.921+00	ss1	science
fadaf65c-f7c1-4327-b8e6-c2c361db8176	55473dfa-dd2b-41e5-b85e-8da87261fa12	SS 1	B	ca97d592-e9a7-498a-adfe-b794f72a5841	2026/2027	second	2026-10-22 18:21:12.93+00	ss1	arts
8e1a5460-789f-4996-a702-f2d69b402906	55473dfa-dd2b-41e5-b85e-8da87261fa12	SS 2	A	9e6576d5-0f28-4332-a796-b3b35c0a7cc8	2026/2027	second	2026-10-22 18:21:12.95+00	ss2	science
afa8bb8f-12ea-480d-949b-ace41851d9c1	55473dfa-dd2b-41e5-b85e-8da87261fa12	JSS 1	A	8ff0d0d4-7040-4207-94ce-b6aa0405b3ff	2026/2027	first	2026-10-21 12:30:01.05+00	jss1	\N
715217da-e2e4-45bc-a7d8-30e3c4fbb152	55473dfa-dd2b-41e5-b85e-8da87261fa12	JSS 1	C	537bd8ee-a149-45dd-a44d-5ade8aa386d4	2026/2027	third	2026-10-22 19:00:34.5+00	jss1	science
306db6c9-cfbf-43f3-a90a-d3fae6a28e56	55473dfa-dd2b-41e5-b85e-8da87261fa12	JSS 1	D	d69e452a-890c-4b55-a34f-3eb5fa67f3f6	2026/2027	third	2026-10-22 19:00:34.515+00	jss1	general
b674150e-ecf1-4406-a813-67dd02768555	55473dfa-dd2b-41e5-b85e-8da87261fa12	JSS 2	C	c7c30512-8bbb-4b6e-877e-1b4103a17bbd	2026/2027	third	2026-10-22 19:00:34.529+00	jss2	general
0be7a4f6-1619-40a3-9f72-a7c262f0b863	55473dfa-dd2b-41e5-b85e-8da87261fa12	JSS 3	D	2278a7b9-a288-4e21-8207-94b80391e82a	2026/2027	third	2026-10-22 19:00:34.56+00	jss3	general
801ac4fb-14ed-49a0-ac4c-4835ff28549f	55473dfa-dd2b-41e5-b85e-8da87261fa12	JSS 3	C	cb4e8023-5ed2-48e9-a9f7-da5282241050	2026/2027	third	2026-10-22 19:00:34.57+00	jss3	general
d08e9e53-f7bd-4d0e-80ad-b22f29d0daab	55473dfa-dd2b-41e5-b85e-8da87261fa12	SS 1	C	ad9caaaa-d557-42cc-9a38-fedcc30c6a00	2026/2027	third	2026-10-22 19:00:34.582+00	ss1	science
d01fc901-3ad1-42b9-a782-8408060e4890	55473dfa-dd2b-41e5-b85e-8da87261fa12	SS 1	D	748ab699-5c99-4542-9a42-23617ee0341a	2026/2027	third	2026-10-22 19:00:34.595+00	ss1	arts
ee626e10-e1e7-477b-99d1-ad0f0b41c637	55473dfa-dd2b-41e5-b85e-8da87261fa12	JSS 2	B	\N	2026/2027	first	2026-10-25 16:31:42.951+00	jss2	general
ce697423-0175-4ab8-aada-ea5e5e0bf577	55473dfa-dd2b-41e5-b85e-8da87261fa12	JSS 3	B	\N	2026/2027	first	2026-10-25 16:32:28.991+00	jss3	general
d76be53d-676a-40e7-a36c-23ebeb29fbc1	55473dfa-dd2b-41e5-b85e-8da87261fa12	SS 2	A	\N	2026/2027	first	2026-10-25 16:35:25.068+00	ss2	science
\.


--
-- Data for Name: documents; Type: TABLE DATA; Schema: public; Owner: school_user
--

COPY public.documents (id, student_id, school_id, type, file_url, filename, uploaded_by, uploaded_at) FROM stdin;
\.


--
-- Data for Name: expense_records; Type: TABLE DATA; Schema: public; Owner: school_user
--

COPY public.expense_records (id, school_id, description, amount, category, recorded_by, date, created_at) FROM stdin;
\.


--
-- Data for Name: fee_structures; Type: TABLE DATA; Schema: public; Owner: school_user
--

COPY public.fee_structures (id, school_id, class_id, term, academic_year, amount, description, created_at) FROM stdin;
\.


--
-- Data for Name: leave_requests; Type: TABLE DATA; Schema: public; Owner: school_user
--

COPY public.leave_requests (id, student_id, school_id, submitted_by, reason, from_date, to_date, status, decision_note, decided_by, decided_at, created_at) FROM stdin;
\.


--
-- Data for Name: message_threads; Type: TABLE DATA; Schema: public; Owner: school_user
--

COPY public.message_threads (id, school_id, parent_id, teacher_id, student_id, created_at) FROM stdin;
\.


--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: school_user
--

COPY public.messages (id, thread_id, sender_id, body, sent_at, read_at) FROM stdin;
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: school_user
--

COPY public.notifications (id, user_id, school_id, title, body, type, data, is_system, is_read, created_at) FROM stdin;
3efe9fc8-2428-4706-855a-f46205fea88a	77dde5e4-f6dc-4b0d-b9b7-86e04882a581	55473dfa-dd2b-41e5-b85e-8da87261fa12	Attendance Marked	You were marked absent from JSS 1 on 2026-10-21.	attendance_alert	{"date": "2026-10-21", "className": "JSS 1", "studentId": "0d1127ea-8d25-4868-9ce5-63259ad922f1"}	f	f	2026-10-22 20:10:17.489+00
52e45054-bf78-4929-b823-3041816c8015	49bad0ce-cfb7-4bc0-a935-ec1d52644a26	55473dfa-dd2b-41e5-b85e-8da87261fa12	Attendance Marked	You were marked absent from JSS 1 on 2026-10-21.	attendance_alert	{"date": "2026-10-21", "className": "JSS 1", "studentId": "545797d7-ec01-4d74-8e49-a0177e267726"}	f	f	2026-10-22 20:10:17.535+00
79408e03-3409-4446-9769-c0c961d96f9a	07ecb076-9745-47aa-8511-b88c92f0ff78	55473dfa-dd2b-41e5-b85e-8da87261fa12	Attendance Marked	You were marked absent from JSS 1 on 2026-10-21.	attendance_alert	{"date": "2026-10-21", "className": "JSS 1", "studentId": "62390e06-36a4-49f3-8066-658b3ad17e53"}	f	f	2026-10-22 20:10:17.563+00
ed551a58-56b0-499a-a711-6e047c6c438e	dea5f580-3891-4f93-b2a8-4600f18b5ce3	55473dfa-dd2b-41e5-b85e-8da87261fa12	Attendance Marked	You were marked absent from JSS 1 on 2026-10-23.	attendance_alert	{"date": "2026-10-23", "className": "JSS 1", "studentId": "27c0237f-3b36-4400-b290-886cdb230f9a"}	f	f	2026-10-23 16:51:28.223+00
\.


--
-- Data for Name: otp_codes; Type: TABLE DATA; Schema: public; Owner: school_user
--

COPY public.otp_codes (id, phone, code, school_code, is_used, expires_at, created_at) FROM stdin;
\.


--
-- Data for Name: parent_student; Type: TABLE DATA; Schema: public; Owner: school_user
--

COPY public.parent_student (id, parent_id, student_id, relationship) FROM stdin;
\.


--
-- Data for Name: parents; Type: TABLE DATA; Schema: public; Owner: school_user
--

COPY public.parents (id, user_id, school_id, full_name, phone, email, occupation, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: payment_receipts; Type: TABLE DATA; Schema: public; Owner: school_user
--

COPY public.payment_receipts (id, payment_id, pdf_url, generated_at) FROM stdin;
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: school_user
--

COPY public.payments (id, student_id, school_id, amount, paystack_reference, paystack_access_code, payment_method, status, term, academic_year, paid_at, created_at) FROM stdin;
\.


--
-- Data for Name: push_tokens; Type: TABLE DATA; Schema: public; Owner: school_user
--

COPY public.push_tokens (id, user_id, token, platform, updated_at) FROM stdin;
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: school_user
--

COPY public.refresh_tokens (id, user_id, token_hash, expires_at, revoked_at, created_at) FROM stdin;
6bc0de6d-df91-4e32-a123-08b4d8baf0b7	a34c317f-5232-41a1-95b8-d762d3a0ec8e	b3cd367851af7fe1e74fac6cb37059338f3a6a9baac5eb36ef9fea735abb9223	2026-11-21 05:29:30.284+00	2026-10-22 05:30:41.864+00	2026-10-22 05:29:30.286+00
c4e50b2a-3d2e-4a77-840c-44940d97313f	a34c317f-5232-41a1-95b8-d762d3a0ec8e	10c049e46ecff8275c40e308041917846b78358ac1eb5ac85481f7c6493427e1	2026-11-21 05:30:41.887+00	\N	2026-10-22 05:30:41.888+00
8f15bee8-1cfa-4080-9994-5c0ee5ffb7d3	a34c317f-5232-41a1-95b8-d762d3a0ec8e	51503e53342c49e14ff6143793084592952b9fe9419bb22e355531f2344289f2	2026-11-21 05:34:10.307+00	2026-10-22 05:36:29.711+00	2026-10-22 05:34:10.309+00
cb2afe78-8db2-44d4-82e0-a52de050dcbd	a34c317f-5232-41a1-95b8-d762d3a0ec8e	51442ff070770dfb749fee65e32a7c4bd5c37762baef57b4f8f05fe393c51872	2026-11-21 05:36:29.73+00	2026-10-22 05:37:26.962+00	2026-10-22 05:36:29.731+00
667849ce-696b-4c7d-b57d-613db0483b8c	a34c317f-5232-41a1-95b8-d762d3a0ec8e	fd1d80179634d74cd5d4107897fbc67db797221650be3af4df71921dfaed59bd	2026-11-21 05:37:26.974+00	2026-10-22 05:37:30.439+00	2026-10-22 05:37:26.975+00
e28e0acf-9102-4951-8cec-14970d3a4ca4	a34c317f-5232-41a1-95b8-d762d3a0ec8e	4524932a2e646ca24d686d1694a57882a7d11b3e763458faa4c18cea5434797c	2026-11-21 05:37:30.455+00	2026-10-22 05:38:59.618+00	2026-10-22 05:37:30.457+00
64180780-7897-4e87-a4bc-873b2473f307	a34c317f-5232-41a1-95b8-d762d3a0ec8e	e4700a9918945b805bccd11f130da3a045a4dba2df2d3c58fb8bfdd2e4f30aa2	2026-11-21 05:38:59.636+00	2026-10-22 05:39:02.675+00	2026-10-22 05:38:59.637+00
b6c35d67-37e7-45e3-be96-05db98a8b1b4	a34c317f-5232-41a1-95b8-d762d3a0ec8e	185824f01e8a82cef3bdbdfc6290a0071b84e9dc202dea3cf7aa542eb6e72dcc	2026-11-21 05:39:02.689+00	2026-10-22 06:15:54.645+00	2026-10-22 05:39:02.69+00
7a7e86ec-ab35-4824-9da8-b2b4dd4d9bea	a34c317f-5232-41a1-95b8-d762d3a0ec8e	89f3f9298841b6e4122fa29503add5540ab3c98a5896d2c7a33e8371c298e4c2	2026-11-21 06:15:54.667+00	2026-10-22 06:16:11.693+00	2026-10-22 06:15:54.67+00
4756ac14-5d0f-4387-920d-66d9067e094a	a34c317f-5232-41a1-95b8-d762d3a0ec8e	c79e51c94f8598ad61986856c4ffc7508e1ab5b4056f98576585fe651a1b831f	2026-11-21 06:16:11.702+00	2026-10-22 06:23:46.718+00	2026-10-22 06:16:11.703+00
8008b57d-b91b-4fd6-877a-0ea0767c3ac6	a34c317f-5232-41a1-95b8-d762d3a0ec8e	5bf2769874d29c83ddcb5b696b1c2b8dbe0be8d8c9a3529d843e77ed864c0f57	2026-11-21 06:23:46.74+00	2026-10-22 06:35:40.223+00	2026-10-22 06:23:46.741+00
af2b457f-28e0-41a7-8d93-773f2eba2def	a34c317f-5232-41a1-95b8-d762d3a0ec8e	51518d6a353e5ad665503dad56f9da98f17d4b79fdad86f870c2deef532d7402	2026-11-21 06:35:40.247+00	2026-10-22 07:06:45.526+00	2026-10-22 06:35:40.248+00
282417ab-1f5d-4685-ae9a-67f1424d7bf9	a34c317f-5232-41a1-95b8-d762d3a0ec8e	f92847b41046dca274446a5187d43893c0195abe3b2aab93404ba366fd4458d6	2026-11-21 07:06:45.561+00	2026-10-22 08:12:25.135+00	2026-10-22 07:06:45.562+00
4c1663c1-8507-41c1-93c4-78676a77e332	a34c317f-5232-41a1-95b8-d762d3a0ec8e	399717c69933e3a8e315d8554a2ce84a08a694f623859c1bcdce2855da18c169	2026-11-21 08:12:25.153+00	2026-10-22 08:26:19.091+00	2026-10-22 08:12:25.154+00
1e59711e-eb03-4e40-9848-5364612729ce	a34c317f-5232-41a1-95b8-d762d3a0ec8e	e8935d9ab3d2189fb424b99c11a08a1b8f53cd2ade7fdfe30f3fc77b138db285	2026-11-21 08:26:19.106+00	2026-10-22 08:32:10.489+00	2026-10-22 08:26:19.108+00
ea2a9b84-6581-4265-a67d-9c5ede738e93	a34c317f-5232-41a1-95b8-d762d3a0ec8e	28360d7d9cc8ce7bde86ff3acffccb98522047a7e563a164d14757dde538b643	2026-11-21 08:32:10.5+00	2026-10-22 08:32:20.204+00	2026-10-22 08:32:10.502+00
deb04332-2290-4d62-b4d3-65fa91f8fdab	a34c317f-5232-41a1-95b8-d762d3a0ec8e	1b01fa4692c18a40488b5eb40b37c3d1c929c039a44a0a0903144430a9237c21	2026-11-21 08:32:20.212+00	2026-10-22 08:32:51.844+00	2026-10-22 08:32:20.215+00
d6135698-6210-4be8-b87e-6919726ddb0f	a34c317f-5232-41a1-95b8-d762d3a0ec8e	3246dd88d00797d68c862468419c01b940779f9754218aba3b4094e42a5732a0	2026-11-21 08:32:51.864+00	2026-10-22 09:36:33.876+00	2026-10-22 08:32:51.865+00
6ca16beb-c675-498d-9a32-729560fe3130	a34c317f-5232-41a1-95b8-d762d3a0ec8e	3f1983783b638ecf9448a0e7c5496ffb3b9a0148e29d063cdcbb78d190ef00a9	2026-11-21 09:36:33.911+00	2026-10-22 10:01:20.645+00	2026-10-22 09:36:33.914+00
a8b008d9-18a0-467f-9815-e3c0c20906dc	a34c317f-5232-41a1-95b8-d762d3a0ec8e	7e50cfb07968af7bf929e888ed10e4cb4cb38d79ee46b46d831f5b9d3ff748ff	2026-11-21 10:01:20.666+00	2026-10-22 10:04:51.175+00	2026-10-22 10:01:20.666+00
772f4ed1-acee-41af-9f21-2be1d351b908	a34c317f-5232-41a1-95b8-d762d3a0ec8e	2efb9a6b23e2cdf563964fd3fffa3cb2cade18b4c39a4356b3181c60b83de3f7	2026-11-21 10:04:51.218+00	2026-10-22 10:24:49.306+00	2026-10-22 10:04:51.219+00
6dc33183-27b7-4dc8-a2ca-9152ba91e37e	a34c317f-5232-41a1-95b8-d762d3a0ec8e	3721824ea05f17debcd3ecccbcabd6eafb4e8011a08cb06572ea7909ad543eb2	2026-11-21 10:24:49.331+00	2026-10-22 10:26:16.868+00	2026-10-22 10:24:49.332+00
a764efcc-d618-4346-b1d5-6ce66eefb226	a34c317f-5232-41a1-95b8-d762d3a0ec8e	15c3c1a6b343c1ffd3f2805d507c04b140e32400be392e25f82b7f774f80c67d	2026-11-21 10:26:16.898+00	2026-10-22 10:37:41.515+00	2026-10-22 10:26:16.908+00
aafa1c97-384f-43ce-9109-3f3bf9cdf7c7	a34c317f-5232-41a1-95b8-d762d3a0ec8e	46d554c7ca394b67610a12ecb5ecf2f4e77836a4e8c6f97e2d2ebce65bb24779	2026-11-21 10:37:41.649+00	2026-10-22 10:37:41.978+00	2026-10-22 10:37:41.69+00
0c3d78d6-8162-41d5-91f1-3756d3a3c2ff	a34c317f-5232-41a1-95b8-d762d3a0ec8e	f9f78462cd8626c1ff6d15fa25f3d39039808b8e553636070df2fbed21d2fb32	2026-11-21 10:37:41.988+00	\N	2026-10-22 10:37:41.989+00
4d45d09d-bc32-4939-81c8-c5a7b714ef44	a34c317f-5232-41a1-95b8-d762d3a0ec8e	7e4768908e925f2089006da6bdd8e17fa839446da17fda0daeae07d26609e161	2026-11-21 11:26:28.738+00	2026-10-22 11:30:04.818+00	2026-10-22 11:26:28.74+00
739cacc7-6684-4619-bed5-2632e50cc1ce	a34c317f-5232-41a1-95b8-d762d3a0ec8e	a3edacb236fdfd9a04a0b84147255be4138bb82959e1f2d202286c76c3e6c5bd	2026-11-21 11:30:04.854+00	2026-10-22 11:30:29.674+00	2026-10-22 11:30:04.855+00
77884345-c030-41f7-84f0-583a205898a6	a34c317f-5232-41a1-95b8-d762d3a0ec8e	bf17768328da201080212c8c25ea08b56eb2d507adcff41851a048304b3363df	2026-11-21 11:31:05.861+00	2026-10-22 11:32:09.364+00	2026-10-22 11:31:05.862+00
c2f92f6c-d8cf-44f4-b71a-62f44892c323	a34c317f-5232-41a1-95b8-d762d3a0ec8e	20a7b727b684a7ef8a918af9c9d4b5b53232eb95ba505b02ee8f53e8c46c473d	2026-11-21 11:32:09.375+00	2026-10-22 12:00:50.274+00	2026-10-22 11:32:09.376+00
5a4f45d9-99c2-4edf-9466-426eccc44685	a34c317f-5232-41a1-95b8-d762d3a0ec8e	946ca135c389cf79242ee91fa25baafd1a25b314277a699bbb09eaabe7330232	2026-11-21 12:00:50.393+00	2026-10-22 12:01:26.963+00	2026-10-22 12:00:50.421+00
fbb336b5-b0cf-433d-b5d7-5b1f69a7f243	a34c317f-5232-41a1-95b8-d762d3a0ec8e	2c49424ec788b1c3359f4791dfa082a24ac3f38a29f8afc289db665e32a1985c	2026-11-21 12:01:26.985+00	2026-10-22 12:01:32.723+00	2026-10-22 12:01:26.986+00
b6770e8d-515d-4658-9e65-92db8450ea13	a34c317f-5232-41a1-95b8-d762d3a0ec8e	86b22538610ea41b37577a9b3a499215044df79e453914f801f6702042ab72e1	2026-11-21 12:01:32.735+00	2026-10-22 12:04:35.756+00	2026-10-22 12:01:32.737+00
f5ffa525-c753-476f-826e-a3c2b4d03de6	a34c317f-5232-41a1-95b8-d762d3a0ec8e	5c6d093d290dc079a3b1109eb4ed0e33912a84a42f8434baa174a5b3c9ee3a34	2026-11-21 12:04:35.783+00	2026-10-22 12:04:40.426+00	2026-10-22 12:04:35.785+00
c8a68b71-02a4-4f67-b15b-d1bf5b9bfea4	a34c317f-5232-41a1-95b8-d762d3a0ec8e	2a14e891f63e9c580e9799e8a5be8670a2a9f7b53fbf1aeea1b85b1aaeadcad9	2026-11-21 12:04:40.445+00	2026-10-22 12:16:00.371+00	2026-10-22 12:04:40.447+00
0a28a26c-cbbc-44a3-a27b-3f6ca51a2fdc	a34c317f-5232-41a1-95b8-d762d3a0ec8e	cd769072cf52aeab940bac9cf81defd6a96a8be03d2bff1114f4c0852f38eee8	2026-11-21 12:16:00.392+00	2026-10-22 12:16:13.675+00	2026-10-22 12:16:00.394+00
05a10aeb-fa8a-426d-8638-6d0c380dbf83	a34c317f-5232-41a1-95b8-d762d3a0ec8e	2e8f6482846b00a407b47c664d6b646b2f79f6c517d4a0b6a55c630658e3aa77	2026-11-21 12:16:13.69+00	2026-10-22 12:16:17.955+00	2026-10-22 12:16:13.693+00
682c2f78-4120-4f35-9f20-0385068acc79	a34c317f-5232-41a1-95b8-d762d3a0ec8e	42079c2651b5c5743968113e1cb84c01ce05665b755b0b750225c6c632c7be85	2026-11-21 12:16:17.966+00	2026-10-22 12:17:31.309+00	2026-10-22 12:16:17.967+00
00129595-36b7-4ce3-808e-d39c9d7b1ffe	5c926164-c0cd-49e5-a1c0-851b475449b0	dd5a89c30578832e058c7247c2323f2f591e358a8d7499dabdb0209f20a20a11	2026-11-21 12:34:14.875+00	2026-10-22 12:39:16.703+00	2026-10-22 12:34:14.876+00
ada654e3-2b7b-4b3e-94e4-1126ad9b52bf	5c926164-c0cd-49e5-a1c0-851b475449b0	38d2f8c985135fe99ac0e2f8d43d9c2ac5e0ca6f5d97d6fe818cd91166bdf7cd	2026-11-21 12:39:16.723+00	2026-10-22 12:39:21.19+00	2026-10-22 12:39:16.723+00
a4ccc7f2-d47d-4f25-bd1c-03f5777f1cdb	5c926164-c0cd-49e5-a1c0-851b475449b0	578003b67244e44b6bc023a999e898a0de413403fd87cbcc3592acd457a0817f	2026-11-21 12:39:21.212+00	2026-10-22 12:40:32.787+00	2026-10-22 12:39:21.213+00
1ac3c788-39ec-4f7d-8178-72f798c46f58	5c926164-c0cd-49e5-a1c0-851b475449b0	92c5a2c2cc3f80666d84d827f95c096fbd74993030e91abceffe1900f9aaeb65	2026-11-21 12:40:32.806+00	2026-10-22 12:40:36.891+00	2026-10-22 12:40:32.807+00
e7a219c3-f376-4806-ae44-31309b0c5c53	5c926164-c0cd-49e5-a1c0-851b475449b0	45d4c11ab2575ce44928e73c7e716e2f0ba4d3070f56b139226009c9b9a0bc90	2026-11-21 12:40:36.918+00	2026-10-22 12:48:48.561+00	2026-10-22 12:40:36.92+00
8a0f7927-da86-45d8-aa59-d85e44ee9382	5c926164-c0cd-49e5-a1c0-851b475449b0	f921e049e1569ee9d7b32a4138e382a029566571fa5a9f2cf5d3a27adcb67789	2026-11-21 12:48:48.586+00	2026-10-22 12:52:19.71+00	2026-10-22 12:48:48.587+00
dc99b6ba-4c3f-4933-b899-bb4ae921cbea	5c926164-c0cd-49e5-a1c0-851b475449b0	90a2f6dfaf7c85bdfb256bcd4aa8dce1a1c98588feeb2280d03115d60c55d1b3	2026-11-21 12:52:19.728+00	2026-10-22 12:52:50.701+00	2026-10-22 12:52:19.729+00
5ee78ddf-f926-4b1e-8feb-3cb9d58ffe4c	5c926164-c0cd-49e5-a1c0-851b475449b0	bcb67924733a527e1657b377ec9148f9ef5456c61dc8c406ad253bc0c0554bce	2026-11-21 12:52:50.71+00	2026-10-22 12:59:53.882+00	2026-10-22 12:52:50.71+00
99b3f5d9-068d-4147-b239-ae5dbf8b81c3	5c926164-c0cd-49e5-a1c0-851b475449b0	62e76d074c722db1d7901c5254480494c796a0c97f8d75a6ce771725d2f142bd	2026-11-21 12:59:53.899+00	2026-10-22 12:59:58.646+00	2026-10-22 12:59:53.9+00
5d7522fc-fc47-46ac-8bb6-1d02777d18b6	5c926164-c0cd-49e5-a1c0-851b475449b0	61dd388c4510a302ae8876aa9c07782b477255b4a754638ea429f5745598a873	2026-11-21 12:59:58.663+00	2026-10-22 13:15:00.386+00	2026-10-22 12:59:58.665+00
22f69b5e-947a-48ec-8139-d74873a14074	5c926164-c0cd-49e5-a1c0-851b475449b0	0b17e2c7f8595e320ec984cc4603f356634b61840714d8b116764b30bbc61278	2026-11-21 13:15:00.397+00	2026-10-22 13:19:13.449+00	2026-10-22 13:15:00.399+00
cef50cda-4eae-4d91-abe4-1f11c42a5283	5c926164-c0cd-49e5-a1c0-851b475449b0	119eae34c1be2b7ec667450ccb567f1bf53584bcd4e9cbd047b3efa85efe6fb5	2026-11-21 13:19:13.469+00	2026-10-22 15:48:52.206+00	2026-10-22 13:19:13.47+00
a7e32346-61f2-45f6-aa13-45f4d73f1740	5c926164-c0cd-49e5-a1c0-851b475449b0	808daf7eb03764675c5755f76a638098d43afe35c60cc3fe05aca39af6317d4f	2026-11-21 15:48:52.281+00	2026-10-22 16:25:41.378+00	2026-10-22 15:48:52.316+00
5f166b96-786c-4442-b957-3568a82628a0	b38ff10a-1f66-4e28-8b0e-56d6f8a2ef62	8fed4ee16dbdf20ce320702125f82c4f3655b1188f91b8618a17a51ea4b377d5	2026-11-21 16:23:48.725+00	2026-10-22 16:24:12.643+00	2026-10-22 16:23:48.726+00
70f65ffc-09c7-471a-9d3a-30bde77ef5b5	b38ff10a-1f66-4e28-8b0e-56d6f8a2ef62	03b764dd6e50a8fa4915a82e894a39ca92e3dcfa2802efdda28b3a6f8389b583	2026-11-21 16:24:12.656+00	2026-10-22 16:24:15.261+00	2026-10-22 16:24:12.657+00
414cb306-cd48-4423-8e60-6d1a256c01f5	b38ff10a-1f66-4e28-8b0e-56d6f8a2ef62	90ba71d31670393dfd9bae7b6ec79de3d9c955afe05170c84fb855a315e6235e	2026-11-21 16:24:15.28+00	2026-10-22 16:24:22.167+00	2026-10-22 16:24:15.281+00
590f77a2-32d1-4c44-9ee2-193d946bf391	b38ff10a-1f66-4e28-8b0e-56d6f8a2ef62	fcc2b4bc252933f033537eb1fa108b2ef9cadd16333eea2137b02de1eee38837	2026-11-21 16:24:22.176+00	2026-10-22 16:24:24.957+00	2026-10-22 16:24:22.177+00
a7a9c08d-b708-473f-931f-98c020497520	b38ff10a-1f66-4e28-8b0e-56d6f8a2ef62	cb4182ac2fd4d30f4f96f1aba637b2bcec57038afe2f39d9afd784a360a8c33c	2026-11-21 16:24:24.974+00	2026-10-22 16:25:41.342+00	2026-10-22 16:24:24.974+00
52abb6c1-58c8-4e25-98bc-a336d4b37932	b38ff10a-1f66-4e28-8b0e-56d6f8a2ef62	c559a3498c806d4fced9d170834cb79bcb0abcacc12d1eeba63edf3cffd5077f	2026-11-21 16:25:41.369+00	2026-10-22 16:40:32.99+00	2026-10-22 16:25:41.37+00
93760cdf-5c32-4966-9637-acbcfc49bb93	b38ff10a-1f66-4e28-8b0e-56d6f8a2ef62	c52625ea099f1fd361f18c02033c7f8ada3502833084b6b7ee692a78bfde9d7b	2026-11-21 16:40:33.062+00	2026-10-22 17:00:40.684+00	2026-10-22 16:40:33.074+00
7d790d3a-9910-44cd-843c-6838a1742826	5c926164-c0cd-49e5-a1c0-851b475449b0	068d43952040f6a64fa754c16f613c6c5549027874d1db1b50c7bbafb59cba4d	2026-11-21 16:25:41.417+00	2026-10-22 17:00:42.88+00	2026-10-22 16:25:41.419+00
88edd6c8-1b0b-40d9-bbcf-aa8d233b00b5	5c926164-c0cd-49e5-a1c0-851b475449b0	02757538577e369ec28e37ca6e60dc2021db62c52fed07c1f7541b209b10c9a9	2026-11-21 17:00:42.902+00	2026-10-22 17:02:42.959+00	2026-10-22 17:00:42.906+00
f03b9f58-e9b3-4a58-9659-f6ec3ae5f8d3	5c926164-c0cd-49e5-a1c0-851b475449b0	f5034ab1fdd0a9a1ec6c1cfedb6b6e772d83fea4640b97f019b84804a3f95d05	2026-11-21 17:02:42.971+00	2026-10-22 17:02:44.892+00	2026-10-22 17:02:42.971+00
c096e7fa-949b-4885-bc06-db83ce2738cf	b38ff10a-1f66-4e28-8b0e-56d6f8a2ef62	910cddaadfb9006fbb2085b5f3af3439cfceca3830af93aeb4eb157c9c65a58d	2026-11-21 17:00:40.7+00	2026-10-22 17:02:59.127+00	2026-10-22 17:00:40.701+00
ffa9bb90-1ef8-4846-9eaa-a6e8cd196235	ab334393-b63e-433c-b9b4-c9a217fbfb94	e1f9ddf671e8d7917df0c8e3553c474e3d9c866763e05e92dd5de396b13a1fac	2026-11-21 17:14:05.294+00	2026-10-22 17:15:13.722+00	2026-10-22 17:14:05.318+00
0fa91573-41dd-486d-9539-bb1a4b031181	14a4c16a-5de5-46b7-892b-ddb8e93034c1	fb9a0c52f52625248c244f0adad1d5992418fbc47377557584068f49fe497f5d	2026-11-21 17:15:45.572+00	2026-10-22 17:18:19.808+00	2026-10-22 17:15:45.572+00
6d7b9987-1255-4996-9d36-0d10fbff1915	cdc55efc-9318-46e8-be97-59fd660234be	2daa68b0de91dcfc2a0f74b7f73301917959039df59b7cf081e34418d4ad2385	2026-11-21 17:18:44.713+00	2026-10-22 17:19:20.296+00	2026-10-22 17:18:44.714+00
e447543a-48ad-4b57-826a-774d4058220c	cdc55efc-9318-46e8-be97-59fd660234be	9a30c38eaa64311a4ceaa3c3d441060902de39945a6ae63ace0a789f5410d2d4	2026-11-21 17:19:20.33+00	2026-10-22 17:19:22.976+00	2026-10-22 17:19:20.33+00
b6a9879f-1d52-424c-9bea-94ef995b51a3	5c926164-c0cd-49e5-a1c0-851b475449b0	cc681ac043e32ac23d3a1c41fa97f4abae91835230e6e995cb41762276096e7a	2026-11-21 17:02:44.912+00	2026-10-22 17:50:07.645+00	2026-10-22 17:02:44.913+00
2a39cb4f-da4d-44d1-b756-d9f17f8a876d	5c926164-c0cd-49e5-a1c0-851b475449b0	95a56908532ea3cf9e1d092edf338c77b4abfbe5f9ab9dfd3215ef5d335e29e5	2026-11-21 17:50:07.723+00	2026-10-22 17:50:10.535+00	2026-10-22 17:50:07.737+00
b4e19819-3326-44d9-a755-11a99bf5a362	5c926164-c0cd-49e5-a1c0-851b475449b0	fc6cb98770a4faed1f0175789eb994f8044931ec7ad64327a6b33c69fe3e5f17	2026-11-21 17:50:10.553+00	2026-10-22 18:23:17.148+00	2026-10-22 17:50:10.554+00
fc650543-bbe5-449e-9d49-b72d4ebebd98	5c926164-c0cd-49e5-a1c0-851b475449b0	43db039139e0be85d9d064147c0e92854b3b2eb92eb6ed69bd0b1e3794c9173f	2026-11-21 18:23:17.233+00	2026-10-22 19:06:17.597+00	2026-10-22 18:23:17.253+00
89d3be8d-5493-4f3e-9dce-d6b438a83e6c	5c926164-c0cd-49e5-a1c0-851b475449b0	9b9fc914dedc1637db461c39d8139fd9489ca5f823e333e4e46db72d0f848b08	2026-11-21 19:06:17.716+00	2026-10-22 19:12:29.028+00	2026-10-22 19:06:17.754+00
e2f72340-58dd-420e-a7f2-578ece66577d	5c926164-c0cd-49e5-a1c0-851b475449b0	a3913a7c445473692e158d323ec1f18ac52e62c1382da4b509260cd42fd4a833	2026-11-21 19:12:29.05+00	2026-10-22 19:12:32.492+00	2026-10-22 19:12:29.051+00
165e3fe6-73ee-4867-9232-d5c2a3b2b7b9	5c926164-c0cd-49e5-a1c0-851b475449b0	d2053775c8861c9c290a96989ff4791b21defd291879d6e4d4e4950d93d48211	2026-11-21 19:12:32.522+00	2026-10-22 19:13:10.664+00	2026-10-22 19:12:32.524+00
4e343d19-1e1f-4eb8-8d4a-26fc0d49f61e	5c926164-c0cd-49e5-a1c0-851b475449b0	d6ce5a1b817578c4cd21467590f917cc7110d36fa01e7a09720fcb3266fc62a8	2026-11-21 19:13:10.678+00	2026-10-22 19:13:19.938+00	2026-10-22 19:13:10.679+00
ad803a90-6f15-4ebc-ac7b-6a5e03f7b889	5c926164-c0cd-49e5-a1c0-851b475449b0	2b5a03f54b8f7b729c6a7da5c78f7db03beef45e9a2eda971af4a4501b88ab28	2026-11-21 19:13:19.954+00	2026-10-22 19:23:05.8+00	2026-10-22 19:13:19.956+00
6e14e8e4-fcdc-49ba-b627-80a5a65288d3	5c926164-c0cd-49e5-a1c0-851b475449b0	cc82085a3934d0fca99620a7a711ab61a14319474a5577057045b687c2cd5931	2026-11-21 19:23:05.817+00	2026-10-22 19:27:12.899+00	2026-10-22 19:23:05.818+00
945b317a-3a32-4fe7-885c-ea8f2e82f584	cdc55efc-9318-46e8-be97-59fd660234be	22d3c1493a3593e646a17c8d69a7c30184935b0cb502839184125f853da1019a	2026-11-21 17:19:22.987+00	2026-10-22 19:27:12.95+00	2026-10-22 17:19:22.987+00
6c5bde2c-82e8-4f19-8cfd-0c50f572bd1a	cdc55efc-9318-46e8-be97-59fd660234be	d58dbf5bb0a9cd31e9f1b4f6265b376bfea2fc57aecb5c48ec646cdbc6890897	2026-11-21 19:27:12.976+00	2026-10-22 19:54:28.046+00	2026-10-22 19:27:12.977+00
5a224eee-4f2d-4981-887c-95165e497b2e	5c926164-c0cd-49e5-a1c0-851b475449b0	e6d5b2e20157c009f2736764bde3dd0870277d44f29b1dc6e4759100787101ec	2026-11-21 19:27:12.927+00	2026-10-22 19:54:28.237+00	2026-10-22 19:27:12.936+00
af811804-8693-492a-99de-196b87ced5e3	cdc55efc-9318-46e8-be97-59fd660234be	d2337ce21e293913106c513618ae22f41b910a4fc5184c8ce9fbd5f0818631f7	2026-11-21 19:54:28.19+00	2026-10-22 20:35:13.613+00	2026-10-22 19:54:28.225+00
f50097d6-5985-4493-89dd-41a216fd7116	5c926164-c0cd-49e5-a1c0-851b475449b0	f79dcbe9ede420a48a1c7c1c60f08d1f6a3c9c6aaf50273e0080772fea72a51e	2026-11-21 19:54:28.283+00	2026-10-22 20:35:13.743+00	2026-10-22 19:54:28.287+00
2fc0a75d-a567-46d6-9f4a-83a2c9e570f7	5c926164-c0cd-49e5-a1c0-851b475449b0	1d45953b60d31655f90bdedf8083c570711fca0166dd255aaef7c1e9d9f15182	2026-11-21 20:35:13.768+00	2026-10-22 20:35:53.821+00	2026-10-22 20:35:13.769+00
7c64bb57-7dbd-45da-82da-4abc594ff236	cdc55efc-9318-46e8-be97-59fd660234be	549ed80305c2e086cf67e1aeda250c69fff41c9bcd15818fdd2c61c63b163b39	2026-11-21 20:35:13.68+00	2026-10-22 20:35:53.812+00	2026-10-22 20:35:13.685+00
e963ddcc-789d-4490-a063-95320654d982	5c926164-c0cd-49e5-a1c0-851b475449b0	631d788356354cca95c53cc26ebb5fbc783ad956e972fd1c3b5f7f0072ab6065	2026-11-21 20:35:53.843+00	2026-10-22 20:36:24.327+00	2026-10-22 20:35:53.844+00
75abb1a9-d0cd-4f71-8419-11ea435d3ed9	cdc55efc-9318-46e8-be97-59fd660234be	e5fe507458f938f50b25891949c501af7d70814501f557b6ce75a2ab9a6dd60d	2026-11-21 20:35:53.856+00	2026-10-22 20:36:24.338+00	2026-10-22 20:35:53.858+00
3b758c3a-4fe0-47e5-a647-dea0e02ce454	cdc55efc-9318-46e8-be97-59fd660234be	0c11c2608cc97b5fa02d841db638eef8b2ec3b8709f049157e5ee555db367ffd	2026-11-21 20:36:24.371+00	2026-10-22 20:37:26.387+00	2026-10-22 20:36:24.372+00
2cad83bb-6ca6-4ca6-854a-c014f5271ced	cdc55efc-9318-46e8-be97-59fd660234be	4a1e146890f246fbfd9f84ec33e397eb4d3b7a41e811d812b5f5cfa357601885	2026-11-21 20:37:26.408+00	\N	2026-10-22 20:37:26.41+00
a0524249-0740-407c-9391-31c755e00ee7	5c926164-c0cd-49e5-a1c0-851b475449b0	16aa2512963e86562d3605c83bf731fe4f3282a924c6e9d124a67174e43ad7ba	2026-11-21 20:36:24.364+00	2026-10-22 20:37:26.415+00	2026-10-22 20:36:24.366+00
7f714984-d6c7-484a-bde9-4763fd448343	5c926164-c0cd-49e5-a1c0-851b475449b0	987e266f8c3d4c4e05ae82c09eb35902d3ca31c2d5ebbec78b6df991879791ba	2026-11-21 20:37:26.445+00	2026-10-22 20:40:08.327+00	2026-10-22 20:37:26.447+00
adb06420-7497-4670-80ae-99ffc828bf3b	5c926164-c0cd-49e5-a1c0-851b475449b0	2498329f633b56e59c803295482678ef863d7ffb21a4f909bec9807b9f4ddde4	2026-11-21 20:40:08.342+00	2026-10-22 20:41:23.25+00	2026-10-22 20:40:08.352+00
cd47123a-6c31-4984-9dbc-1bd102b1bb9f	5c926164-c0cd-49e5-a1c0-851b475449b0	57949b1f14736235de352ef5a83bc5f38dfc52e100dd9b5f0e3eb4c0e8d6b7f7	2026-11-21 20:41:23.269+00	2026-10-22 20:41:25.97+00	2026-10-22 20:41:23.273+00
551c5976-41af-4454-9ac6-1dd375f7ded7	5c926164-c0cd-49e5-a1c0-851b475449b0	c38876f868492d3d1038f08d7e362fd916867593a95fe91c85d8ed47534c162e	2026-11-21 20:41:25.993+00	2026-10-22 20:43:07.889+00	2026-10-22 20:41:25.994+00
93d6073e-29bf-4eac-9aeb-dfccb2473863	5c926164-c0cd-49e5-a1c0-851b475449b0	b66d7d84eb0981a454c42b16767fdbcd578b76ea7d9ba6953afa116e6198f108	2026-11-21 20:43:07.903+00	2026-10-22 20:43:10.975+00	2026-10-22 20:43:07.905+00
eaa400c8-3159-4244-bdf9-c8bb62cc48df	5c926164-c0cd-49e5-a1c0-851b475449b0	579723570466a35d6f392a38e2e705da63892f8a33cb2f175978484a635a829f	2026-11-21 20:43:10.987+00	2026-10-22 20:43:21.611+00	2026-10-22 20:43:10.988+00
b71a8363-60f0-4ef0-b065-38183592c16c	5c926164-c0cd-49e5-a1c0-851b475449b0	ccf748218ac727d1797440873653107e849a9d350cefc3dedc2d63a894b40670	2026-11-21 20:43:21.627+00	2026-10-22 20:43:25.052+00	2026-10-22 20:43:21.628+00
65f7a9fb-7309-4191-9159-256f3ae56c9c	5c926164-c0cd-49e5-a1c0-851b475449b0	6f64f6b485bd2ad3574e9d20683d2ec56def2b2f9eae0e4e820929a83ce49582	2026-11-21 20:43:25.073+00	2026-10-22 20:54:55.445+00	2026-10-22 20:43:25.074+00
ee871e3d-a9d0-46fd-8194-2be0d917f5fb	5c926164-c0cd-49e5-a1c0-851b475449b0	ec6c1ca93e7ce971fa140eb0b7130d6ef4e440ef586f97fc12a2037d5d8094a8	2026-11-21 20:54:55.457+00	2026-10-22 21:00:05.382+00	2026-10-22 20:54:55.458+00
bcd0fed0-ed73-47be-942f-db1ddcb3ff28	5c926164-c0cd-49e5-a1c0-851b475449b0	f13c0a425fe81c73fdb5e43833782af2d682660a796926467dc832a31c4fd7fb	2026-11-21 21:00:05.395+00	2026-10-22 21:00:50.327+00	2026-10-22 21:00:05.396+00
f44ec921-7caf-4780-a63d-5a1f98f3faa4	5c926164-c0cd-49e5-a1c0-851b475449b0	e11d43be528eb8717b1b324bf823213b8ec79ca87b9521e617f561998bccf885	2026-11-21 21:00:50.342+00	2026-10-22 21:04:48.836+00	2026-10-22 21:00:50.343+00
02915a20-4cdd-4d35-8578-ba44e3511c8f	5c926164-c0cd-49e5-a1c0-851b475449b0	3de4e047969062c4e0187b2a0b3d83b5c91ed4ac7155070e11511d195e64bb14	2026-11-21 21:04:48.851+00	2026-10-22 21:13:57.473+00	2026-10-22 21:04:48.852+00
57250a40-9b26-4c2e-ab33-b99e62b2b3fe	5c926164-c0cd-49e5-a1c0-851b475449b0	f117543d916fa5bfe8309bc1e9ba3227504207129ba3c43621346f28ceb5a43b	2026-11-21 21:13:57.497+00	2026-10-22 21:14:58.603+00	2026-10-22 21:13:57.498+00
2c3dad0c-08cf-4ea2-afab-9db700d25c66	5c926164-c0cd-49e5-a1c0-851b475449b0	17204211beff7e3edc79169715a459dc17ab23741a20746cbc6fc0f2c0356650	2026-11-21 21:14:58.631+00	2026-10-22 21:19:55.87+00	2026-10-22 21:14:58.632+00
2607576d-7f43-4fca-a4e7-e8ee53ac3ef7	5c926164-c0cd-49e5-a1c0-851b475449b0	ac1d100518ad8f118d76a5a83d9a768551c83bddeeb962e76cadaa5912f752d3	2026-11-21 21:19:55.879+00	2026-10-22 21:19:59.409+00	2026-10-22 21:19:55.88+00
a151126d-a337-484a-bc52-3be42f36039d	5c926164-c0cd-49e5-a1c0-851b475449b0	b43f9da5906ed90b476cdb5d9d113babc1d62cf4464ca16d5c5ef27fc553a485	2026-11-21 21:19:59.431+00	2026-10-22 21:20:17.544+00	2026-10-22 21:19:59.434+00
74ca95c7-ab34-453c-8598-b9bd8e339173	5c926164-c0cd-49e5-a1c0-851b475449b0	2e943eb34d81ab4949ec719574dadefac252b84e4f9e6143ce73e220b542c454	2026-11-21 21:20:17.555+00	2026-10-22 21:20:20.367+00	2026-10-22 21:20:17.555+00
0d43a76b-0b34-47a3-a27a-14153d89a08d	5c926164-c0cd-49e5-a1c0-851b475449b0	9aac696aeb0f996a362eccd90dfb5d3ac04e211cea32def55a57eb55d228ae18	2026-11-21 21:20:20.387+00	2026-10-22 21:38:12.256+00	2026-10-22 21:20:20.389+00
883bb9e1-bf79-4892-8028-2b87c0fdff6d	5c926164-c0cd-49e5-a1c0-851b475449b0	4fc25634d470c42fedce9240ecc09915d395fd502cdb80233bea3288731933a9	2026-11-21 21:38:12.278+00	2026-10-22 21:39:48.923+00	2026-10-22 21:38:12.28+00
dd4d4bc4-dc15-46d9-9f13-c7f4aef1cb48	5c926164-c0cd-49e5-a1c0-851b475449b0	32ad01e458635a1449fd8c0560295dc3bb144bc4b70236bf576f3ba065199e07	2026-11-21 21:39:48.932+00	2026-10-22 21:39:52.527+00	2026-10-22 21:39:48.934+00
30696efb-9ee6-4d93-83a9-aae8ccbac142	5c926164-c0cd-49e5-a1c0-851b475449b0	8801600c9dc1e4ce3cbfb6ed9bafa51c14ad8c35037164ba14e5458531e31698	2026-11-21 21:39:52.55+00	2026-10-22 21:58:14.493+00	2026-10-22 21:39:52.551+00
a7aafa41-1d6b-4dae-bae1-063b0bcacbb4	5c926164-c0cd-49e5-a1c0-851b475449b0	f7bff8e28c001f1b51d38dce7ee1a542ca9263fee5c92051ea5ad4cebbc03a53	2026-11-21 21:58:14.515+00	2026-10-22 21:58:20.317+00	2026-10-22 21:58:14.519+00
cf328db2-2cef-483e-bf29-db52c4298dc6	5c926164-c0cd-49e5-a1c0-851b475449b0	38b6d87a6344b203cdb835bf87a0810a2be23b0d37d22b83ffd7dcbcaa2df952	2026-11-21 21:58:20.343+00	2026-10-22 21:58:33.334+00	2026-10-22 21:58:20.344+00
df57b4f1-bdfa-41f3-a430-3582d506408d	5c926164-c0cd-49e5-a1c0-851b475449b0	8afea43e0c494c4f341fb075ddccb01eb82e7c69bfcfd3b7a739c458ba2296f8	2026-11-21 21:58:33.347+00	2026-10-22 21:58:39.509+00	2026-10-22 21:58:33.351+00
82f42fef-168b-4aa4-859f-387aedc17007	5c926164-c0cd-49e5-a1c0-851b475449b0	cb504f1eba0511c5b0e2b29aa366127ead8e8eb3e9d15ac3cf59f7959dd40091	2026-11-21 21:58:39.526+00	2026-10-22 21:58:49.022+00	2026-10-22 21:58:39.526+00
f0c95806-9b1b-41eb-b38a-5865af186934	5c926164-c0cd-49e5-a1c0-851b475449b0	e7187cce26687c30902394aa0b83f37a19ced6f0836c2f76779e61f377fc8498	2026-11-21 21:58:49.029+00	2026-10-22 21:58:55.646+00	2026-10-22 21:58:49.029+00
11873437-5a57-485e-a317-d11ab9cd8539	5c926164-c0cd-49e5-a1c0-851b475449b0	75504ab52b532ab5a0d4ea45e99b5a11c58df1389c029a306b660c19cb01b277	2026-11-21 21:58:55.658+00	2026-10-22 22:03:59.17+00	2026-10-22 21:58:55.658+00
5870972f-5946-41c6-be41-2620f5b9c65f	5c926164-c0cd-49e5-a1c0-851b475449b0	80969b1884ad916102afb5740c7b79540be7eb91469c45d04c11a43cc944c373	2026-11-21 22:03:59.194+00	2026-10-22 22:04:05.596+00	2026-10-22 22:03:59.199+00
649e2074-86cf-4fe7-b53d-dc1848ed2907	5c926164-c0cd-49e5-a1c0-851b475449b0	f52d295229ba41460e993d47d7951ef0c9a7bc4ad26bee6b597ebb71df8dee81	2026-11-21 22:04:05.621+00	2026-10-22 22:06:21.78+00	2026-10-22 22:04:05.622+00
59358e89-037b-4d0d-ab17-1f6829aa9112	5c926164-c0cd-49e5-a1c0-851b475449b0	20b0f41091a06c0843f30465f41cd660da913416b7afe62c539778f356ce6678	2026-11-21 22:06:21.796+00	2026-10-22 22:06:27.868+00	2026-10-22 22:06:21.797+00
9513269f-b2cb-4276-8f38-9c606612a6d1	5c926164-c0cd-49e5-a1c0-851b475449b0	57bd893887cb01848c8e5f575e92d6f3fe0e07111e7c9fc8f3ef6eea24409bad	2026-11-21 22:06:27.886+00	2026-10-22 22:09:53.292+00	2026-10-22 22:06:27.887+00
8700025c-3216-4a9f-bc84-03624d3444db	5c926164-c0cd-49e5-a1c0-851b475449b0	b103aaed36ecb9b0fc3e7319b5bc8df96fe4f804086ed1be583fce7a679d2992	2026-11-21 22:09:53.308+00	2026-10-22 22:10:00.476+00	2026-10-22 22:09:53.309+00
3635f10a-9504-4be0-a7d1-6ef1a766be8f	5c926164-c0cd-49e5-a1c0-851b475449b0	61401dba7ecad32c10f866536e18a3c9a61eb7c3c9bca5d61cc7c7128e9d0832	2026-11-21 22:10:00.489+00	2026-10-23 15:24:24.951+00	2026-10-22 22:10:00.491+00
de1121d1-d190-4450-9626-5261f0426f0e	5c926164-c0cd-49e5-a1c0-851b475449b0	81da69c1b3502c788d6f23eb2d7cbded0b68b091af08d1ed3af06ea871726e40	2026-11-22 15:24:25.042+00	2026-10-23 15:38:04.903+00	2026-10-23 15:24:25.052+00
67a58f4c-ae17-4c01-9ce7-6a4e9bb1588f	5c926164-c0cd-49e5-a1c0-851b475449b0	a0b677182ce6d657ac3475ac43f619b9eaa5e6fe9c3ef3725e78c2ef4a831dbb	2026-11-22 15:38:04.924+00	2026-10-23 15:38:09.555+00	2026-10-23 15:38:04.925+00
5b556404-ba00-46e2-9c83-5191b4fa1d15	5c926164-c0cd-49e5-a1c0-851b475449b0	b58413545ea50e416848d540d98cabae10ad1e2ec260bf481715d531f27c5b32	2026-11-22 15:38:09.569+00	2026-10-23 15:41:57.275+00	2026-10-23 15:38:09.571+00
b4c9027f-5c51-4e3e-9bec-5b60fc097a41	5c926164-c0cd-49e5-a1c0-851b475449b0	28718795153628b97207835663f0f5563cab8749c8c822d0b5773f9b735cf86a	2026-11-22 15:41:57.29+00	2026-10-23 15:42:00.721+00	2026-10-23 15:41:57.293+00
9165488c-12ff-4363-b401-c9363be05616	5c926164-c0cd-49e5-a1c0-851b475449b0	322a286585a1c4e3a69a4e4e7abfe6f506215d3de6419c955ee873e818cb034a	2026-11-22 15:42:00.73+00	2026-10-23 15:44:02.738+00	2026-10-23 15:42:00.731+00
42dd8245-437a-482d-9208-159f89de1baf	5c926164-c0cd-49e5-a1c0-851b475449b0	103870d3ab1adae908cefd67d5abe62d3151f117667bebf57074cb2c223124dc	2026-11-22 15:44:02.747+00	2026-10-23 15:44:08.159+00	2026-10-23 15:44:02.749+00
02084349-f972-4053-95d0-e6cec9136f27	5c926164-c0cd-49e5-a1c0-851b475449b0	e4c51cc5fa538e4935d46daba16f182141f1e2cbf901c33e463628955b25cf6e	2026-11-22 15:44:08.186+00	2026-10-23 16:01:11.338+00	2026-10-23 15:44:08.187+00
28e9e555-4671-4de7-84ad-9c4037653966	5c926164-c0cd-49e5-a1c0-851b475449b0	9d51dd0417b8b34c4f140ba309512dcba0082ef20862b7d0a80db429df8806d5	2026-11-22 16:01:11.358+00	2026-10-23 16:01:14.267+00	2026-10-23 16:01:11.359+00
4d9d1876-b55d-4a47-87f0-fc17960eae67	5c926164-c0cd-49e5-a1c0-851b475449b0	e6b029c24114f79ee682fa57b52db7637d6d70032d09118e5f2b33a0fc09bb74	2026-11-22 16:01:14.293+00	2026-10-23 16:02:02.626+00	2026-10-23 16:01:14.295+00
b304f47c-1f3a-41b6-a706-ff658025c216	5c926164-c0cd-49e5-a1c0-851b475449b0	e64a404ffb7b47b62337f959a8b95a18700bdf387c7fe0af7fddfccc219c7976	2026-11-22 16:02:02.648+00	2026-10-23 16:05:23.047+00	2026-10-23 16:02:02.648+00
bd40cbf6-be62-4ca1-86c0-38f56cd28cde	5c926164-c0cd-49e5-a1c0-851b475449b0	4435a0ac99b0973637f59e12a4e8f88f14ec89ff3cb9d07fa759fe6682e0c37a	2026-11-22 16:05:23.066+00	2026-10-23 16:25:04.776+00	2026-10-23 16:05:23.067+00
99a91095-10b4-4efa-9c84-5ffa4140df73	5c926164-c0cd-49e5-a1c0-851b475449b0	39ced21726eaac1cdce8fdf6fb172b1684fb744d49801f98e4fbd9f417a5607a	2026-11-22 16:25:04.792+00	2026-10-23 16:44:18.976+00	2026-10-23 16:25:04.792+00
58a48942-82c8-46bb-99b2-89bbedbcb8b0	5c926164-c0cd-49e5-a1c0-851b475449b0	9746d748b2ebc940e61270208c386c3afb5c987aa63b0eba81e5f23de247fa5a	2026-11-22 16:44:18.99+00	2026-10-23 16:50:24.032+00	2026-10-23 16:44:18.991+00
6fb3e3b4-501a-4f90-a33e-945fc60969c3	5c926164-c0cd-49e5-a1c0-851b475449b0	e58a0a69fded2a86cb136eb92734026d9b5391aea012957740f64c66118c9786	2026-11-22 16:50:24.043+00	2026-10-25 06:29:39.805+00	2026-10-23 16:50:24.043+00
ec581105-27a4-4bb9-a8d7-f5d86f454fa1	5c926164-c0cd-49e5-a1c0-851b475449b0	83950173d007edd584b43f9a780ea0ebbf3d49afc7b38d37be0adccd82505ff2	2026-11-24 06:29:39.925+00	2026-10-25 08:39:41.324+00	2026-10-25 06:29:39.957+00
f7eea427-0116-4899-bcfe-09b593e940b4	5c926164-c0cd-49e5-a1c0-851b475449b0	4d125eade949a99b37c6e4c7e5eb5cedd2b54b59cf0d9e377a5beecd85643f09	2026-11-24 08:39:41.35+00	2026-10-25 08:40:08.264+00	2026-10-25 08:39:41.351+00
22775010-7575-44db-b67c-1af5168802a0	5c926164-c0cd-49e5-a1c0-851b475449b0	fe70e658e944fa3f422edb3d6eb2fc1dc34dd5712286377061aec0c0e95294eb	2026-11-24 08:40:08.274+00	2026-10-25 08:40:11.38+00	2026-10-25 08:40:08.277+00
bef868ae-9495-4b81-b47b-fcb61cc04118	5c926164-c0cd-49e5-a1c0-851b475449b0	7bda3ed41913ef71d465c875eec6018da561ee85c0b2b08d89b752b84375f631	2026-11-24 08:40:11.401+00	2026-10-25 09:10:45.417+00	2026-10-25 08:40:11.403+00
2518acf9-220b-4b59-babb-f62fa11c685e	5c926164-c0cd-49e5-a1c0-851b475449b0	18f5880c9aa904589f2a60042f1de05cefa7c8943be8abcdea6a7dd9a2238a26	2026-11-24 09:10:45.431+00	2026-10-25 09:50:25.254+00	2026-10-25 09:10:45.432+00
aa1209b5-882c-4bab-9875-387c25f6fd2f	5c926164-c0cd-49e5-a1c0-851b475449b0	1d4f4aadbd97667964a53c7bf0e5c322b505c21842ff209d2942574a444bafd9	2026-11-24 09:50:25.276+00	2026-10-25 12:55:45.098+00	2026-10-25 09:50:25.277+00
c0075682-30cc-4c35-a847-69d52bf5dbc1	5c926164-c0cd-49e5-a1c0-851b475449b0	ad5c1f17e49016d10c7dcf6f641df61d94adeddaa50dd401393d995a78158875	2026-11-24 12:55:45.115+00	2026-10-25 13:01:01.615+00	2026-10-25 12:55:45.117+00
b8fd3db5-c650-4c77-a469-f156e336895b	5c926164-c0cd-49e5-a1c0-851b475449b0	ccf54227e1b09c04ae57d50020efc62821b1fd3ce503946be123e733d92df97f	2026-11-24 13:01:01.629+00	2026-10-25 14:35:14.55+00	2026-10-25 13:01:01.631+00
0c2c16e8-9c36-4fef-aa72-3d221caa77b9	5c926164-c0cd-49e5-a1c0-851b475449b0	80a79ac36cdec25d57b2f147afc98182a2dd69958556cc922f68860550451fd1	2026-11-24 14:35:14.559+00	2026-10-25 14:35:17.633+00	2026-10-25 14:35:14.562+00
59add854-94ac-45ba-bde7-fd500220e726	5c926164-c0cd-49e5-a1c0-851b475449b0	616996ec7f745d24bf2b44479a2c6889ae3d9f0f808419f6805b7de128b356f6	2026-11-24 14:35:17.646+00	2026-10-25 16:34:57.177+00	2026-10-25 14:35:17.648+00
47c66ab8-43a1-4efa-8afb-6938584761ff	5c926164-c0cd-49e5-a1c0-851b475449b0	ddf2f5dd020ef013bbf7d20d55bcf87123b00bdb8df6a44845ebcb8ed7a2083f	2026-11-24 16:34:57.233+00	\N	2026-10-25 16:34:57.237+00
d76c1bdc-e65f-400d-b821-f9bbca8c3322	14a4c16a-5de5-46b7-892b-ddb8e93034c1	0239e170fa5f4b2227297c45aa158772f6840e135dabcf15f9a2aa147338e3b4	2026-11-24 16:42:25.994+00	2026-10-25 16:42:52.299+00	2026-10-25 16:42:25.995+00
ced22f61-99b9-464f-86b4-152249ccca95	14a4c16a-5de5-46b7-892b-ddb8e93034c1	c99596c7164cae704e47c98a34f96b133102c279e17b433f1b9ae9d7a56d6dc3	2026-11-24 16:42:52.304+00	\N	2026-10-25 16:42:52.305+00
\.


--
-- Data for Name: report_cards; Type: TABLE DATA; Schema: public; Owner: school_user
--

COPY public.report_cards (id, student_id, class_id, term, academic_year, pdf_url, is_published, published_at, generated_at, created_at, attendance_days_absent, attendance_days_present, attendance_percentage, average_score, class_position, class_teacher_remark, next_term_begins, principal_remark, total_score, total_students_in_class) FROM stdin;
\.


--
-- Data for Name: schools; Type: TABLE DATA; Schema: public; Owner: school_user
--

COPY public.schools (id, name, address, logo_url, school_code, subscription_tier, currency, is_active, created_at, updated_at, deleted_at) FROM stdin;
55473dfa-dd2b-41e5-b85e-8da87261fa12	Whyte code tech	SUITE A06-A07 GOSTU PLAZA FIRST AVENUE GWARINPA ABUJA BESIDE OANDO FUEL STATION BESIDE iFITNESS CENTER	\N	WHY100	free	NGN	t	2026-10-21 12:30:00.882+00	2026-10-21 12:30:00.882+00	\N
9c2566ca-8f8a-4c9f-86fe-8e89181b5c60	WhyteCode Academy	12 Aba Road, Port Harcourt, Rivers State	https://res.cloudinary.com/demo/logo.png	GFA010	free	NGN	t	2026-10-22 05:26:59.61+00	2026-10-22 05:26:59.61+00	\N
\.


--
-- Data for Name: scores; Type: TABLE DATA; Schema: public; Owner: school_user
--

COPY public.scores (id, assessment_id, student_id, score, graded_by, graded_at) FROM stdin;
d5a8e132-af4e-49d5-a3ce-64c0f2edd20d	3b5b840d-ed4a-44dc-a634-8db1724cf1f1	76de287c-5dde-4928-9334-624cf116ce77	98	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 15:41:45.774+00
f3a06dff-1786-48e6-a3fb-b8d04210d19c	3b5b840d-ed4a-44dc-a634-8db1724cf1f1	d8b48673-7ee0-4888-966b-2d51f6fd21ea	76	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 15:41:45.775+00
8b30bd82-9911-40b7-a551-b82f01b37248	3b5b840d-ed4a-44dc-a634-8db1724cf1f1	9d730237-4270-4a1f-9ee4-c2f3f78255e8	43	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 15:41:45.775+00
b92d18ef-8841-44c7-afd6-bc4e2f567c4e	3b5b840d-ed4a-44dc-a634-8db1724cf1f1	597a8662-2058-461d-ae43-2c0efa9fbc75	45	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 15:41:45.775+00
d647f8ba-b2ac-4773-bc93-93c6f707b37c	3b5b840d-ed4a-44dc-a634-8db1724cf1f1	c7aa1a5d-1cdb-4647-a692-d4d8607662c1	86	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 15:41:45.775+00
23279c21-b389-4f03-ab0b-5fcd779d030c	3b5b840d-ed4a-44dc-a634-8db1724cf1f1	6358fc6e-0d94-4cfd-bbf5-8a6071180e95	99	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 15:41:45.775+00
bd558cf5-76a6-4290-a957-f5b94f725742	3b5b840d-ed4a-44dc-a634-8db1724cf1f1	703ebe18-2305-4066-ac76-00bd7b33ec2d	87	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 15:41:45.775+00
b0299fb5-b3db-4835-b543-7fbd5d4a1ef3	3b5b840d-ed4a-44dc-a634-8db1724cf1f1	0244350c-e7c2-458c-b84a-de3f7a88b696	64	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 15:41:45.775+00
2e3dafbc-e818-468f-ae59-a6980e76fec3	3b5b840d-ed4a-44dc-a634-8db1724cf1f1	527716c1-7f99-408f-ae99-27b29fe07e71	44	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 15:41:45.775+00
998db754-103f-4d4b-8d5b-43fe5b2c29a8	3b5b840d-ed4a-44dc-a634-8db1724cf1f1	e72d4c36-103f-4382-a03e-fe6597d005e4	70	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 15:41:45.776+00
50e5e9e5-baf7-468a-a46d-ae3c72441ffd	5787c948-3555-4024-b6f9-6eab3a7fffa3	76de287c-5dde-4928-9334-624cf116ce77	60	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 15:44:46.392+00
5cddc09b-06c4-45a7-802d-0c4d6c7f5903	5787c948-3555-4024-b6f9-6eab3a7fffa3	d8b48673-7ee0-4888-966b-2d51f6fd21ea	79	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 15:44:46.392+00
8c2ce069-bae8-46d9-a2fe-2015e339c18d	5787c948-3555-4024-b6f9-6eab3a7fffa3	9d730237-4270-4a1f-9ee4-c2f3f78255e8	87	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 15:44:46.392+00
78cd71fa-273b-4271-ba7c-d88a0c4d5964	5787c948-3555-4024-b6f9-6eab3a7fffa3	597a8662-2058-461d-ae43-2c0efa9fbc75	68	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 15:44:46.393+00
7d24dca5-fca5-44b3-9b99-049bcf9cab28	5787c948-3555-4024-b6f9-6eab3a7fffa3	c7aa1a5d-1cdb-4647-a692-d4d8607662c1	100	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 15:44:46.393+00
c2e50593-6fba-4e62-8666-6a06d7ac2a6e	5787c948-3555-4024-b6f9-6eab3a7fffa3	6358fc6e-0d94-4cfd-bbf5-8a6071180e95	98	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 15:44:46.393+00
aa0d7895-66c4-4880-848e-7a3a68d0b92e	5787c948-3555-4024-b6f9-6eab3a7fffa3	703ebe18-2305-4066-ac76-00bd7b33ec2d	87	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 15:44:46.393+00
e419dce4-0450-42ec-8dbc-6f6df4448ff0	5787c948-3555-4024-b6f9-6eab3a7fffa3	0244350c-e7c2-458c-b84a-de3f7a88b696	76	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 15:44:46.393+00
bdd302ab-0a26-4d69-808f-b24eee81f68e	5787c948-3555-4024-b6f9-6eab3a7fffa3	527716c1-7f99-408f-ae99-27b29fe07e71	72	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 15:44:46.393+00
fd48a895-b683-48d6-a145-7087305bfac5	5787c948-3555-4024-b6f9-6eab3a7fffa3	e72d4c36-103f-4382-a03e-fe6597d005e4	98	5c926164-c0cd-49e5-a1c0-851b475449b0	2026-10-23 15:44:46.393+00
\.


--
-- Data for Name: staff; Type: TABLE DATA; Schema: public; Owner: school_user
--

COPY public.staff (id, user_id, school_id, full_name, role_title, subject_specialty, photo_url, is_active, created_at, updated_at) FROM stdin;
d6974752-6a58-4a5f-a137-58e640de8166	5c926164-c0cd-49e5-a1c0-851b475449b0	55473dfa-dd2b-41e5-b85e-8da87261fa12	Kal Whyte	Administrator	\N	\N	t	2026-10-21 12:30:00.962+00	2026-10-21 12:30:00.962+00
eb404c46-6936-4437-83f1-32ad565a36c0	0a286dce-6248-4e54-a6a9-adf58d6c6f79	55473dfa-dd2b-41e5-b85e-8da87261fa12	Adewale Olatunji	Subject Teacher	Basic Science	\N	t	2026-10-22 18:24:39.645+00	2026-10-25 09:54:15.961+00
a35968e8-3ab5-4fff-ac84-570ea053e417	a34c317f-5232-41a1-95b8-d762d3a0ec8e	9c2566ca-8f8a-4c9f-86fe-8e89181b5c60	Kal Whyte	Principal	Mathematics	\N	t	2026-10-22 05:26:59.671+00	2026-10-22 10:54:38.973+00
48d94fb7-bc1a-4c6e-b1e3-535ffdf2a291	14a4c16a-5de5-46b7-892b-ddb8e93034c1	55473dfa-dd2b-41e5-b85e-8da87261fa12	Johnny Nosike	Class Teacher	Mathematics	\N	t	2026-10-22 14:15:59.658+00	2026-10-22 14:15:59.658+00
2cfe0d5c-b1bf-449a-946f-c8e240102489	b38ff10a-1f66-4e28-8b0e-56d6f8a2ef62	9c2566ca-8f8a-4c9f-86fe-8e89181b5c60	Ngozi Adeyemi	Class Teacher	Mathematics	https://res.cloudinary.com/demo/photo.jpg	t	2026-10-22 11:09:04.76+00	2026-10-22 14:31:26.825+00
26b22979-e43d-43ff-85d7-27bcb4ac08af	ab334393-b63e-433c-b9b4-c9a217fbfb94	55473dfa-dd2b-41e5-b85e-8da87261fa12	Ngozi Joy Okoroafor	Vice Principal	English	\N	t	2026-10-22 14:18:29.706+00	2026-10-22 17:06:51.408+00
623d1d91-0f9d-4507-ac8d-cb54d6fb5126	3955e864-ea70-434d-9097-de8f3918345b	55473dfa-dd2b-41e5-b85e-8da87261fa12	Promise Chidozie Onwuliri	Class Teacher	English	\N	t	2026-10-22 17:08:11.468+00	2026-10-22 17:08:11.468+00
88736099-1499-4a35-a9f8-7de880474815	cdc55efc-9318-46e8-be97-59fd660234be	55473dfa-dd2b-41e5-b85e-8da87261fa12	Ejiofor Emmanuel	Subject Teacher	Physics	\N	t	2026-10-22 17:17:50.026+00	2026-10-22 17:18:10.925+00
703fdb8b-c913-4f2d-9d27-07ffa9c4e7b0	cb7dca24-ec02-4d4a-8964-a8ceabe5df2c	55473dfa-dd2b-41e5-b85e-8da87261fa12	Professor Whyte Walker	Principal	\N	\N	t	2026-10-22 18:21:12.742+00	2026-10-22 18:21:12.742+00
9635de27-665b-4fbe-b601-87294487852a	dee000f4-b543-4536-92d6-bcc9fe85e777	55473dfa-dd2b-41e5-b85e-8da87261fa12	Sola Okorie	Class Teacher	\N	\N	t	2026-10-22 18:21:13.354+00	2026-10-22 18:21:13.354+00
e7c17cd2-4f92-4a16-80c1-8dffb60c653c	fbb06551-4071-449c-8c96-75e861869c2f	55473dfa-dd2b-41e5-b85e-8da87261fa12	Bisi Chukwu	Class Teacher	\N	\N	t	2026-10-22 18:21:13.37+00	2026-10-22 18:21:13.37+00
05b8d208-481c-4a2a-abb6-9365a8b2f6c3	6dbbff6e-49ee-46d5-ae81-b554a2ffa021	55473dfa-dd2b-41e5-b85e-8da87261fa12	Dayo Onyekachi	Class Teacher	\N	\N	t	2026-10-22 18:21:13.379+00	2026-10-22 18:21:13.379+00
1f0a3cef-60b7-4928-8c02-c9ab7d58aa7d	741733f7-5021-4079-be60-e8bb47d22858	55473dfa-dd2b-41e5-b85e-8da87261fa12	Nkechi Afolabi	Class Teacher	\N	\N	t	2026-10-22 18:21:13.386+00	2026-10-22 18:21:13.386+00
c6032717-7bc7-4920-b2a2-34ff91f65b64	e4b19ccb-383e-4e83-a992-e0ca69bb131f	55473dfa-dd2b-41e5-b85e-8da87261fa12	Nnamdi Mbah	Class Teacher	\N	\N	t	2026-10-22 18:21:13.395+00	2026-10-22 18:21:13.395+00
8a18957d-514e-49f5-a582-c52ad279b521	565a5cbf-9870-4023-86a0-8da0090e3561	55473dfa-dd2b-41e5-b85e-8da87261fa12	Seun Fashola	Class Teacher	\N	\N	t	2026-10-22 18:21:13.402+00	2026-10-22 18:21:13.402+00
ff59dc58-8813-40c4-86c8-cdac9d9d9954	17300738-7572-482e-82aa-2495bd41e648	55473dfa-dd2b-41e5-b85e-8da87261fa12	Ike Fashola	Class Teacher	\N	\N	t	2026-10-22 18:21:13.411+00	2026-10-22 18:21:13.411+00
018216f8-497b-4224-ab77-d13267ea40fd	6f094c04-7d39-4258-93e1-76137a436f2d	55473dfa-dd2b-41e5-b85e-8da87261fa12	Kemi Abiodun	Class Teacher	\N	\N	t	2026-10-22 18:21:13.417+00	2026-10-22 18:21:13.417+00
4ef4b3a7-b7d2-4e85-ad38-89a80a020302	844c7dbc-cd40-4a18-b241-86a4b3677b31	55473dfa-dd2b-41e5-b85e-8da87261fa12	Temi Adesanya	Class Teacher	\N	\N	t	2026-10-22 18:21:13.426+00	2026-10-22 18:21:13.426+00
11387f8c-4712-49a6-99bf-144e9b285e30	5e6837f8-db46-4b68-add2-833757b2d739	55473dfa-dd2b-41e5-b85e-8da87261fa12	Kola Okafor	Class Teacher	\N	\N	t	2026-10-22 18:21:13.433+00	2026-10-22 18:21:13.433+00
4cf0fe1b-7177-4ad3-a84f-b504af793c0c	10a6a239-9543-40a8-b087-3da5b9d37653	55473dfa-dd2b-41e5-b85e-8da87261fa12	Babatunde Adebayo	Class Teacher	\N	\N	t	2026-10-22 18:21:13.441+00	2026-10-22 18:21:13.441+00
110e719b-f7e1-4f54-b2d3-ffca5af7502b	e7ba8251-cacb-4475-b6ca-dd1a2cb33ecf	55473dfa-dd2b-41e5-b85e-8da87261fa12	Folake Abiodun	Class Teacher	\N	\N	t	2026-10-22 18:21:13.448+00	2026-10-22 18:21:13.448+00
efd3b34a-8123-46bd-b667-55f72d6c8fec	65a0cb8f-1488-4f19-8190-b6500ee8fdfa	55473dfa-dd2b-41e5-b85e-8da87261fa12	Rotimi Okorie	Class Teacher	\N	\N	t	2026-10-22 18:24:39.543+00	2026-10-22 18:24:39.543+00
07854791-ba8b-40f1-a736-e8a1aeb92e99	7c053256-f736-4196-83fd-f22f2ed779ae	55473dfa-dd2b-41e5-b85e-8da87261fa12	Taiwo Eze	Class Teacher	\N	\N	t	2026-10-22 18:24:39.562+00	2026-10-22 18:24:39.562+00
aa44e78c-9c08-4fbe-90d1-fc42710311c4	1214021f-048a-40fc-a2d0-9b004dfc63b6	55473dfa-dd2b-41e5-b85e-8da87261fa12	Dayo Nwachukwu	Class Teacher	\N	\N	t	2026-10-22 18:24:39.571+00	2026-10-22 18:24:39.571+00
b5c1e55c-7604-4412-8fda-c018b7052744	3966098a-becf-49ad-a80b-ab132e1f9b00	55473dfa-dd2b-41e5-b85e-8da87261fa12	Bisi Olatunji	Class Teacher	\N	\N	t	2026-10-22 18:24:39.58+00	2026-10-22 18:24:39.58+00
1c912992-2c6b-4b91-8bd6-27f1823b31cd	ad9cdf94-a3ef-4c49-8375-7f992b5fa3c5	55473dfa-dd2b-41e5-b85e-8da87261fa12	Femi Nwachukwu	Class Teacher	\N	\N	t	2026-10-22 18:24:39.59+00	2026-10-22 18:24:39.59+00
0deff77b-f13b-47c8-9e95-a5cdcce8130b	78c42769-de2e-4876-987e-d7d4b414918a	55473dfa-dd2b-41e5-b85e-8da87261fa12	Chiamaka Dike	Class Teacher	\N	\N	t	2026-10-22 18:24:39.6+00	2026-10-22 18:24:39.6+00
0f3d8137-c7ea-4d2b-b86f-8b258b8dcf2b	33c813aa-833b-433b-ac1c-d70ec8909c70	55473dfa-dd2b-41e5-b85e-8da87261fa12	Blessing Afolabi	Class Teacher	\N	\N	t	2026-10-22 18:24:39.61+00	2026-10-22 18:24:39.61+00
ca97d592-e9a7-498a-adfe-b794f72a5841	03f3f031-0e58-476e-a03d-393f15a2c6e0	55473dfa-dd2b-41e5-b85e-8da87261fa12	Folake Adebayo	Class Teacher	\N	\N	t	2026-10-22 18:24:39.619+00	2026-10-22 18:24:39.619+00
9e6576d5-0f28-4332-a796-b3b35c0a7cc8	f152b564-5b1e-48c5-943a-b1490f2508bb	55473dfa-dd2b-41e5-b85e-8da87261fa12	Kemi Okonkwo	Class Teacher	\N	\N	t	2026-10-22 18:24:39.628+00	2026-10-22 18:24:39.628+00
cf187dd4-10a9-4290-a094-3e1501500532	cc47794d-2985-49b6-8d55-80255ab42db8	55473dfa-dd2b-41e5-b85e-8da87261fa12	Temi Dike	Class Teacher	\N	\N	t	2026-10-22 18:24:39.637+00	2026-10-22 18:24:39.637+00
3c88d824-0a9c-4ab1-b670-63e07d753573	35a0f941-77a8-4739-90d9-ea2d34f1ae07	55473dfa-dd2b-41e5-b85e-8da87261fa12	Yetunde Mbah	Class Teacher	\N	\N	t	2026-10-22 18:24:39.655+00	2026-10-22 18:24:39.655+00
8ff0d0d4-7040-4207-94ce-b6aa0405b3ff	fe2d1530-d0bb-4b19-b6dc-bcdb24767441	55473dfa-dd2b-41e5-b85e-8da87261fa12	Femi Onyekachi	Class Teacher	\N	\N	t	2026-10-22 19:00:35.029+00	2026-10-22 19:00:35.029+00
537bd8ee-a149-45dd-a44d-5ade8aa386d4	4939bac3-b189-46d7-830b-a6525df07835	55473dfa-dd2b-41e5-b85e-8da87261fa12	Lara Ogundimu	Class Teacher	\N	\N	t	2026-10-22 19:00:35.048+00	2026-10-22 19:00:35.048+00
d69e452a-890c-4b55-a34f-3eb5fa67f3f6	27a2fae4-1893-467c-8647-a9348633f9bf	55473dfa-dd2b-41e5-b85e-8da87261fa12	Ngozi Okorie	Class Teacher	\N	\N	t	2026-10-22 19:00:35.058+00	2026-10-22 19:00:35.058+00
c7c30512-8bbb-4b6e-877e-1b4103a17bbd	27579cdd-3d18-48bf-b2df-949e93b3866f	55473dfa-dd2b-41e5-b85e-8da87261fa12	Kehinde Afolabi	Class Teacher	\N	\N	t	2026-10-22 19:00:35.067+00	2026-10-22 19:00:35.067+00
2278a7b9-a288-4e21-8207-94b80391e82a	64b07ad1-01c0-44a0-8413-de8dd0e56360	55473dfa-dd2b-41e5-b85e-8da87261fa12	Chidi Balogun	Class Teacher	\N	\N	t	2026-10-22 19:00:35.076+00	2026-10-22 19:00:35.076+00
cb4e8023-5ed2-48e9-a9f7-da5282241050	4fcf0f32-401d-4fc7-bf9f-99e758845448	55473dfa-dd2b-41e5-b85e-8da87261fa12	Seun Fashola	Class Teacher	\N	\N	t	2026-10-22 19:00:35.083+00	2026-10-22 19:00:35.083+00
ad9caaaa-d557-42cc-9a38-fedcc30c6a00	1eeef1e7-ee63-4acf-8019-d992404e9276	55473dfa-dd2b-41e5-b85e-8da87261fa12	Funke Mbah	Class Teacher	\N	\N	t	2026-10-22 19:00:35.092+00	2026-10-22 19:00:35.092+00
748ab699-5c99-4542-9a42-23617ee0341a	f5c4678e-f528-42e1-8ea3-37c2b81773f3	55473dfa-dd2b-41e5-b85e-8da87261fa12	Seun Nwosu	Class Teacher	\N	\N	t	2026-10-22 19:00:35.099+00	2026-10-22 19:00:35.099+00
47694af3-44f4-44fd-8535-6814b5d7b674	f7bd5e64-7722-4ba6-aee4-8f8043db61f6	55473dfa-dd2b-41e5-b85e-8da87261fa12	Dayo Afolabi	Class Teacher	\N	\N	t	2026-10-22 19:00:35.109+00	2026-10-22 19:00:35.109+00
9b167351-c1ea-4a4e-8780-c2b4a2a05ae0	29e633bf-f16b-4f98-9cb3-6fd2f5b4896e	55473dfa-dd2b-41e5-b85e-8da87261fa12	Ifeanyi Afolabi	Class Teacher	\N	\N	t	2026-10-22 19:00:35.116+00	2026-10-22 19:00:35.116+00
c8dba8bf-d946-45a3-a8e2-6759e9c2ec88	4cda0a07-802c-463e-a6c6-f8073f3affcf	55473dfa-dd2b-41e5-b85e-8da87261fa12	Dayo Obi	Class Teacher	\N	\N	t	2026-10-22 19:00:35.125+00	2026-10-22 19:00:35.125+00
f13e2c8c-50e4-4a44-8871-70471e7cbf0b	0ba0f2f7-5f68-41d3-9e27-1b852652900b	55473dfa-dd2b-41e5-b85e-8da87261fa12	Sola Ogundimu	Class Teacher	\N	\N	t	2026-10-22 19:00:35.132+00	2026-10-22 19:00:35.132+00
\.


--
-- Data for Name: student_fee_ledger; Type: TABLE DATA; Schema: public; Owner: school_user
--

COPY public.student_fee_ledger (id, student_id, school_id, term, academic_year, total_owed, total_paid, balance, last_updated) FROM stdin;
\.


--
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: school_user
--

COPY public.students (id, user_id, school_id, admission_number, full_name, dob, gender, class_id, guardian_name, photo_url, is_active, created_at, updated_at, deleted_at) FROM stdin;
bc376ebf-aca1-4037-90d1-c263182a6143	992e8547-9e7d-4586-9ce8-d2ccf1143fc1	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/8330	Kola Chukwu	\N	male	1110fe28-558c-485e-a5cd-2e1f879bee90	\N	\N	t	2026-10-22 18:21:13.772+00	2026-10-22 18:21:13.772+00	\N
9cde47f2-7050-4d40-926f-1172ea928193	11641544-c531-4373-816e-0c8da58df460	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/1482	Babatunde Adesanya	\N	male	1110fe28-558c-485e-a5cd-2e1f879bee90	\N	\N	t	2026-10-22 18:21:13.78+00	2026-10-22 18:21:13.78+00	\N
ab80616e-09ee-4c42-a1ab-1e01fb345950	95d4dfb1-42b6-4a58-a6a7-c08267433227	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/8147	Nnamdi Obi	\N	male	1110fe28-558c-485e-a5cd-2e1f879bee90	\N	\N	t	2026-10-22 18:21:13.789+00	2026-10-22 18:21:13.789+00	\N
089122a1-3166-4120-8046-fb3c41bd0356	fcd1ea4a-0f86-4b55-8c0c-e869fb942551	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/9919	Seun Adebayo	\N	male	1110fe28-558c-485e-a5cd-2e1f879bee90	\N	\N	t	2026-10-22 18:21:13.798+00	2026-10-22 18:21:13.798+00	\N
b81b9fdf-b33c-4d9a-a48f-13878cf6cd72	3ac2adb7-0885-4170-be24-24c913c4eba0	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/8421	Tobi Balogun	\N	male	1110fe28-558c-485e-a5cd-2e1f879bee90	\N	\N	t	2026-10-22 18:21:13.808+00	2026-10-22 18:21:13.808+00	\N
da4ae721-9f82-41d8-bd4a-f937015dea4f	31322301-0cab-4aa7-91e0-eadcea50953e	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/8959	Ngozi Obi	\N	female	fadaf65c-f7c1-4327-b8e6-c2c361db8176	\N	\N	t	2026-10-22 18:21:13.816+00	2026-10-22 18:21:13.816+00	\N
473836a4-a8e9-4220-8a45-32ffb61407b7	3c40cd84-a103-4df7-88ac-4b80f601fd8a	9c2566ca-8f8a-4c9f-86fe-8e89181b5c60	GFA010/2026/0002	Emeka Okafor	2008-04-15	male	09fa9324-a688-4dbd-b388-9a905d5b017b	Mrs. Ngozi Okoroafor	https://res.cloudinary.com/demo/photo.png	t	2026-10-22 08:27:32.166+00	2026-10-22 09:57:05.462+00	\N
8881dc25-0266-4a5a-a1e9-61aa180c4223	0abe5bbc-7e1b-4f5e-b7e2-9a1ff045bdf4	9c2566ca-8f8a-4c9f-86fe-8e89181b5c60	GFA010/2026/0001	Emeka Okafor	\N	male	ae782cfd-a7b3-4f1b-bf44-32f9d1afe2e1	Mrs. Ngozi Okoroafor	https://res.cloudinary.com/demo/photo.png	t	2026-10-22 06:14:02.052+00	2026-10-22 09:57:27.383+00	\N
95738447-114b-4bfa-8238-1e8ac5880bbb	68c71ec3-e433-4674-ae80-ad5fbe5cb00d	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/0001	Ejiofor Emmanuel	\N	male	afa8bb8f-12ea-480d-949b-ace41851d9c1	Amaka Ejiofor	https://res.cloudinary.com/demo/photo.png	t	2026-10-22 12:37:53.087+00	2026-10-22 12:38:40.249+00	\N
b3d8af7d-79f3-407d-906a-70f0da75e208	aad8e336-0f97-455b-a8a1-60d498b10660	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/1701	Nnamdi Okonkwo	\N	male	afa8bb8f-12ea-480d-949b-ace41851d9c1	\N	\N	t	2026-10-22 18:21:13.46+00	2026-10-22 18:21:13.46+00	\N
0d1127ea-8d25-4868-9ce5-63259ad922f1	77dde5e4-f6dc-4b0d-b9b7-86e04882a581	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/9758	Chiamaka Onyekachi	\N	female	afa8bb8f-12ea-480d-949b-ace41851d9c1	\N	\N	t	2026-10-22 18:21:13.488+00	2026-10-22 18:21:13.488+00	\N
37d2e835-20ad-4e81-9ffa-35ec3d208df1	ea5957d2-01c6-4310-bc83-a5fe5a0e3481	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/5508	Ifeanyi Chukwu	\N	male	afa8bb8f-12ea-480d-949b-ace41851d9c1	\N	\N	t	2026-10-22 18:21:13.499+00	2026-10-22 18:21:13.499+00	\N
545797d7-ec01-4d74-8e49-a0177e267726	49bad0ce-cfb7-4bc0-a935-ec1d52644a26	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/2469	Nkechi Dike	\N	female	afa8bb8f-12ea-480d-949b-ace41851d9c1	\N	\N	t	2026-10-22 18:21:13.508+00	2026-10-22 18:21:13.508+00	\N
e550f8ef-d6a2-4416-9f23-ab2c48f99abb	5c1c4845-34c6-4f1f-b09f-798289ffd7ed	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/7230	Sola Okorie	\N	male	afa8bb8f-12ea-480d-949b-ace41851d9c1	\N	\N	t	2026-10-22 18:21:13.517+00	2026-10-22 18:21:13.517+00	\N
27c0237f-3b36-4400-b290-886cdb230f9a	dea5f580-3891-4f93-b2a8-4600f18b5ce3	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/3390	Tolani Onyekachi	\N	female	8ecbb9ec-466d-4074-8a2b-7f851e3b2505	\N	\N	t	2026-10-22 18:21:13.526+00	2026-10-22 18:21:13.526+00	\N
607d8984-c66e-4d82-a8b9-2c3dc55850f1	f760443b-e6e1-4b46-9ce2-819518e79e01	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/9179	Seun Dike	\N	male	8ecbb9ec-466d-4074-8a2b-7f851e3b2505	\N	\N	t	2026-10-22 18:21:13.536+00	2026-10-22 18:21:13.536+00	\N
efac6ae9-7cee-45cf-a716-93fb9699dba6	88e1235b-525a-4de3-b736-59e2358e8c26	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/8007	Amaka Okonkwo	\N	female	8ecbb9ec-466d-4074-8a2b-7f851e3b2505	\N	\N	t	2026-10-22 18:21:13.545+00	2026-10-22 18:21:13.545+00	\N
ffd5acde-6f6f-4f13-ae34-38be8d30b47a	9cb65288-eba7-477b-959d-f17eaa2fe0ff	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/7694	Sola Mbah	\N	male	8ecbb9ec-466d-4074-8a2b-7f851e3b2505	\N	\N	t	2026-10-22 18:21:13.554+00	2026-10-22 18:21:13.554+00	\N
0115d7ae-ff97-46c6-a00e-22a2aeaf4bdd	3341819f-421b-46d0-9aa9-e41fa63d54d2	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/7036	Kola Onyekachi	\N	male	8ecbb9ec-466d-4074-8a2b-7f851e3b2505	\N	\N	t	2026-10-22 18:21:13.563+00	2026-10-22 18:21:13.563+00	\N
76de287c-5dde-4928-9334-624cf116ce77	3caee5ce-0b97-4a4e-960a-44d87ef53ad2	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/6784	Bisi Nwachukwu	\N	female	c1ac00b6-3080-41c6-b4af-19392f8ca82c	\N	\N	t	2026-10-22 18:21:13.572+00	2026-10-22 18:21:13.572+00	\N
0244350c-e7c2-458c-b84a-de3f7a88b696	3a3d8a38-a11f-4a65-a03c-761430d93324	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/5029	Tobi Adebayo	\N	male	c1ac00b6-3080-41c6-b4af-19392f8ca82c	\N	\N	t	2026-10-22 18:21:13.584+00	2026-10-22 18:21:13.584+00	\N
597a8662-2058-461d-ae43-2c0efa9fbc75	5ba3d71c-bf3b-490c-9dd6-9cc6a83c8ed2	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/8530	Ifeoma Adebayo	\N	female	c1ac00b6-3080-41c6-b4af-19392f8ca82c	\N	\N	t	2026-10-22 18:21:13.594+00	2026-10-22 18:21:13.594+00	\N
d8b48673-7ee0-4888-966b-2d51f6fd21ea	787b1b9f-3bae-4591-80e0-31ba2b33c27b	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/7246	Chidi Eze	\N	male	c1ac00b6-3080-41c6-b4af-19392f8ca82c	\N	\N	t	2026-10-22 18:21:13.605+00	2026-10-22 18:21:13.605+00	\N
527716c1-7f99-408f-ae99-27b29fe07e71	766f7bfc-d28b-4dbe-bdec-3abee8701081	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/2908	Tobi Ogundimu	\N	male	c1ac00b6-3080-41c6-b4af-19392f8ca82c	\N	\N	t	2026-10-22 18:21:13.613+00	2026-10-22 18:21:13.613+00	\N
5eb9a1b2-43d0-436f-8d7f-bc0196c18b01	5e286edf-3d92-459f-ab96-c6d3dd3f3f3a	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/7376	Babatunde Abiodun	\N	male	df59c19a-8732-42d0-9e7e-31e1334994f7	\N	\N	t	2026-10-22 18:21:13.623+00	2026-10-22 18:21:13.623+00	\N
e793e579-a470-4692-abb9-7268a0687449	119a2f59-d5d3-4f7d-8629-3cf27344776e	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/4786	Nnamdi Adeyemi	\N	male	df59c19a-8732-42d0-9e7e-31e1334994f7	\N	\N	t	2026-10-22 18:21:13.633+00	2026-10-22 18:21:13.633+00	\N
444c4cd2-986f-4c64-8291-fa03f9633bba	54cd13fa-fcd5-43d9-ad32-e763da261dd2	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/5166	Blessing Onyekachi	\N	female	df59c19a-8732-42d0-9e7e-31e1334994f7	\N	\N	t	2026-10-22 18:21:13.643+00	2026-10-22 18:21:13.643+00	\N
8c441c4b-7fee-4715-bfdb-4b0d8f9e1396	e3f1a85b-f319-45c9-b26e-ac058ddabb8a	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/7253	Kehinde Abiodun	\N	female	df59c19a-8732-42d0-9e7e-31e1334994f7	\N	\N	t	2026-10-22 18:21:13.653+00	2026-10-22 18:21:13.653+00	\N
6454b036-3fb7-4d19-a116-a8e0c117cf85	dcf6c2cf-439a-44da-b661-b9d6643dc4be	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/5985	Nkechi Obi	\N	female	df59c19a-8732-42d0-9e7e-31e1334994f7	\N	\N	t	2026-10-22 18:21:13.662+00	2026-10-22 18:21:13.662+00	\N
27b0fe78-2321-4233-848e-b4420fd9342d	4c52c41c-557c-45f9-8126-ffcb13f8ea4d	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/2923	Chidi Dike	\N	male	d1b0410c-caf9-4e20-a23c-8a1a3bff8d60	\N	\N	t	2026-10-22 18:21:13.671+00	2026-10-22 18:21:13.671+00	\N
94a5a018-dd12-4be7-a633-c1e65015e113	3d947874-6e7c-4c93-a4ae-2577bb4b1aa8	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/7977	Ike Nwosu	\N	male	d1b0410c-caf9-4e20-a23c-8a1a3bff8d60	\N	\N	t	2026-10-22 18:21:13.681+00	2026-10-22 18:21:13.681+00	\N
ed9605f1-5a3a-4cca-b3dc-fce06c3ff9b0	17328965-2214-4f67-bb82-10fb43f889d2	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/2414	Tobi Nwachukwu	\N	male	d1b0410c-caf9-4e20-a23c-8a1a3bff8d60	\N	\N	t	2026-10-22 18:21:13.691+00	2026-10-22 18:21:13.691+00	\N
9ea835f8-b7f7-4b34-9f6d-fff30e5d1dcf	5759fc0a-13f9-4746-b77c-b02e2d270bff	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/4322	Emeka Afolabi	\N	male	d1b0410c-caf9-4e20-a23c-8a1a3bff8d60	\N	\N	t	2026-10-22 18:21:13.7+00	2026-10-22 18:21:13.7+00	\N
51dba70c-b611-4b1e-9e2a-d380063645b2	883f13ed-07f6-468b-a102-ea14a3e72197	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/3032	Amaka Abiodun	\N	female	d1b0410c-caf9-4e20-a23c-8a1a3bff8d60	\N	\N	t	2026-10-22 18:21:13.709+00	2026-10-22 18:21:13.709+00	\N
8d9a10fd-c0bc-44da-9825-d19da6abb40f	241c59f2-1133-4b0c-9ebb-67993d4fdbad	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/9374	Chioma Okonkwo	\N	female	619802b8-ed2c-41cf-93e3-52a12dc6218a	\N	\N	t	2026-10-22 18:21:13.718+00	2026-10-22 18:21:13.718+00	\N
633b1a04-b4e8-4956-93ce-18b0e4ec5db3	d5db8f9c-7d19-4275-8de2-b37f699bb86d	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/4916	Kemi Nwosu	\N	female	619802b8-ed2c-41cf-93e3-52a12dc6218a	\N	\N	t	2026-10-22 18:21:13.73+00	2026-10-22 18:21:13.73+00	\N
84a29e6b-ed9d-41e8-a1db-8dd582eaf463	445b52e9-a455-433e-af3b-225c280bea0c	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/2727	Adeola Olatunji	\N	female	619802b8-ed2c-41cf-93e3-52a12dc6218a	\N	\N	t	2026-10-22 18:21:13.74+00	2026-10-22 18:21:13.74+00	\N
9dbae32d-a3c5-48db-bb8e-1ea82ca1d797	2d85533b-fd2c-4476-91f2-29c1be7f6d13	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/1127	Adewale Eze	\N	male	619802b8-ed2c-41cf-93e3-52a12dc6218a	\N	\N	t	2026-10-22 18:21:13.751+00	2026-10-22 18:21:13.751+00	\N
e9945b50-effa-4bf3-baa9-1d09105034d3	3307f59b-652a-41f0-8e0d-5f281395b31c	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/2812	Rotimi Okonkwo	\N	male	619802b8-ed2c-41cf-93e3-52a12dc6218a	\N	\N	t	2026-10-22 18:21:13.762+00	2026-10-22 18:21:13.762+00	\N
6e1f4b8f-b6b9-4985-aa92-00771833e46e	e618ca15-42dd-48cb-aedd-8ec6a8737587	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/3647	Chiamaka Okorie	\N	female	fadaf65c-f7c1-4327-b8e6-c2c361db8176	\N	\N	t	2026-10-22 18:21:13.825+00	2026-10-22 18:21:13.825+00	\N
6d80ca30-a7a5-4bd1-8c7e-27450984c219	c99c894b-e73b-4d1a-82a6-3eb4bdb4b391	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/7738	Tobi Fashola	\N	male	fadaf65c-f7c1-4327-b8e6-c2c361db8176	\N	\N	t	2026-10-22 18:21:13.834+00	2026-10-22 18:21:13.834+00	\N
c7fe56ba-4c5f-4e2e-b32c-4c00dcae6424	36f1c917-b7c8-41af-b882-e512721eb03a	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/9848	Folake Nwosu	\N	female	fadaf65c-f7c1-4327-b8e6-c2c361db8176	\N	\N	t	2026-10-22 18:21:13.843+00	2026-10-22 18:21:13.843+00	\N
523175cc-245a-4726-8b06-35ac0c1678ef	5ca78764-ef26-477c-a7b1-f8560bdd1b44	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/5608	Ike Adebayo	\N	male	fadaf65c-f7c1-4327-b8e6-c2c361db8176	\N	\N	t	2026-10-22 18:21:13.852+00	2026-10-22 18:21:13.852+00	\N
e50f57f8-0a71-41ad-8d3b-4613542a230e	c159bdfe-e005-4833-a081-0f17bdb14879	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/9794	Dayo Adeyemi	\N	male	8e1a5460-789f-4996-a702-f2d69b402906	\N	\N	t	2026-10-22 18:21:13.861+00	2026-10-22 18:21:13.861+00	\N
f1e4296c-30b1-42b3-b9c8-27e4ae5dd380	51b3e543-5fe6-4d6f-aeb2-f75f69a54edd	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/7554	Ngozi Okorie	\N	female	8e1a5460-789f-4996-a702-f2d69b402906	\N	\N	t	2026-10-22 18:21:13.871+00	2026-10-22 18:21:13.871+00	\N
4ed2dbd9-9482-4b25-98e3-dc3e7f510637	e4d68a56-3d09-4563-b4b5-dd836578bf61	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/4270	Kola Dike	\N	male	8e1a5460-789f-4996-a702-f2d69b402906	\N	\N	t	2026-10-22 18:21:13.88+00	2026-10-22 18:21:13.88+00	\N
3a664ee8-3d06-4ac8-b7e8-104f348c41c9	c1ba7623-6bf4-4914-980e-214accfb7b74	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/2673	Uche Fashola	\N	male	8e1a5460-789f-4996-a702-f2d69b402906	\N	\N	t	2026-10-22 18:21:13.889+00	2026-10-22 18:21:13.889+00	\N
c1f2866d-2a7b-4033-9c23-1db0df1a164d	c66d3451-7764-4bc8-9759-27e162065915	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/7774	Blessing Olatunji	\N	female	8e1a5460-789f-4996-a702-f2d69b402906	\N	\N	t	2026-10-22 18:21:13.898+00	2026-10-22 18:21:13.898+00	\N
61e8df6d-c5d1-4274-ade4-0ebc95158b7c	b68478d3-dee2-4ae7-b533-9278f8578d22	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/5747	Uche Mbah	\N	male	641cf9ab-d2e1-4d5c-9905-36b9d333a875	\N	\N	t	2026-10-22 18:21:13.907+00	2026-10-22 18:21:13.907+00	\N
13687753-7c3d-4402-bcc8-d64f737913ad	f4cdae26-054e-4d16-acdc-a7b8f4993658	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/6289	Kola Afolabi	\N	male	641cf9ab-d2e1-4d5c-9905-36b9d333a875	\N	\N	t	2026-10-22 18:21:13.915+00	2026-10-22 18:21:13.915+00	\N
509e5c4f-2c9b-4e68-a2ae-82b69d8dfccb	096c813d-c689-4c5f-abf0-4a951fccdb43	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/6735	Bisi Onyekachi	\N	female	641cf9ab-d2e1-4d5c-9905-36b9d333a875	\N	\N	t	2026-10-22 18:21:13.927+00	2026-10-22 18:21:13.927+00	\N
ed61cec4-30af-4cd3-9e7e-6646d503896f	c586e2f7-f349-4670-8078-c50a618566d1	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/1520	Blessing Abiodun	\N	female	641cf9ab-d2e1-4d5c-9905-36b9d333a875	\N	\N	t	2026-10-22 18:21:13.935+00	2026-10-22 18:21:13.935+00	\N
fcb217a6-c2cc-4414-9579-eb7e50a4215b	ebb8d272-46e0-44ff-bf29-d9255f4b150e	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/1746	Ngozi Abiodun	\N	female	641cf9ab-d2e1-4d5c-9905-36b9d333a875	\N	\N	t	2026-10-22 18:21:13.943+00	2026-10-22 18:21:13.943+00	\N
1c584944-dcb0-4957-be59-29457edfb668	7a2598b8-7485-4785-b105-97f9a236e327	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/3088	Taiwo Nwosu	\N	female	51a30184-8995-47bd-8bf8-79eed7049a0d	\N	\N	t	2026-10-22 18:21:13.951+00	2026-10-22 18:21:13.951+00	\N
360c897c-f6e3-42b2-930e-b07843b5eca6	098d35f4-5c42-47c5-8547-80c95b417d39	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/7404	Adaeze Balogun	\N	female	51a30184-8995-47bd-8bf8-79eed7049a0d	\N	\N	t	2026-10-22 18:21:13.96+00	2026-10-22 18:21:13.96+00	\N
2fa81157-a706-48d8-81ac-a3d3bc6d2de9	c37f7aa2-496d-4121-b22d-72e872826dbe	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/4399	Ifeanyi Mbah	\N	male	51a30184-8995-47bd-8bf8-79eed7049a0d	\N	\N	t	2026-10-22 18:21:13.968+00	2026-10-22 18:21:13.968+00	\N
3b4ec356-c0af-4476-8892-46a3e3804771	69d507e9-7d80-4da9-90fb-73938a151f72	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/4820	Ngozi Adeyemi	\N	female	51a30184-8995-47bd-8bf8-79eed7049a0d	\N	\N	t	2026-10-22 18:21:13.978+00	2026-10-22 18:21:13.978+00	\N
6d500d17-e4e9-4a7b-a30d-32df39200173	508f54b5-44b6-4fa4-8883-43d3084afeab	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/6333	Babatunde Okonkwo	\N	male	51a30184-8995-47bd-8bf8-79eed7049a0d	\N	\N	t	2026-10-22 18:21:13.986+00	2026-10-22 18:21:13.986+00	\N
0f7407c8-0a1a-44f4-9e69-6a5fac874d56	35dfe57e-64e3-4539-8b1d-f553abebc52a	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/6786	Kunle Mbah	\N	male	48a13b05-d5e3-4039-bd26-24dea4f9bde7	\N	\N	t	2026-10-22 18:21:13.995+00	2026-10-22 18:21:13.995+00	\N
5ed584ad-a964-4c41-800e-11173b29efed	1cda946b-b52c-4471-b7e0-31dfbde728de	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/6226	Gbenga Onyekachi	\N	male	48a13b05-d5e3-4039-bd26-24dea4f9bde7	\N	\N	t	2026-10-22 18:21:14.004+00	2026-10-22 18:21:14.004+00	\N
15731351-7f9d-40ff-8d62-189cd21ce53b	d9bf19ca-230d-4c13-a144-9c1b00c52709	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/8835	Yetunde Nwosu	\N	female	48a13b05-d5e3-4039-bd26-24dea4f9bde7	\N	\N	t	2026-10-22 18:21:14.013+00	2026-10-22 18:21:14.013+00	\N
08c8f58b-96f8-4744-8130-a9c405d455e1	bef7a879-8956-45cd-a04a-130a6b87cbc7	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/3281	Ifeoma Eze	\N	female	48a13b05-d5e3-4039-bd26-24dea4f9bde7	\N	\N	t	2026-10-22 18:21:14.021+00	2026-10-22 18:21:14.021+00	\N
1ecb9355-5c52-4e62-a420-84209ad57978	c91cbda9-63b3-46db-8bec-1629548fc6cb	55473dfa-dd2b-41e5-b85e-8da87261fa12	GFA/2026/8063	Chiamaka Nwosu	\N	female	48a13b05-d5e3-4039-bd26-24dea4f9bde7	\N	\N	t	2026-10-22 18:21:14.031+00	2026-10-22 18:21:14.031+00	\N
a0b9674c-b1aa-48d9-b947-bdb94f0744e1	3b873bbc-d322-467c-817f-926490ee4ec5	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/4024	Kehinde Okafor	\N	female	afa8bb8f-12ea-480d-949b-ace41851d9c1	\N	\N	t	2026-10-22 18:24:39.668+00	2026-10-22 18:24:39.668+00	\N
322cf32a-4a3d-4695-a4c7-df6f804b199b	ab5180b3-6247-40ce-abd5-9a626fc8392a	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/7591	Gbenga Okorie	\N	male	afa8bb8f-12ea-480d-949b-ace41851d9c1	\N	\N	t	2026-10-22 18:24:39.701+00	2026-10-22 18:24:39.701+00	\N
5bcba3b8-36d1-4cc3-9e30-73daf68a4bd3	dc4f1bfc-4afa-4881-81cc-8a621fd33812	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/3544	Nnamdi Balogun	\N	male	afa8bb8f-12ea-480d-949b-ace41851d9c1	\N	\N	t	2026-10-22 18:24:39.715+00	2026-10-22 18:24:39.715+00	\N
515b9585-847a-421b-8dad-9925fcd7dc7d	1fa895a8-680e-4259-93c4-3526cd5abfc5	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/7457	Femi Nwosu	\N	male	afa8bb8f-12ea-480d-949b-ace41851d9c1	\N	\N	t	2026-10-22 18:24:39.73+00	2026-10-22 18:24:39.73+00	\N
a235802e-195c-46a6-be96-bcbcc4dac04f	ee82baed-b7fc-4622-9628-500b70530151	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/5496	Tobi Nwachukwu	\N	male	afa8bb8f-12ea-480d-949b-ace41851d9c1	\N	\N	t	2026-10-22 18:24:39.741+00	2026-10-22 18:24:39.741+00	\N
0b273b90-2b52-4e8b-ade8-487fabf301d8	5175a3e7-f8b3-4810-be41-7089e2fe99c4	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/1100	Chioma Nwosu	\N	female	8ecbb9ec-466d-4074-8a2b-7f851e3b2505	\N	\N	t	2026-10-22 18:24:39.751+00	2026-10-22 18:24:39.751+00	\N
bad94c9b-004e-4e48-bbdc-7c446a1a3968	729f34ff-eaff-41d9-96b6-9c8106c550e1	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/7535	Kunle Balogun	\N	male	8ecbb9ec-466d-4074-8a2b-7f851e3b2505	\N	\N	t	2026-10-22 18:24:39.764+00	2026-10-22 18:24:39.764+00	\N
751e6e62-eb49-447f-844d-4e9677d649f7	6de493b1-36b2-4a0c-8c4b-73d252ead569	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/9043	Obinna Ogundimu	\N	male	8ecbb9ec-466d-4074-8a2b-7f851e3b2505	\N	\N	t	2026-10-22 18:24:39.776+00	2026-10-22 18:24:39.776+00	\N
a9390c24-3ed9-4938-a5c3-4f1e51cbdf87	1210beb7-7985-4607-a547-ef76a3c35fa8	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/7696	Nnamdi Ogundimu	\N	male	8ecbb9ec-466d-4074-8a2b-7f851e3b2505	\N	\N	t	2026-10-22 18:24:39.786+00	2026-10-22 18:24:39.786+00	\N
d43c16a1-b717-4386-9be1-afcc82aea84c	b39a7b59-65e3-4eef-a153-b19a59bcd9eb	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/9755	Dayo Okonkwo	\N	male	8ecbb9ec-466d-4074-8a2b-7f851e3b2505	\N	\N	t	2026-10-22 18:24:39.796+00	2026-10-22 18:24:39.796+00	\N
9d730237-4270-4a1f-9ee4-c2f3f78255e8	6dafc102-a345-42ec-9641-c13da641864f	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/4579	Emeka Onyekachi	\N	male	c1ac00b6-3080-41c6-b4af-19392f8ca82c	\N	\N	t	2026-10-22 18:24:39.805+00	2026-10-22 18:24:39.805+00	\N
703ebe18-2305-4066-ac76-00bd7b33ec2d	ee7718b0-6f2e-4a62-86a1-072faad97668	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/6455	Nnamdi Olatunji	\N	male	c1ac00b6-3080-41c6-b4af-19392f8ca82c	\N	\N	t	2026-10-22 18:24:39.818+00	2026-10-22 18:24:39.818+00	\N
e72d4c36-103f-4382-a03e-fe6597d005e4	83535c63-cf01-466e-b6f0-3ae62a8dd768	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/6900	Tolani Nwosu	\N	female	c1ac00b6-3080-41c6-b4af-19392f8ca82c	\N	\N	t	2026-10-22 18:24:39.828+00	2026-10-22 18:24:39.828+00	\N
c7aa1a5d-1cdb-4647-a692-d4d8607662c1	8d7edd1e-a372-4089-9084-38b28b0c97d4	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/9181	Kemi Eze	\N	female	c1ac00b6-3080-41c6-b4af-19392f8ca82c	\N	\N	t	2026-10-22 18:24:39.837+00	2026-10-22 18:24:39.837+00	\N
6358fc6e-0d94-4cfd-bbf5-8a6071180e95	6f544747-2c1b-4d6c-931b-38fca3eb8ea9	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/9733	Kunle Afolabi	\N	male	c1ac00b6-3080-41c6-b4af-19392f8ca82c	\N	\N	t	2026-10-22 18:24:39.847+00	2026-10-22 18:24:39.847+00	\N
91d18ab9-8157-4c68-bb6a-2e7ebc933f7d	87d28201-f52e-4a7e-8bcf-bb8a4eeee1e3	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/2814	Seun Eze	\N	male	df59c19a-8732-42d0-9e7e-31e1334994f7	\N	\N	t	2026-10-22 18:24:39.857+00	2026-10-22 18:24:39.857+00	\N
f2a6f2f4-7207-46f5-9a1f-0c350fc22980	b261fdfe-baa5-4f58-9a7e-8d19ae53d472	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/5408	Ngozi Nwosu	\N	female	df59c19a-8732-42d0-9e7e-31e1334994f7	\N	\N	t	2026-10-22 18:24:39.868+00	2026-10-22 18:24:39.868+00	\N
9e0f0cc6-4863-4004-a5c6-00ac449cd091	d4ad1bae-fcd6-49d1-b44c-bd111759d431	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/6318	Blessing Olatunji	\N	female	df59c19a-8732-42d0-9e7e-31e1334994f7	\N	\N	t	2026-10-22 18:24:39.877+00	2026-10-22 18:24:39.877+00	\N
ea42d6a2-8d01-4bbb-b002-90e73f52e32a	5b7b699f-a1eb-4b90-bf2e-c0902c5f65ca	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/6077	Chioma Afolabi	\N	female	df59c19a-8732-42d0-9e7e-31e1334994f7	\N	\N	t	2026-10-22 18:24:39.886+00	2026-10-22 18:24:39.886+00	\N
c24bb4b5-c13e-408b-9843-837c12eb3e07	1e33c060-076f-42bf-884e-288a14a71e65	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/6117	Ngozi Onyekachi	\N	female	df59c19a-8732-42d0-9e7e-31e1334994f7	\N	\N	t	2026-10-22 18:24:39.896+00	2026-10-22 18:24:39.896+00	\N
7026d6f0-27a1-402d-8ea6-66a49f872ecc	f4ec90d6-9f80-4bea-a8e0-846efaeae356	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/2321	Emeka Fashola	\N	male	d1b0410c-caf9-4e20-a23c-8a1a3bff8d60	\N	\N	t	2026-10-22 18:24:39.906+00	2026-10-22 18:24:39.906+00	\N
f3c89c02-b040-467f-b19f-8e87b3f02d72	046d5f41-8e19-4c37-a3a8-d555172439b4	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/4081	Ifeanyi Fashola	\N	male	d1b0410c-caf9-4e20-a23c-8a1a3bff8d60	\N	\N	t	2026-10-22 18:24:39.915+00	2026-10-22 18:24:39.915+00	\N
0ecbedeb-df5b-46c2-885e-0502d1ccae26	e4e95e69-ab65-4219-91de-bc70c52c9b53	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/6426	Kemi Onyekachi	\N	female	d1b0410c-caf9-4e20-a23c-8a1a3bff8d60	\N	\N	t	2026-10-22 18:24:39.923+00	2026-10-22 18:24:39.923+00	\N
966a6342-6593-4cd0-9c79-9e70c3953bee	27d4899b-40db-4710-9555-c4e3ce833bf9	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/9055	Sade Abiodun	\N	female	d1b0410c-caf9-4e20-a23c-8a1a3bff8d60	\N	\N	t	2026-10-22 18:24:39.932+00	2026-10-22 18:24:39.932+00	\N
edbfaf78-e4f4-4e35-9baa-c073f088cad4	514c0219-dcb3-4a67-9d0d-03e28e1c3155	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/8232	Chioma Okonkwo	\N	female	d1b0410c-caf9-4e20-a23c-8a1a3bff8d60	\N	\N	t	2026-10-22 18:24:39.942+00	2026-10-22 18:24:39.942+00	\N
80a634d3-ea5f-4b4d-b308-bdedb52e26b5	0808b295-f4e3-4076-9a19-70108116fabc	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/5855	Femi Adebayo	\N	male	619802b8-ed2c-41cf-93e3-52a12dc6218a	\N	\N	t	2026-10-22 18:24:39.951+00	2026-10-22 18:24:39.951+00	\N
743199b7-7a07-477b-9632-201c3d84c676	7ffe7056-658d-40ed-a017-3c2cd94c7005	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/6686	Sola Adesanya	\N	male	619802b8-ed2c-41cf-93e3-52a12dc6218a	\N	\N	t	2026-10-22 18:24:39.961+00	2026-10-22 18:24:39.961+00	\N
94363c6a-27a7-442d-b4c6-eba893da524f	65cdbd03-b690-4152-822e-e8ce2617d130	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/5248	Blessing Adebayo	\N	female	619802b8-ed2c-41cf-93e3-52a12dc6218a	\N	\N	t	2026-10-22 18:24:39.97+00	2026-10-22 18:24:39.97+00	\N
c562efdb-3794-435c-8deb-e9276a54b7a8	c8459b52-fac9-435c-a9f7-3994230df9d6	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/2304	Adewale Adebayo	\N	male	619802b8-ed2c-41cf-93e3-52a12dc6218a	\N	\N	t	2026-10-22 18:24:39.979+00	2026-10-22 18:24:39.979+00	\N
2730c092-97ae-438c-a390-b3ef8ff2c79e	924c628a-943e-43b5-8035-e3c778867798	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/2385	Taiwo Olatunji	\N	female	619802b8-ed2c-41cf-93e3-52a12dc6218a	\N	\N	t	2026-10-22 18:24:39.989+00	2026-10-22 18:24:39.989+00	\N
57629a2c-1f0c-4ee5-9d89-4669a88a6ae5	4bbdf05c-d1e8-4275-b820-3e6700e1be13	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/9957	Folake Chukwu	\N	female	1110fe28-558c-485e-a5cd-2e1f879bee90	\N	\N	t	2026-10-22 18:24:39.997+00	2026-10-22 18:24:39.997+00	\N
e8485d65-9e56-4235-867d-dce86808fc54	44ccc5f9-2573-4f14-9d46-3c6c8c823c26	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/8547	Gbenga Afolabi	\N	male	1110fe28-558c-485e-a5cd-2e1f879bee90	\N	\N	t	2026-10-22 18:24:40.007+00	2026-10-22 18:24:40.007+00	\N
32bd5ecb-1470-4fac-97cb-1ca8ae1cd60b	7c74ecee-861d-4108-a8dd-76c7da19b495	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/2419	Taiwo Adesanya	\N	female	1110fe28-558c-485e-a5cd-2e1f879bee90	\N	\N	t	2026-10-22 18:24:40.018+00	2026-10-22 18:24:40.018+00	\N
be034844-d496-41fb-8289-68d35cca723b	11dab51e-50d9-43e7-a01a-e7c911a49e07	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/5453	Femi Balogun	\N	male	1110fe28-558c-485e-a5cd-2e1f879bee90	\N	\N	t	2026-10-22 18:24:40.027+00	2026-10-22 18:24:40.027+00	\N
e254ecf5-cd09-4c7d-9ff6-1bae9158520f	3f3fb184-b778-495b-a2d5-eff69280c276	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/9162	Obinna Balogun	\N	male	1110fe28-558c-485e-a5cd-2e1f879bee90	\N	\N	t	2026-10-22 18:24:40.035+00	2026-10-22 18:24:40.035+00	\N
d5045f23-a317-4ecf-be08-5aab7c52a4b9	10ac4ba7-7180-48f2-bb9c-3b7316c829d4	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/8866	Funke Okonkwo	\N	female	fadaf65c-f7c1-4327-b8e6-c2c361db8176	\N	\N	t	2026-10-22 18:24:40.044+00	2026-10-22 18:24:40.044+00	\N
bf28e619-eded-40f5-9e2d-11b459763294	bb163cd9-f0bd-4590-9a64-8d096191f938	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/4492	Gbenga Onyekachi	\N	male	fadaf65c-f7c1-4327-b8e6-c2c361db8176	\N	\N	t	2026-10-22 18:24:40.053+00	2026-10-22 18:24:40.053+00	\N
7f801ce1-0843-49c6-a3fb-a1b61c474744	943b4382-975a-4328-a60d-ba7c538bfaf8	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/1983	Yetunde Nwachukwu	\N	female	fadaf65c-f7c1-4327-b8e6-c2c361db8176	\N	\N	t	2026-10-22 18:24:40.061+00	2026-10-22 18:24:40.061+00	\N
b76fe21d-285f-402f-830b-cbadcc5c7dd7	3fe1f1f6-dfe1-45f8-973a-646069b543f0	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/3741	Sade Adeyemi	\N	female	fadaf65c-f7c1-4327-b8e6-c2c361db8176	\N	\N	t	2026-10-22 18:24:40.071+00	2026-10-22 18:24:40.071+00	\N
ed69c76a-0f9b-41ef-82a1-414ee8685f13	e09c23b0-061a-436e-a25b-c97230325eaf	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/5629	Nkechi Mbah	\N	female	fadaf65c-f7c1-4327-b8e6-c2c361db8176	\N	\N	t	2026-10-22 18:24:40.08+00	2026-10-22 18:24:40.08+00	\N
22cb0dc4-cccf-4035-90d8-7d20dd252901	170e8a11-6347-4a98-ae35-c8d6aaa07b09	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/6898	Funke Okonkwo	\N	female	8e1a5460-789f-4996-a702-f2d69b402906	\N	\N	t	2026-10-22 18:24:40.089+00	2026-10-22 18:24:40.089+00	\N
9a5db877-fc4a-46f4-934e-00260c929919	4c2c010d-0f31-4ffc-befd-210adfa048b5	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/6315	Jide Nwachukwu	\N	male	8e1a5460-789f-4996-a702-f2d69b402906	\N	\N	t	2026-10-22 18:24:40.1+00	2026-10-22 18:24:40.1+00	\N
79972a56-dfcd-4663-b64b-16610b7d85ae	ae5cd631-5635-4fb4-b726-e1e7f7d8e74b	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/9903	Folake Fashola	\N	female	8e1a5460-789f-4996-a702-f2d69b402906	\N	\N	t	2026-10-22 18:24:40.109+00	2026-10-22 18:24:40.109+00	\N
da94c1a3-3404-4173-b9f2-2767d869195a	b6787477-9e5a-4b79-8bc8-2f2a18d60d2f	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/3295	Bisi Nwachukwu	\N	female	8e1a5460-789f-4996-a702-f2d69b402906	\N	\N	t	2026-10-22 18:24:40.119+00	2026-10-22 18:24:40.119+00	\N
3be96f1e-d961-42e5-91e7-86eb998f76bd	796003b2-d82c-4e12-ba59-1fe4650e4567	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/1177	Femi Eze	\N	male	8e1a5460-789f-4996-a702-f2d69b402906	\N	\N	t	2026-10-22 18:24:40.128+00	2026-10-22 18:24:40.128+00	\N
01b180b3-5ffd-408c-b0e9-c203b313309a	a1b6ca71-d7ef-4648-ab38-b7c90505636a	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/1619	Obinna Adesanya	\N	male	641cf9ab-d2e1-4d5c-9905-36b9d333a875	\N	\N	t	2026-10-22 18:24:40.136+00	2026-10-22 18:24:40.136+00	\N
6008f810-ed53-4b3f-a0d0-5d975351f4e5	b4f62b39-d6eb-43f4-9992-bf9a2e88c3d6	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/6331	Sade Onyekachi	\N	female	641cf9ab-d2e1-4d5c-9905-36b9d333a875	\N	\N	t	2026-10-22 18:24:40.147+00	2026-10-22 18:24:40.147+00	\N
ce461b29-1b7f-4a37-b711-908aa19deaa5	41d9d507-1bde-4b16-98c8-d84535e117fd	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/9780	Kemi Chukwu	\N	female	641cf9ab-d2e1-4d5c-9905-36b9d333a875	\N	\N	t	2026-10-22 18:24:40.158+00	2026-10-22 18:24:40.158+00	\N
a3c86f1c-57c2-49a5-ba06-191b5bbb9bd0	803c4f49-5b15-4e59-8b43-81767c6252c0	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/5679	Ike Adesanya	\N	male	641cf9ab-d2e1-4d5c-9905-36b9d333a875	\N	\N	t	2026-10-22 18:24:40.168+00	2026-10-22 18:24:40.168+00	\N
4f4970a2-c969-4b3f-a292-a4b8cfd3efe3	a16b32a1-49c8-49fb-be26-bc78879f7479	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/3171	Temi Ogundimu	\N	female	641cf9ab-d2e1-4d5c-9905-36b9d333a875	\N	\N	t	2026-10-22 18:24:40.178+00	2026-10-22 18:24:40.178+00	\N
859667a9-e311-4490-b69f-b7653a667320	5d06fd22-088e-4206-bb54-c82de66844a1	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/6087	Gbenga Dike	\N	male	51a30184-8995-47bd-8bf8-79eed7049a0d	\N	\N	t	2026-10-22 18:24:40.187+00	2026-10-22 18:24:40.187+00	\N
4edaa322-5e9d-4605-9c08-16e862bfcef2	1e0116f0-47c4-48e5-9553-087338a0177a	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/8007	Gbenga Abiodun	\N	male	51a30184-8995-47bd-8bf8-79eed7049a0d	\N	\N	t	2026-10-22 18:24:40.199+00	2026-10-22 18:24:40.199+00	\N
3bb370c0-89b0-4a36-ba0e-fb10f413de26	757d3183-addb-43db-bf9a-b7e57a01d62c	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/8341	Yetunde Chukwu	\N	female	51a30184-8995-47bd-8bf8-79eed7049a0d	\N	\N	t	2026-10-22 18:24:40.208+00	2026-10-22 18:24:40.208+00	\N
a6397c80-f8e4-43ba-9d7d-d823f3511765	4dc1f692-f5f0-4e19-bafd-790edaf72efc	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/9532	Ike Okonkwo	\N	male	51a30184-8995-47bd-8bf8-79eed7049a0d	\N	\N	t	2026-10-22 18:24:40.22+00	2026-10-22 18:24:40.22+00	\N
40dd129a-af25-4ea6-bbb6-8a69d1e88c99	d341e9a4-4365-49b4-b1a3-898f45b8c569	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/8206	Ngozi Okorie	\N	female	51a30184-8995-47bd-8bf8-79eed7049a0d	\N	\N	t	2026-10-22 18:24:40.23+00	2026-10-22 18:24:40.23+00	\N
28e106e1-896a-44da-bdee-24a70efe3c96	c17ae35d-dd66-47ea-8e4e-a58545a2f0d5	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/1204	Chiamaka Adesanya	\N	female	48a13b05-d5e3-4039-bd26-24dea4f9bde7	\N	\N	t	2026-10-22 18:24:40.239+00	2026-10-22 18:24:40.239+00	\N
f0be106a-3baa-4f96-96c5-d8a4f15d3741	1fd891a8-26fd-4c48-8ad3-dd4242e1b4c0	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/3212	Bisi Chukwu	\N	female	48a13b05-d5e3-4039-bd26-24dea4f9bde7	\N	\N	t	2026-10-22 18:24:40.249+00	2026-10-22 18:24:40.249+00	\N
e3cc99ba-e75f-4c37-9ef8-016302063f3b	8e7c146f-05e6-47c2-bce9-edc8c9cf409c	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/3553	Ifeoma Okonkwo	\N	female	48a13b05-d5e3-4039-bd26-24dea4f9bde7	\N	\N	t	2026-10-22 18:24:40.257+00	2026-10-22 18:24:40.257+00	\N
90b6d714-1da5-43c1-bb8e-253f5bdbe9aa	8c4f8d74-7c46-4e3c-a589-ab734a6a5af5	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/6032	Kola Okorie	\N	male	48a13b05-d5e3-4039-bd26-24dea4f9bde7	\N	\N	t	2026-10-22 18:24:40.268+00	2026-10-22 18:24:40.268+00	\N
e15fce23-0f4c-4348-8c4e-c29e4a3a384f	7575905a-993f-4f33-ad0c-2c560a8b6c3e	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/7075	Bisi Mbah	\N	female	48a13b05-d5e3-4039-bd26-24dea4f9bde7	\N	\N	t	2026-10-22 18:24:40.276+00	2026-10-22 18:24:40.276+00	\N
9a60a493-84b1-4fd9-911f-01e4b9f23179	600e0d9f-c1d2-4929-b345-7895c21b69f6	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/8829	Gbenga Afolabi	\N	male	afa8bb8f-12ea-480d-949b-ace41851d9c1	\N	\N	t	2026-10-22 19:00:35.144+00	2026-10-22 19:00:35.144+00	\N
d6a71905-e404-4dde-8ff2-71a31e718842	a83cd36f-9f9c-489a-8d4b-acafc6c0c3f3	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/8463	Chiamaka Okonkwo	\N	female	afa8bb8f-12ea-480d-949b-ace41851d9c1	\N	\N	t	2026-10-22 19:00:35.172+00	2026-10-22 19:00:35.172+00	\N
6eff2334-1685-437e-917f-0e4d83f976c7	e6e468a5-6fa9-48be-952b-23dfad7ab312	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/9921	Kehinde Adeyemi	\N	female	afa8bb8f-12ea-480d-949b-ace41851d9c1	\N	\N	t	2026-10-22 19:00:35.188+00	2026-10-22 19:00:35.188+00	\N
62390e06-36a4-49f3-8066-658b3ad17e53	07ecb076-9745-47aa-8511-b88c92f0ff78	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/6387	Nkechi Okorie	\N	female	afa8bb8f-12ea-480d-949b-ace41851d9c1	\N	\N	t	2026-10-22 19:00:35.202+00	2026-10-22 19:00:35.202+00	\N
4074dadf-6ab8-483e-b36b-a80b0e614893	cf5c08c6-ddcf-418b-a425-25439dd68a95	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/2358	Sade Okafor	\N	female	afa8bb8f-12ea-480d-949b-ace41851d9c1	\N	\N	t	2026-10-22 19:00:35.22+00	2026-10-22 19:00:35.22+00	\N
2976633c-8afe-4163-a698-f2c580cd825f	e0d7749e-0c46-434f-bd66-1d72c543a3ff	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/4008	Bisi Ogundimu	\N	female	715217da-e2e4-45bc-a7d8-30e3c4fbb152	\N	\N	t	2026-10-22 19:00:35.231+00	2026-10-22 19:00:35.231+00	\N
210c3f3d-2414-4e9c-9859-5dd350a06508	be3dbb51-1c36-4c99-8f5b-7d5bf0814ad0	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/4253	Ifeanyi Eze	\N	male	715217da-e2e4-45bc-a7d8-30e3c4fbb152	\N	\N	t	2026-10-22 19:00:35.242+00	2026-10-22 19:00:35.242+00	\N
f2abe492-be63-4ad8-9da9-005808a39082	12d3be15-a634-4cf5-bcb7-86edbe52b781	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/7358	Ifeanyi Fashola	\N	male	715217da-e2e4-45bc-a7d8-30e3c4fbb152	\N	\N	t	2026-10-22 19:00:35.251+00	2026-10-22 19:00:35.251+00	\N
a2b862d5-4f7c-445c-bbf0-14775f6724ab	f1e9d640-6ef7-4287-b16a-6e6158594675	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/6177	Adaeze Adesanya	\N	female	715217da-e2e4-45bc-a7d8-30e3c4fbb152	\N	\N	t	2026-10-22 19:00:35.261+00	2026-10-22 19:00:35.261+00	\N
df05d1f5-c7c0-4730-86e7-4e939c61e846	968a4f9f-3c97-4f5f-bb69-d62d17e0b62f	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/5120	Dayo Okorie	\N	male	715217da-e2e4-45bc-a7d8-30e3c4fbb152	\N	\N	t	2026-10-22 19:00:35.269+00	2026-10-22 19:00:35.269+00	\N
47522dd8-0839-4b85-9ed4-7763b0fc3de9	2b0ec281-baca-40e8-8666-92caec27305e	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/6718	Sade Onyekachi	\N	female	306db6c9-cfbf-43f3-a90a-d3fae6a28e56	\N	\N	t	2026-10-22 19:00:35.278+00	2026-10-22 19:00:35.278+00	\N
e9431c72-19f4-4944-9495-9c7a4ffbb954	78160c7e-a545-4b25-8c64-5dfe6e697d57	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/3051	Lara Chukwu	\N	female	306db6c9-cfbf-43f3-a90a-d3fae6a28e56	\N	\N	t	2026-10-22 19:00:35.287+00	2026-10-22 19:00:35.287+00	\N
89bc033a-236d-4966-b90f-3bc87858506f	35b1ae1f-4f49-4a3b-9f9b-c1f6b3128343	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/4150	Uche Nwachukwu	\N	male	306db6c9-cfbf-43f3-a90a-d3fae6a28e56	\N	\N	t	2026-10-22 19:00:35.298+00	2026-10-22 19:00:35.298+00	\N
d87ffb79-4f02-4e0e-85f0-f083ae4ba026	98d4d62c-952b-4573-a160-4219a66665fe	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/8261	Chidi Ogundimu	\N	male	306db6c9-cfbf-43f3-a90a-d3fae6a28e56	\N	\N	t	2026-10-22 19:00:35.307+00	2026-10-22 19:00:35.307+00	\N
b7634f78-cec5-4a8f-9a83-e36fe7f3091b	68cb443a-baba-4f43-9026-73ec79c81ce0	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/4563	Yetunde Abiodun	\N	female	306db6c9-cfbf-43f3-a90a-d3fae6a28e56	\N	\N	t	2026-10-22 19:00:35.316+00	2026-10-22 19:00:35.316+00	\N
ce7a88f1-e4fb-4ba4-afda-543893324dd9	ee4ce6f0-9b9e-4126-93c0-d08205d8f5c9	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/1784	Folake Dike	\N	female	b674150e-ecf1-4406-a813-67dd02768555	\N	\N	t	2026-10-22 19:00:35.326+00	2026-10-22 19:00:35.326+00	\N
9b40a4b7-97ff-4ea4-aa39-5d98bea45410	16a9cc6c-c722-4064-9c24-74b7dd662a1d	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/9072	Ike Onyekachi	\N	male	b674150e-ecf1-4406-a813-67dd02768555	\N	\N	t	2026-10-22 19:00:35.335+00	2026-10-22 19:00:35.335+00	\N
0ab7c5a8-99bf-47b0-9aa9-e6d1e2743205	9e851bb4-bf5a-4984-8950-2af4c43c6c89	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/2854	Femi Adesanya	\N	male	b674150e-ecf1-4406-a813-67dd02768555	\N	\N	t	2026-10-22 19:00:35.345+00	2026-10-22 19:00:35.345+00	\N
e3f87aad-8b13-420f-9458-9b135138322a	f1bd1ced-78cc-45c2-b199-e56853650e07	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/1281	Obinna Okafor	\N	male	b674150e-ecf1-4406-a813-67dd02768555	\N	\N	t	2026-10-22 19:00:35.353+00	2026-10-22 19:00:35.353+00	\N
e2fa1e09-18c1-4953-a823-d98d10a3649a	21792720-d445-4048-80a3-93daa6b66e96	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/1277	Chidi Dike	\N	male	b674150e-ecf1-4406-a813-67dd02768555	\N	\N	t	2026-10-22 19:00:35.363+00	2026-10-22 19:00:35.363+00	\N
8764b6b0-7a20-4c47-a772-60533f761621	c308fc92-fed2-4512-83e1-5059a2c0bce3	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/4972	Kunle Adesanya	\N	male	0be7a4f6-1619-40a3-9f72-a7c262f0b863	\N	\N	t	2026-10-22 19:00:35.372+00	2026-10-22 19:00:35.372+00	\N
9e47e86d-7ce6-49ca-89db-1090dd814ce3	a7373ccb-a0cd-4e7f-80fc-1c85d91b7841	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/9203	Taiwo Adebayo	\N	female	0be7a4f6-1619-40a3-9f72-a7c262f0b863	\N	\N	t	2026-10-22 19:00:35.381+00	2026-10-22 19:00:35.381+00	\N
f46cd806-9d6c-4520-87f6-1a1b85a165a6	6003e883-600d-465a-96bf-6cd311c1650e	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/5144	Tunde Okorie	\N	male	0be7a4f6-1619-40a3-9f72-a7c262f0b863	\N	\N	t	2026-10-22 19:00:35.391+00	2026-10-22 19:00:35.391+00	\N
2a611d56-1b19-420e-a5ad-be81c19d3d92	9b8ec8a8-5e14-436b-a7e4-b219c7e71d44	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/2420	Ike Eze	\N	male	0be7a4f6-1619-40a3-9f72-a7c262f0b863	\N	\N	t	2026-10-22 19:00:35.4+00	2026-10-22 19:00:35.4+00	\N
0fe291b8-0ba7-43db-a904-84ed76a781ca	086f440f-10d6-4044-9012-237e99190513	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/3339	Tolani Nwosu	\N	female	0be7a4f6-1619-40a3-9f72-a7c262f0b863	\N	\N	t	2026-10-22 19:00:35.407+00	2026-10-22 19:00:35.407+00	\N
d610a498-f319-44f2-82bf-727c8c96b910	86e2ce1f-b661-4435-8bed-a6e09eba138a	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/6452	Amaka Nwachukwu	\N	female	801ac4fb-14ed-49a0-ac4c-4835ff28549f	\N	\N	t	2026-10-22 19:00:35.416+00	2026-10-22 19:00:35.416+00	\N
ed291d93-2c97-41b9-bc8e-d2617b3bf9e3	176584de-366b-4735-a2cb-fe0a2e141810	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/6545	Taiwo Mbah	\N	female	801ac4fb-14ed-49a0-ac4c-4835ff28549f	\N	\N	t	2026-10-22 19:00:35.426+00	2026-10-22 19:00:35.426+00	\N
a8461518-342a-46ca-a62e-6adafacf7baa	1942d9ea-332f-4caf-b995-72a8144ba3e2	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/4953	Sade Abiodun	\N	female	801ac4fb-14ed-49a0-ac4c-4835ff28549f	\N	\N	t	2026-10-22 19:00:35.435+00	2026-10-22 19:00:35.435+00	\N
335cd6c0-81df-4af9-9903-8d4c7c69e25f	e00ca26b-ac4f-485a-a91d-5ad311718d04	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/9568	Kemi Dike	\N	female	801ac4fb-14ed-49a0-ac4c-4835ff28549f	\N	\N	t	2026-10-22 19:00:35.444+00	2026-10-22 19:00:35.444+00	\N
fe4d2e1f-b581-441d-bace-f1c7ad78713a	acb703df-efe8-4ec8-a906-218820edcbf0	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/8441	Uche Okorie	\N	male	801ac4fb-14ed-49a0-ac4c-4835ff28549f	\N	\N	t	2026-10-22 19:00:35.453+00	2026-10-22 19:00:35.453+00	\N
2423d3f3-53e6-40ab-90cc-1cdc62d91d5a	4dda43ea-2e5c-4b7d-bcbe-0cfc3670035d	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/9940	Tolani Adesanya	\N	female	d08e9e53-f7bd-4d0e-80ad-b22f29d0daab	\N	\N	t	2026-10-22 19:00:35.464+00	2026-10-22 19:00:35.464+00	\N
e3fdfc37-0349-4519-b2e9-9eea8adf6300	ee42e381-1f68-467f-b212-864233c71ea8	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/6158	Bisi Fashola	\N	female	d08e9e53-f7bd-4d0e-80ad-b22f29d0daab	\N	\N	t	2026-10-22 19:00:35.477+00	2026-10-22 19:00:35.477+00	\N
8f84b489-1ac2-4c34-a015-2f544115600a	89d89c7b-75b7-44fe-a9d8-e994ea3ca405	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/9970	Adeola Nwosu	\N	female	d08e9e53-f7bd-4d0e-80ad-b22f29d0daab	\N	\N	t	2026-10-22 19:00:35.488+00	2026-10-22 19:00:35.488+00	\N
0f78055b-9eff-4fbb-bdbb-428a2ed6b159	6fc9eb2b-3b06-40e4-8b8b-07de79190d26	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/8403	Dayo Onyekachi	\N	male	d08e9e53-f7bd-4d0e-80ad-b22f29d0daab	\N	\N	t	2026-10-22 19:00:35.5+00	2026-10-22 19:00:35.5+00	\N
3e96b8b5-87bf-4fe1-a659-79931c3ab15d	23545366-b123-4601-a0f7-16bbb7f49fd1	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/8944	Blessing Dike	\N	female	d08e9e53-f7bd-4d0e-80ad-b22f29d0daab	\N	\N	t	2026-10-22 19:00:35.509+00	2026-10-22 19:00:35.509+00	\N
a89f9c2f-ab94-4ee9-b6ff-72995a338744	b8f4c056-b0d6-45de-aee7-b6aa6292b578	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/3962	Uche Afolabi	\N	male	d01fc901-3ad1-42b9-a782-8408060e4890	\N	\N	t	2026-10-22 19:00:35.518+00	2026-10-22 19:00:35.518+00	\N
0bcadfff-ef0d-4bca-b663-6fbdb063fe8e	ae46bc75-2ea3-41fe-bb36-ded6771b8890	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/6618	Gbenga Balogun	\N	male	d01fc901-3ad1-42b9-a782-8408060e4890	\N	\N	t	2026-10-22 19:00:35.532+00	2026-10-22 19:00:35.532+00	\N
e4606f92-2c72-4971-a41a-cb6de108fd8a	0079341e-58e2-4ecb-a546-795310743822	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/6189	Adewale Okonkwo	\N	male	d01fc901-3ad1-42b9-a782-8408060e4890	\N	\N	t	2026-10-22 19:00:35.541+00	2026-10-22 19:00:35.541+00	\N
037bc517-d21b-4ea4-8922-119e2e3027ed	61da38a3-b27f-4e51-aee2-a8646e822c57	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/3755	Amaka Nwachukwu	\N	female	d01fc901-3ad1-42b9-a782-8408060e4890	\N	\N	t	2026-10-22 19:00:35.55+00	2026-10-22 19:00:35.55+00	\N
63870548-2613-4542-b5db-e6a2e196bfa9	43671990-7340-4a84-9be9-9de076c112f8	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/4181	Obinna Ogundimu	\N	male	d01fc901-3ad1-42b9-a782-8408060e4890	\N	\N	t	2026-10-22 19:00:35.559+00	2026-10-22 19:00:35.559+00	\N
4a584da0-ef3b-4ebd-8420-77b4dd38615b	e1b46db1-6a65-493d-820f-457604775cd8	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/9478	Rotimi Eze	\N	male	7a748658-0722-462b-a6a5-c8d8e3916b5e	\N	\N	t	2026-10-22 19:00:35.572+00	2026-10-22 19:00:35.572+00	\N
a12c3526-77ae-4129-b51a-e647ef801052	2f7e1683-5edc-4494-9326-2ebd4def599c	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/8893	Ngozi Nwosu	\N	female	7a748658-0722-462b-a6a5-c8d8e3916b5e	\N	\N	t	2026-10-22 19:00:35.581+00	2026-10-22 19:00:35.581+00	\N
66d8885f-dcfd-4d2c-b646-cbec8cc3be0d	bbab68dc-c9f3-45b3-8717-9ee2a3e3fd22	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/4285	Chidi Okonkwo	\N	male	7a748658-0722-462b-a6a5-c8d8e3916b5e	\N	\N	t	2026-10-22 19:00:35.591+00	2026-10-22 19:00:35.591+00	\N
7a6d10d6-a836-4407-b3b2-350d006f3300	6f9eb978-e41a-4b48-98e4-9f3556a9134a	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/4104	Tunde Mbah	\N	male	7a748658-0722-462b-a6a5-c8d8e3916b5e	\N	\N	t	2026-10-22 19:00:35.601+00	2026-10-22 19:00:35.601+00	\N
6ed8f717-fd1b-4fd8-b832-30e86f7220dd	0d7bb570-bf0b-480b-b97a-45b37dcf6363	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/5494	Gbenga Nwosu	\N	male	7a748658-0722-462b-a6a5-c8d8e3916b5e	\N	\N	t	2026-10-22 19:00:35.61+00	2026-10-22 19:00:35.61+00	\N
83661cc8-996c-405a-b4e8-2cf5de3022b8	cff676c7-7dbd-48db-a6f6-6e0f7e21bdc6	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/6786	Folake Nwachukwu	\N	female	e3476888-76e0-4a42-bad8-3678c5e7f311	\N	\N	t	2026-10-22 19:00:35.621+00	2026-10-22 19:00:35.621+00	\N
64f65b30-cbc2-4fff-b408-f9c517fee3d0	5f513577-f6fa-463d-95c2-38db4be6d716	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/2707	Adeola Nwachukwu	\N	female	e3476888-76e0-4a42-bad8-3678c5e7f311	\N	\N	t	2026-10-22 19:00:35.632+00	2026-10-22 19:00:35.632+00	\N
b116a67c-4049-4e1a-938a-dd73c923cb01	f14cd1e4-b9f8-495a-be2b-859da6c4a6d7	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/7444	Chidi Onyekachi	\N	male	e3476888-76e0-4a42-bad8-3678c5e7f311	\N	\N	t	2026-10-22 19:00:35.642+00	2026-10-22 19:00:35.642+00	\N
fb85cd15-4cce-4844-99d4-efffa7c04aea	18119dff-c76c-454a-8b3f-d1c61e244318	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/3355	Yetunde Fashola	\N	female	e3476888-76e0-4a42-bad8-3678c5e7f311	\N	\N	t	2026-10-22 19:00:35.65+00	2026-10-22 19:00:35.65+00	\N
a99f9d58-468b-445b-9dbc-7373754bb09c	f150d1cd-f81d-4144-a9a2-dc056c644f3a	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/4453	Gbenga Adesanya	\N	male	e3476888-76e0-4a42-bad8-3678c5e7f311	\N	\N	t	2026-10-22 19:00:35.661+00	2026-10-22 19:00:35.661+00	\N
ec206e55-efa4-405c-b631-94987b6bbc2e	39d47941-3c02-44f2-9093-eb842fc66d12	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/7339	Gbenga Abiodun	\N	male	5252a0ab-36c6-4823-87ec-632a339c4dc0	\N	\N	t	2026-10-22 19:00:35.67+00	2026-10-22 19:00:35.67+00	\N
2d4aa346-1580-46ef-96e2-7e7e536334b6	6709dff1-4957-4053-abb0-2c558e7e591a	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/4650	Obinna Fashola	\N	male	5252a0ab-36c6-4823-87ec-632a339c4dc0	\N	\N	t	2026-10-22 19:00:35.679+00	2026-10-22 19:00:35.679+00	\N
d27f8a9e-1f2a-40fc-83e7-f2392f8d6052	799744f7-aff1-4d62-8e83-e590378f3879	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/1986	Femi Okonkwo	\N	male	5252a0ab-36c6-4823-87ec-632a339c4dc0	\N	\N	t	2026-10-22 19:00:35.689+00	2026-10-22 19:00:35.689+00	\N
48601f36-e5c5-44d2-91a5-3e7914fbf26d	669e57eb-5cbb-4cd5-9c29-20a3b2eecaa5	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/7827	Blessing Chukwu	\N	female	5252a0ab-36c6-4823-87ec-632a339c4dc0	\N	\N	t	2026-10-22 19:00:35.698+00	2026-10-22 19:00:35.698+00	\N
49c86f27-1113-4c53-a96e-486b7fe82bee	f2b328b5-e026-49c0-8d33-eb9f3d8404a0	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/6728	Folake Olatunji	\N	female	5252a0ab-36c6-4823-87ec-632a339c4dc0	\N	\N	t	2026-10-22 19:00:35.706+00	2026-10-22 19:00:35.706+00	\N
d4561be5-987e-4414-ac3d-9a6464e670e2	3cd18d61-0207-43de-8145-c99f61d2e0f7	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/4629	Adeola Balogun	\N	female	65961c57-bdba-4f4d-9956-791f065f8a43	\N	\N	t	2026-10-22 19:00:35.716+00	2026-10-22 19:00:35.716+00	\N
2da21d60-17af-4e41-a663-1895404202d0	90df74e7-9f9e-4ec9-8a71-f598a4ea17f5	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/3383	Kehinde Chukwu	\N	female	65961c57-bdba-4f4d-9956-791f065f8a43	\N	\N	t	2026-10-22 19:00:35.727+00	2026-10-22 19:00:35.727+00	\N
ea0358f4-8508-49f6-b565-9b82fdf1e4f7	e4486b73-e450-4693-8dec-a0176f4a0cc5	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/4399	Amaka Eze	\N	female	65961c57-bdba-4f4d-9956-791f065f8a43	\N	\N	t	2026-10-22 19:00:35.735+00	2026-10-22 19:00:35.735+00	\N
d245f31d-83d3-44e5-8fa1-8ced0f90575d	0ad59d65-a045-4d3a-91d4-74842750532b	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/3562	Chidi Eze	\N	male	65961c57-bdba-4f4d-9956-791f065f8a43	\N	\N	t	2026-10-22 19:00:35.745+00	2026-10-22 19:00:35.745+00	\N
44004eaf-ee1d-45be-90de-076a2e1c3d81	2d2c0d72-21bd-4909-9639-c55969f41dc9	55473dfa-dd2b-41e5-b85e-8da87261fa12	WHY100/2026/2573	Obinna Adeyemi	\N	male	65961c57-bdba-4f4d-9956-791f065f8a43	\N	\N	t	2026-10-22 19:00:35.753+00	2026-10-22 19:00:35.753+00	\N
\.


--
-- Data for Name: subjects; Type: TABLE DATA; Schema: public; Owner: school_user
--

COPY public.subjects (id, school_id, name, class_id, is_core, teacher_id, created_at) FROM stdin;
f360a3e3-14dc-4744-a7cf-c15feaca4770	55473dfa-dd2b-41e5-b85e-8da87261fa12	English Language	afa8bb8f-12ea-480d-949b-ace41851d9c1	t	\N	2026-10-22 18:21:12.994+00
815cec6f-83a7-4529-92d5-430476ea177d	55473dfa-dd2b-41e5-b85e-8da87261fa12	Mathematics	afa8bb8f-12ea-480d-949b-ace41851d9c1	t	\N	2026-10-22 18:21:13.004+00
43bc6104-c19f-4df0-986e-4cfe29a9c60c	55473dfa-dd2b-41e5-b85e-8da87261fa12	Basic Science	afa8bb8f-12ea-480d-949b-ace41851d9c1	t	\N	2026-10-22 18:21:13.012+00
15f03069-992c-4b6f-b440-4f39e27bbdaf	55473dfa-dd2b-41e5-b85e-8da87261fa12	Social Studies	afa8bb8f-12ea-480d-949b-ace41851d9c1	t	\N	2026-10-22 18:21:13.018+00
692b5aae-308d-4fa7-8563-d89d6e9281d4	55473dfa-dd2b-41e5-b85e-8da87261fa12	Business Studies	afa8bb8f-12ea-480d-949b-ace41851d9c1	t	\N	2026-10-22 18:21:13.026+00
1ce3577b-585b-491b-928e-e35d3f14360c	55473dfa-dd2b-41e5-b85e-8da87261fa12	Agricultural Science	afa8bb8f-12ea-480d-949b-ace41851d9c1	t	\N	2026-10-22 18:21:13.035+00
eb56f056-412d-47e6-a88b-9a22cdec6d5c	55473dfa-dd2b-41e5-b85e-8da87261fa12	Basic Technology	afa8bb8f-12ea-480d-949b-ace41851d9c1	t	\N	2026-10-22 18:21:13.043+00
009efebc-8405-45cc-affb-928c1ca9a208	55473dfa-dd2b-41e5-b85e-8da87261fa12	English Language	8ecbb9ec-466d-4074-8a2b-7f851e3b2505	t	\N	2026-10-22 18:21:13.047+00
aebe7645-d992-4d95-8c0a-c02352ce6bde	55473dfa-dd2b-41e5-b85e-8da87261fa12	Mathematics	8ecbb9ec-466d-4074-8a2b-7f851e3b2505	t	\N	2026-10-22 18:21:13.053+00
b2bcc1dc-9b9e-4cfe-8e98-d4be3d555f25	55473dfa-dd2b-41e5-b85e-8da87261fa12	Basic Science	8ecbb9ec-466d-4074-8a2b-7f851e3b2505	t	\N	2026-10-22 18:21:13.064+00
5bc21808-41a2-416b-ae22-379901cdcc88	55473dfa-dd2b-41e5-b85e-8da87261fa12	Social Studies	8ecbb9ec-466d-4074-8a2b-7f851e3b2505	t	\N	2026-10-22 18:21:13.072+00
855d9b68-f504-4476-a99f-992e754dec2a	55473dfa-dd2b-41e5-b85e-8da87261fa12	Christian Religious Studies	8ecbb9ec-466d-4074-8a2b-7f851e3b2505	t	\N	2026-10-22 18:21:13.079+00
415e3d16-571d-40d5-84cf-ed049de73d55	55473dfa-dd2b-41e5-b85e-8da87261fa12	Agricultural Science	8ecbb9ec-466d-4074-8a2b-7f851e3b2505	t	\N	2026-10-22 18:21:13.083+00
613ea69f-78d1-47e5-81b5-59d615e35937	55473dfa-dd2b-41e5-b85e-8da87261fa12	Basic Technology	8ecbb9ec-466d-4074-8a2b-7f851e3b2505	t	\N	2026-10-22 18:21:13.088+00
c03b5daa-5b36-4833-8845-a53d7046e451	55473dfa-dd2b-41e5-b85e-8da87261fa12	English Language	c1ac00b6-3080-41c6-b4af-19392f8ca82c	t	\N	2026-10-22 18:21:13.092+00
1096778e-456b-4cd8-b03c-a6c8f28f27a7	55473dfa-dd2b-41e5-b85e-8da87261fa12	Mathematics	c1ac00b6-3080-41c6-b4af-19392f8ca82c	t	\N	2026-10-22 18:21:13.096+00
22fb8f87-e1da-43af-a20c-c3bb4e39c0d3	55473dfa-dd2b-41e5-b85e-8da87261fa12	Basic Science	c1ac00b6-3080-41c6-b4af-19392f8ca82c	t	\N	2026-10-22 18:21:13.101+00
8711930f-6666-4290-a8a7-85f324f98785	55473dfa-dd2b-41e5-b85e-8da87261fa12	Social Studies	c1ac00b6-3080-41c6-b4af-19392f8ca82c	t	\N	2026-10-22 18:21:13.108+00
39f7d7f5-15dc-40c1-a79a-0f22e8040811	55473dfa-dd2b-41e5-b85e-8da87261fa12	Christian Religious Studies	c1ac00b6-3080-41c6-b4af-19392f8ca82c	t	\N	2026-10-22 18:21:13.111+00
2d501155-60aa-4aae-824d-b085d90b6201	55473dfa-dd2b-41e5-b85e-8da87261fa12	Agricultural Science	c1ac00b6-3080-41c6-b4af-19392f8ca82c	t	\N	2026-10-22 18:21:13.114+00
73613eab-a7a0-4905-bf2a-b695d68e8d6d	55473dfa-dd2b-41e5-b85e-8da87261fa12	Basic Technology	c1ac00b6-3080-41c6-b4af-19392f8ca82c	t	\N	2026-10-22 18:21:13.117+00
78ef98ef-70fe-40be-936f-6c5046140d21	55473dfa-dd2b-41e5-b85e-8da87261fa12	English Language	df59c19a-8732-42d0-9e7e-31e1334994f7	t	\N	2026-10-22 18:21:13.121+00
5afec519-9ba9-4c59-8c0d-31dcbbf46f46	55473dfa-dd2b-41e5-b85e-8da87261fa12	Mathematics	df59c19a-8732-42d0-9e7e-31e1334994f7	t	\N	2026-10-22 18:21:13.126+00
0fb88f8e-be91-4ece-8cd7-cfb98045c59a	55473dfa-dd2b-41e5-b85e-8da87261fa12	Basic Science	df59c19a-8732-42d0-9e7e-31e1334994f7	t	\N	2026-10-22 18:21:13.131+00
35adfe07-1976-4795-baa2-a88b2bd139f9	55473dfa-dd2b-41e5-b85e-8da87261fa12	Social Studies	df59c19a-8732-42d0-9e7e-31e1334994f7	t	\N	2026-10-22 18:21:13.134+00
8d186ee6-1b26-425c-bde9-b6d873fc31be	55473dfa-dd2b-41e5-b85e-8da87261fa12	Business Studies	df59c19a-8732-42d0-9e7e-31e1334994f7	t	\N	2026-10-22 18:21:13.138+00
55770981-bdd2-4394-b065-fb6755f88562	55473dfa-dd2b-41e5-b85e-8da87261fa12	Agricultural Science	df59c19a-8732-42d0-9e7e-31e1334994f7	t	\N	2026-10-22 18:21:13.142+00
7ba0e226-f54d-46f0-b831-5e7f214422bc	55473dfa-dd2b-41e5-b85e-8da87261fa12	Basic Technology	df59c19a-8732-42d0-9e7e-31e1334994f7	t	\N	2026-10-22 18:21:13.145+00
c265f1b6-fcef-4306-b5c8-98836301ae2d	55473dfa-dd2b-41e5-b85e-8da87261fa12	English Language	d1b0410c-caf9-4e20-a23c-8a1a3bff8d60	t	\N	2026-10-22 18:21:13.148+00
dc1dd179-17d6-459a-b151-3b4db95ecda9	55473dfa-dd2b-41e5-b85e-8da87261fa12	Mathematics	d1b0410c-caf9-4e20-a23c-8a1a3bff8d60	t	\N	2026-10-22 18:21:13.151+00
7a305479-5963-49d6-ab3f-fa2fb8defa01	55473dfa-dd2b-41e5-b85e-8da87261fa12	Basic Science	d1b0410c-caf9-4e20-a23c-8a1a3bff8d60	t	\N	2026-10-22 18:21:13.155+00
54e10737-df3d-4da6-93eb-38299cee59c4	55473dfa-dd2b-41e5-b85e-8da87261fa12	Basic Technology	d1b0410c-caf9-4e20-a23c-8a1a3bff8d60	t	\N	2026-10-22 18:21:13.159+00
1b5c5ef6-d5f4-4cb7-9596-7a24f3f2ba3a	55473dfa-dd2b-41e5-b85e-8da87261fa12	Civic Education	d1b0410c-caf9-4e20-a23c-8a1a3bff8d60	t	\N	2026-10-22 18:21:13.163+00
7319d6dd-2522-4733-b5ef-cd5d3dc50eaa	55473dfa-dd2b-41e5-b85e-8da87261fa12	Agricultural Science	d1b0410c-caf9-4e20-a23c-8a1a3bff8d60	t	\N	2026-10-22 18:21:13.166+00
4a9c8821-64eb-4186-a1ad-c3e8a89cee9d	55473dfa-dd2b-41e5-b85e-8da87261fa12	Business Studies	d1b0410c-caf9-4e20-a23c-8a1a3bff8d60	t	\N	2026-10-22 18:21:13.17+00
031a4e72-5fee-4cff-ba69-b445fff539b9	55473dfa-dd2b-41e5-b85e-8da87261fa12	English Language	619802b8-ed2c-41cf-93e3-52a12dc6218a	t	\N	2026-10-22 18:21:13.174+00
8664add0-9dad-4bf7-9505-08a5e192bd5f	55473dfa-dd2b-41e5-b85e-8da87261fa12	Mathematics	619802b8-ed2c-41cf-93e3-52a12dc6218a	t	\N	2026-10-22 18:21:13.177+00
0a6b0e64-96df-4505-a720-d342773c16f6	55473dfa-dd2b-41e5-b85e-8da87261fa12	Basic Science	619802b8-ed2c-41cf-93e3-52a12dc6218a	t	\N	2026-10-22 18:21:13.181+00
a69d322f-0a52-4225-ac1f-1634116afcb8	55473dfa-dd2b-41e5-b85e-8da87261fa12	Basic Technology	619802b8-ed2c-41cf-93e3-52a12dc6218a	t	\N	2026-10-22 18:21:13.184+00
9db05a25-efb4-4c59-870b-90dca998847a	55473dfa-dd2b-41e5-b85e-8da87261fa12	Civic Education	619802b8-ed2c-41cf-93e3-52a12dc6218a	t	\N	2026-10-22 18:21:13.188+00
f54a0ff4-14a7-4fdc-bf41-f891a27e05b4	55473dfa-dd2b-41e5-b85e-8da87261fa12	Agricultural Science	619802b8-ed2c-41cf-93e3-52a12dc6218a	t	\N	2026-10-22 18:21:13.192+00
fd5b07c1-8caa-4b72-8157-9c3049cbf988	55473dfa-dd2b-41e5-b85e-8da87261fa12	Business Studies	619802b8-ed2c-41cf-93e3-52a12dc6218a	t	\N	2026-10-22 18:21:13.195+00
cf632485-dae1-4eb3-b1b3-97e07cd6c86b	55473dfa-dd2b-41e5-b85e-8da87261fa12	English Language	1110fe28-558c-485e-a5cd-2e1f879bee90	t	\N	2026-10-22 18:21:13.199+00
4680a62f-2a61-4a20-ae7b-9e906aae3d6f	55473dfa-dd2b-41e5-b85e-8da87261fa12	Mathematics	1110fe28-558c-485e-a5cd-2e1f879bee90	t	\N	2026-10-22 18:21:13.202+00
3c7af053-8f76-4126-909e-53b0de3fe192	55473dfa-dd2b-41e5-b85e-8da87261fa12	Physics	1110fe28-558c-485e-a5cd-2e1f879bee90	t	\N	2026-10-22 18:21:13.206+00
e53c21a3-b1ce-47e4-b35b-43864c29106d	55473dfa-dd2b-41e5-b85e-8da87261fa12	Chemistry	1110fe28-558c-485e-a5cd-2e1f879bee90	t	\N	2026-10-22 18:21:13.21+00
1c86589d-1cfa-4b8d-ba73-8133f4d01d14	55473dfa-dd2b-41e5-b85e-8da87261fa12	Biology	1110fe28-558c-485e-a5cd-2e1f879bee90	t	\N	2026-10-22 18:21:13.213+00
2a824588-b7de-45f5-8eaf-9eaa80d6b51b	55473dfa-dd2b-41e5-b85e-8da87261fa12	Geography	1110fe28-558c-485e-a5cd-2e1f879bee90	t	\N	2026-10-22 18:21:13.216+00
f2159530-6161-4906-b092-1b94d4d5a9a8	55473dfa-dd2b-41e5-b85e-8da87261fa12	Civic Education	1110fe28-558c-485e-a5cd-2e1f879bee90	t	\N	2026-10-22 18:21:13.219+00
50d74f30-832a-4825-bd0b-98057ac78295	55473dfa-dd2b-41e5-b85e-8da87261fa12	English Language	fadaf65c-f7c1-4327-b8e6-c2c361db8176	t	\N	2026-10-22 18:21:13.224+00
4108a1ce-f657-406e-bc13-b43de1162985	55473dfa-dd2b-41e5-b85e-8da87261fa12	Mathematics	fadaf65c-f7c1-4327-b8e6-c2c361db8176	t	\N	2026-10-22 18:21:13.227+00
404eb98c-77bb-41a5-8b89-6fc6ab6ab276	55473dfa-dd2b-41e5-b85e-8da87261fa12	Physics	fadaf65c-f7c1-4327-b8e6-c2c361db8176	t	\N	2026-10-22 18:21:13.231+00
ad220aaf-e72a-4ef3-97e6-a223c05f8136	55473dfa-dd2b-41e5-b85e-8da87261fa12	Chemistry	fadaf65c-f7c1-4327-b8e6-c2c361db8176	t	\N	2026-10-22 18:21:13.234+00
b70595df-ee27-4751-a826-c386e688f423	55473dfa-dd2b-41e5-b85e-8da87261fa12	Biology	fadaf65c-f7c1-4327-b8e6-c2c361db8176	t	\N	2026-10-22 18:21:13.238+00
b29b101c-00ea-4fc5-8f5f-aaf8850c6a66	55473dfa-dd2b-41e5-b85e-8da87261fa12	Geography	fadaf65c-f7c1-4327-b8e6-c2c361db8176	t	\N	2026-10-22 18:21:13.242+00
a70be137-2263-4f09-a79c-36ae1ac5fcd5	55473dfa-dd2b-41e5-b85e-8da87261fa12	Civic Education	fadaf65c-f7c1-4327-b8e6-c2c361db8176	t	\N	2026-10-22 18:21:13.246+00
a0827c44-9e5a-4138-b728-6f93a7c25412	55473dfa-dd2b-41e5-b85e-8da87261fa12	English Language	8e1a5460-789f-4996-a702-f2d69b402906	t	\N	2026-10-22 18:21:13.249+00
bd974ac9-a3ef-47f3-8f39-7598fdd27370	55473dfa-dd2b-41e5-b85e-8da87261fa12	Mathematics	8e1a5460-789f-4996-a702-f2d69b402906	t	\N	2026-10-22 18:21:13.252+00
87cfc326-f60e-45cd-86cf-5823b75bc002	55473dfa-dd2b-41e5-b85e-8da87261fa12	Physics	8e1a5460-789f-4996-a702-f2d69b402906	t	\N	2026-10-22 18:21:13.257+00
7d7111d1-86ec-4c1c-bd04-07107fbf06da	55473dfa-dd2b-41e5-b85e-8da87261fa12	Chemistry	8e1a5460-789f-4996-a702-f2d69b402906	t	\N	2026-10-22 18:21:13.261+00
c949abb1-9fdc-4d11-9f91-25b4436a1cbf	55473dfa-dd2b-41e5-b85e-8da87261fa12	Further Mathematics	8e1a5460-789f-4996-a702-f2d69b402906	t	\N	2026-10-22 18:21:13.264+00
39814b6e-37e7-4c9b-a8d6-c276904e2d48	55473dfa-dd2b-41e5-b85e-8da87261fa12	Biology	8e1a5460-789f-4996-a702-f2d69b402906	t	\N	2026-10-22 18:21:13.268+00
f885913c-6a0c-457c-8b73-c5d729d42ae3	55473dfa-dd2b-41e5-b85e-8da87261fa12	Geography	8e1a5460-789f-4996-a702-f2d69b402906	t	\N	2026-10-22 18:21:13.272+00
a0740ee2-ecfe-4878-bddf-0cf39cd70023	55473dfa-dd2b-41e5-b85e-8da87261fa12	English Language	641cf9ab-d2e1-4d5c-9905-36b9d333a875	t	\N	2026-10-22 18:21:13.276+00
23eb443b-1ac6-4a65-adbf-2b89856e808f	55473dfa-dd2b-41e5-b85e-8da87261fa12	Mathematics	641cf9ab-d2e1-4d5c-9905-36b9d333a875	t	\N	2026-10-22 18:21:13.279+00
27ebf36b-4bd7-4435-aa9e-88ffc8c840b4	55473dfa-dd2b-41e5-b85e-8da87261fa12	Physics	641cf9ab-d2e1-4d5c-9905-36b9d333a875	t	\N	2026-10-22 18:21:13.282+00
08572d46-3759-4b13-a9d2-f4e9e74aab04	55473dfa-dd2b-41e5-b85e-8da87261fa12	Chemistry	641cf9ab-d2e1-4d5c-9905-36b9d333a875	t	\N	2026-10-22 18:21:13.286+00
cb172d43-7405-4994-9fdc-c541839d2b9c	55473dfa-dd2b-41e5-b85e-8da87261fa12	Further Mathematics	641cf9ab-d2e1-4d5c-9905-36b9d333a875	t	\N	2026-10-22 18:21:13.29+00
1bef2e29-1d34-4fde-b69b-58d8662f2314	55473dfa-dd2b-41e5-b85e-8da87261fa12	Biology	641cf9ab-d2e1-4d5c-9905-36b9d333a875	t	\N	2026-10-22 18:21:13.293+00
720fcff9-ef34-4da0-b002-195642b27060	55473dfa-dd2b-41e5-b85e-8da87261fa12	Geography	641cf9ab-d2e1-4d5c-9905-36b9d333a875	t	\N	2026-10-22 18:21:13.296+00
eecf7ed0-fd44-46e7-b516-7344d39fb8eb	55473dfa-dd2b-41e5-b85e-8da87261fa12	English Language	51a30184-8995-47bd-8bf8-79eed7049a0d	t	\N	2026-10-22 18:21:13.3+00
989b8a54-ca07-4102-aabd-b6f396a1c5f1	55473dfa-dd2b-41e5-b85e-8da87261fa12	Mathematics	51a30184-8995-47bd-8bf8-79eed7049a0d	t	\N	2026-10-22 18:21:13.304+00
827f2cba-e355-4d29-bd09-239366218438	55473dfa-dd2b-41e5-b85e-8da87261fa12	Physics	51a30184-8995-47bd-8bf8-79eed7049a0d	t	\N	2026-10-22 18:21:13.308+00
0de4094f-e1da-4741-b06a-dd621600924b	55473dfa-dd2b-41e5-b85e-8da87261fa12	Chemistry	51a30184-8995-47bd-8bf8-79eed7049a0d	t	\N	2026-10-22 18:21:13.311+00
7e009875-40be-4f86-9ee8-ebe3df7e87a6	55473dfa-dd2b-41e5-b85e-8da87261fa12	Economics	51a30184-8995-47bd-8bf8-79eed7049a0d	t	\N	2026-10-22 18:21:13.315+00
f6dd4304-0ca0-4d6b-989a-7520133f96da	55473dfa-dd2b-41e5-b85e-8da87261fa12	Biology	51a30184-8995-47bd-8bf8-79eed7049a0d	t	\N	2026-10-22 18:21:13.318+00
2b347183-b3d3-4dbe-b380-9207e8200995	55473dfa-dd2b-41e5-b85e-8da87261fa12	Literature in English	51a30184-8995-47bd-8bf8-79eed7049a0d	t	\N	2026-10-22 18:21:13.324+00
ea94abba-fe34-43e1-9e97-ed7150dba455	55473dfa-dd2b-41e5-b85e-8da87261fa12	English Language	48a13b05-d5e3-4039-bd26-24dea4f9bde7	t	\N	2026-10-22 18:21:13.327+00
aea6cbb1-9355-41ac-a84f-9123a8224589	55473dfa-dd2b-41e5-b85e-8da87261fa12	Mathematics	48a13b05-d5e3-4039-bd26-24dea4f9bde7	t	\N	2026-10-22 18:21:13.33+00
279bc2de-05d4-45e6-986f-0c1b1066e43b	55473dfa-dd2b-41e5-b85e-8da87261fa12	Physics	48a13b05-d5e3-4039-bd26-24dea4f9bde7	t	\N	2026-10-22 18:21:13.334+00
a053d81a-bccf-4c6b-9b72-657ab744e3c2	55473dfa-dd2b-41e5-b85e-8da87261fa12	Chemistry	48a13b05-d5e3-4039-bd26-24dea4f9bde7	t	\N	2026-10-22 18:21:13.338+00
78f1594b-d71a-4f6f-8074-deb4a15c022c	55473dfa-dd2b-41e5-b85e-8da87261fa12	Economics	48a13b05-d5e3-4039-bd26-24dea4f9bde7	t	\N	2026-10-22 18:21:13.341+00
24157252-c9c3-4343-a04c-7601154ea7f0	55473dfa-dd2b-41e5-b85e-8da87261fa12	Biology	48a13b05-d5e3-4039-bd26-24dea4f9bde7	t	\N	2026-10-22 18:21:13.344+00
9f64a791-c018-4262-97dd-57b24c0d0492	55473dfa-dd2b-41e5-b85e-8da87261fa12	Literature in English	48a13b05-d5e3-4039-bd26-24dea4f9bde7	t	\N	2026-10-22 18:21:13.347+00
34558b3f-fabd-4d28-8300-cef50e1b6da8	55473dfa-dd2b-41e5-b85e-8da87261fa12	English Language	715217da-e2e4-45bc-a7d8-30e3c4fbb152	t	\N	2026-10-22 19:00:34.679+00
a2bd1c71-954a-43c5-b717-3ab0e4117bb4	55473dfa-dd2b-41e5-b85e-8da87261fa12	Mathematics	715217da-e2e4-45bc-a7d8-30e3c4fbb152	t	\N	2026-10-22 19:00:34.685+00
dd3d4804-df9a-4a35-ad88-6447dc626170	55473dfa-dd2b-41e5-b85e-8da87261fa12	Basic Science	715217da-e2e4-45bc-a7d8-30e3c4fbb152	t	\N	2026-10-22 19:00:34.694+00
b7e02245-784c-427f-b5f8-076943835f8a	55473dfa-dd2b-41e5-b85e-8da87261fa12	Social Studies	715217da-e2e4-45bc-a7d8-30e3c4fbb152	t	\N	2026-10-22 19:00:34.7+00
aeb11406-537e-4941-9b3a-1cd9f8cf3981	55473dfa-dd2b-41e5-b85e-8da87261fa12	Christian Religious Studies	715217da-e2e4-45bc-a7d8-30e3c4fbb152	t	\N	2026-10-22 19:00:34.704+00
3d85f286-7b8f-40fa-882f-9a2290620ccc	55473dfa-dd2b-41e5-b85e-8da87261fa12	Agricultural Science	715217da-e2e4-45bc-a7d8-30e3c4fbb152	t	\N	2026-10-22 19:00:34.709+00
a73720f6-87c8-40fa-bda9-ea68aa0ad694	55473dfa-dd2b-41e5-b85e-8da87261fa12	Basic Technology	715217da-e2e4-45bc-a7d8-30e3c4fbb152	t	\N	2026-10-22 19:00:34.728+00
2568e2e8-275f-494b-b2a2-044fc75af155	55473dfa-dd2b-41e5-b85e-8da87261fa12	English Language	306db6c9-cfbf-43f3-a90a-d3fae6a28e56	t	\N	2026-10-22 19:00:34.732+00
3742ffc7-e817-4145-b2a3-115fb4edfbaf	55473dfa-dd2b-41e5-b85e-8da87261fa12	Mathematics	306db6c9-cfbf-43f3-a90a-d3fae6a28e56	t	\N	2026-10-22 19:00:34.737+00
8de73bae-b607-41b8-b5bd-1a16845c5375	55473dfa-dd2b-41e5-b85e-8da87261fa12	Basic Science	306db6c9-cfbf-43f3-a90a-d3fae6a28e56	t	\N	2026-10-22 19:00:34.742+00
4d4a7d2c-b619-4173-88a7-8152d0d4eda6	55473dfa-dd2b-41e5-b85e-8da87261fa12	Social Studies	306db6c9-cfbf-43f3-a90a-d3fae6a28e56	t	\N	2026-10-22 19:00:34.746+00
6765774d-d5cd-4ab4-81c7-596710dffde8	55473dfa-dd2b-41e5-b85e-8da87261fa12	Christian Religious Studies	306db6c9-cfbf-43f3-a90a-d3fae6a28e56	t	\N	2026-10-22 19:00:34.753+00
f1b04295-eb80-48aa-b514-16ef930ec146	55473dfa-dd2b-41e5-b85e-8da87261fa12	Agricultural Science	306db6c9-cfbf-43f3-a90a-d3fae6a28e56	t	\N	2026-10-22 19:00:34.759+00
f0d9c5e1-1c42-4ae1-a86a-2e5925e938a6	55473dfa-dd2b-41e5-b85e-8da87261fa12	Basic Technology	306db6c9-cfbf-43f3-a90a-d3fae6a28e56	t	\N	2026-10-22 19:00:34.763+00
62eecfbf-6333-4161-b1f7-4a40936458df	55473dfa-dd2b-41e5-b85e-8da87261fa12	English Language	b674150e-ecf1-4406-a813-67dd02768555	t	\N	2026-10-22 19:00:34.767+00
4f942273-5513-4012-a310-6478605235f0	55473dfa-dd2b-41e5-b85e-8da87261fa12	Mathematics	b674150e-ecf1-4406-a813-67dd02768555	t	\N	2026-10-22 19:00:34.773+00
17b31e3b-9324-4a0b-ab4b-2ce5c15e8a8a	55473dfa-dd2b-41e5-b85e-8da87261fa12	Basic Science	b674150e-ecf1-4406-a813-67dd02768555	t	\N	2026-10-22 19:00:34.779+00
2d536ce9-5988-4399-b270-7bc5664d1753	55473dfa-dd2b-41e5-b85e-8da87261fa12	Social Studies	b674150e-ecf1-4406-a813-67dd02768555	t	\N	2026-10-22 19:00:34.783+00
cda4bd3b-f93f-40dc-82fc-cc632d0ddc8c	55473dfa-dd2b-41e5-b85e-8da87261fa12	Business Studies	b674150e-ecf1-4406-a813-67dd02768555	t	\N	2026-10-22 19:00:34.787+00
5d163235-701c-4c18-a9de-1c0c5962f699	55473dfa-dd2b-41e5-b85e-8da87261fa12	Agricultural Science	b674150e-ecf1-4406-a813-67dd02768555	t	\N	2026-10-22 19:00:34.793+00
f626cb92-c885-4eed-9496-27c826566d3b	55473dfa-dd2b-41e5-b85e-8da87261fa12	Basic Technology	b674150e-ecf1-4406-a813-67dd02768555	t	\N	2026-10-22 19:00:34.797+00
ec87a666-e508-45d7-ab7c-557f068c1896	55473dfa-dd2b-41e5-b85e-8da87261fa12	English Language	0be7a4f6-1619-40a3-9f72-a7c262f0b863	t	\N	2026-10-22 19:00:34.802+00
098beb84-7d5a-4d72-a17d-648af38c5eda	55473dfa-dd2b-41e5-b85e-8da87261fa12	Mathematics	0be7a4f6-1619-40a3-9f72-a7c262f0b863	t	\N	2026-10-22 19:00:34.807+00
828085be-565e-45a7-92ab-b78ab741da7d	55473dfa-dd2b-41e5-b85e-8da87261fa12	Basic Science	0be7a4f6-1619-40a3-9f72-a7c262f0b863	t	\N	2026-10-22 19:00:34.813+00
f4f911d9-29d8-4408-9fb4-32e2a618e69b	55473dfa-dd2b-41e5-b85e-8da87261fa12	Basic Technology	0be7a4f6-1619-40a3-9f72-a7c262f0b863	t	\N	2026-10-22 19:00:34.816+00
5f909d15-1543-412f-9e01-c27e2122e399	55473dfa-dd2b-41e5-b85e-8da87261fa12	Civic Education	0be7a4f6-1619-40a3-9f72-a7c262f0b863	t	\N	2026-10-22 19:00:34.82+00
9e60c57d-25e2-4154-8271-affd6d9d6bec	55473dfa-dd2b-41e5-b85e-8da87261fa12	Agricultural Science	0be7a4f6-1619-40a3-9f72-a7c262f0b863	t	\N	2026-10-22 19:00:34.824+00
e3b3a051-857d-43c6-bdfa-c62fb44f9916	55473dfa-dd2b-41e5-b85e-8da87261fa12	Business Studies	0be7a4f6-1619-40a3-9f72-a7c262f0b863	t	\N	2026-10-22 19:00:34.828+00
cecdba94-5925-4ce2-a4ad-aa2b2166ca62	55473dfa-dd2b-41e5-b85e-8da87261fa12	English Language	801ac4fb-14ed-49a0-ac4c-4835ff28549f	t	\N	2026-10-22 19:00:34.831+00
7e9af073-01c1-43ed-ad27-c64117327d69	55473dfa-dd2b-41e5-b85e-8da87261fa12	Mathematics	801ac4fb-14ed-49a0-ac4c-4835ff28549f	t	\N	2026-10-22 19:00:34.835+00
d9b9316c-eda9-4ab1-a95a-d9a4527ae69c	55473dfa-dd2b-41e5-b85e-8da87261fa12	Basic Science	801ac4fb-14ed-49a0-ac4c-4835ff28549f	t	\N	2026-10-22 19:00:34.84+00
744cdf2a-8d77-4928-8abe-528b11668bf2	55473dfa-dd2b-41e5-b85e-8da87261fa12	Basic Technology	801ac4fb-14ed-49a0-ac4c-4835ff28549f	t	\N	2026-10-22 19:00:34.845+00
49e6a8e1-6166-4626-bd49-31b0eee72277	55473dfa-dd2b-41e5-b85e-8da87261fa12	Civic Education	801ac4fb-14ed-49a0-ac4c-4835ff28549f	t	\N	2026-10-22 19:00:34.848+00
b1743b0a-a98a-4d36-937d-46a7a1963dab	55473dfa-dd2b-41e5-b85e-8da87261fa12	Agricultural Science	801ac4fb-14ed-49a0-ac4c-4835ff28549f	t	\N	2026-10-22 19:00:34.851+00
90d415a3-0365-49eb-8e49-eaa63b9beb50	55473dfa-dd2b-41e5-b85e-8da87261fa12	Business Studies	801ac4fb-14ed-49a0-ac4c-4835ff28549f	t	\N	2026-10-22 19:00:34.854+00
9cf90e46-c443-4dd7-8bb5-b85f28b28340	55473dfa-dd2b-41e5-b85e-8da87261fa12	English Language	d08e9e53-f7bd-4d0e-80ad-b22f29d0daab	t	\N	2026-10-22 19:00:34.858+00
47194a6a-892d-401a-bcfc-77095bc3641e	55473dfa-dd2b-41e5-b85e-8da87261fa12	Mathematics	d08e9e53-f7bd-4d0e-80ad-b22f29d0daab	t	\N	2026-10-22 19:00:34.862+00
d50aef8e-bdef-4fa1-8785-f502c85d2d9f	55473dfa-dd2b-41e5-b85e-8da87261fa12	Physics	d08e9e53-f7bd-4d0e-80ad-b22f29d0daab	t	\N	2026-10-22 19:00:34.865+00
1e42a999-5d61-459a-9d72-2f146d2d5aaf	55473dfa-dd2b-41e5-b85e-8da87261fa12	Chemistry	d08e9e53-f7bd-4d0e-80ad-b22f29d0daab	t	\N	2026-10-22 19:00:34.868+00
179b94fd-8bf9-4a40-be22-458076b2ae3f	55473dfa-dd2b-41e5-b85e-8da87261fa12	Biology	d08e9e53-f7bd-4d0e-80ad-b22f29d0daab	t	\N	2026-10-22 19:00:34.872+00
17416dc9-fde5-4206-8f3d-883ff8a757e1	55473dfa-dd2b-41e5-b85e-8da87261fa12	Geography	d08e9e53-f7bd-4d0e-80ad-b22f29d0daab	t	\N	2026-10-22 19:00:34.877+00
73ceaa59-d0e5-40d4-9129-aac88f9047e1	55473dfa-dd2b-41e5-b85e-8da87261fa12	Civic Education	d08e9e53-f7bd-4d0e-80ad-b22f29d0daab	t	\N	2026-10-22 19:00:34.88+00
17c1a9a2-f214-4035-880b-496aef77bd37	55473dfa-dd2b-41e5-b85e-8da87261fa12	English Language	d01fc901-3ad1-42b9-a782-8408060e4890	t	\N	2026-10-22 19:00:34.883+00
99f82809-7dc9-4fbc-ba46-c71358107c75	55473dfa-dd2b-41e5-b85e-8da87261fa12	Mathematics	d01fc901-3ad1-42b9-a782-8408060e4890	t	\N	2026-10-22 19:00:34.886+00
cec2d2d3-b584-47f5-832f-7ba11d302f88	55473dfa-dd2b-41e5-b85e-8da87261fa12	Physics	d01fc901-3ad1-42b9-a782-8408060e4890	t	\N	2026-10-22 19:00:34.891+00
c27e31de-bfe6-4b0c-84b9-a0bb0d9c0753	55473dfa-dd2b-41e5-b85e-8da87261fa12	Chemistry	d01fc901-3ad1-42b9-a782-8408060e4890	t	\N	2026-10-22 19:00:34.895+00
43451487-033c-44f6-8c8f-65eef57d6a4d	55473dfa-dd2b-41e5-b85e-8da87261fa12	Biology	d01fc901-3ad1-42b9-a782-8408060e4890	t	\N	2026-10-22 19:00:34.898+00
c2414b07-ddcd-4093-a549-2edbd184e56d	55473dfa-dd2b-41e5-b85e-8da87261fa12	Geography	d01fc901-3ad1-42b9-a782-8408060e4890	t	\N	2026-10-22 19:00:34.902+00
fd24fed1-5d71-4f67-a5a5-f3f836485eef	55473dfa-dd2b-41e5-b85e-8da87261fa12	Civic Education	d01fc901-3ad1-42b9-a782-8408060e4890	t	\N	2026-10-22 19:00:34.906+00
3e5c67d5-e121-4e2f-8366-6103b3a2d128	55473dfa-dd2b-41e5-b85e-8da87261fa12	English Language	7a748658-0722-462b-a6a5-c8d8e3916b5e	t	\N	2026-10-22 19:00:34.909+00
003bd3a8-abb8-4b38-bd76-92a6916aea5f	55473dfa-dd2b-41e5-b85e-8da87261fa12	Mathematics	7a748658-0722-462b-a6a5-c8d8e3916b5e	t	\N	2026-10-22 19:00:34.912+00
ba500b9d-e767-4338-b73d-e6fee5483f0c	55473dfa-dd2b-41e5-b85e-8da87261fa12	Physics	7a748658-0722-462b-a6a5-c8d8e3916b5e	t	\N	2026-10-22 19:00:34.917+00
25089181-63a1-4b27-8b7c-81fd86b02dfe	55473dfa-dd2b-41e5-b85e-8da87261fa12	Chemistry	7a748658-0722-462b-a6a5-c8d8e3916b5e	t	\N	2026-10-22 19:00:34.922+00
bf72e6ca-adea-4335-bf80-d73096049ce8	55473dfa-dd2b-41e5-b85e-8da87261fa12	Further Mathematics	7a748658-0722-462b-a6a5-c8d8e3916b5e	t	\N	2026-10-22 19:00:34.927+00
5b447957-ba85-491f-93e3-a283da3c0c65	55473dfa-dd2b-41e5-b85e-8da87261fa12	Biology	7a748658-0722-462b-a6a5-c8d8e3916b5e	t	\N	2026-10-22 19:00:34.93+00
4a8ba9ab-32db-4a66-bd43-8c483c5710f9	55473dfa-dd2b-41e5-b85e-8da87261fa12	Geography	7a748658-0722-462b-a6a5-c8d8e3916b5e	t	\N	2026-10-22 19:00:34.932+00
d9f1a909-0aa1-4045-9765-26da299191e6	55473dfa-dd2b-41e5-b85e-8da87261fa12	English Language	e3476888-76e0-4a42-bad8-3678c5e7f311	t	\N	2026-10-22 19:00:34.935+00
4fddb943-d512-44aa-95e8-0eea43e24014	55473dfa-dd2b-41e5-b85e-8da87261fa12	Mathematics	e3476888-76e0-4a42-bad8-3678c5e7f311	t	\N	2026-10-22 19:00:34.939+00
642db769-bfe3-4402-8bbf-bc8c635f2916	55473dfa-dd2b-41e5-b85e-8da87261fa12	Physics	e3476888-76e0-4a42-bad8-3678c5e7f311	t	\N	2026-10-22 19:00:34.942+00
85eb4db1-39d4-4816-9212-5433f749f0d1	55473dfa-dd2b-41e5-b85e-8da87261fa12	Chemistry	e3476888-76e0-4a42-bad8-3678c5e7f311	t	\N	2026-10-22 19:00:34.945+00
fa0816c8-e75c-400d-8495-4d2bba1ed56c	55473dfa-dd2b-41e5-b85e-8da87261fa12	Further Mathematics	e3476888-76e0-4a42-bad8-3678c5e7f311	t	\N	2026-10-22 19:00:34.952+00
97e44322-caec-40bb-becb-429b648ae64a	55473dfa-dd2b-41e5-b85e-8da87261fa12	Biology	e3476888-76e0-4a42-bad8-3678c5e7f311	t	\N	2026-10-22 19:00:34.957+00
1288da91-4d2b-4cf2-ab52-95ec9f17a5c2	55473dfa-dd2b-41e5-b85e-8da87261fa12	Geography	e3476888-76e0-4a42-bad8-3678c5e7f311	t	\N	2026-10-22 19:00:34.961+00
e0e6778a-47f9-46c1-bfa0-b21e96743308	55473dfa-dd2b-41e5-b85e-8da87261fa12	English Language	5252a0ab-36c6-4823-87ec-632a339c4dc0	t	\N	2026-10-22 19:00:34.964+00
e8d06d34-6621-423f-b5ed-11c73e4ede1e	55473dfa-dd2b-41e5-b85e-8da87261fa12	Mathematics	5252a0ab-36c6-4823-87ec-632a339c4dc0	t	\N	2026-10-22 19:00:34.967+00
5323bb1a-b2ef-4bbb-b6cb-bf5f39a15b63	55473dfa-dd2b-41e5-b85e-8da87261fa12	Physics	5252a0ab-36c6-4823-87ec-632a339c4dc0	t	\N	2026-10-22 19:00:34.971+00
62f70a66-fa94-47d7-8bcc-3da44b9535c2	55473dfa-dd2b-41e5-b85e-8da87261fa12	Chemistry	5252a0ab-36c6-4823-87ec-632a339c4dc0	t	\N	2026-10-22 19:00:34.974+00
15ee436b-a715-4ae0-819a-0641638154fe	55473dfa-dd2b-41e5-b85e-8da87261fa12	Economics	5252a0ab-36c6-4823-87ec-632a339c4dc0	t	\N	2026-10-22 19:00:34.977+00
0b48f7a5-89ce-4535-83c7-c9ae491baef6	55473dfa-dd2b-41e5-b85e-8da87261fa12	Biology	5252a0ab-36c6-4823-87ec-632a339c4dc0	t	\N	2026-10-22 19:00:34.982+00
dc732f4c-95e3-4098-b54c-429269c33a63	55473dfa-dd2b-41e5-b85e-8da87261fa12	Literature in English	5252a0ab-36c6-4823-87ec-632a339c4dc0	t	\N	2026-10-22 19:00:34.987+00
74b26dd1-1c6a-4d3e-8621-cbe32440b197	55473dfa-dd2b-41e5-b85e-8da87261fa12	English Language	65961c57-bdba-4f4d-9956-791f065f8a43	t	\N	2026-10-22 19:00:34.993+00
447eb03d-216e-49b1-bedf-e090e47328a2	55473dfa-dd2b-41e5-b85e-8da87261fa12	Mathematics	65961c57-bdba-4f4d-9956-791f065f8a43	t	\N	2026-10-22 19:00:34.997+00
ee54d725-bf76-4543-8aa1-414300a13d0d	55473dfa-dd2b-41e5-b85e-8da87261fa12	Physics	65961c57-bdba-4f4d-9956-791f065f8a43	t	\N	2026-10-22 19:00:35+00
6da18339-286f-4bcc-ac1e-856e342ee2ea	55473dfa-dd2b-41e5-b85e-8da87261fa12	Chemistry	65961c57-bdba-4f4d-9956-791f065f8a43	t	\N	2026-10-22 19:00:35.005+00
40fc4bde-dd94-4d04-ba72-44a750e8ed70	55473dfa-dd2b-41e5-b85e-8da87261fa12	Economics	65961c57-bdba-4f4d-9956-791f065f8a43	t	\N	2026-10-22 19:00:35.01+00
9048e6ab-c99f-42cb-832e-04d8da668bc1	55473dfa-dd2b-41e5-b85e-8da87261fa12	Biology	65961c57-bdba-4f4d-9956-791f065f8a43	t	\N	2026-10-22 19:00:35.014+00
4c7be22e-0be2-40e8-ace2-513de9f72f57	55473dfa-dd2b-41e5-b85e-8da87261fa12	Literature in English	65961c57-bdba-4f4d-9956-791f065f8a43	t	\N	2026-10-22 19:00:35.017+00
\.


--
-- Data for Name: timetable_periods; Type: TABLE DATA; Schema: public; Owner: school_user
--

COPY public.timetable_periods (id, class_id, subject_id, day_of_week, start_time, end_time) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: school_user
--

COPY public.users (id, school_id, phone, email, password_, role, is_active, last_login, created_at, updated_at, email_verified_at, phone_verified_at) FROM stdin;
9cb65288-eba7-477b-959d-f17eaa2fe0ff	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409155007388	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.551+00	2026-10-22 18:21:13.551+00	\N	\N
3341819f-421b-46d0-9aa9-e41fa63d54d2	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409147338625	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.561+00	2026-10-22 18:21:13.561+00	\N	\N
0abe5bbc-7e1b-4f5e-b7e2-9a1ff045bdf4	9c2566ca-8f8a-4c9f-86fe-8e89181b5c60	+2348012345679	emeka@gmail.com	\N	student	t	\N	2026-10-22 06:14:02.036+00	2026-10-22 06:14:02.036+00	\N	\N
3c40cd84-a103-4df7-88ac-4b80f601fd8a	9c2566ca-8f8a-4c9f-86fe-8e89181b5c60	+2348012345623	emekas@gmail.com	\N	student	t	\N	2026-10-22 08:27:32.15+00	2026-10-22 09:57:05.447+00	\N	\N
3caee5ce-0b97-4a4e-960a-44d87ef53ad2	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407068056661	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.57+00	2026-10-22 18:21:13.57+00	\N	\N
3a3d8a38-a11f-4a65-a03c-761430d93324	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409075366059	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.58+00	2026-10-22 18:21:13.58+00	\N	\N
5ba3d71c-bf3b-490c-9dd6-9cc6a83c8ed2	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408125389219	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.592+00	2026-10-22 18:21:13.592+00	\N	\N
787b1b9f-3bae-4591-80e0-31ba2b33c27b	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407040016290	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.602+00	2026-10-22 18:21:13.602+00	\N	\N
a34c317f-5232-41a1-95b8-d762d3a0ec8e	9c2566ca-8f8a-4c9f-86fe-8e89181b5c60	+2348012345678	principal@example.com	\N	class_teacher	t	2026-10-22 11:31:05.839+00	2026-10-22 05:26:59.647+00	2026-10-22 11:31:05.84+00	\N	2026-10-22 11:31:05.839+00
5c926164-c0cd-49e5-a1c0-851b475449b0	55473dfa-dd2b-41e5-b85e-8da87261fa12	+2348106054408	whytecode.tech@gmail.com	\N	admin	t	2026-10-22 12:34:14.837+00	2026-10-21 12:30:00.933+00	2026-10-22 12:34:14.844+00	\N	2026-10-22 12:34:14.837+00
68c71ec3-e433-4674-ae80-ad5fbe5cb00d	55473dfa-dd2b-41e5-b85e-8da87261fa12	+2348132500147	superkalel55@gmail.com	\N	student	t	\N	2026-10-22 12:37:53.066+00	2026-10-22 12:37:53.066+00	\N	\N
766f7bfc-d28b-4dbe-bdec-3abee8701081	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409010180386	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.611+00	2026-10-22 18:21:13.611+00	\N	\N
5e286edf-3d92-459f-ab96-c6d3dd3f3f3a	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407038066186	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.62+00	2026-10-22 18:21:13.62+00	\N	\N
119a2f59-d5d3-4f7d-8629-3cf27344776e	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407061584930	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.63+00	2026-10-22 18:21:13.63+00	\N	\N
54cd13fa-fcd5-43d9-ad32-e763da261dd2	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409186057658	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.64+00	2026-10-22 18:21:13.64+00	\N	\N
e3f1a85b-f319-45c9-b26e-ac058ddabb8a	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408060472544	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.65+00	2026-10-22 18:21:13.65+00	\N	\N
b38ff10a-1f66-4e28-8b0e-56d6f8a2ef62	9c2566ca-8f8a-4c9f-86fe-8e89181b5c60	+2348016345678	\N	\N	admin	t	2026-10-22 16:23:48.707+00	2026-10-22 11:09:04.725+00	2026-10-22 16:23:48.71+00	\N	2026-10-22 16:23:48.707+00
dcf6c2cf-439a-44da-b661-b9d6643dc4be	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409190230701	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.66+00	2026-10-22 18:21:13.66+00	\N	\N
3955e864-ea70-434d-9097-de8f3918345b	55473dfa-dd2b-41e5-b85e-8da87261fa12	+2348012345671	\N	\N	class_teacher	t	\N	2026-10-22 17:08:11.455+00	2026-10-22 17:08:11.455+00	\N	\N
ab334393-b63e-433c-b9b4-c9a217fbfb94	55473dfa-dd2b-41e5-b85e-8da87261fa12	+2348106055408	\N	\N	vice_principal	t	2026-10-22 17:14:05.252+00	2026-10-22 14:18:29.697+00	2026-10-22 17:14:05.271+00	\N	2026-10-22 17:14:05.252+00
4c52c41c-557c-45f9-8126-ffcb13f8ea4d	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409116767642	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.669+00	2026-10-22 18:21:13.669+00	\N	\N
cdc55efc-9318-46e8-be97-59fd660234be	55473dfa-dd2b-41e5-b85e-8da87261fa12	+2348132500141	\N	\N	subject_teacher	t	2026-10-22 17:18:44.704+00	2026-10-22 17:17:50.015+00	2026-10-22 17:18:44.704+00	\N	2026-10-22 17:18:44.704+00
cb7dca24-ec02-4d4a-8964-a8ceabe5df2c	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407058921453	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	principal	t	\N	2026-10-22 18:21:12.723+00	2026-10-22 18:21:12.723+00	\N	\N
dee000f4-b543-4536-92d6-bcc9fe85e777	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407013303984	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	class_teacher	t	\N	2026-10-22 18:21:13.351+00	2026-10-22 18:21:13.351+00	\N	\N
fbb06551-4071-449c-8c96-75e861869c2f	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408015295216	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	class_teacher	t	\N	2026-10-22 18:21:13.367+00	2026-10-22 18:21:13.367+00	\N	\N
6dbbff6e-49ee-46d5-ae81-b554a2ffa021	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408078417128	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	class_teacher	t	\N	2026-10-22 18:21:13.377+00	2026-10-22 18:21:13.377+00	\N	\N
741733f7-5021-4079-be60-e8bb47d22858	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408031662214	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	class_teacher	t	\N	2026-10-22 18:21:13.384+00	2026-10-22 18:21:13.384+00	\N	\N
e4b19ccb-383e-4e83-a992-e0ca69bb131f	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409012133787	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	class_teacher	t	\N	2026-10-22 18:21:13.392+00	2026-10-22 18:21:13.392+00	\N	\N
565a5cbf-9870-4023-86a0-8da0090e3561	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409192073756	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	class_teacher	t	\N	2026-10-22 18:21:13.4+00	2026-10-22 18:21:13.4+00	\N	\N
17300738-7572-482e-82aa-2495bd41e648	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409183816136	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	class_teacher	t	\N	2026-10-22 18:21:13.408+00	2026-10-22 18:21:13.408+00	\N	\N
6f094c04-7d39-4258-93e1-76137a436f2d	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408060828601	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	class_teacher	t	\N	2026-10-22 18:21:13.415+00	2026-10-22 18:21:13.415+00	\N	\N
844c7dbc-cd40-4a18-b241-86a4b3677b31	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409041028053	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	class_teacher	t	\N	2026-10-22 18:21:13.423+00	2026-10-22 18:21:13.423+00	\N	\N
5e6837f8-db46-4b68-add2-833757b2d739	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409099719121	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	class_teacher	t	\N	2026-10-22 18:21:13.43+00	2026-10-22 18:21:13.43+00	\N	\N
10a6a239-9543-40a8-b087-3da5b9d37653	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408025396652	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	class_teacher	t	\N	2026-10-22 18:21:13.438+00	2026-10-22 18:21:13.438+00	\N	\N
e7ba8251-cacb-4475-b6ca-dd1a2cb33ecf	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407018160092	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	class_teacher	t	\N	2026-10-22 18:21:13.445+00	2026-10-22 18:21:13.445+00	\N	\N
aad8e336-0f97-455b-a8a1-60d498b10660	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409156775186	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.454+00	2026-10-22 18:21:13.454+00	\N	\N
77dde5e4-f6dc-4b0d-b9b7-86e04882a581	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408070481948	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.484+00	2026-10-22 18:21:13.484+00	\N	\N
ea5957d2-01c6-4310-bc83-a5fe5a0e3481	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407074940962	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.497+00	2026-10-22 18:21:13.497+00	\N	\N
49bad0ce-cfb7-4bc0-a935-ec1d52644a26	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408139513920	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.506+00	2026-10-22 18:21:13.506+00	\N	\N
5c1c4845-34c6-4f1f-b09f-798289ffd7ed	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409070586465	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.515+00	2026-10-22 18:21:13.515+00	\N	\N
dea5f580-3891-4f93-b2a8-4600f18b5ce3	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407085289894	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.524+00	2026-10-22 18:21:13.524+00	\N	\N
f760443b-e6e1-4b46-9ce2-819518e79e01	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408133391445	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.534+00	2026-10-22 18:21:13.534+00	\N	\N
88e1235b-525a-4de3-b736-59e2358e8c26	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409057957698	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.543+00	2026-10-22 18:21:13.543+00	\N	\N
3d947874-6e7c-4c93-a4ae-2577bb4b1aa8	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408116026861	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.678+00	2026-10-22 18:21:13.678+00	\N	\N
17328965-2214-4f67-bb82-10fb43f889d2	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409142112057	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.689+00	2026-10-22 18:21:13.689+00	\N	\N
5759fc0a-13f9-4746-b77c-b02e2d270bff	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409019753492	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.697+00	2026-10-22 18:21:13.697+00	\N	\N
883f13ed-07f6-468b-a102-ea14a3e72197	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408055726782	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.707+00	2026-10-22 18:21:13.707+00	\N	\N
241c59f2-1133-4b0c-9ebb-67993d4fdbad	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409144821421	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.716+00	2026-10-22 18:21:13.716+00	\N	\N
14a4c16a-5de5-46b7-892b-ddb8e93034c1	55473dfa-dd2b-41e5-b85e-8da87261fa12	+2348012345670	\N	\N	class_teacher	t	2026-10-25 16:42:25.98+00	2026-10-22 14:15:59.647+00	2026-10-25 16:42:25.984+00	\N	2026-10-25 16:42:25.98+00
d5db8f9c-7d19-4275-8de2-b37f699bb86d	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408131327167	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.727+00	2026-10-22 18:21:13.727+00	\N	\N
445b52e9-a455-433e-af3b-225c280bea0c	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409099576067	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.738+00	2026-10-22 18:21:13.738+00	\N	\N
2d85533b-fd2c-4476-91f2-29c1be7f6d13	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408081057541	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.748+00	2026-10-22 18:21:13.748+00	\N	\N
3307f59b-652a-41f0-8e0d-5f281395b31c	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408173626458	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.76+00	2026-10-22 18:21:13.76+00	\N	\N
992e8547-9e7d-4586-9ce8-d2ccf1143fc1	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408137052579	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.77+00	2026-10-22 18:21:13.77+00	\N	\N
11641544-c531-4373-816e-0c8da58df460	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409130584792	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.778+00	2026-10-22 18:21:13.778+00	\N	\N
95d4dfb1-42b6-4a58-a6a7-c08267433227	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407087352289	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.786+00	2026-10-22 18:21:13.786+00	\N	\N
fcd1ea4a-0f86-4b55-8c0c-e869fb942551	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408150242033	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.796+00	2026-10-22 18:21:13.796+00	\N	\N
3ac2adb7-0885-4170-be24-24c913c4eba0	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409182074191	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.805+00	2026-10-22 18:21:13.805+00	\N	\N
31322301-0cab-4aa7-91e0-eadcea50953e	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409027148206	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.814+00	2026-10-22 18:21:13.814+00	\N	\N
e618ca15-42dd-48cb-aedd-8ec6a8737587	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409017225917	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.823+00	2026-10-22 18:21:13.823+00	\N	\N
c99c894b-e73b-4d1a-82a6-3eb4bdb4b391	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408037735970	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.832+00	2026-10-22 18:21:13.832+00	\N	\N
36f1c917-b7c8-41af-b882-e512721eb03a	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409134224937	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.841+00	2026-10-22 18:21:13.841+00	\N	\N
5ca78764-ef26-477c-a7b1-f8560bdd1b44	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407040219606	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.849+00	2026-10-22 18:21:13.849+00	\N	\N
c159bdfe-e005-4833-a081-0f17bdb14879	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409046673917	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.859+00	2026-10-22 18:21:13.859+00	\N	\N
51b3e543-5fe6-4d6f-aeb2-f75f69a54edd	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409040059945	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.868+00	2026-10-22 18:21:13.868+00	\N	\N
e4d68a56-3d09-4563-b4b5-dd836578bf61	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407065395836	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.878+00	2026-10-22 18:21:13.878+00	\N	\N
c1ba7623-6bf4-4914-980e-214accfb7b74	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408119710872	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.887+00	2026-10-22 18:21:13.887+00	\N	\N
c66d3451-7764-4bc8-9759-27e162065915	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409137812763	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.896+00	2026-10-22 18:21:13.896+00	\N	\N
b68478d3-dee2-4ae7-b533-9278f8578d22	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407012576159	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.905+00	2026-10-22 18:21:13.905+00	\N	\N
f4cdae26-054e-4d16-acdc-a7b8f4993658	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409079452461	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.913+00	2026-10-22 18:21:13.913+00	\N	\N
096c813d-c689-4c5f-abf0-4a951fccdb43	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409168578341	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.924+00	2026-10-22 18:21:13.924+00	\N	\N
c586e2f7-f349-4670-8078-c50a618566d1	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408076091037	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.933+00	2026-10-22 18:21:13.933+00	\N	\N
ebb8d272-46e0-44ff-bf29-d9255f4b150e	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408012622605	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.941+00	2026-10-22 18:21:13.941+00	\N	\N
7a2598b8-7485-4785-b105-97f9a236e327	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408174288855	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.949+00	2026-10-22 18:21:13.949+00	\N	\N
098d35f4-5c42-47c5-8547-80c95b417d39	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408179073760	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.958+00	2026-10-22 18:21:13.958+00	\N	\N
c37f7aa2-496d-4121-b22d-72e872826dbe	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407099408160	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.966+00	2026-10-22 18:21:13.966+00	\N	\N
69d507e9-7d80-4da9-90fb-73938a151f72	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408058028607	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.976+00	2026-10-22 18:21:13.976+00	\N	\N
508f54b5-44b6-4fa4-8883-43d3084afeab	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409144498568	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.984+00	2026-10-22 18:21:13.984+00	\N	\N
35dfe57e-64e3-4539-8b1d-f553abebc52a	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409179053586	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:13.993+00	2026-10-22 18:21:13.993+00	\N	\N
1cda946b-b52c-4471-b7e0-31dfbde728de	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407054851720	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:14.002+00	2026-10-22 18:21:14.002+00	\N	\N
d9bf19ca-230d-4c13-a144-9c1b00c52709	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407031714522	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:14.01+00	2026-10-22 18:21:14.01+00	\N	\N
bef7a879-8956-45cd-a04a-130a6b87cbc7	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408050384780	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:14.018+00	2026-10-22 18:21:14.018+00	\N	\N
c91cbda9-63b3-46db-8bec-1629548fc6cb	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409052103521	\N	$2b$10$6.SI2BNxeiZMEQJICF/t0OXsB2UZhkusb02zp9h6zRYPfHOmpZEn6	student	t	\N	2026-10-22 18:21:14.028+00	2026-10-22 18:21:14.028+00	\N	\N
65a0cb8f-1488-4f19-8190-b6500ee8fdfa	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407092280984	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	class_teacher	t	\N	2026-10-22 18:24:39.535+00	2026-10-22 18:24:39.535+00	\N	\N
7c053256-f736-4196-83fd-f22f2ed779ae	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408069154792	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	class_teacher	t	\N	2026-10-22 18:24:39.559+00	2026-10-22 18:24:39.559+00	\N	\N
1214021f-048a-40fc-a2d0-9b004dfc63b6	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409147761647	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	class_teacher	t	\N	2026-10-22 18:24:39.568+00	2026-10-22 18:24:39.568+00	\N	\N
3966098a-becf-49ad-a80b-ab132e1f9b00	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409124805106	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	class_teacher	t	\N	2026-10-22 18:24:39.577+00	2026-10-22 18:24:39.577+00	\N	\N
ad9cdf94-a3ef-4c49-8375-7f992b5fa3c5	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407046336483	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	class_teacher	t	\N	2026-10-22 18:24:39.586+00	2026-10-22 18:24:39.586+00	\N	\N
78c42769-de2e-4876-987e-d7d4b414918a	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409054721146	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	class_teacher	t	\N	2026-10-22 18:24:39.597+00	2026-10-22 18:24:39.597+00	\N	\N
33c813aa-833b-433b-ac1c-d70ec8909c70	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409141967578	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	class_teacher	t	\N	2026-10-22 18:24:39.607+00	2026-10-22 18:24:39.607+00	\N	\N
03f3f031-0e58-476e-a03d-393f15a2c6e0	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409064324676	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	class_teacher	t	\N	2026-10-22 18:24:39.616+00	2026-10-22 18:24:39.616+00	\N	\N
f152b564-5b1e-48c5-943a-b1490f2508bb	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409020379352	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	class_teacher	t	\N	2026-10-22 18:24:39.625+00	2026-10-22 18:24:39.625+00	\N	\N
cc47794d-2985-49b6-8d55-80255ab42db8	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409054250655	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	class_teacher	t	\N	2026-10-22 18:24:39.634+00	2026-10-22 18:24:39.634+00	\N	\N
35a0f941-77a8-4739-90d9-ea2d34f1ae07	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409171219108	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	class_teacher	t	\N	2026-10-22 18:24:39.651+00	2026-10-22 18:24:39.651+00	\N	\N
3b873bbc-d322-467c-817f-926490ee4ec5	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408124151672	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:39.663+00	2026-10-22 18:24:39.663+00	\N	\N
ab5180b3-6247-40ce-abd5-9a626fc8392a	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408015617607	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:39.696+00	2026-10-22 18:24:39.696+00	\N	\N
dc4f1bfc-4afa-4881-81cc-8a621fd33812	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409027771203	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:39.712+00	2026-10-22 18:24:39.712+00	\N	\N
1fa895a8-680e-4259-93c4-3526cd5abfc5	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408116045366	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:39.727+00	2026-10-22 18:24:39.727+00	\N	\N
ee82baed-b7fc-4622-9628-500b70530151	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408158159491	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:39.739+00	2026-10-22 18:24:39.739+00	\N	\N
5175a3e7-f8b3-4810-be41-7089e2fe99c4	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409163009615	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:39.748+00	2026-10-22 18:24:39.748+00	\N	\N
729f34ff-eaff-41d9-96b6-9c8106c550e1	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408098100505	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:39.761+00	2026-10-22 18:24:39.761+00	\N	\N
6de493b1-36b2-4a0c-8c4b-73d252ead569	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409086513948	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:39.773+00	2026-10-22 18:24:39.773+00	\N	\N
1210beb7-7985-4607-a547-ef76a3c35fa8	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409197812171	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:39.783+00	2026-10-22 18:24:39.783+00	\N	\N
b39a7b59-65e3-4eef-a153-b19a59bcd9eb	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409134048273	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:39.793+00	2026-10-22 18:24:39.793+00	\N	\N
6dafc102-a345-42ec-9641-c13da641864f	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409193707436	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:39.803+00	2026-10-22 18:24:39.803+00	\N	\N
ee7718b0-6f2e-4a62-86a1-072faad97668	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409149632475	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:39.815+00	2026-10-22 18:24:39.815+00	\N	\N
83535c63-cf01-466e-b6f0-3ae62a8dd768	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407055129438	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:39.826+00	2026-10-22 18:24:39.826+00	\N	\N
8d7edd1e-a372-4089-9084-38b28b0c97d4	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407042108445	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:39.835+00	2026-10-22 18:24:39.835+00	\N	\N
6f544747-2c1b-4d6c-931b-38fca3eb8ea9	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409173633786	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:39.844+00	2026-10-22 18:24:39.844+00	\N	\N
87d28201-f52e-4a7e-8bcf-bb8a4eeee1e3	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407057965473	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:39.855+00	2026-10-22 18:24:39.855+00	\N	\N
b261fdfe-baa5-4f58-9a7e-8d19ae53d472	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409174282660	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:39.865+00	2026-10-22 18:24:39.865+00	\N	\N
d4ad1bae-fcd6-49d1-b44c-bd111759d431	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407034414153	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:39.875+00	2026-10-22 18:24:39.875+00	\N	\N
5b7b699f-a1eb-4b90-bf2e-c0902c5f65ca	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408086402392	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:39.883+00	2026-10-22 18:24:39.883+00	\N	\N
1e33c060-076f-42bf-884e-288a14a71e65	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408142305389	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:39.894+00	2026-10-22 18:24:39.894+00	\N	\N
f4ec90d6-9f80-4bea-a8e0-846efaeae356	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408171613819	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:39.903+00	2026-10-22 18:24:39.903+00	\N	\N
046d5f41-8e19-4c37-a3a8-d555172439b4	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409129808601	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:39.913+00	2026-10-22 18:24:39.913+00	\N	\N
e4e95e69-ab65-4219-91de-bc70c52c9b53	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408175887879	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:39.921+00	2026-10-22 18:24:39.921+00	\N	\N
27d4899b-40db-4710-9555-c4e3ce833bf9	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407081501468	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:39.93+00	2026-10-22 18:24:39.93+00	\N	\N
514c0219-dcb3-4a67-9d0d-03e28e1c3155	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408122258705	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:39.939+00	2026-10-22 18:24:39.939+00	\N	\N
0808b295-f4e3-4076-9a19-70108116fabc	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407069766950	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:39.948+00	2026-10-22 18:24:39.948+00	\N	\N
7ffe7056-658d-40ed-a017-3c2cd94c7005	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408140960314	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:39.958+00	2026-10-22 18:24:39.958+00	\N	\N
65cdbd03-b690-4152-822e-e8ce2617d130	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408133872081	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:39.968+00	2026-10-22 18:24:39.968+00	\N	\N
c8459b52-fac9-435c-a9f7-3994230df9d6	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409195463154	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:39.976+00	2026-10-22 18:24:39.976+00	\N	\N
924c628a-943e-43b5-8035-e3c778867798	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408049513592	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:39.987+00	2026-10-22 18:24:39.987+00	\N	\N
4bbdf05c-d1e8-4275-b820-3e6700e1be13	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408199485537	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:39.995+00	2026-10-22 18:24:39.995+00	\N	\N
44ccc5f9-2573-4f14-9d46-3c6c8c823c26	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409116512287	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:40.004+00	2026-10-22 18:24:40.004+00	\N	\N
7c74ecee-861d-4108-a8dd-76c7da19b495	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408075683134	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:40.016+00	2026-10-22 18:24:40.016+00	\N	\N
11dab51e-50d9-43e7-a01a-e7c911a49e07	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407035758332	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:40.025+00	2026-10-22 18:24:40.025+00	\N	\N
3f3fb184-b778-495b-a2d5-eff69280c276	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409040166367	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:40.033+00	2026-10-22 18:24:40.033+00	\N	\N
10ac4ba7-7180-48f2-bb9c-3b7316c829d4	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409036058120	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:40.041+00	2026-10-22 18:24:40.041+00	\N	\N
bb163cd9-f0bd-4590-9a64-8d096191f938	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408187107462	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:40.051+00	2026-10-22 18:24:40.051+00	\N	\N
943b4382-975a-4328-a60d-ba7c538bfaf8	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407091932126	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:40.059+00	2026-10-22 18:24:40.059+00	\N	\N
3fe1f1f6-dfe1-45f8-973a-646069b543f0	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409056430874	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:40.068+00	2026-10-22 18:24:40.068+00	\N	\N
e09c23b0-061a-436e-a25b-c97230325eaf	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407059309677	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:40.077+00	2026-10-22 18:24:40.077+00	\N	\N
170e8a11-6347-4a98-ae35-c8d6aaa07b09	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409129259878	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:40.087+00	2026-10-22 18:24:40.087+00	\N	\N
4c2c010d-0f31-4ffc-befd-210adfa048b5	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408035011947	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:40.097+00	2026-10-22 18:24:40.097+00	\N	\N
ae5cd631-5635-4fb4-b726-e1e7f7d8e74b	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409177812783	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:40.107+00	2026-10-22 18:24:40.107+00	\N	\N
b6787477-9e5a-4b79-8bc8-2f2a18d60d2f	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408156722847	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:40.117+00	2026-10-22 18:24:40.117+00	\N	\N
796003b2-d82c-4e12-ba59-1fe4650e4567	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407095695062	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:40.125+00	2026-10-22 18:24:40.125+00	\N	\N
a1b6ca71-d7ef-4648-ab38-b7c90505636a	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408175074108	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:40.134+00	2026-10-22 18:24:40.134+00	\N	\N
b4f62b39-d6eb-43f4-9992-bf9a2e88c3d6	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407079151674	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:40.144+00	2026-10-22 18:24:40.144+00	\N	\N
41d9d507-1bde-4b16-98c8-d84535e117fd	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408159248784	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:40.155+00	2026-10-22 18:24:40.155+00	\N	\N
803c4f49-5b15-4e59-8b43-81767c6252c0	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409053158542	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:40.166+00	2026-10-22 18:24:40.166+00	\N	\N
a16b32a1-49c8-49fb-be26-bc78879f7479	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408048304723	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:40.175+00	2026-10-22 18:24:40.175+00	\N	\N
5d06fd22-088e-4206-bb54-c82de66844a1	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408085065836	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:40.185+00	2026-10-22 18:24:40.185+00	\N	\N
1e0116f0-47c4-48e5-9553-087338a0177a	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408049398730	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:40.196+00	2026-10-22 18:24:40.196+00	\N	\N
757d3183-addb-43db-bf9a-b7e57a01d62c	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407092883949	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:40.205+00	2026-10-22 18:24:40.205+00	\N	\N
4dc1f692-f5f0-4e19-bafd-790edaf72efc	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407072454077	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:40.218+00	2026-10-22 18:24:40.218+00	\N	\N
d341e9a4-4365-49b4-b1a3-898f45b8c569	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409099944196	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:40.227+00	2026-10-22 18:24:40.227+00	\N	\N
c17ae35d-dd66-47ea-8e4e-a58545a2f0d5	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407056826954	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:40.237+00	2026-10-22 18:24:40.237+00	\N	\N
1fd891a8-26fd-4c48-8ad3-dd4242e1b4c0	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409012427482	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:40.247+00	2026-10-22 18:24:40.247+00	\N	\N
8e7c146f-05e6-47c2-bce9-edc8c9cf409c	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408097066251	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:40.256+00	2026-10-22 18:24:40.256+00	\N	\N
8c4f8d74-7c46-4e3c-a589-ab734a6a5af5	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408117984095	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:40.265+00	2026-10-22 18:24:40.265+00	\N	\N
7575905a-993f-4f33-ad0c-2c560a8b6c3e	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409112843293	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	student	t	\N	2026-10-22 18:24:40.274+00	2026-10-22 18:24:40.274+00	\N	\N
fe2d1530-d0bb-4b19-b6dc-bcdb24767441	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409197671833	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	class_teacher	t	\N	2026-10-22 19:00:35.022+00	2026-10-22 19:00:35.022+00	\N	\N
4939bac3-b189-46d7-830b-a6525df07835	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409025427713	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	class_teacher	t	\N	2026-10-22 19:00:35.046+00	2026-10-22 19:00:35.046+00	\N	\N
27a2fae4-1893-467c-8647-a9348633f9bf	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408187193239	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	class_teacher	t	\N	2026-10-22 19:00:35.054+00	2026-10-22 19:00:35.054+00	\N	\N
27579cdd-3d18-48bf-b2df-949e93b3866f	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409118735785	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	class_teacher	t	\N	2026-10-22 19:00:35.064+00	2026-10-22 19:00:35.064+00	\N	\N
64b07ad1-01c0-44a0-8413-de8dd0e56360	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409161401645	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	class_teacher	t	\N	2026-10-22 19:00:35.073+00	2026-10-22 19:00:35.073+00	\N	\N
4fcf0f32-401d-4fc7-bf9f-99e758845448	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409021839197	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	class_teacher	t	\N	2026-10-22 19:00:35.081+00	2026-10-22 19:00:35.081+00	\N	\N
1eeef1e7-ee63-4acf-8019-d992404e9276	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408082988330	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	class_teacher	t	\N	2026-10-22 19:00:35.089+00	2026-10-22 19:00:35.089+00	\N	\N
f5c4678e-f528-42e1-8ea3-37c2b81773f3	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409050346068	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	class_teacher	t	\N	2026-10-22 19:00:35.097+00	2026-10-22 19:00:35.097+00	\N	\N
f7bd5e64-7722-4ba6-aee4-8f8043db61f6	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408096577142	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	class_teacher	t	\N	2026-10-22 19:00:35.105+00	2026-10-22 19:00:35.105+00	\N	\N
29e633bf-f16b-4f98-9cb3-6fd2f5b4896e	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409198141902	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	class_teacher	t	\N	2026-10-22 19:00:35.114+00	2026-10-22 19:00:35.114+00	\N	\N
4cda0a07-802c-463e-a6c6-f8073f3affcf	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408188288598	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	class_teacher	t	\N	2026-10-22 19:00:35.122+00	2026-10-22 19:00:35.122+00	\N	\N
0ba0f2f7-5f68-41d3-9e27-1b852652900b	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409164223731	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	class_teacher	t	\N	2026-10-22 19:00:35.13+00	2026-10-22 19:00:35.13+00	\N	\N
600e0d9f-c1d2-4929-b345-7895c21b69f6	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409123045011	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.138+00	2026-10-22 19:00:35.138+00	\N	\N
a83cd36f-9f9c-489a-8d4b-acafc6c0c3f3	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408135869082	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.168+00	2026-10-22 19:00:35.168+00	\N	\N
e6e468a5-6fa9-48be-952b-23dfad7ab312	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409176572485	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.183+00	2026-10-22 19:00:35.183+00	\N	\N
07ecb076-9745-47aa-8511-b88c92f0ff78	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407088377401	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.199+00	2026-10-22 19:00:35.199+00	\N	\N
cf5c08c6-ddcf-418b-a425-25439dd68a95	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409162940844	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.217+00	2026-10-22 19:00:35.217+00	\N	\N
e0d7749e-0c46-434f-bd66-1d72c543a3ff	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407093263633	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.228+00	2026-10-22 19:00:35.228+00	\N	\N
be3dbb51-1c36-4c99-8f5b-7d5bf0814ad0	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408152122376	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.239+00	2026-10-22 19:00:35.239+00	\N	\N
12d3be15-a634-4cf5-bcb7-86edbe52b781	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408117028348	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.249+00	2026-10-22 19:00:35.249+00	\N	\N
f1e9d640-6ef7-4287-b16a-6e6158594675	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409038474497	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.259+00	2026-10-22 19:00:35.259+00	\N	\N
968a4f9f-3c97-4f5f-bb69-d62d17e0b62f	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409150229062	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.267+00	2026-10-22 19:00:35.267+00	\N	\N
2b0ec281-baca-40e8-8666-92caec27305e	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408182167794	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.276+00	2026-10-22 19:00:35.276+00	\N	\N
78160c7e-a545-4b25-8c64-5dfe6e697d57	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408165196187	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.284+00	2026-10-22 19:00:35.284+00	\N	\N
35b1ae1f-4f49-4a3b-9f9b-c1f6b3128343	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409157091353	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.296+00	2026-10-22 19:00:35.296+00	\N	\N
98d4d62c-952b-4573-a160-4219a66665fe	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408053077412	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.305+00	2026-10-22 19:00:35.305+00	\N	\N
68cb443a-baba-4f43-9026-73ec79c81ce0	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409130126710	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.314+00	2026-10-22 19:00:35.314+00	\N	\N
ee4ce6f0-9b9e-4126-93c0-d08205d8f5c9	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408056138632	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.324+00	2026-10-22 19:00:35.324+00	\N	\N
16a9cc6c-c722-4064-9c24-74b7dd662a1d	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408059242578	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.332+00	2026-10-22 19:00:35.332+00	\N	\N
9e851bb4-bf5a-4984-8950-2af4c43c6c89	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407013853755	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.342+00	2026-10-22 19:00:35.342+00	\N	\N
f1bd1ced-78cc-45c2-b199-e56853650e07	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407087219163	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.351+00	2026-10-22 19:00:35.351+00	\N	\N
21792720-d445-4048-80a3-93daa6b66e96	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408149836274	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.361+00	2026-10-22 19:00:35.361+00	\N	\N
c308fc92-fed2-4512-83e1-5059a2c0bce3	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409156035119	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.369+00	2026-10-22 19:00:35.369+00	\N	\N
a7373ccb-a0cd-4e7f-80fc-1c85d91b7841	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409171055478	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.379+00	2026-10-22 19:00:35.379+00	\N	\N
6003e883-600d-465a-96bf-6cd311c1650e	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409114584218	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.388+00	2026-10-22 19:00:35.388+00	\N	\N
9b8ec8a8-5e14-436b-a7e4-b219c7e71d44	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409162601373	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.397+00	2026-10-22 19:00:35.397+00	\N	\N
086f440f-10d6-4044-9012-237e99190513	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407013324287	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.405+00	2026-10-22 19:00:35.405+00	\N	\N
86e2ce1f-b661-4435-8bed-a6e09eba138a	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407079739197	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.414+00	2026-10-22 19:00:35.414+00	\N	\N
176584de-366b-4735-a2cb-fe0a2e141810	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409129628997	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.423+00	2026-10-22 19:00:35.423+00	\N	\N
1942d9ea-332f-4caf-b995-72a8144ba3e2	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408168173448	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.433+00	2026-10-22 19:00:35.433+00	\N	\N
e00ca26b-ac4f-485a-a91d-5ad311718d04	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409150309356	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.442+00	2026-10-22 19:00:35.442+00	\N	\N
acb703df-efe8-4ec8-a906-218820edcbf0	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409117221258	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.451+00	2026-10-22 19:00:35.451+00	\N	\N
4dda43ea-2e5c-4b7d-bcbe-0cfc3670035d	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409094308643	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.461+00	2026-10-22 19:00:35.461+00	\N	\N
ee42e381-1f68-467f-b212-864233c71ea8	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408030591549	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.474+00	2026-10-22 19:00:35.474+00	\N	\N
89d89c7b-75b7-44fe-a9d8-e994ea3ca405	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408184226793	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.486+00	2026-10-22 19:00:35.486+00	\N	\N
6fc9eb2b-3b06-40e4-8b8b-07de79190d26	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409149370237	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.497+00	2026-10-22 19:00:35.497+00	\N	\N
23545366-b123-4601-a0f7-16bbb7f49fd1	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407055768665	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.507+00	2026-10-22 19:00:35.507+00	\N	\N
b8f4c056-b0d6-45de-aee7-b6aa6292b578	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408083056250	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.515+00	2026-10-22 19:00:35.515+00	\N	\N
ae46bc75-2ea3-41fe-bb36-ded6771b8890	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408091989811	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.529+00	2026-10-22 19:00:35.529+00	\N	\N
0079341e-58e2-4ecb-a546-795310743822	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409128320999	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.539+00	2026-10-22 19:00:35.539+00	\N	\N
61da38a3-b27f-4e51-aee2-a8646e822c57	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409098946300	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.548+00	2026-10-22 19:00:35.548+00	\N	\N
43671990-7340-4a84-9be9-9de076c112f8	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408013905258	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.556+00	2026-10-22 19:00:35.556+00	\N	\N
e1b46db1-6a65-493d-820f-457604775cd8	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408120278390	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.569+00	2026-10-22 19:00:35.569+00	\N	\N
2f7e1683-5edc-4494-9326-2ebd4def599c	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409126879555	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.579+00	2026-10-22 19:00:35.579+00	\N	\N
bbab68dc-c9f3-45b3-8717-9ee2a3e3fd22	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409182604814	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.588+00	2026-10-22 19:00:35.588+00	\N	\N
6f9eb978-e41a-4b48-98e4-9f3556a9134a	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407041131447	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.599+00	2026-10-22 19:00:35.599+00	\N	\N
0d7bb570-bf0b-480b-b97a-45b37dcf6363	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407067464679	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.608+00	2026-10-22 19:00:35.608+00	\N	\N
cff676c7-7dbd-48db-a6f6-6e0f7e21bdc6	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409166783055	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.619+00	2026-10-22 19:00:35.619+00	\N	\N
5f513577-f6fa-463d-95c2-38db4be6d716	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408148256401	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.63+00	2026-10-22 19:00:35.63+00	\N	\N
f14cd1e4-b9f8-495a-be2b-859da6c4a6d7	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409060946440	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.639+00	2026-10-22 19:00:35.639+00	\N	\N
18119dff-c76c-454a-8b3f-d1c61e244318	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408046203307	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.648+00	2026-10-22 19:00:35.648+00	\N	\N
f150d1cd-f81d-4144-a9a2-dc056c644f3a	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23407029033289	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.657+00	2026-10-22 19:00:35.657+00	\N	\N
39d47941-3c02-44f2-9093-eb842fc66d12	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409167947086	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.668+00	2026-10-22 19:00:35.668+00	\N	\N
6709dff1-4957-4053-abb0-2c558e7e591a	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409110148511	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.676+00	2026-10-22 19:00:35.676+00	\N	\N
799744f7-aff1-4d62-8e83-e590378f3879	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409053832197	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.686+00	2026-10-22 19:00:35.686+00	\N	\N
669e57eb-5cbb-4cd5-9c29-20a3b2eecaa5	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409193907119	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.696+00	2026-10-22 19:00:35.696+00	\N	\N
f2b328b5-e026-49c0-8d33-eb9f3d8404a0	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409182533634	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.704+00	2026-10-22 19:00:35.704+00	\N	\N
3cd18d61-0207-43de-8145-c99f61d2e0f7	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409115958744	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.714+00	2026-10-22 19:00:35.714+00	\N	\N
90df74e7-9f9e-4ec9-8a71-f598a4ea17f5	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409067176202	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.724+00	2026-10-22 19:00:35.724+00	\N	\N
e4486b73-e450-4693-8dec-a0176f4a0cc5	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409092717012	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.733+00	2026-10-22 19:00:35.733+00	\N	\N
0ad59d65-a045-4d3a-91d4-74842750532b	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409156552497	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.742+00	2026-10-22 19:00:35.742+00	\N	\N
2d2c0d72-21bd-4909-9639-c55969f41dc9	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23409178583967	\N	$2b$10$HoMPVQujavTXjZAWKAdPg.YmzNvgsaXRCjsmwHQGlxpTta97sfbV6	student	t	\N	2026-10-22 19:00:35.751+00	2026-10-22 19:00:35.751+00	\N	\N
0a286dce-6248-4e54-a6a9-adf58d6c6f79	55473dfa-dd2b-41e5-b85e-8da87261fa12	+23408173922471	\N	$2b$10$2ubY39y7LqkrbmausMjJw.HKo24NlJQX3gjVOr1DmbMwUr.2Wh/uu	class_teacher	t	\N	2026-10-22 18:24:39.642+00	2026-10-25 09:54:15.978+00	\N	\N
\.


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: announcements announcements_pkey; Type: CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_pkey PRIMARY KEY (id);


--
-- Name: assessments assessments_pkey; Type: CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.assessments
    ADD CONSTRAINT assessments_pkey PRIMARY KEY (id);


--
-- Name: attendance attendance_pkey; Type: CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_pkey PRIMARY KEY (id);


--
-- Name: bursary_approvals bursary_approvals_pkey; Type: CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.bursary_approvals
    ADD CONSTRAINT bursary_approvals_pkey PRIMARY KEY (id);


--
-- Name: class_enrollments class_enrollments_pkey; Type: CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.class_enrollments
    ADD CONSTRAINT class_enrollments_pkey PRIMARY KEY (id);


--
-- Name: classes classes_pkey; Type: CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_pkey PRIMARY KEY (id);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: expense_records expense_records_pkey; Type: CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.expense_records
    ADD CONSTRAINT expense_records_pkey PRIMARY KEY (id);


--
-- Name: fee_structures fee_structures_pkey; Type: CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.fee_structures
    ADD CONSTRAINT fee_structures_pkey PRIMARY KEY (id);


--
-- Name: leave_requests leave_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.leave_requests
    ADD CONSTRAINT leave_requests_pkey PRIMARY KEY (id);


--
-- Name: message_threads message_threads_pkey; Type: CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.message_threads
    ADD CONSTRAINT message_threads_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: otp_codes otp_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.otp_codes
    ADD CONSTRAINT otp_codes_pkey PRIMARY KEY (id);


--
-- Name: parent_student parent_student_pkey; Type: CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.parent_student
    ADD CONSTRAINT parent_student_pkey PRIMARY KEY (id);


--
-- Name: parents parents_pkey; Type: CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.parents
    ADD CONSTRAINT parents_pkey PRIMARY KEY (id);


--
-- Name: payment_receipts payment_receipts_pkey; Type: CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.payment_receipts
    ADD CONSTRAINT payment_receipts_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: push_tokens push_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.push_tokens
    ADD CONSTRAINT push_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: report_cards report_cards_pkey; Type: CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.report_cards
    ADD CONSTRAINT report_cards_pkey PRIMARY KEY (id);


--
-- Name: schools schools_pkey; Type: CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.schools
    ADD CONSTRAINT schools_pkey PRIMARY KEY (id);


--
-- Name: scores scores_pkey; Type: CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.scores
    ADD CONSTRAINT scores_pkey PRIMARY KEY (id);


--
-- Name: staff staff_pkey; Type: CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_pkey PRIMARY KEY (id);


--
-- Name: student_fee_ledger student_fee_ledger_pkey; Type: CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.student_fee_ledger
    ADD CONSTRAINT student_fee_ledger_pkey PRIMARY KEY (id);


--
-- Name: students students_pkey; Type: CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (id);


--
-- Name: subjects subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_pkey PRIMARY KEY (id);


--
-- Name: timetable_periods timetable_periods_pkey; Type: CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.timetable_periods
    ADD CONSTRAINT timetable_periods_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: announcements_school_id_created_at_idx; Type: INDEX; Schema: public; Owner: school_user
--

CREATE INDEX announcements_school_id_created_at_idx ON public.announcements USING btree (school_id, created_at DESC);


--
-- Name: assessments_subject_id_idx; Type: INDEX; Schema: public; Owner: school_user
--

CREATE INDEX assessments_subject_id_idx ON public.assessments USING btree (subject_id);


--
-- Name: attendance_class_id_date_idx; Type: INDEX; Schema: public; Owner: school_user
--

CREATE INDEX attendance_class_id_date_idx ON public.attendance USING btree (class_id, date);


--
-- Name: attendance_student_id_date_key; Type: INDEX; Schema: public; Owner: school_user
--

CREATE UNIQUE INDEX attendance_student_id_date_key ON public.attendance USING btree (student_id, date);


--
-- Name: attendance_student_id_idx; Type: INDEX; Schema: public; Owner: school_user
--

CREATE INDEX attendance_student_id_idx ON public.attendance USING btree (student_id);


--
-- Name: class_enrollments_class_id_idx; Type: INDEX; Schema: public; Owner: school_user
--

CREATE INDEX class_enrollments_class_id_idx ON public.class_enrollments USING btree (class_id);


--
-- Name: class_enrollments_class_id_student_id_key; Type: INDEX; Schema: public; Owner: school_user
--

CREATE UNIQUE INDEX class_enrollments_class_id_student_id_key ON public.class_enrollments USING btree (class_id, student_id);


--
-- Name: class_enrollments_student_id_idx; Type: INDEX; Schema: public; Owner: school_user
--

CREATE INDEX class_enrollments_student_id_idx ON public.class_enrollments USING btree (student_id);


--
-- Name: classes_school_id_idx; Type: INDEX; Schema: public; Owner: school_user
--

CREATE INDEX classes_school_id_idx ON public.classes USING btree (school_id);


--
-- Name: classes_school_id_name_arm_academic_year_term_key; Type: INDEX; Schema: public; Owner: school_user
--

CREATE UNIQUE INDEX classes_school_id_name_arm_academic_year_term_key ON public.classes USING btree (school_id, name, arm, academic_year, term);


--
-- Name: documents_student_id_idx; Type: INDEX; Schema: public; Owner: school_user
--

CREATE INDEX documents_student_id_idx ON public.documents USING btree (student_id);


--
-- Name: expense_records_school_id_date_idx; Type: INDEX; Schema: public; Owner: school_user
--

CREATE INDEX expense_records_school_id_date_idx ON public.expense_records USING btree (school_id, date);


--
-- Name: fee_structures_class_id_term_academic_year_key; Type: INDEX; Schema: public; Owner: school_user
--

CREATE UNIQUE INDEX fee_structures_class_id_term_academic_year_key ON public.fee_structures USING btree (class_id, term, academic_year);


--
-- Name: fee_structures_school_id_idx; Type: INDEX; Schema: public; Owner: school_user
--

CREATE INDEX fee_structures_school_id_idx ON public.fee_structures USING btree (school_id);


--
-- Name: leave_requests_school_id_status_idx; Type: INDEX; Schema: public; Owner: school_user
--

CREATE INDEX leave_requests_school_id_status_idx ON public.leave_requests USING btree (school_id, status);


--
-- Name: message_threads_parent_id_idx; Type: INDEX; Schema: public; Owner: school_user
--

CREATE INDEX message_threads_parent_id_idx ON public.message_threads USING btree (parent_id);


--
-- Name: message_threads_parent_id_teacher_id_student_id_key; Type: INDEX; Schema: public; Owner: school_user
--

CREATE UNIQUE INDEX message_threads_parent_id_teacher_id_student_id_key ON public.message_threads USING btree (parent_id, teacher_id, student_id);


--
-- Name: message_threads_teacher_id_idx; Type: INDEX; Schema: public; Owner: school_user
--

CREATE INDEX message_threads_teacher_id_idx ON public.message_threads USING btree (teacher_id);


--
-- Name: messages_thread_id_sent_at_idx; Type: INDEX; Schema: public; Owner: school_user
--

CREATE INDEX messages_thread_id_sent_at_idx ON public.messages USING btree (thread_id, sent_at DESC);


--
-- Name: notifications_user_id_is_read_created_at_idx; Type: INDEX; Schema: public; Owner: school_user
--

CREATE INDEX notifications_user_id_is_read_created_at_idx ON public.notifications USING btree (user_id, is_read, created_at DESC);


--
-- Name: otp_codes_phone_is_used_expires_at_idx; Type: INDEX; Schema: public; Owner: school_user
--

CREATE INDEX otp_codes_phone_is_used_expires_at_idx ON public.otp_codes USING btree (phone, is_used, expires_at);


--
-- Name: parent_student_parent_id_student_id_key; Type: INDEX; Schema: public; Owner: school_user
--

CREATE UNIQUE INDEX parent_student_parent_id_student_id_key ON public.parent_student USING btree (parent_id, student_id);


--
-- Name: parent_student_student_id_idx; Type: INDEX; Schema: public; Owner: school_user
--

CREATE INDEX parent_student_student_id_idx ON public.parent_student USING btree (student_id);


--
-- Name: parents_school_id_idx; Type: INDEX; Schema: public; Owner: school_user
--

CREATE INDEX parents_school_id_idx ON public.parents USING btree (school_id);


--
-- Name: parents_user_id_key; Type: INDEX; Schema: public; Owner: school_user
--

CREATE UNIQUE INDEX parents_user_id_key ON public.parents USING btree (user_id);


--
-- Name: payment_receipts_payment_id_key; Type: INDEX; Schema: public; Owner: school_user
--

CREATE UNIQUE INDEX payment_receipts_payment_id_key ON public.payment_receipts USING btree (payment_id);


--
-- Name: payments_paystack_reference_idx; Type: INDEX; Schema: public; Owner: school_user
--

CREATE INDEX payments_paystack_reference_idx ON public.payments USING btree (paystack_reference);


--
-- Name: payments_paystack_reference_key; Type: INDEX; Schema: public; Owner: school_user
--

CREATE UNIQUE INDEX payments_paystack_reference_key ON public.payments USING btree (paystack_reference);


--
-- Name: payments_school_id_idx; Type: INDEX; Schema: public; Owner: school_user
--

CREATE INDEX payments_school_id_idx ON public.payments USING btree (school_id);


--
-- Name: payments_status_idx; Type: INDEX; Schema: public; Owner: school_user
--

CREATE INDEX payments_status_idx ON public.payments USING btree (status);


--
-- Name: payments_student_id_idx; Type: INDEX; Schema: public; Owner: school_user
--

CREATE INDEX payments_student_id_idx ON public.payments USING btree (student_id);


--
-- Name: push_tokens_token_key; Type: INDEX; Schema: public; Owner: school_user
--

CREATE UNIQUE INDEX push_tokens_token_key ON public.push_tokens USING btree (token);


--
-- Name: push_tokens_user_id_idx; Type: INDEX; Schema: public; Owner: school_user
--

CREATE INDEX push_tokens_user_id_idx ON public.push_tokens USING btree (user_id);


--
-- Name: refresh_tokens_token_hash_key; Type: INDEX; Schema: public; Owner: school_user
--

CREATE UNIQUE INDEX refresh_tokens_token_hash_key ON public.refresh_tokens USING btree (token_hash);


--
-- Name: refresh_tokens_user_id_idx; Type: INDEX; Schema: public; Owner: school_user
--

CREATE INDEX refresh_tokens_user_id_idx ON public.refresh_tokens USING btree (user_id);


--
-- Name: report_cards_student_id_idx; Type: INDEX; Schema: public; Owner: school_user
--

CREATE INDEX report_cards_student_id_idx ON public.report_cards USING btree (student_id);


--
-- Name: report_cards_student_id_term_academic_year_key; Type: INDEX; Schema: public; Owner: school_user
--

CREATE UNIQUE INDEX report_cards_student_id_term_academic_year_key ON public.report_cards USING btree (student_id, term, academic_year);


--
-- Name: schools_name_idx; Type: INDEX; Schema: public; Owner: school_user
--

CREATE INDEX schools_name_idx ON public.schools USING btree (name);


--
-- Name: schools_school_code_key; Type: INDEX; Schema: public; Owner: school_user
--

CREATE UNIQUE INDEX schools_school_code_key ON public.schools USING btree (school_code);


--
-- Name: scores_assessment_id_idx; Type: INDEX; Schema: public; Owner: school_user
--

CREATE INDEX scores_assessment_id_idx ON public.scores USING btree (assessment_id);


--
-- Name: scores_assessment_id_student_id_key; Type: INDEX; Schema: public; Owner: school_user
--

CREATE UNIQUE INDEX scores_assessment_id_student_id_key ON public.scores USING btree (assessment_id, student_id);


--
-- Name: scores_student_id_idx; Type: INDEX; Schema: public; Owner: school_user
--

CREATE INDEX scores_student_id_idx ON public.scores USING btree (student_id);


--
-- Name: staff_school_id_idx; Type: INDEX; Schema: public; Owner: school_user
--

CREATE INDEX staff_school_id_idx ON public.staff USING btree (school_id);


--
-- Name: staff_user_id_key; Type: INDEX; Schema: public; Owner: school_user
--

CREATE UNIQUE INDEX staff_user_id_key ON public.staff USING btree (user_id);


--
-- Name: student_fee_ledger_student_id_idx; Type: INDEX; Schema: public; Owner: school_user
--

CREATE INDEX student_fee_ledger_student_id_idx ON public.student_fee_ledger USING btree (student_id);


--
-- Name: student_fee_ledger_student_id_term_academic_year_key; Type: INDEX; Schema: public; Owner: school_user
--

CREATE UNIQUE INDEX student_fee_ledger_student_id_term_academic_year_key ON public.student_fee_ledger USING btree (student_id, term, academic_year);


--
-- Name: students_class_id_idx; Type: INDEX; Schema: public; Owner: school_user
--

CREATE INDEX students_class_id_idx ON public.students USING btree (class_id);


--
-- Name: students_school_id_admission_number_key; Type: INDEX; Schema: public; Owner: school_user
--

CREATE UNIQUE INDEX students_school_id_admission_number_key ON public.students USING btree (school_id, admission_number);


--
-- Name: students_school_id_idx; Type: INDEX; Schema: public; Owner: school_user
--

CREATE INDEX students_school_id_idx ON public.students USING btree (school_id);


--
-- Name: students_user_id_key; Type: INDEX; Schema: public; Owner: school_user
--

CREATE UNIQUE INDEX students_user_id_key ON public.students USING btree (user_id);


--
-- Name: subjects_class_id_idx; Type: INDEX; Schema: public; Owner: school_user
--

CREATE INDEX subjects_class_id_idx ON public.subjects USING btree (class_id);


--
-- Name: subjects_class_id_name_key; Type: INDEX; Schema: public; Owner: school_user
--

CREATE UNIQUE INDEX subjects_class_id_name_key ON public.subjects USING btree (class_id, name);


--
-- Name: subjects_teacher_id_idx; Type: INDEX; Schema: public; Owner: school_user
--

CREATE INDEX subjects_teacher_id_idx ON public.subjects USING btree (teacher_id);


--
-- Name: users_email_key; Type: INDEX; Schema: public; Owner: school_user
--

CREATE UNIQUE INDEX users_email_key ON public.users USING btree (email);


--
-- Name: users_phone_idx; Type: INDEX; Schema: public; Owner: school_user
--

CREATE INDEX users_phone_idx ON public.users USING btree (phone);


--
-- Name: users_phone_key; Type: INDEX; Schema: public; Owner: school_user
--

CREATE UNIQUE INDEX users_phone_key ON public.users USING btree (phone);


--
-- Name: users_school_id_idx; Type: INDEX; Schema: public; Owner: school_user
--

CREATE INDEX users_school_id_idx ON public.users USING btree (school_id);


--
-- Name: announcements announcements_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: announcements announcements_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: announcements announcements_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: assessments assessments_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.assessments
    ADD CONSTRAINT assessments_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: assessments assessments_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.assessments
    ADD CONSTRAINT assessments_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: attendance attendance_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: attendance attendance_recorded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_recorded_by_fkey FOREIGN KEY (recorded_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: attendance attendance_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bursary_approvals bursary_approvals_approved_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.bursary_approvals
    ADD CONSTRAINT bursary_approvals_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: bursary_approvals bursary_approvals_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.bursary_approvals
    ADD CONSTRAINT bursary_approvals_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bursary_approvals bursary_approvals_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.bursary_approvals
    ADD CONSTRAINT bursary_approvals_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: class_enrollments class_enrollments_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.class_enrollments
    ADD CONSTRAINT class_enrollments_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: class_enrollments class_enrollments_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.class_enrollments
    ADD CONSTRAINT class_enrollments_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: classes classes_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: classes classes_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.staff(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: documents documents_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: documents documents_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: documents documents_uploaded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: expense_records expense_records_recorded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.expense_records
    ADD CONSTRAINT expense_records_recorded_by_fkey FOREIGN KEY (recorded_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: expense_records expense_records_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.expense_records
    ADD CONSTRAINT expense_records_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fee_structures fee_structures_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.fee_structures
    ADD CONSTRAINT fee_structures_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fee_structures fee_structures_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.fee_structures
    ADD CONSTRAINT fee_structures_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: leave_requests leave_requests_decided_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.leave_requests
    ADD CONSTRAINT leave_requests_decided_by_fkey FOREIGN KEY (decided_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: leave_requests leave_requests_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.leave_requests
    ADD CONSTRAINT leave_requests_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: leave_requests leave_requests_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.leave_requests
    ADD CONSTRAINT leave_requests_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: leave_requests leave_requests_submitted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.leave_requests
    ADD CONSTRAINT leave_requests_submitted_by_fkey FOREIGN KEY (submitted_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: message_threads message_threads_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.message_threads
    ADD CONSTRAINT message_threads_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.parents(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: message_threads message_threads_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.message_threads
    ADD CONSTRAINT message_threads_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: message_threads message_threads_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.message_threads
    ADD CONSTRAINT message_threads_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: message_threads message_threads_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.message_threads
    ADD CONSTRAINT message_threads_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.staff(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: messages messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: messages messages_thread_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_thread_id_fkey FOREIGN KEY (thread_id) REFERENCES public.message_threads(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: notifications notifications_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: parent_student parent_student_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.parent_student
    ADD CONSTRAINT parent_student_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.parents(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: parent_student parent_student_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.parent_student
    ADD CONSTRAINT parent_student_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: parents parents_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.parents
    ADD CONSTRAINT parents_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: parents parents_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.parents
    ADD CONSTRAINT parents_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: payment_receipts payment_receipts_payment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.payment_receipts
    ADD CONSTRAINT payment_receipts_payment_id_fkey FOREIGN KEY (payment_id) REFERENCES public.payments(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: payments payments_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: payments payments_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: push_tokens push_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.push_tokens
    ADD CONSTRAINT push_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: report_cards report_cards_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.report_cards
    ADD CONSTRAINT report_cards_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: report_cards report_cards_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.report_cards
    ADD CONSTRAINT report_cards_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: scores scores_assessment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.scores
    ADD CONSTRAINT scores_assessment_id_fkey FOREIGN KEY (assessment_id) REFERENCES public.assessments(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: scores scores_graded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.scores
    ADD CONSTRAINT scores_graded_by_fkey FOREIGN KEY (graded_by) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: scores scores_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.scores
    ADD CONSTRAINT scores_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: staff staff_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: staff staff_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: student_fee_ledger student_fee_ledger_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.student_fee_ledger
    ADD CONSTRAINT student_fee_ledger_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: student_fee_ledger student_fee_ledger_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.student_fee_ledger
    ADD CONSTRAINT student_fee_ledger_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.students(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: students students_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: students students_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: students students_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: subjects subjects_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: subjects subjects_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: subjects subjects_teacher_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_teacher_id_fkey FOREIGN KEY (teacher_id) REFERENCES public.staff(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: timetable_periods timetable_periods_class_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.timetable_periods
    ADD CONSTRAINT timetable_periods_class_id_fkey FOREIGN KEY (class_id) REFERENCES public.classes(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: timetable_periods timetable_periods_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.timetable_periods
    ADD CONSTRAINT timetable_periods_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: users users_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: school_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict N2617auEcNwoEykGS7YbN73qAU5yFRRa6FHy3RgKbUVW3CUgjhb91iUQDHsZLJj

