<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

foreach (\App\Models\Role::all() as $r) {
    $r->name = strtoupper(str_replace(' ', '_', $r->name));
    $r->save();
}
foreach (\App\Models\User::all() as $u) {
    if ($u->username == 'tu1') {
        $role = \App\Models\Role::where('name', 'TATA_USAHA')->first();
        if ($role) {
            $u->role_id = $role->id;
            $u->save();
        }
    }
}
echo "fixed\n";
