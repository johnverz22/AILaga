import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';

/// Lazily initializes the [AppDatabase] as a singleton.
///
/// The database file path is resolved by [path_provider] inside the
/// [AppDatabase] constructor (via [LazyDatabase]).  Disposing the provider
/// (e.g., when the app shuts down) will cleanly close the connection.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
