-- Anise App SQLite Export

-- Table: migrations
CREATE TABLE "migrations" ("id" integer primary key autoincrement not null, "migration" varchar not null, "batch" integer not null);

INSERT INTO "migrations" ("id", "migration", "batch") VALUES ('1', '0001_01_01_000000_create_users_table', '1');
INSERT INTO "migrations" ("id", "migration", "batch") VALUES ('2', '0001_01_01_000001_create_cache_table', '1');
INSERT INTO "migrations" ("id", "migration", "batch") VALUES ('3', '0001_01_01_000002_create_jobs_table', '1');
INSERT INTO "migrations" ("id", "migration", "batch") VALUES ('4', '2026_08_31_213300_create_personal_access_tokens_table', '1');
INSERT INTO "migrations" ("id", "migration", "batch") VALUES ('5', '2026_09_01_042810_create_academic_years_table', '1');
INSERT INTO "migrations" ("id", "migration", "batch") VALUES ('6', '2026_09_01_042812_create_majors_table', '1');
INSERT INTO "migrations" ("id", "migration", "batch") VALUES ('7', '2026_09_01_042814_create_guru_profiles_table', '1');
INSERT INTO "migrations" ("id", "migration", "batch") VALUES ('8', '2026_09_01_042816_create_siswa_profiles_table', '1');
INSERT INTO "migrations" ("id", "migration", "batch") VALUES ('9', '2026_09_01_042818_create_classes_table', '1');
INSERT INTO "migrations" ("id", "migration", "batch") VALUES ('10', '2026_09_01_042820_create_class_students_table', '1');
INSERT INTO "migrations" ("id", "migration", "batch") VALUES ('11', '2026_09_01_042822_create_structural_assignments_table', '1');
INSERT INTO "migrations" ("id", "migration", "batch") VALUES ('12', '2026_09_01_042824_create_guru_wali_students_table', '1');
INSERT INTO "migrations" ("id", "migration", "batch") VALUES ('13', '2026_09_01_042826_create_guru_bk_classes_table', '1');
INSERT INTO "migrations" ("id", "migration", "batch") VALUES ('14', '2026_09_01_042828_create_subjects_table', '1');
INSERT INTO "migrations" ("id", "migration", "batch") VALUES ('15', '2026_09_01_042830_create_schedules_table', '1');
INSERT INTO "migrations" ("id", "migration", "batch") VALUES ('16', '2026_09_01_042832_create_attendances_table', '1');
INSERT INTO "migrations" ("id", "migration", "batch") VALUES ('17', '2026_09_01_042834_create_presensi_logs_table', '1');
INSERT INTO "migrations" ("id", "migration", "batch") VALUES ('18', '2026_09_01_042836_create_teacher_attendances_table', '1');
INSERT INTO "migrations" ("id", "migration", "batch") VALUES ('19', '2026_09_01_042838_create_journals_table', '1');
INSERT INTO "migrations" ("id", "migration", "batch") VALUES ('20', '2026_09_01_042841_create_journal_tasks_table', '1');
INSERT INTO "migrations" ("id", "migration", "batch") VALUES ('21', '2026_09_01_042843_create_journal_task_attachments_table', '1');
INSERT INTO "migrations" ("id", "migration", "batch") VALUES ('22', '2026_09_01_042845_create_student_task_submissions_table', '1');
INSERT INTO "migrations" ("id", "migration", "batch") VALUES ('23', '2026_09_01_042847_create_student_task_grades_table', '1');
INSERT INTO "migrations" ("id", "migration", "batch") VALUES ('24', '2026_09_01_042849_create_point_rules_table', '1');
INSERT INTO "migrations" ("id", "migration", "batch") VALUES ('25', '2026_09_01_042851_create_student_point_logs_table', '1');
INSERT INTO "migrations" ("id", "migration", "batch") VALUES ('26', '2026_09_01_042853_create_kpi_indicators_table', '1');
INSERT INTO "migrations" ("id", "migration", "batch") VALUES ('27', '2026_09_01_042855_create_teacher_kpi_period_summaries_table', '1');
INSERT INTO "migrations" ("id", "migration", "batch") VALUES ('28', '2026_09_01_042857_create_habits_table', '1');
INSERT INTO "migrations" ("id", "migration", "batch") VALUES ('29', '2026_09_01_042859_create_student_habit_logs_table', '1');
INSERT INTO "migrations" ("id", "migration", "batch") VALUES ('30', '2026_09_01_042901_create_assessments_table', '1');
INSERT INTO "migrations" ("id", "migration", "batch") VALUES ('31', '2026_09_01_042903_create_journal_reviews_table', '1');
INSERT INTO "migrations" ("id", "migration", "batch") VALUES ('32', '2026_09_01_042905_create_journal_comments_table', '1');
INSERT INTO "migrations" ("id", "migration", "batch") VALUES ('33', '2026_09_01_042907_create_student_reports_table', '1');
INSERT INTO "migrations" ("id", "migration", "batch") VALUES ('34', '2026_09_01_042909_create_habit_verifications_table', '1');
INSERT INTO "migrations" ("id", "migration", "batch") VALUES ('35', '2026_09_01_042911_create_teaching_administrations_table', '1');
INSERT INTO "migrations" ("id", "migration", "batch") VALUES ('36', '2026_09_01_042913_create_notifications_table', '1');

