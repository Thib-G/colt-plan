--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.6
-- Dumped by pg_dump version 9.6.6

-- Started on 2018-02-27 07:46:21

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 5 (class 2615 OID 25498)
-- Name: colt_viz_dev; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA colt_viz_dev;


SET search_path = colt_viz_dev, pg_catalog;

--
-- TOC entry 200 (class 1255 OID 25499)
-- Name: add_user_timestamp(); Type: FUNCTION; Schema: colt_viz_dev; Owner: -
--

CREATE FUNCTION add_user_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF TG_OP = 'INSERT' THEN
		NEW.created_by := current_user;
		NEW.created_at := current_timestamp;
	END IF;
	NEW.updated_by := current_user;
	NEW.updated_at := current_timestamp;

	RETURN NEW;
END;
$$;


SET default_with_oids = false;

--
-- TOC entry 199 (class 1259 OID 33913)
-- Name: async_component; Type: TABLE; Schema: colt_viz_dev; Owner: -
--

CREATE TABLE async_component (
    id integer NOT NULL,
    component text,
    content text
);


--
-- TOC entry 198 (class 1259 OID 33911)
-- Name: async_component_id_seq; Type: SEQUENCE; Schema: colt_viz_dev; Owner: -
--

CREATE SEQUENCE async_component_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2215 (class 0 OID 0)
-- Dependencies: 198
-- Name: async_component_id_seq; Type: SEQUENCE OWNED BY; Schema: colt_viz_dev; Owner: -
--

ALTER SEQUENCE async_component_id_seq OWNED BY async_component.id;


--
-- TOC entry 195 (class 1259 OID 25630)
-- Name: finished_tasks; Type: TABLE; Schema: colt_viz_dev; Owner: -
--

CREATE TABLE finished_tasks (
    id integer NOT NULL,
    created_by text,
    created_at timestamp with time zone,
    updated_by text,
    updated_at timestamp with time zone,
    project_id integer,
    task_id integer,
    finished_date date NOT NULL
);


--
-- TOC entry 2216 (class 0 OID 0)
-- Dependencies: 195
-- Name: TABLE finished_tasks; Type: COMMENT; Schema: colt_viz_dev; Owner: -
--

COMMENT ON TABLE finished_tasks IS 'List of finished tasks by template and by task.';


--
-- TOC entry 2217 (class 0 OID 0)
-- Dependencies: 195
-- Name: COLUMN finished_tasks.finished_date; Type: COMMENT; Schema: colt_viz_dev; Owner: -
--

COMMENT ON COLUMN finished_tasks.finished_date IS 'Date to specify when the task actually ended.';


--
-- TOC entry 194 (class 1259 OID 25628)
-- Name: finished_tasks_id_seq; Type: SEQUENCE; Schema: colt_viz_dev; Owner: -
--

CREATE SEQUENCE finished_tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2218 (class 0 OID 0)
-- Dependencies: 194
-- Name: finished_tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: colt_viz_dev; Owner: -
--

ALTER SEQUENCE finished_tasks_id_seq OWNED BY finished_tasks.id;


--
-- TOC entry 192 (class 1259 OID 25539)
-- Name: start_dates; Type: TABLE; Schema: colt_viz_dev; Owner: -
--

CREATE TABLE start_dates (
    id integer NOT NULL,
    created_by text,
    created_at timestamp with time zone,
    updated_by text,
    updated_at timestamp with time zone,
    project_descr text,
    start_date date,
    template_id integer,
    project_leader_login text
);


--
-- TOC entry 2219 (class 0 OID 0)
-- Dependencies: 192
-- Name: TABLE start_dates; Type: COMMENT; Schema: colt_viz_dev; Owner: -
--

COMMENT ON TABLE start_dates IS 'A list of projects with their theoretical start dates.';


--
-- TOC entry 2220 (class 0 OID 0)
-- Dependencies: 192
-- Name: COLUMN start_dates.project_leader_login; Type: COMMENT; Schema: colt_viz_dev; Owner: -
--

COMMENT ON COLUMN start_dates.project_leader_login IS 'Infrabel''s login of the project leader';


--
-- TOC entry 188 (class 1259 OID 25502)
-- Name: tasks; Type: TABLE; Schema: colt_viz_dev; Owner: -
--

