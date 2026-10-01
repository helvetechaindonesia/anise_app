<?php
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$user = App\Models\User::where('username', '198510082022211002')->first(); // Abdullah (Guru)
$request = Illuminate\Http\Request::create('/api/habits/guru-stats', 'GET');
$request->setUserResolver(function () use ($user) {
    return $user;
});
$controller = new App\Http\Controllers\Api\HabitController();
$response = $controller->guruHabitStats($request);
echo json_encode($response->getData());