-- Table: users
CREATE TABLE "users" ("id" varchar not null, "full_name" varchar not null, "username" varchar not null, "email" varchar not null, "email_verified_at" datetime, "password_hash" varchar not null, "role_type" varchar check ("role_type" in ('ADMIN', 'GURU', 'SISWA', 'WALI')) not null, "is_active" tinyint(1) not null default '1', "remember_token" varchar, "created_at" datetime, "updated_at" datetime, primary key ("id"));

INSERT INTO "users" ("id", "full_name", "username", "email", "email_verified_at", "password_hash", "role_type", "is_active", "remember_token", "created_at", "updated_at") VALUES ('01a059f0-4aa2-72a8-86fc-2e14460101a4', 'Super Administrator', 'admin', 'admin@anise.com', NULL, '$2y$12$bS7awxUlEnZPeHukJgxyh.0FjCmIAva8Y0BPsvmcE4K1Ltmt837wm', 'ADMIN', '1', NULL, '2026-08-31 22:28:35', '2026-08-31 22:28:35');
INSERT INTO "users" ("id", "full_name", "username", "email", "email_verified_at", "password_hash", "role_type", "is_active", "remember_token", "created_at", "updated_at") VALUES ('01a059f0-4b8d-7325-bdf2-5c8d62d0e287', 'Budi Santoso, S.Kom.', 'guru1', 'budi.guru@anise.com', NULL, '$2y$12$lnzw04TsO72UnKeqih.Xc.AQYsxu0I4pqdXPEl3luuHgX/j1atOX.', 'GURU', '1', NULL, '2026-08-31 22:28:35', '2026-08-31 22:28:35');
INSERT INTO "users" ("id", "full_name", "username", "email", "email_verified_at", "password_hash", "role_type", "is_active", "remember_token", "created_at", "updated_at") VALUES ('01a059f0-4c9b-738a-bac4-630d2bd132ca', 'Andi Wijaya', 'siswa1', 'andi.siswa@anise.com', NULL, '$2y$12$Y0e7cAmor2e5qKP.9TSTpOoEgehVdwXGgSo/nLl2t/ivorGKK5CJe', 'SISWA', '1', NULL, '2026-08-31 22:28:35', '2026-08-31 22:28:35');

-- Table: password_reset_tokens
CREATE TABLE "password_reset_tokens" ("email" varchar not null, "token" varchar not null, "created_at" datetime, primary key ("email"));

-- Table: sessions
CREATE TABLE "sessions" ("id" varchar not null, "user_id" varchar, "ip_address" varchar, "user_agent" text, "payload" text not null, "last_activity" integer not null, primary key ("id"));

-- Table: cache
CREATE TABLE "cache" ("key" varchar not null, "value" text not null, "expiration" integer not null, primary key ("key"));

-- Table: cache_locks
CREATE TABLE "cache_locks" ("key" varchar not null, "owner" varchar not null, "expiration" integer not null, primary key ("key"));

-- Table: jobs
CREATE TABLE "jobs" ("id" integer primary key autoincrement not null, "queue" varchar not null, "payload" text not null, "attempts" integer not null, "reserved_at" integer, "available_at" integer not null, "created_at" integer not null);

-- Table: job_batches
CREATE TABLE "job_batches" ("id" varchar not null, "name" varchar not null, "total_jobs" integer not null, "pending_jobs" integer not null, "failed_jobs" integer not null, "failed_job_ids" text not null, "options" text, "cancelled_at" integer, "created_at" integer not null, "finished_at" integer, primary key ("id"));