CREATE TABLE tasks (
    id integer NOT NULL,
    created_by text,
    created_at timestamp with time zone,
    updated_by text,
    updated_at timestamp with time zone,
    template_id integer,
    order_nr integer,
    task_descr text,
    yr_before double precision,
    activity_type text,
    resmgr_id integer
);


--
-- TOC entry 2221 (class 0 OID 0)
-- Dependencies: 188
-- Name: TABLE tasks; Type: COMMENT; Schema: colt_viz_dev; Owner: -
--

COMMENT ON TABLE tasks IS 'List of tasks by template, with an order number';


--
-- TOC entry 190 (class 1259 OID 25517)
-- Name: templates; Type: TABLE; Schema: colt_viz_dev; Owner: -
--

CREATE TABLE templates (
    id integer NOT NULL,
    created_by text,
    created_at timestamp with time zone,
    updated_by text,
    updated_at timestamp with time zone,
    descr text
);


--
-- TOC entry 2222 (class 0 OID 0)
-- Dependencies: 190
-- Name: TABLE templates; Type: COMMENT; Schema: colt_viz_dev; Owner: -
--

COMMENT ON TABLE templates IS 'Names of project templates';


--
-- TOC entry 193 (class 1259 OID 25554)
-- Name: plannings_vw; Type: VIEW; Schema: colt_viz_dev; Owner: -
--

CREATE VIEW plannings_vw AS
 SELECT start_dates.id AS start_dates_id,
    start_dates.project_descr,
    start_dates.start_date,
    templates.descr AS template_descr,
    tasks.order_nr,
    tasks.task_descr,
    tasks.yr_before,
    tasks.activity_type,
    ((start_dates.start_date - (tasks.yr_before * '1 year'::interval)))::date AS calculated_date
   FROM ((start_dates
     JOIN templates ON ((start_dates.template_id = templates.id)))
     JOIN tasks ON ((tasks.template_id = templates.id)))
  ORDER BY start_dates.id, tasks.order_nr;


--
-- TOC entry 197 (class 1259 OID 25685)
-- Name: project_leaders; Type: TABLE; Schema: colt_viz_dev; Owner: -
--

CREATE TABLE project_leaders (
    id integer NOT NULL,
    created_by text,
    created_at timestamp with time zone,
    updated_by text,
    updated_at timestamp with time zone,
    login text NOT NULL,
    name text NOT NULL
);


--
-- TOC entry 196 (class 1259 OID 25683)
-- Name: project_leaders_id_seq; Type: SEQUENCE; Schema: colt_viz_dev; Owner: -
--

CREATE SEQUENCE project_leaders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2223 (class 0 OID 0)
-- Dependencies: 196
-- Name: project_leaders_id_seq; Type: SEQUENCE OWNED BY; Schema: colt_viz_dev; Owner: -
--

ALTER SEQUENCE project_leaders_id_seq OWNED BY project_leaders.id;


--
-- TOC entry 191 (class 1259 OID 25537)
-- Name: start_dates_id_seq; Type: SEQUENCE; Schema: colt_viz_dev; Owner: -
--

CREATE SEQUENCE start_dates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2224 (class 0 OID 0)
-- Dependencies: 191
-- Name: start_dates_id_seq; Type: SEQUENCE OWNED BY; Schema: colt_viz_dev; Owner: -
--

ALTER SEQUENCE start_dates_id_seq OWNED BY start_dates.id;


--
-- TOC entry 187 (class 1259 OID 25500)
-- Name: tasks_id_seq; Type: SEQUENCE; Schema: colt_viz_dev; Owner: -
--

CREATE SEQUENCE tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2225 (class 0 OID 0)
-- Dependencies: 187
-- Name: tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: colt_viz_dev; Owner: -
--

ALTER SEQUENCE tasks_id_seq OWNED BY tasks.id;


--
-- TOC entry 189 (class 1259 OID 25515)
-- Name: templates_id_seq; Type: SEQUENCE; Schema: colt_viz_dev; Owner: -
--

CREATE SEQUENCE templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2226 (class 0 OID 0)
-- Dependencies: 189
-- Name: templates_id_seq; Type: SEQUENCE OWNED BY; Schema: colt_viz_dev; Owner: -
--

