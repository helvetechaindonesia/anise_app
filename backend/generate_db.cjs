const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const modelsDir = path.join(__dirname, 'app', 'Models');
const migrationsDir = path.join(__dirname, 'database', 'migrations');

if (!fs.existsSync(modelsDir)) fs.mkdirSync(modelsDir, { recursive: true });
if (!fs.existsSync(migrationsDir)) fs.mkdirSync(migrationsDir, { recursive: true });

function getTimestamp(offset) {
    const now = new Date(Date.now() + offset * 1000);
    const pad = n => n.toString().padStart(2, '0');
    return `${now.getFullYear()}_${pad(now.getMonth() + 1)}_${pad(now.getDate())}_${pad(now.getHours())}${pad(now.getMinutes())}${pad(now.getSeconds())}`;
}

function generateModel(name, table, fillable) {
    const content = `<?php

namespace App\\Models;

use Illuminate\\Database\\Eloquent\\Factories\\HasFactory;
use Illuminate\\Database\\Eloquent\\Model;
use Illuminate\\Database\\Eloquent\\Concerns\\HasUuids;

class ${name} extends Model
{
    use HasFactory, HasUuids;

    protected $table = '${table}';
    protected $fillable = [
        ${fillable.map(f => `'${f}'`).join(',\n        ')}
    ];
}
`;
    // For GuruProfile and SiswaProfile, primary key is user_id
    let modifiedContent = content;
    if (table === 'guru_profiles' || table === 'siswa_profiles') {
        modifiedContent = modifiedContent.replace(
            `protected $table = '${table}';`,
            `protected $table = '${table}';\n    protected $primaryKey = 'user_id';\n    public $incrementing = false;\n    protected $keyType = 'string';`
        );
    }

    fs.writeFileSync(path.join(modelsDir, `${name}.php`), modifiedContent);
}

function generateMigration(name, table, upContent, offset) {
    const ts = getTimestamp(offset);
    const filename = `${ts}_create_${table}_table.php`;
    
    let pk = `$table->uuid('id')->primary();`;
    if (table === 'guru_profiles' || table === 'siswa_profiles') pk = '';

    const content = `<?php

use Illuminate\\Database\\Migrations\\Migration;
use Illuminate\\Database\\Schema\\Blueprint;
use Illuminate\\Support\\Facades\\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('${table}', function (Blueprint $table) {
            ${pk}
${upContent}
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('${table}');
    }
};
`;
    fs.writeFileSync(path.join(migrationsDir, filename), content);
}

