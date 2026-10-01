<?php
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$guru = App\Models\User::whereIn('role_id', App\Models\Role::whereIn('name', ['GURU', 'GURU_BK'])->pluck('id'))->first();

echo "Role ID: " . $guru->role_id . "\n";
echo "Role Name: " . ($guru->role ? $guru->role->name : 'null') . "\n";
echo "Role Type Attribute: " . $guru->role_type . "\n";