ALTER SEQUENCE templates_id_seq OWNED BY templates.id;


--
-- TOC entry 2053 (class 2604 OID 33916)
-- Name: async_component id; Type: DEFAULT; Schema: colt_viz_dev; Owner: -
--

ALTER TABLE ONLY async_component ALTER COLUMN id SET DEFAULT nextval('async_component_id_seq'::regclass);


--
-- TOC entry 2051 (class 2604 OID 25633)
-- Name: finished_tasks id; Type: DEFAULT; Schema: colt_viz_dev; Owner: -
--

ALTER TABLE ONLY finished_tasks ALTER COLUMN id SET DEFAULT nextval('finished_tasks_id_seq'::regclass);


--
-- TOC entry 2052 (class 2604 OID 25688)
-- Name: project_leaders id; Type: DEFAULT; Schema: colt_viz_dev; Owner: -
--

ALTER TABLE ONLY project_leaders ALTER COLUMN id SET DEFAULT nextval('project_leaders_id_seq'::regclass);


--
-- TOC entry 2050 (class 2604 OID 25542)
-- Name: start_dates id; Type: DEFAULT; Schema: colt_viz_dev; Owner: -
--

ALTER TABLE ONLY start_dates ALTER COLUMN id SET DEFAULT nextval('start_dates_id_seq'::regclass);


--
-- TOC entry 2048 (class 2604 OID 25505)
-- Name: tasks id; Type: DEFAULT; Schema: colt_viz_dev; Owner: -
--

ALTER TABLE ONLY tasks ALTER COLUMN id SET DEFAULT nextval('tasks_id_seq'::regclass);


--
-- TOC entry 2049 (class 2604 OID 25520)
-- Name: templates id; Type: DEFAULT; Schema: colt_viz_dev; Owner: -
--

ALTER TABLE ONLY templates ALTER COLUMN id SET DEFAULT nextval('templates_id_seq'::regclass);


--
-- TOC entry 2210 (class 0 OID 33913)
-- Dependencies: 199
-- Data for Name: async_component; Type: TABLE DATA; Schema: colt_viz_dev; Owner: -
--

COPY async_component (id, component, content) FROM stdin;
1	my-async-component	{\r\n\ttemplate: '<div>{{ msg }}</div>',\r\n\tdata: function() {\r\n\t\treturn {\r\n\t\t\tmsg: 'Async component works!'\r\n\t\t};\r\n\t}\r\n}
\.


--
-- TOC entry 2227 (class 0 OID 0)
-- Dependencies: 198
-- Name: async_component_id_seq; Type: SEQUENCE SET; Schema: colt_viz_dev; Owner: -
--

SELECT pg_catalog.setval('async_component_id_seq', 1, true);


--
-- TOC entry 2206 (class 0 OID 25630)
-- Dependencies: 195
-- Data for Name: finished_tasks; Type: TABLE DATA; Schema: colt_viz_dev; Owner: -
--

