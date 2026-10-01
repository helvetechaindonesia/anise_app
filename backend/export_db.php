<?php

$dbFile = __DIR__ . '/database/database.sqlite';
$outputFile = __DIR__ . '/anise_app_export.sql';

if (!file_exists($dbFile)) {
    die("Database file not found at: $dbFile\n");
}

$pdo = new PDO('sqlite:' . $dbFile);
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

$sql = "-- Anise App SQLite Export\n\n";

// Get all tables
$stmt = $pdo->query("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'");
$tables = $stmt->fetchAll(PDO::FETCH_COLUMN);

foreach ($tables as $table) {
    $sql .= "-- Table: $table\n";
    $stmt = $pdo->query("SELECT sql FROM sqlite_master WHERE type='table' AND name='$table'");
    $createTable = $stmt->fetchColumn();
    $sql .= $createTable . ";\n\n";

    $stmt = $pdo->query("SELECT * FROM \"$table\"");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($rows) > 0) {
        foreach ($rows as $row) {
            $keys = array_keys($row);
            $values = array_values($row);

            $escapedValues = array_map(function ($value) use ($pdo) {
                if ($value === null) return 'NULL';
                return $pdo->quote($value);
            }, $values);

            $keysString = '"' . implode('", "', $keys) . '"';
            $valuesString = implode(", ", $escapedValues);

            $sql .= "INSERT INTO \"$table\" ($keysString) VALUES ($valuesString);\n";
        }
        $sql .= "\n";
    }
}

file_put_contents($outputFile, $sql);
echo "Berhasil! File SQL telah diekspor ke: $outputFile\n";
