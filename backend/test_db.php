$schedules = DB::table('schedules')->take(5)->get();
echo json_encode($schedules);
