class LearnRecordConstants {
  LearnRecordConstants._();

  static const String tableName = 'content_learn_records';

  static const String statusPending = 'pending';
  static const String statusFailed = 'failed';
  static const String statusSuccess = 'success';

  static const int minValidLearnSeconds = 1;
  static const int maxRetentionDays = 7;
}