-- Table: failed_jobs
CREATE TABLE "failed_jobs" ("id" integer primary key autoincrement not null, "uuid" varchar not null, "connection" varchar not null, "queue" varchar not null, "payload" text not null, "exception" text not null, "failed_at" datetime not null default CURRENT_TIMESTAMP);

-- Table: personal_access_tokens
CREATE TABLE "personal_access_tokens" ("id" integer primary key autoincrement not null, "tokenable_type" varchar not null, "tokenable_id" integer not null, "name" text not null, "token" varchar not null, "abilities" text, "last_used_at" datetime, "expires_at" datetime, "created_at" datetime, "updated_at" datetime);

INSERT INTO "personal_access_tokens" ("id", "tokenable_type", "tokenable_id", "name", "token", "abilities", "last_used_at", "expires_at", "created_at", "updated_at") VALUES ('1', 'App\Models\User', '01a059f0-4b8d-7325-bdf2-5c8d62d0e287', 'auth_token', '010262613e52260932933ee10fba8e2678f2357124e5aa400895eb41f9a19a91', '["*"]', '2026-08-31 22:30:49', NULL, '2026-08-31 22:30:48', '2026-08-31 22:30:49');

-- Table: academic_years
CREATE TABLE "academic_years" ("id" varchar not null, "name" varchar not null, "semester" varchar check ("semester" in ('GANJIL', 'GENAP')) not null, "is_active" tinyint(1) not null default '0', "start_date" date not null, "end_date" date not null, "created_at" datetime, "updated_at" datetime, primary key ("id"));

INSERT INTO "academic_years" ("id", "name", "semester", "is_active", "start_date", "end_date", "created_at", "updated_at") VALUES ('01a059f0-497e-70cf-9c6d-0f347151910d', '2026/2027', 'GANJIL', '1', '2026-07-15', '2026-12-20', '2026-08-31 22:28:34', '2026-08-31 22:28:34');

-- Table: majors
CREATE TABLE "majors" ("id" varchar not null, "code" varchar not null, "name" varchar not null, "created_at" datetime, "updated_at" datetime, primary key ("id"));

INSERT INTO "majors" ("id", "code", "name", "created_at", "updated_at") VALUES ('01a059f0-49a1-7266-9fa1-987ba2291a10', 'RPL', 'Rekayasa Perangkat Lunak', '2026-08-31 22:28:34', '2026-08-31 22:28:34');

-- Table: guru_profiles
CREATE TABLE "guru_profiles" ("user_id" varchar not null, "nip_nuptk" varchar, "gender" varchar check ("gender" in ('L', 'P')) not null, "employment_status" varchar, "created_at" datetime, "updated_at" datetime, foreign key("user_id") references "users"("id") on delete cascade, primary key ("user_id"));

INSERT INTO "guru_profiles" ("user_id", "nip_nuptk", "gender", "employment_status", "created_at", "updated_at") VALUES ('01a059f0-4b8d-7325-bdf2-5c8d62d0e287', '198001012010011001', 'L', 'PNS', '2026-08-31 22:28:35', '2026-08-31 22:28:35');

-- Table: siswa_profiles
CREATE TABLE "siswa_profiles" ("user_id" varchar not null, "nisn" varchar, "nis" varchar, "academic_year_id" varchar, "gender" varchar check ("gender" in ('L', 'P')) not null, "behavior_points" integer not null default '100', "created_at" datetime, "updated_at" datetime, foreign key("user_id") references "users"("id") on delete cascade, foreign key("academic_year_id") references "academic_years"("id") on delete set null, primary key ("user_id"));

INSERT INTO "siswa_profiles" ("user_id", "nisn", "nis", "academic_year_id", "gender", "behavior_points", "created_at", "updated_at") VALUES ('01a059f0-4c9b-738a-bac4-630d2bd132ca', '0012345678', '1001', '01a059f0-497e-70cf-9c6d-0f347151910d', 'L', '100', '2026-08-31 22:28:35', '2026-08-31 22:28:35');

-- Table: classes
CREATE TABLE "classes" ("id" varchar not null, "academic_year_id" varchar not null, "name" varchar not null, "grade_level" integer not null, "major_id" varchar not null, "homeroom_teacher_id" varchar, "created_at" datetime, "updated_at" datetime, foreign key("academic_year_id") references "academic_years"("id") on delete cascade, foreign key("major_id") references "majors"("id") on delete cascade, foreign key("homeroom_teacher_id") references "users"("id") on delete set null, primary key ("id"));

