<?php
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$user = App\Models\User::where('username', 'sugiono')->first();
if ($user) {
    echo "Sugiono Role ID: " . $user->role_id . "\n";
    echo "Sugiono Role Name: " . ($user->role ? $user->role->name : 'none') . "\n";
} else {
    echo "Sugiono not found\n";
}
