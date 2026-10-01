<?php
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$schedules = App\Models\Schedule::with(['class.major', 'subject'])->get();
foreach ($schedules as $sched) {
    echo $sched->class->grade_level . ' ' . ($sched->class->major ? $sched->class->major->code : '') . ' ' . $sched->class->name . "\n";
}
