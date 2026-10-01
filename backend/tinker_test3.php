<?php
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$guru = App\Models\User::where('username', 'abdullah')->first();
if (!$guru) {
    $guru = App\Models\User::whereIn('role_id', App\Models\Role::whereIn('name', ['GURU', 'GURU_BK'])->pluck('id'))->first();
}

$student = App\Models\User::where('role_id', App\Models\Role::where('name', 'SISWA')->value('id'))->first();

$controller = new App\Http\Controllers\Api\HabitController();
$request = Illuminate\Http\Request::create('/api/habits/stats?student_id=' . $student->id, 'GET', ['student_id' => $student->id]);
$request->setUserResolver(function () use ($guru) { return $guru; });
try {
    $response = $controller->getHabitStats($request);
    echo json_encode($response->getData(), JSON_PRETTY_PRINT);
} catch (\Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n" . $e->getTraceAsString();
}
