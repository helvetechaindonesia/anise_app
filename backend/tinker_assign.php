<?php
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$gurus = App\Models\User::whereIn('role_id', App\Models\Role::whereIn('name', ['GURU', 'GURU_BK'])->pluck('id'))->get();
$academicYear = App\Models\AcademicYear::where('is_active', true)->first();

$classes = App\Models\SchoolClass::all();
$students = App\Models\User::where('role_id', App\Models\Role::where('name', 'SISWA')->value('id'))->get();

// Assign class to each guru
foreach ($gurus as $index => $guru) {
    if (isset($classes[$index])) {
        $classes[$index]->wali_kelas_id = $guru->id;
        $classes[$index]->save();
        
        $classStudents = $students->slice($index * 5, 5);
        foreach ($classStudents as $siswa) {
            App\Models\ClassStudent::firstOrCreate([
                'class_id' => $classes[$index]->id,
                'student_id' => $siswa->id
            ]);
            App\Models\GuruWaliStudent::firstOrCreate([
                'guru_id' => $guru->id,
                'student_id' => $siswa->id,
                'academic_year_id' => $academicYear->id
            ]);
        }
    }
}
echo "Assigned students to ALL gurus.\n";
