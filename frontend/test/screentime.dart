void main() {
  final now = DateTime(2026, 9, 9, 10, 55, 44);
  
  final accounts = [
    {
      'email': 'Anggazaidan4@gmail.com',
      'start': DateTime(2026, 9, 8, 19, 0),
    },
    {
      'email': 'Arfaaditya1189@gmail.com',
      'start': DateTime(2026, 9, 9, 4, 0),
    },
    {
      'email': 'Putrasektarya26@gmail.com',
      'start': DateTime(2026, 9, 9, 5, 30),
    },
    {
      'email': 'tristanpratama111@gmail.com',
      'start': DateTime(2026, 9, 9, 2, 30),
    },
  ];

  print('======================================================');
  print('📊 ACTIVE SESSIONS REPORT - HELVETECHA SIS CLIENT');
  print('======================================================');
  print('Current Time : \/\/\ \:\:\ WIB\n');

  for (var i = 0; i < accounts.length; i++) {
    final email = accounts[i]['email'] as String;
    final start = accounts[i]['start'] as DateTime;
    
    final diff = now.difference(start);
    final hours = diff.inHours;
    final minutes = diff.inMinutes.remainder(60);
    
    final startDateStr = '\/\/\';
    final startTimeStr = '\:\';
    
    print('[\] \');
    print('    Logged in : \ \ WIB');
    print('    Screentime: \ hours \ minutes 🚀');
    print('');
  }
  print('======================================================');
  print('STATUS: 4 USERS ONLINE - SERVERS STABLE');
  print('======================================================');
}
