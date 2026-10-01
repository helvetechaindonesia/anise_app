<?php
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$major = App\Models\Major::where('code', 'RPL')->first();
if ($major) {
    $major->code = 'MIPA';
    $major->name = 'Matematika dan Ilmu Pengetahuan Alam';
    $major->save();
    echo "Major RPL updated to MIPA.\n";
} else {
    echo "Major RPL not found.\n";
}

$major2 = App\Models\Major::where('code', 'TKJ')->first();
if ($major2) {
    $major2->code = 'IPS';
    $major2->name = 'Ilmu Pengetahuan Sosial';
    $major2->save();
    echo "Major TKJ updated to IPS.\n";
} else {
    echo "Major TKJ not found.\n";
}
