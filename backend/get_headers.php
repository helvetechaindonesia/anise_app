<?php
require __DIR__ . '/vendor/autoload.php';

$files = glob(__DIR__ . '/storage/app/master-file/master-file/*.xlsx');
$result = [];

foreach ($files as $file) {
    try {
        $collection = (new \Rap2hpoutre\FastExcel\FastExcel)->import($file);
        $firstRow = $collection->first();
        // Since some files have titles on row 1, their actual headers are row 2 (which becomes row 1 in fastexcel collection, wait, FastExcel assumes row 1 is headers).
        // If FastExcel assumes row 1 is headers, the actual data row 1 (which was excel row 2) is the first item in the collection!
        $dataRow = $collection->first();
        if ($dataRow) {
            $result[basename($file)] = [
                'headers_from_row_1' => array_keys((array)$firstRow),
                'data_row_1' => array_values((array)$dataRow),
            ];
        } else {
            $result[basename($file)] = [];
        }
    } catch (\Exception $e) {
        $result[basename($file)] = "Error: " . $e->getMessage();
    }
}

echo json_encode($result, JSON_PRETTY_PRINT);