INSERT INTO "classes" ("id", "academic_year_id", "name", "grade_level", "major_id", "homeroom_teacher_id", "created_at", "updated_at") VALUES ('01a059f0-4bb7-71fc-be1c-8dc05b0563b1', '01a059f0-497e-70cf-9c6d-0f347151910d', 'X RPL 1', '10', '01a059f0-49a1-7266-9fa1-987ba2291a10', '01a059f0-4b8d-7325-bdf2-5c8d62d0e287', '2026-08-31 22:28:35', '2026-08-31 22:28:35');

-- Table: class_students
CREATE TABLE "class_students" ("id" varchar not null, "class_id" varchar not null, "student_id" varchar not null, "status" varchar not null default 'ACTIVE', "created_at" datetime, "updated_at" datetime, foreign key("class_id") references "classes"("id") on delete cascade, foreign key("student_id") references "users"("id") on delete cascade, primary key ("id"));

INSERT INTO "class_students" ("id", "class_id", "student_id", "status", "created_at", "updated_at") VALUES ('01a059f0-4cc5-7353-a5d7-d1c3c56abc61', '01a059f0-4bb7-71fc-be1c-8dc05b0563b1', '01a059f0-4c9b-738a-bac4-630d2bd132ca', 'ACTIVE', '2026-08-31 22:28:35', '2026-08-31 22:28:35');

-- Table: structural_assignments
CREATE TABLE "structural_assignments" ("id" varchar not null, "guru_id" varchar not null, "role_title" varchar not null, "academic_year_id" varchar not null, "created_at" datetime, "updated_at" datetime, foreign key("guru_id") references "users"("id") on delete cascade, foreign key("academic_year_id") references "academic_years"("id") on delete cascade, primary key ("id"));

-- Table: guru_wali_students
CREATE TABLE "guru_wali_students" ("id" varchar not null, "guru_id" varchar not null, "student_id" varchar not null, "academic_year_id" varchar not null, "created_at" datetime, "updated_at" datetime, foreign key("guru_id") references "users"("id") on delete cascade, foreign key("student_id") references "users"("id") on delete cascade, foreign key("academic_year_id") references "academic_years"("id") on delete cascade, primary key ("id"));

-- Table: guru_bk_classes
CREATE TABLE "guru_bk_classes" ("id" varchar not null, "guru_id" varchar not null, "class_id" varchar not null, "academic_year_id" varchar not null, "created_at" datetime, "updated_at" datetime, foreign key("guru_id") references "users"("id") on delete cascade, foreign key("class_id") references "classes"("id") on delete cascade, foreign key("academic_year_id") references "academic_years"("id") on delete cascade, primary key ("id"));

-- Table: subjects
CREATE TABLE "subjects" ("id" varchar not null, "code" varchar not null, "name" varchar not null, "created_at" datetime, "updated_at" datetime, primary key ("id"));

INSERT INTO "subjects" ("id", "code", "name", "created_at", "updated_at") VALUES ('01a059f0-4cda-70b0-9aeb-61860eead436', 'PBO', 'Pemrograman Berorientasi Objek', '2026-08-31 22:28:35', '2026-08-31 22:28:35');

-- Table: schedules
CREATE TABLE "schedules" ("id" varchar not null, "academic_year_id" varchar not null, "class_id" varchar not null, "subject_id" varchar not null, "teacher_id" varchar not null, "day_of_week" varchar not null, "start_time" time not null, "end_time" time not null, "created_at" datetime, "updated_at" datetime, foreign key("academic_year_id") references "academic_years"("id") on delete cascade, foreign key("class_id") references "classes"("id") on delete cascade, foreign key("subject_id") references "subjects"("id") on delete cascade, foreign key("teacher_id") references "users"("id") on delete cascade, primary key ("id"));

INSERT INTO "schedules" ("id", "academic_year_id", "class_id", "subject_id", "teacher_id", "day_of_week", "start_time", "end_time", "created_at", "updated_at") VALUES ('01a059f0-4cf0-739d-a0a4-3644b68f09fe', '01a059f0-497e-70cf-9c6d-0f347151910d', '01a059f0-4bb7-71fc-be1c-8dc05b0563b1', '01a059f0-4cda-70b0-9aeb-61860eead436', '01a059f0-4b8d-7325-bdf2-5c8d62d0e287', '1', '07:00:00', '09:00:00', '2026-08-31 22:28:35', '2026-08-31 22:28:35');

