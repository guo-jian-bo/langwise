import 'dart:async';
import 'dart:math';

import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';

class SearchHintRotator {
  final RxString currentHint = ''.obs;

  final Random _random = Random();
  Timer? _timer;
  List<_WeightedSearchHint> _hints = <_WeightedSearchHint>[];
  List<String> _currentRoundHints = <String>[];
  int _currentIndex = 0;

  void updateHints(List<ZhenduScriptQuerySearchHintEntity> hints) {
    final Map<String, int> uniqueHints = <String, int>{};
    for (final ZhenduScriptQuerySearchHintEntity hint in hints) {
      final String text = (hint.text ?? '').trim();
      if (text.isEmpty) continue;
      final int weight = hint.weight ?? 0;
      final int? currentWeight = uniqueHints[text];
      if (currentWeight == null || weight > currentWeight) {
        uniqueHints[text] = weight;
      }
    }
    _hints = uniqueHints.entries
        .map(
          (entry) => _WeightedSearchHint(
            text: entry.key,
            weight: entry.value > 0 ? entry.value : 1,
          ),
        )
        .toList();
    _currentRoundHints = _buildWeightedRoundHints();
    _currentIndex = 0;
    _timer?.cancel();

    if (_currentRoundHints.isEmpty) {
      currentHint.value = '';
      return;
    }

    currentHint.value = _currentRoundHints.first;
    if (_currentRoundHints.length == 1) {
      return;
    }

    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _advanceHint();
    });
  }

  void _advanceHint() {
    if (_currentRoundHints.isEmpty) return;
    _currentIndex++;
    if (_currentIndex >= _currentRoundHints.length) {
      _currentRoundHints = _buildWeightedRoundHints();
      _currentIndex = 0;
    }
    if (_currentRoundHints.isEmpty) {
      currentHint.value = '';
      return;
    }
    currentHint.value = _currentRoundHints[_currentIndex];
  }

  List<String> _buildWeightedRoundHints() {
    if (_hints.isEmpty) return <String>[];
    final List<_WeightedSearchHint> remaining =
        List<_WeightedSearchHint>.from(_hints);
    final List<String> roundHints = <String>[];
    while (remaining.isNotEmpty) {
      final int totalWeight = remaining.fold<int>(
        0,
        (sum, item) => sum + item.weight,
      );
      double target = _random.nextDouble() * totalWeight;
      int selectedIndex = remaining.length - 1;
      for (int i = 0; i < remaining.length; i++) {
        target -= remaining[i].weight;
        if (target < 0) {
          selectedIndex = i;
          break;
        }
      }
      roundHints.add(remaining.removeAt(selectedIndex).text);
    }
    return roundHints;
  }

  void dispose() {
    _timer?.cancel();
  }
}

class _WeightedSearchHint {
  final String text;
  final int weight;

  const _WeightedSearchHint({
    required this.text,
    required this.weight,
  });
}
