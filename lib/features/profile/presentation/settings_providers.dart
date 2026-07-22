import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../climbing_routes/domain/route_grade.dart';

/// The grading system the user wants approximate conversions into; null
/// means "original grades only". Persisted across restarts.
class PreferredGradingSystemNotifier extends AsyncNotifier<GradingSystem?> {
  static const _key = 'preferred_grading_system';

  @override
  Future<GradingSystem?> build() async {
    final prefs = await SharedPreferences.getInstance();
    return GradingSystem.values.asNameMap()[prefs.getString(_key) ?? ''];
  }

  Future<void> set(GradingSystem? system) async {
    final prefs = await SharedPreferences.getInstance();
    if (system == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, system.name);
    }
    state = AsyncData(system);
  }
}

final preferredGradingSystemProvider =
    AsyncNotifierProvider<PreferredGradingSystemNotifier, GradingSystem?>(
      PreferredGradingSystemNotifier.new,
    );
