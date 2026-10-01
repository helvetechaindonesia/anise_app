<?php
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$user = App\Models\User::where('username', 'abdullah')->first();
$schedules = App\Models\Schedule::where('teacher_id', $user->id)->with(['class.major', 'subject'])->get();
foreach ($schedules as $sched) {
    echo $sched->class->grade_level . ' ' . ($sched->class->major ? $sched->class->major->code : '') . ' ' . $sched->class->name . "\n";
}