COPY finished_tasks (id, created_by, created_at, updated_by, updated_at, project_id, task_id, finished_date) FROM stdin;
75	thib	2018-02-07 18:54:20.723552+01	thib	2018-02-07 18:54:20.723552+01	2	32	2018-02-07
76	thib	2018-02-07 18:54:21.921521+01	thib	2018-02-07 18:54:21.921521+01	2	33	2018-02-07
77	thib	2018-02-07 18:54:23.177107+01	thib	2018-02-07 18:54:23.177107+01	2	34	2018-02-07
147	thib	2018-02-17 18:34:10.567938+01	thib	2018-02-17 18:34:10.567938+01	1	40	2018-02-25
80	thib	2018-02-08 17:26:34.932718+01	thib	2018-02-08 17:26:34.932718+01	1	58	2018-02-08
149	thib	2018-02-17 19:09:37.878842+01	thib	2018-02-17 19:09:37.878842+01	1	46	2018-02-23
10	thib	2018-02-06 18:42:33.443657+01	thib	2018-02-06 18:42:33.443657+01	3	46	2019-12-31
152	thib	2018-02-17 19:16:08.747429+01	thib	2018-02-17 19:16:08.747429+01	1	44	2018-02-23
13	thib	2018-02-06 19:11:12.770314+01	thib	2018-02-06 19:11:12.770314+01	3	44	2019-12-31
14	thib	2018-02-06 19:12:30.901299+01	thib	2018-02-06 19:12:30.901299+01	3	42	2019-12-31
18	thib	2018-02-06 19:16:01.513053+01	thib	2018-02-06 19:16:01.513053+01	3	40	2019-12-31
158	thib	2018-02-17 22:21:43.218324+01	thib	2018-02-17 22:21:43.218324+01	5	40	2018-02-17
21	thib	2018-02-06 19:26:33.068356+01	thib	2018-02-06 19:26:33.068356+01	3	58	2019-12-31
26	thib	2018-02-06 20:08:38.47135+01	thib	2018-02-06 20:08:38.47135+01	4	51	2019-12-31
95	thib	2018-02-17 12:48:09.111179+01	thib	2018-02-17 12:48:09.111179+01	4	48	2018-02-17
28	thib	2018-02-06 20:26:20.048144+01	thib	2018-02-06 20:26:20.048144+01	4	52	2019-12-31
32	thib	2018-02-06 20:27:59.810491+01	thib	2018-02-06 20:27:59.810491+01	4	42	2019-12-31
33	thib	2018-02-06 20:28:01.638601+01	thib	2018-02-06 20:28:01.638601+01	4	43	2019-12-31
100	thib	2018-02-17 13:22:59.633638+01	thib	2018-02-17 13:22:59.633638+01	4	40	2018-02-17
105	thib	2018-02-17 13:24:21.265808+01	thib	2018-02-17 13:24:21.265808+01	4	32	2018-02-17
106	thib	2018-02-17 13:24:22.113021+01	thib	2018-02-17 13:24:22.113021+01	4	33	2018-02-17
107	thib	2018-02-17 13:24:23.088416+01	thib	2018-02-17 13:24:23.088416+01	4	34	2018-02-17
45	thib	2018-02-06 20:28:28.746012+01	thib	2018-02-06 20:28:28.746012+01	4	46	2019-12-31
108	thib	2018-02-17 13:27:08.772146+01	thib	2018-02-17 13:27:08.772146+01	4	36	2018-02-17
111	thib	2018-02-17 14:12:26.253666+01	thib	2018-02-17 14:12:26.253666+01	5	33	2018-02-17
113	thib	2018-02-17 14:15:37.866898+01	thib	2018-02-17 14:15:37.866898+01	5	34	2018-02-17
63	thib	2018-02-06 22:46:38.427788+01	thib	2018-02-06 22:46:38.427788+01	1	32	2019-12-31
64	thib	2018-02-06 22:46:39.261289+01	thib	2018-02-06 22:46:39.261289+01	1	33	2019-12-31
65	thib	2018-02-06 22:46:40.07307+01	thib	2018-02-06 22:46:40.07307+01	1	34	2019-12-31
66	thib	2018-02-06 22:47:25.352107+01	thib	2018-02-06 22:47:25.352107+01	1	35	2019-12-31
72	thib	2018-02-06 23:10:16.701276+01	thib	2018-02-06 23:10:16.701276+01	1	51	2018-02-06
74	thib	2018-02-06 23:54:40.486416+01	thib	2018-02-06 23:54:40.486416+01	1	36	2018-02-06
189	thib	2018-02-17 23:35:14.854341+01	thib	2018-02-17 23:35:14.854341+01	5	37	2018-02-17
192	thib	2018-02-17 23:36:14.814992+01	thib	2018-02-17 23:36:14.814992+01	5	39	2018-02-20
194	thib	2018-02-18 17:44:12.371659+01	thib	2018-02-18 17:44:12.371659+01	5	38	2018-02-18
203	thib	2018-02-19 00:18:36.118071+01	thib	2018-02-19 00:18:36.118071+01	5	35	2018-02-01
146	thib	2018-02-17 18:30:48.545541+01	thib	2018-02-17 18:30:48.545541+01	1	45	2018-02-28
204	thib	2018-02-20 18:31:43.234441+01	thib	2018-02-20 18:31:43.234441+01	5	32	2018-02-20
205	thib	2018-02-20 18:31:46.829094+01	thib	2018-02-20 18:31:46.829094+01	5	41	2018-02-20
207	thib	2018-02-26 11:53:35.159961+01	thib	2018-02-26 11:53:35.159961+01	4	53	2018-03-01
209	thib	2018-02-26 12:01:20.439669+01	thib	2018-02-26 12:01:20.439669+01	4	47	2018-01-05
\.