-- Table: attendances
CREATE TABLE "attendances" ("id" varchar not null, "user_id" varchar not null, "tanggal" date not null, "jam_masuk" datetime, "status" varchar not null, "created_at" datetime, "updated_at" datetime, foreign key("user_id") references "users"("id") on delete cascade, primary key ("id"));

-- Table: presensi_logs
CREATE TABLE "presensi_logs" ("id" varchar not null, "user_id" varchar not null, "scan_time" datetime not null, "status" varchar not null, "snapshot_url" text, "created_at" datetime, "updated_at" datetime, foreign key("user_id") references "users"("id") on delete cascade, primary key ("id"));

-- Table: teacher_attendances
CREATE TABLE "teacher_attendances" ("id" varchar not null, "schedule_id" varchar not null, "teacher_id" varchar not null, "attendance_date" date not null, "check_in_time" datetime, "created_at" datetime, "updated_at" datetime, foreign key("schedule_id") references "schedules"("id") on delete cascade, foreign key("teacher_id") references "users"("id") on delete cascade, primary key ("id"));

-- Table: journals
CREATE TABLE "journals" ("id" varchar not null, "schedule_id" varchar, "teacher_id" varchar not null, "class_id" varchar not null, "subject_id" varchar not null, "teaching_date" date not null, "topic_material" text not null, "created_at" datetime, "updated_at" datetime, foreign key("schedule_id") references "schedules"("id") on delete set null, foreign key("teacher_id") references "users"("id") on delete cascade, foreign key("class_id") references "classes"("id") on delete cascade, foreign key("subject_id") references "subjects"("id") on delete cascade, primary key ("id"));

-- Table: journal_tasks
CREATE TABLE "journal_tasks" ("id" varchar not null, "journal_id" varchar not null, "title" varchar not null, "due_date" datetime, "created_at" datetime, "updated_at" datetime, foreign key("journal_id") references "journals"("id") on delete cascade, primary key ("id"));

-- Table: journal_task_attachments
CREATE TABLE "journal_task_attachments" ("id" varchar not null, "journal_task_id" varchar not null, "file_name" varchar not null, "file_url" text not null, "created_at" datetime, "updated_at" datetime, foreign key("journal_task_id") references "journal_tasks"("id") on delete cascade, primary key ("id"));

-- Table: student_task_submissions
CREATE TABLE "student_task_submissions" ("id" varchar not null, "journal_task_id" varchar not null, "student_id" varchar not null, "status" varchar not null default 'PENDING', "submitted_at" datetime, "created_at" datetime, "updated_at" datetime, foreign key("journal_task_id") references "journal_tasks"("id") on delete cascade, foreign key("student_id") references "users"("id") on delete cascade, primary key ("id"));

-- Table: student_task_grades
CREATE TABLE "student_task_grades" ("id" varchar not null, "submission_id" varchar not null, "teacher_id" varchar not null, "score" numeric, "created_at" datetime, "updated_at" datetime, foreign key("submission_id") references "student_task_submissions"("id") on delete cascade, foreign key("teacher_id") references "users"("id") on delete cascade, primary key ("id"));

-- Table: point_rules
CREATE TABLE "point_rules" ("id" varchar not null, "code" varchar not null, "type" varchar not null, "points" integer not null, "created_at" datetime, "updated_at" datetime, primary key ("id"));

-- Table: student_point_logs
CREATE TABLE "student_point_logs" ("id" varchar not null, "student_id" varchar not null, "point_rule_id" varchar not null, "reporter_id" varchar, "points_change" integer not null, "status" varchar not null default 'APPROVED', "created_at" datetime, "updated_at" datetime, foreign key("student_id") references "users"("id") on delete cascade, foreign key("point_rule_id") references "point_rules"("id") on delete cascade, foreign key("reporter_id") references "users"("id") on delete set null, primary key ("id"));

-- Table: kpi_indicators
CREATE TABLE "kpi_indicators" ("id" varchar not null, "code" varchar not null, "weight_percentage" numeric not null, "created_at" datetime, "updated_at" datetime, primary key ("id"));

-- Table: teacher_kpi_period_summaries
CREATE TABLE "teacher_kpi_period_summaries" ("id" varchar not null, "teacher_id" varchar not null, "academic_year_id" varchar not null, "period_month" integer not null, "final_kpi_score" numeric not null, "created_at" datetime, "updated_at" datetime, foreign key("teacher_id") references "users"("id") on delete cascade, foreign key("academic_year_id") references "academic_years"("id") on delete cascade, primary key ("id"));

