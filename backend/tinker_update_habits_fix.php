<?php
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

Illuminate\Support\Facades\DB::statement('PRAGMA foreign_keys = OFF;');
App\Models\StudentHabitLog::truncate();
App\Models\Habit::truncate();
Illuminate\Support\Facades\DB::statement('PRAGMA foreign_keys = ON;');

$habits = [
    ['code' => 'HBT01', 'title' => 'Bangun Pagi', 'category' => 'KEDISIPLINAN'],
    ['code' => 'HBT02', 'title' => 'Beribadah', 'category' => 'IBADAH'],
    ['code' => 'HBT03', 'title' => 'Berolahraga', 'category' => 'KESEHATAN'],
    ['code' => 'HBT04', 'title' => 'Makan Sehat & Bergizi', 'category' => 'KESEHATAN'],
    ['code' => 'HBT05', 'title' => 'Gemar Belajar', 'category' => 'AKADEMIK'],
    ['code' => 'HBT06', 'title' => 'Bermasyarakat', 'category' => 'SOSIAL'],
    ['code' => 'HBT07', 'title' => 'Tidur Cepat', 'category' => 'KEDISIPLINAN'],
];

foreach ($habits as $habit) {
    App\Models\Habit::create([
        'code' => $habit['code'],
        'title' => $habit['title'],
        'category' => $habit['category'],
    ]);
}
echo "Habits updated to 7 new ones.\n";