--
-- TOC entry 2228 (class 0 OID 0)
-- Dependencies: 194
-- Name: finished_tasks_id_seq; Type: SEQUENCE SET; Schema: colt_viz_dev; Owner: -
--

SELECT pg_catalog.setval('finished_tasks_id_seq', 209, true);


--
-- TOC entry 2208 (class 0 OID 25685)
-- Dependencies: 197
-- Data for Name: project_leaders; Type: TABLE DATA; Schema: colt_viz_dev; Owner: -
--

COPY project_leaders (id, created_by, created_at, updated_by, updated_at, login, name) FROM stdin;
1	pgthib	2018-02-07 17:08:20.801253+01	pgthib	2018-02-07 17:08:20.801253+01	JJD8300	Goelff Thibaut
3	pgthib	2018-02-07 17:08:49.263584+01	pgthib	2018-02-07 17:08:49.263584+01	BCD2300	Talus Jean
2	pgthib	2018-02-07 17:08:33.339048+01	pgthib	2018-02-07 17:08:55.679741+01	ABC1200	Talliage Jean
4	pgthib	2018-02-07 17:09:20.527341+01	pgthib	2018-02-07 17:09:20.527341+01	CDE3400	Térieur Alain
5	pgthib	2018-02-07 17:09:32.941144+01	pgthib	2018-02-07 17:09:32.941144+01	CDE3500	Térieur Alex
\.


--
-- TOC entry 2229 (class 0 OID 0)
-- Dependencies: 196
-- Name: project_leaders_id_seq; Type: SEQUENCE SET; Schema: colt_viz_dev; Owner: -
--

SELECT pg_catalog.setval('project_leaders_id_seq', 5, true);


--
-- TOC entry 2204 (class 0 OID 25539)
-- Dependencies: 192
-- Data for Name: start_dates; Type: TABLE DATA; Schema: colt_viz_dev; Owner: -
--

COPY start_dates (id, created_by, created_at, updated_by, updated_at, project_descr, start_date, template_id, project_leader_login) FROM stdin;
1	pgthib	2018-01-26 22:30:16.309505+01	pgthib	2018-02-08 17:46:04.354161+01	Project 1	2019-05-01	1	JJD8300
4	pgthib	2018-01-28 14:48:48.514547+01	pgthib	2018-02-08 17:46:07.993318+01	Super projet	2021-03-23	1	JJD8300
2	pgthib	2018-01-26 22:30:32.182219+01	pgthib	2018-02-08 17:46:12.005048+01	Project 2	2018-09-01	1	ABC1200
3	pgthib	2018-01-26 22:31:07.248261+01	pgthib	2018-02-08 17:46:17.3693+01	Project 3	2020-03-01	1	BCD2300
5	pgthib	2018-02-17 13:58:51.714417+01	pgthib	2018-02-17 13:58:51.714417+01	Un autre renouvellement	2022-01-01	1	JJD8300
\.


--
-- TOC entry 2230 (class 0 OID 0)
-- Dependencies: 191
-- Name: start_dates_id_seq; Type: SEQUENCE SET; Schema: colt_viz_dev; Owner: -
--

SELECT pg_catalog.setval('start_dates_id_seq', 5, true);


--
-- TOC entry 2200 (class 0 OID 25502)
-- Dependencies: 188
-- Data for Name: tasks; Type: TABLE DATA; Schema: colt_viz_dev; Owner: -
--