-- Table: habits
CREATE TABLE "habits" ("id" varchar not null, "code" varchar not null, "title" varchar not null, "category" varchar not null, "created_at" datetime, "updated_at" datetime, primary key ("id"));

INSERT INTO "habits" ("id", "code", "title", "category", "created_at", "updated_at") VALUES ('01a059f0-4d04-71b4-a842-2249895c6542', 'HBT01', 'Sholat Dhuha', 'IBADAH', '2026-08-31 22:28:35', '2026-08-31 22:28:35');
INSERT INTO "habits" ("id", "code", "title", "category", "created_at", "updated_at") VALUES ('01a059f0-4d19-7332-8a14-30b645ae9efa', 'HBT02', 'Piket Kelas', 'KEDISIPLINAN', '2026-08-31 22:28:35', '2026-08-31 22:28:35');
INSERT INTO "habits" ("id", "code", "title", "category", "created_at", "updated_at") VALUES ('01a059f0-4d2d-70ea-afdf-2189e3ae2ad0', 'HBT03', 'Literasi Pagi', 'AKADEMIK', '2026-08-31 22:28:35', '2026-08-31 22:28:35');

-- Table: student_habit_logs
CREATE TABLE "student_habit_logs" ("id" varchar not null, "student_id" varchar not null, "habit_id" varchar not null, "logged_date" date not null, "status" varchar not null default 'PENDING', "created_at" datetime, "updated_at" datetime, foreign key("student_id") references "users"("id") on delete cascade, foreign key("habit_id") references "habits"("id") on delete cascade, primary key ("id"));

-- Table: assessments
CREATE TABLE "assessments" ("id" varchar not null, "class_id" varchar not null, "subject_id" varchar not null, "title" varchar not null, "assessment_date" date not null, "created_at" datetime, "updated_at" datetime, foreign key("class_id") references "classes"("id") on delete cascade, foreign key("subject_id") references "subjects"("id") on delete cascade, primary key ("id"));

-- Table: journal_reviews
CREATE TABLE "journal_reviews" ("id" varchar not null, "journal_id" varchar not null, "student_id" varchar not null, "rating" integer not null default '5', "review_text" text, "created_at" datetime, "updated_at" datetime, foreign key("journal_id") references "journals"("id") on delete cascade, foreign key("student_id") references "users"("id") on delete cascade, primary key ("id"));

-- Table: journal_comments
CREATE TABLE "journal_comments" ("id" varchar not null, "journal_id" varchar not null, "user_id" varchar not null, "comment_text" text not null, "created_at" datetime, "updated_at" datetime, foreign key("journal_id") references "journals"("id") on delete cascade, foreign key("user_id") references "users"("id") on delete cascade, primary key ("id"));

-- Table: student_reports
CREATE TABLE "student_reports" ("id" varchar not null, "student_id" varchar not null, "report_title" varchar not null, "report_text" text not null, "status" varchar not null default 'PENDING', "created_at" datetime, "updated_at" datetime, foreign key("student_id") references "users"("id") on delete cascade, primary key ("id"));

-- Table: habit_verifications
CREATE TABLE "habit_verifications" ("id" varchar not null, "student_habit_log_id" varchar not null, "teacher_id" varchar not null, "status" varchar not null default 'VERIFIED', "verification_note" text, "created_at" datetime, "updated_at" datetime, foreign key("student_habit_log_id") references "student_habit_logs"("id") on delete cascade, foreign key("teacher_id") references "users"("id") on delete cascade, primary key ("id"));

-- Table: teaching_administrations
CREATE TABLE "teaching_administrations" ("id" varchar not null, "guru_id" varchar not null, "subject_id" varchar not null, "document_name" varchar not null, "document_url" text not null, "created_at" datetime, "updated_at" datetime, foreign key("guru_id") references "users"("id") on delete cascade, foreign key("subject_id") references "subjects"("id") on delete cascade, primary key ("id"));

-- Table: notifications
CREATE TABLE "notifications" ("id" varchar not null, "user_id" varchar not null, "title" varchar not null, "message" text not null, "is_read" tinyint(1) not null default '0', "created_at" datetime, "updated_at" datetime, foreign key("user_id") references "users"("id") on delete cascade, primary key ("id"));