const schemas = [
    {
        model: 'AcademicYear', table: 'academic_years',
        fillable: ['name', 'semester', 'is_active', 'start_date', 'end_date'],
        up: `            $table->string('name');
            $table->enum('semester', ['GANJIL', 'GENAP']);
            $table->boolean('is_active')->default(false);
            $table->date('start_date');
            $table->date('end_date');`
    },
    {
        model: 'Major', table: 'majors',
        fillable: ['code', 'name'],
        up: `            $table->string('code')->unique();
            $table->string('name');`
    },
    {
        model: 'GuruProfile', table: 'guru_profiles',
        fillable: ['user_id', 'nip_nuptk', 'gender', 'employment_status'],
        up: `            $table->foreignUuid('user_id')->primary()->constrained('users')->cascadeOnDelete();
            $table->string('nip_nuptk')->nullable();
            $table->enum('gender', ['L', 'P']);
            $table->string('employment_status')->nullable();`
    },
    {
        model: 'SiswaProfile', table: 'siswa_profiles',
        fillable: ['user_id', 'nisn', 'nis', 'academic_year_id', 'gender', 'behavior_points'],
        up: `            $table->foreignUuid('user_id')->primary()->constrained('users')->cascadeOnDelete();
            $table->string('nisn')->nullable();
            $table->string('nis')->nullable();
            $table->foreignUuid('academic_year_id')->nullable()->constrained('academic_years')->nullOnDelete();
            $table->enum('gender', ['L', 'P']);
            $table->integer('behavior_points')->default(100);`
    },
    {
        model: 'SchoolClass', table: 'classes',
        fillable: ['academic_year_id', 'name', 'grade_level', 'major_id', 'homeroom_teacher_id'],
        up: `            $table->foreignUuid('academic_year_id')->constrained('academic_years')->cascadeOnDelete();
            $table->string('name');
            $table->smallInteger('grade_level');
            $table->foreignUuid('major_id')->constrained('majors')->cascadeOnDelete();
            $table->foreignUuid('homeroom_teacher_id')->nullable()->constrained('users')->nullOnDelete();`
    },
    {
        model: 'ClassStudent', table: 'class_students',
        fillable: ['class_id', 'student_id', 'status'],
        up: `            $table->foreignUuid('class_id')->constrained('classes')->cascadeOnDelete();
            $table->foreignUuid('student_id')->constrained('users')->cascadeOnDelete();
            $table->string('status')->default('ACTIVE');`
    },
    {
        model: 'StructuralAssignment', table: 'structural_assignments',
        fillable: ['guru_id', 'role_title', 'academic_year_id'],
        up: `            $table->foreignUuid('guru_id')->constrained('users')->cascadeOnDelete();
            $table->string('role_title');
            $table->foreignUuid('academic_year_id')->constrained('academic_years')->cascadeOnDelete();`
    },
    {
        model: 'GuruWaliStudent', table: 'guru_wali_students',
        fillable: ['guru_id', 'student_id', 'academic_year_id'],
        up: `            $table->foreignUuid('guru_id')->constrained('users')->cascadeOnDelete();
            $table->foreignUuid('student_id')->constrained('users')->cascadeOnDelete();
            $table->foreignUuid('academic_year_id')->constrained('academic_years')->cascadeOnDelete();`
    },
    {
        model: 'GuruBkClass', table: 'guru_bk_classes',
        fillable: ['guru_id', 'class_id', 'academic_year_id'],
        up: `            $table->foreignUuid('guru_id')->constrained('users')->cascadeOnDelete();
            $table->foreignUuid('class_id')->constrained('classes')->cascadeOnDelete();
            $table->foreignUuid('academic_year_id')->constrained('academic_years')->cascadeOnDelete();`
    },
    {
        model: 'Subject', table: 'subjects',
        fillable: ['code', 'name'],
        up: `            $table->string('code')->unique();
            $table->string('name');`
    },
    {
        model: 'Schedule', table: 'schedules',
        fillable: ['academic_year_id', 'class_id', 'subject_id', 'teacher_id', 'day_of_week', 'start_time', 'end_time'],
        up: `            $table->foreignUuid('academic_year_id')->constrained('academic_years')->cascadeOnDelete();
            $table->foreignUuid('class_id')->constrained('classes')->cascadeOnDelete();
            $table->foreignUuid('subject_id')->constrained('subjects')->cascadeOnDelete();
            $table->foreignUuid('teacher_id')->constrained('users')->cascadeOnDelete();
            $table->string('day_of_week');
            $table->time('start_time');
            $table->time('end_time');`
    },
    {
        model: 'Attendance', table: 'attendances',
        fillable: ['user_id', 'tanggal', 'jam_masuk', 'status'],
        up: `            $table->foreignUuid('user_id')->constrained('users')->cascadeOnDelete();
            $table->date('tanggal');
            $table->timestamp('jam_masuk')->nullable();
            $table->string('status');`
    },
    {
        model: 'PresensiLog', table: 'presensi_logs',
        fillable: ['user_id', 'scan_time', 'status', 'snapshot_url'],
        up: `            $table->foreignUuid('user_id')->constrained('users')->cascadeOnDelete();
            $table->timestamp('scan_time');
            $table->string('status');
            $table->text('snapshot_url')->nullable();`
    },
    {
        model: 'TeacherAttendance', table: 'teacher_attendances',
        fillable: ['schedule_id', 'teacher_id', 'attendance_date', 'check_in_time'],
        up: `            $table->foreignUuid('schedule_id')->constrained('schedules')->cascadeOnDelete();
            $table->foreignUuid('teacher_id')->constrained('users')->cascadeOnDelete();
            $table->date('attendance_date');
            $table->timestamp('check_in_time')->nullable();`
    },
    {
        model: 'Journal', table: 'journals',
        fillable: ['schedule_id', 'teacher_id', 'class_id', 'subject_id', 'teaching_date', 'topic_material'],
        up: `            $table->foreignUuid('schedule_id')->nullable()->constrained('schedules')->nullOnDelete();
            $table->foreignUuid('teacher_id')->constrained('users')->cascadeOnDelete();
            $table->foreignUuid('class_id')->constrained('classes')->cascadeOnDelete();
            $table->foreignUuid('subject_id')->constrained('subjects')->cascadeOnDelete();
            $table->date('teaching_date');
            $table->text('topic_material');`
    },
    {
        model: 'JournalTask', table: 'journal_tasks',
        fillable: ['journal_id', 'title', 'due_date'],
        up: `            $table->foreignUuid('journal_id')->constrained('journals')->cascadeOnDelete();
            $table->string('title');
            $table->timestamp('due_date')->nullable();`
    },
    {
        model: 'JournalTaskAttachment', table: 'journal_task_attachments',
        fillable: ['journal_task_id', 'file_name', 'file_url'],
        up: `            $table->foreignUuid('journal_task_id')->constrained('journal_tasks')->cascadeOnDelete();
            $table->string('file_name');
            $table->text('file_url');`
    },
    {
        model: 'StudentTaskSubmission', table: 'student_task_submissions',
        fillable: ['journal_task_id', 'student_id', 'status', 'submitted_at'],
        up: `            $table->foreignUuid('journal_task_id')->constrained('journal_tasks')->cascadeOnDelete();
            $table->foreignUuid('student_id')->constrained('users')->cascadeOnDelete();
            $table->string('status')->default('PENDING');
            $table->timestamp('submitted_at')->nullable();`
    },
    {
        model: 'StudentTaskGrade', table: 'student_task_grades',
        fillable: ['submission_id', 'teacher_id', 'score'],
        up: `            $table->foreignUuid('submission_id')->constrained('student_task_submissions')->cascadeOnDelete();
            $table->foreignUuid('teacher_id')->constrained('users')->cascadeOnDelete();
            $table->decimal('score', 5, 2)->nullable();`
    },
    {
        model: 'PointRule', table: 'point_rules',
        fillable: ['code', 'type', 'points'],
        up: `            $table->string('code')->unique();
            $table->string('type');
            $table->integer('points');`
    },
    {
        model: 'StudentPointLog', table: 'student_point_logs',
        fillable: ['student_id', 'point_rule_id', 'reporter_id', 'points_change', 'status'],
        up: `            $table->foreignUuid('student_id')->constrained('users')->cascadeOnDelete();
            $table->foreignUuid('point_rule_id')->constrained('point_rules')->cascadeOnDelete();
            $table->foreignUuid('reporter_id')->nullable()->constrained('users')->nullOnDelete();
            $table->integer('points_change');
            $table->string('status')->default('APPROVED');`
    },
    {
        model: 'KpiIndicator', table: 'kpi_indicators',
        fillable: ['code', 'weight_percentage'],
        up: `            $table->string('code')->unique();
            $table->decimal('weight_percentage', 5, 2);`
    },
    {
        model: 'TeacherKpiPeriodSummary', table: 'teacher_kpi_period_summaries',
        fillable: ['teacher_id', 'academic_year_id', 'period_month', 'final_kpi_score'],
        up: `            $table->foreignUuid('teacher_id')->constrained('users')->cascadeOnDelete();
            $table->foreignUuid('academic_year_id')->constrained('academic_years')->cascadeOnDelete();
            $table->smallInteger('period_month');
            $table->decimal('final_kpi_score', 5, 2);`
    },
    {
        model: 'Habit', table: 'habits',
        fillable: ['code', 'title', 'category'],
        up: `            $table->string('code')->unique();
            $table->string('title');
            $table->string('category');`
    },
    {
        model: 'StudentHabitLog', table: 'student_habit_logs',
        fillable: ['student_id', 'habit_id', 'logged_date', 'status'],
        up: `            $table->foreignUuid('student_id')->constrained('users')->cascadeOnDelete();
            $table->foreignUuid('habit_id')->constrained('habits')->cascadeOnDelete();
            $table->date('logged_date');
            $table->string('status')->default('PENDING');`
    },
    {
        model: 'Assessment', table: 'assessments',
        fillable: ['class_id', 'subject_id', 'title', 'assessment_date'],
        up: `            $table->foreignUuid('class_id')->constrained('classes')->cascadeOnDelete();
            $table->foreignUuid('subject_id')->constrained('subjects')->cascadeOnDelete();
            $table->string('title');
            $table->date('assessment_date');`
    },
    // Missing schemas
    {
        model: 'JournalReview', table: 'journal_reviews',
        fillable: ['journal_id', 'student_id', 'rating', 'review_text'],
        up: `            $table->foreignUuid('journal_id')->constrained('journals')->cascadeOnDelete();
            $table->foreignUuid('student_id')->constrained('users')->cascadeOnDelete();
            $table->integer('rating')->default(5);
            $table->text('review_text')->nullable();`
    },
    {
        model: 'JournalComment', table: 'journal_comments',
        fillable: ['journal_id', 'user_id', 'comment_text'],
        up: `            $table->foreignUuid('journal_id')->constrained('journals')->cascadeOnDelete();
            $table->foreignUuid('user_id')->constrained('users')->cascadeOnDelete();
            $table->text('comment_text');`
    },
    {
        model: 'StudentReport', table: 'student_reports',
        fillable: ['student_id', 'report_title', 'report_text', 'status'],
        up: `            $table->foreignUuid('student_id')->constrained('users')->cascadeOnDelete();
            $table->string('report_title');
            $table->text('report_text');
            $table->string('status')->default('PENDING');`
    },
    {
        model: 'HabitVerification', table: 'habit_verifications',
        fillable: ['student_habit_log_id', 'teacher_id', 'status', 'verification_note'],
        up: `            $table->foreignUuid('student_habit_log_id')->constrained('student_habit_logs')->cascadeOnDelete();
            $table->foreignUuid('teacher_id')->constrained('users')->cascadeOnDelete();
            $table->string('status')->default('VERIFIED');
            $table->text('verification_note')->nullable();`
    },
    {
        model: 'TeachingAdministration', table: 'teaching_administrations',
        fillable: ['guru_id', 'subject_id', 'document_name', 'document_url'],
        up: `            $table->foreignUuid('guru_id')->constrained('users')->cascadeOnDelete();
            $table->foreignUuid('subject_id')->constrained('subjects')->cascadeOnDelete();
            $table->string('document_name');
            $table->text('document_url');`
    },
    {
        model: 'Notification', table: 'notifications',
        fillable: ['user_id', 'title', 'message', 'is_read'],
        up: `            $table->foreignUuid('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('title');
            $table->text('message');
            $table->boolean('is_read')->default(false);`
    }
];

schemas.forEach((s, i) => {
    generateModel(s.model, s.table, s.fillable);
    generateMigration(s.model, s.table, s.up, i * 2); // 2 second offsets for sequential filenames
    console.log(`Generated ${s.model}`);
});