COPY tasks (id, created_by, created_at, updated_by, updated_at, template_id, order_nr, task_descr, yr_before, activity_type, resmgr_id) FROM stdin;
32	pgthib	2018-01-26 00:07:46.118098+01	pgthib	2018-01-26 00:07:46.118098+01	1	10	Créer fiche TrackPro	5	V	\N
33	pgthib	2018-01-26 00:07:46.118098+01	pgthib	2018-01-26 00:07:46.118098+01	1	20	Créer Project Scope Document (PSD)	5	V	\N
34	pgthib	2018-01-26 00:07:46.118098+01	pgthib	2018-01-26 00:07:46.118098+01	1	30	Encoder la V1 dans SAP	5	V	\N
35	pgthib	2018-01-26 00:07:46.118098+01	pgthib	2018-01-26 00:07:46.118098+01	1	40	Kickoff Projet	4	V	\N
36	pgthib	2018-01-26 00:07:46.118098+01	pgthib	2018-01-26 00:07:46.118098+01	1	50	Faire levé	3.5	V	\N
37	pgthib	2018-01-26 00:07:46.118098+01	pgthib	2018-01-26 00:07:46.118098+01	1	60	Faire analyse de ballast	3	V	\N
38	pgthib	2018-01-26 00:07:46.118098+01	pgthib	2018-01-26 00:07:46.118098+01	1	70	Faire essais Panda	3	V	\N
39	pgthib	2018-01-26 00:07:46.118098+01	pgthib	2018-01-26 00:07:46.118098+01	1	80	Faire étude de tracé	3	V	\N
40	pgthib	2018-01-26 00:07:46.118098+01	pgthib	2018-01-26 00:07:46.118098+01	1	90	Dessiner Plan schématique de phasage	2.5	V	\N
41	pgthib	2018-01-26 00:07:46.118098+01	pgthib	2018-01-26 00:07:46.118098+01	1	100	Valider partie Caténaires	2.5	CAT	\N
42	pgthib	2018-01-26 00:07:46.118098+01	pgthib	2018-01-26 00:07:46.118098+01	1	110	Valider partie Signalisation	2.5	SI	\N
43	pgthib	2018-01-26 00:07:46.118098+01	pgthib	2018-01-26 00:07:46.118098+01	1	115	Valider partie OA	2.5	V	\N
44	pgthib	2018-01-26 00:07:46.118098+01	pgthib	2018-01-26 00:07:46.118098+01	1	120	Validation partie Voie	2.5	V	\N
45	pgthib	2018-01-26 00:07:46.118098+01	pgthib	2018-01-26 00:07:46.118098+01	1	130	Demander Mises Hors Service voies	2.5	V	\N
46	pgthib	2018-01-26 00:07:46.118098+01	pgthib	2018-01-26 00:07:46.118098+01	1	140	Encoder dates dans BI-IP TrackPro	2.5	V	\N
47	pgthib	2018-01-26 00:07:46.118098+01	pgthib	2018-01-26 00:07:46.118098+01	1	150	Créer réservations dans SAP	2	V	\N
48	pgthib	2018-01-26 00:07:46.118098+01	pgthib	2018-01-26 00:07:46.118098+01	1	160	Introduire V437 provisoire	2	V	\N
49	pgthib	2018-01-26 00:07:46.118098+01	pgthib	2018-01-26 00:07:46.118098+01	1	170	Réserver grue Kirow	2	V	\N
50	pgthib	2018-01-26 00:07:46.118098+01	pgthib	2018-01-26 00:07:46.118098+01	1	180	Dessiner Plans LRS + valider	2	V	\N
51	pgthib	2018-01-26 00:07:46.118098+01	pgthib	2018-01-26 00:07:46.118098+01	1	190	Dessiner Plans PN + valider	2	V	\N
52	pgthib	2018-01-26 00:07:46.118098+01	pgthib	2018-01-26 00:07:46.118098+01	1	200	Introduire V437 définitif	1.5	V	\N
53	pgthib	2018-01-26 00:07:46.118098+01	pgthib	2018-01-26 00:07:46.118098+01	1	210	Ajouter postes Caténaires dans CSC	1.5	CAT	\N
54	pgthib	2018-01-26 00:07:46.118098+01	pgthib	2018-01-26 00:07:46.118098+01	1	220	Ajouter postes Signalisation dans CSC	1.5	SI	\N
55	pgthib	2018-01-26 00:07:46.118098+01	pgthib	2018-01-26 00:07:46.118098+01	1	225	Ajouter postes OA dans CSC	1.5	V	\N
56	pgthib	2018-01-26 00:07:46.118098+01	pgthib	2018-01-26 00:07:46.118098+01	1	230	Dessiner Plans CSC	1.5	V	\N
57	pgthib	2018-01-26 00:07:46.118098+01	pgthib	2018-01-26 00:07:46.118098+01	1	240	Envoyer CSC à l'Area	1	V	\N
58	pgthib	2018-01-26 00:07:46.118098+01	pgthib	2018-01-26 00:07:46.118098+01	1	250	Dessiner Plan d'implantation	0.5	V	\N
59	pgthib	2018-01-26 00:07:46.118098+01	pgthib	2018-01-26 00:08:12.97913+01	1	260	Début chantier	0	START	\N
\.


