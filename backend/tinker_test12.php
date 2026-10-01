<?php
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$gurus = App\Models\User::whereIn('role_id', App\Models\Role::whereIn('name', ['GURU', 'GURU_BK'])->pluck('id'))->get();
foreach ($gurus as $g) {
    echo $g->username . " - " . $g->full_name . "\n";
}
