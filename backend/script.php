<?php
require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

foreach (\App\Models\User::all() as $u) {
    if ($u->username == 'tu1') {
        $u->role_id = \App\Models\Role::where('name', 'TATA_USAHA')->first()->id;
        $u->save();
        echo "Updated tu1 role\n";
    }
}
echo "Done\n";
