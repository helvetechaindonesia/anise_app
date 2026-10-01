<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use Rap2hpoutre\FastExcel\FastExcel;

$files = glob(storage_path('app/master-file/*.xlsx'));
foreach ($files as $file) {
    echo "--- " . basename($file) . " ---\n";
    try {
        $collection = (new FastExcel)->import($file);
        if ($collection->count() > 0) {
            $first = (array) $collection->first();
            echo "Header: " . implode(", ", array_keys($first)) . "\n";
            echo "Row 1: " . implode(", ", array_values($first)) . "\n";
        } else {
            echo "Empty file.\n";
        }
    } catch (\Exception $e) {
        echo "Error: " . $e->getMessage() . "\n";
    }
    echo "\n";
}