--
-- TOC entry 2231 (class 0 OID 0)
-- Dependencies: 187
-- Name: tasks_id_seq; Type: SEQUENCE SET; Schema: colt_viz_dev; Owner: -
--

SELECT pg_catalog.setval('tasks_id_seq', 59, true);


--
-- TOC entry 2202 (class 0 OID 25517)
-- Dependencies: 190
-- Data for Name: templates; Type: TABLE DATA; Schema: colt_viz_dev; Owner: -
--

COPY templates (id, created_by, created_at, updated_by, updated_at, descr) FROM stdin;
1	pgthib	2018-01-26 22:22:54.064553+01	pgthib	2018-01-26 22:22:54.064553+01	AW Planning
\.


--
-- TOC entry 2232 (class 0 OID 0)
-- Dependencies: 189
-- Name: templates_id_seq; Type: SEQUENCE SET; Schema: colt_viz_dev; Owner: -
--

SELECT pg_catalog.setval('templates_id_seq', 1, true);


--
-- TOC entry 2068 (class 2606 OID 33923)
-- Name: async_component async_component_component_key; Type: CONSTRAINT; Schema: colt_viz_dev; Owner: -
--

ALTER TABLE ONLY async_component
    ADD CONSTRAINT async_component_component_key UNIQUE (component);


--
-- TOC entry 2070 (class 2606 OID 33921)
-- Name: async_component async_component_pkey; Type: CONSTRAINT; Schema: colt_viz_dev; Owner: -
--

ALTER TABLE ONLY async_component
    ADD CONSTRAINT async_component_pkey PRIMARY KEY (id);


--
-- TOC entry 2061 (class 2606 OID 25638)
-- Name: finished_tasks finished_tasks_pkey; Type: CONSTRAINT; Schema: colt_viz_dev; Owner: -
--

ALTER TABLE ONLY finished_tasks
    ADD CONSTRAINT finished_tasks_pkey PRIMARY KEY (id);


--
-- TOC entry 2064 (class 2606 OID 25695)
-- Name: project_leaders project_leaders_login_key; Type: CONSTRAINT; Schema: colt_viz_dev; Owner: -
--

ALTER TABLE ONLY project_leaders
    ADD CONSTRAINT project_leaders_login_key UNIQUE (login);


--
-- TOC entry 2066 (class 2606 OID 25693)
-- Name: project_leaders project_leaders_pkey; Type: CONSTRAINT; Schema: colt_viz_dev; Owner: -
--

ALTER TABLE ONLY project_leaders
    ADD CONSTRAINT project_leaders_pkey PRIMARY KEY (id);


--
-- TOC entry 2059 (class 2606 OID 25548)
-- Name: start_dates start_dates_pkey; Type: CONSTRAINT; Schema: colt_viz_dev; Owner: -
--

ALTER TABLE ONLY start_dates
    ADD CONSTRAINT start_dates_pkey PRIMARY KEY (id);


--
-- TOC entry 2055 (class 2606 OID 25510)
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: colt_viz_dev; Owner: -
--

ALTER TABLE ONLY tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- TOC entry 2057 (class 2606 OID 25525)
-- Name: templates templates_pkey; Type: CONSTRAINT; Schema: colt_viz_dev; Owner: -
--

ALTER TABLE ONLY templates
    ADD CONSTRAINT templates_pkey PRIMARY KEY (id);


--
-- TOC entry 2062 (class 1259 OID 33905)
-- Name: finished_tasks_project_id_idx; Type: INDEX; Schema: colt_viz_dev; Owner: -
--

