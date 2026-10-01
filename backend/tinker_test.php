<?php
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

// simulate the logged in user as abdullah
$guru = App\Models\User::where('username', 'abdullah')->first();
if (!$guru) {
    // try to get any guru
    $guru = App\Models\User::whereIn('role_id', App\Models\Role::whereIn('name', ['GURU', 'GURU_BK'])->pluck('id'))->first();
}

echo "Testing as: " . $guru->username . "\n";
$controller = new App\Http\Controllers\Api\HabitController();
// simulate request
$request = Illuminate\Http\Request::create('/api/habits/monitored-students', 'GET');
$request->setUserResolver(function () use ($guru) { return $guru; });
$response = $controller->monitoredStudents($request);
echo json_encode($response->getData(), JSON_PRETTY_PRINT);
