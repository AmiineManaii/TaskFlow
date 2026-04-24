class DateUtils {
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  static String formatDateTime(DateTime date) {
    return '${formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) return 'Il y a ${diff.inMinutes} min';
      return 'Il y a ${diff.inHours}h';
    }
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} jours';
    return formatDate(date);
  }

  static String formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(date.year, date.month, date.day);
    final diff = due.difference(today).inDays;

    if (diff < 0) return 'En retard de ${-diff}j';
    if (diff == 0) return "Aujourd'hui";
    if (diff == 1) return 'Demain';
    if (diff < 7) return 'Dans ${diff}j';
    return formatDate(date);
  }
}