CREATE INDEX finished_tasks_project_id_idx ON finished_tasks USING btree (project_id);


--
-- TOC entry 2079 (class 2620 OID 25649)
-- Name: finished_tasks trg_finished_tasks_user_timestamp; Type: TRIGGER; Schema: colt_viz_dev; Owner: -
--

CREATE TRIGGER trg_finished_tasks_user_timestamp BEFORE INSERT OR UPDATE ON finished_tasks FOR EACH ROW EXECUTE PROCEDURE add_user_timestamp();


--
-- TOC entry 2080 (class 2620 OID 25696)
-- Name: project_leaders trg_project_leaders_user_timestamp; Type: TRIGGER; Schema: colt_viz_dev; Owner: -
--

CREATE TRIGGER trg_project_leaders_user_timestamp BEFORE INSERT OR UPDATE ON project_leaders FOR EACH ROW EXECUTE PROCEDURE add_user_timestamp();


--
-- TOC entry 2078 (class 2620 OID 25546)
-- Name: start_dates trg_start_dates_user_timestamp; Type: TRIGGER; Schema: colt_viz_dev; Owner: -
--

CREATE TRIGGER trg_start_dates_user_timestamp BEFORE INSERT OR UPDATE ON start_dates FOR EACH ROW EXECUTE PROCEDURE add_user_timestamp();


--
-- TOC entry 2076 (class 2620 OID 25511)
-- Name: tasks trg_tasks_user_timestamp; Type: TRIGGER; Schema: colt_viz_dev; Owner: -
--

CREATE TRIGGER trg_tasks_user_timestamp BEFORE INSERT OR UPDATE ON tasks FOR EACH ROW EXECUTE PROCEDURE add_user_timestamp();


--
-- TOC entry 2077 (class 2620 OID 25526)
-- Name: templates trg_templates_user_timestamp; Type: TRIGGER; Schema: colt_viz_dev; Owner: -
--

CREATE TRIGGER trg_templates_user_timestamp BEFORE INSERT OR UPDATE ON templates FOR EACH ROW EXECUTE PROCEDURE add_user_timestamp();


--
-- TOC entry 2074 (class 2606 OID 25639)
-- Name: finished_tasks finished_tasks_project_id_fkey; Type: FK CONSTRAINT; Schema: colt_viz_dev; Owner: -
--

ALTER TABLE ONLY finished_tasks
    ADD CONSTRAINT finished_tasks_project_id_fkey FOREIGN KEY (project_id) REFERENCES start_dates(id);


--
-- TOC entry 2075 (class 2606 OID 25644)
-- Name: finished_tasks finished_tasks_task_id_fkey; Type: FK CONSTRAINT; Schema: colt_viz_dev; Owner: -
--

ALTER TABLE ONLY finished_tasks
    ADD CONSTRAINT finished_tasks_task_id_fkey FOREIGN KEY (task_id) REFERENCES tasks(id);


--
-- TOC entry 2073 (class 2606 OID 25703)
-- Name: start_dates start_dates_project_leader_login_fkey; Type: FK CONSTRAINT; Schema: colt_viz_dev; Owner: -
--

ALTER TABLE ONLY start_dates
    ADD CONSTRAINT start_dates_project_leader_login_fkey FOREIGN KEY (project_leader_login) REFERENCES project_leaders(login);


--
-- TOC entry 2072 (class 2606 OID 25549)
-- Name: start_dates start_dates_template_id_fkey; Type: FK CONSTRAINT; Schema: colt_viz_dev; Owner: -
--

ALTER TABLE ONLY start_dates
    ADD CONSTRAINT start_dates_template_id_fkey FOREIGN KEY (template_id) REFERENCES templates(id);


--
-- TOC entry 2071 (class 2606 OID 25532)
-- Name: tasks tasks_template_id_fkey; Type: FK CONSTRAINT; Schema: colt_viz_dev; Owner: -
--

ALTER TABLE ONLY tasks
    ADD CONSTRAINT tasks_template_id_fkey FOREIGN KEY (template_id) REFERENCES templates(id);


-- Completed on 2018-02-27 07:46:23

--
-- PostgreSQL database dump complete
--

