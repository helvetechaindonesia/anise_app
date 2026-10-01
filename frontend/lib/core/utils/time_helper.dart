class TimeHelper {
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 0 && hour <= 10) {
      return 'Selamat Pagi,';
    } else if (hour > 10 && hour <= 15) {
      return 'Selamat Siang,';
    } else if (hour > 15 && hour <= 18) {
      return 'Selamat Sore,';
    } else {
      return 'Selamat Malam,';
    }
  }
}
