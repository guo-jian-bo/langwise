import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  final projectRoot = Directory.current;
  final libDir = Directory('${projectRoot.path}/lib');
  if (!libDir.existsSync()) {
    stderr.writeln('Cannot find lib/ under: ${projectRoot.path}');
    exit(2);
  }

  final guideAnchorImplPath = File('${projectRoot.path}/lib/common/widgets/guide_engine/guide_anchor.dart').path;
  final labelsPath = '${projectRoot.path}/tool/guide_labels.json';

  final anchorUsages = <_AnchorUsage>[];
  final dartFiles = libDir
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  for (final file in dartFiles) {
    if (file.path == guideAnchorImplPath) continue;
    final content = file.readAsStringSync();

    // Fast prefilter
    if (!content.contains('GuideAnchor(')) continue;

    // Find each GuideAnchor(...) call block (best-effort)
    final matches = RegExp(r'GuideAnchor\s*\(', multiLine: true).allMatches(content).toList();
    if (matches.isEmpty) continue;

    for (final m in matches) {
      final start = m.start;
      final callText = _extractCallText(content, start);
      if (callText == null) continue;

      final id = _extractStringArg(callText, 'id');
      final routeExpr = _extractExprArg(callText, 'route');

      if (id == null || id.isEmpty) {
        stderr.writeln('[WARN] Missing/invalid id in ${file.path}');
        continue;
      }
      if (routeExpr == null || routeExpr.isEmpty) {
        stderr.writeln('[WARN] Missing route for GuideAnchor(id: $id) in ${file.path}');
        continue;
      }

      // Enforce S1 stability: id must be a literal string.
      // If you later allow const variables, you can relax this.
      anchorUsages.add(_AnchorUsage(routeExpr: routeExpr.trim(), id: id.trim(), filePath: file.path));
    }
  }

  final anchorsByRoute = <String, Set<String>>{};
  for (final u in anchorUsages) {
    anchorsByRoute.putIfAbsent(u.routeExpr, () => <String>{}).add(u.id);
  }

  final routes = anchorsByRoute.keys.toList()..sort();

  final labels = _ensureAndLoadLabels(
    labelsPath: labelsPath,
    routes: routes,
    anchorsByRoute: anchorsByRoute,
  );

  final routeLabels = _buildRouteLabels(routes: routes, labels: labels);
  final anchorLabelsByRoute = _buildAnchorLabelsByRoute(routes: routes, anchorsByRoute: anchorsByRoute, labels: labels);
  final outPath = '${projectRoot.path}/lib/common/widgets/guide_engine/guide_manifest.g.dart';

  final out = StringBuffer();
  out.writeln("import 'package:langwise/app/routes/app_pages.dart';");
  out.writeln('');
  out.writeln('class GuideManifest {');

  out.writeln('  static const List<String> routes = <String>[');
  for (final r in routes) {
    out.writeln('    $r,');
  }
  out.writeln('  ];');
  out.writeln('');

  out.writeln('  static const Map<String, List<String>> anchorsByRoute = <String, List<String>>{');
  for (final r in routes) {
    final ids = anchorsByRoute[r]!.toList()..sort();
    out.writeln('    $r: <String>[');
    for (final id in ids) {
      out.writeln('      ${jsonEncode(id)},');
    }
    out.writeln('    ],');
  }
  out.writeln('  };');

  out.writeln('');
  out.writeln('  static const Map<String, String> routeLabels = <String, String>{');
  for (final r in routes) {
    final label = routeLabels[r];
    if (label == null || label.isEmpty) continue;
    out.writeln('    $r: ${jsonEncode(label)},');
  }
  out.writeln('  };');

  out.writeln('');
  out.writeln('  static const Map<String, Map<String, String>> anchorLabelsByRoute = <String, Map<String, String>>{');
  for (final r in routes) {
    final m = anchorLabelsByRoute[r] ?? const <String, String>{};
    if (m.isEmpty) continue;
    out.writeln('    $r: <String, String>{');
    final keys = m.keys.toList()..sort();
    for (final id in keys) {
      out.writeln('      ${jsonEncode(id)}: ${jsonEncode(m[id])},');
    }
    out.writeln('    },');
  }
  out.writeln('  };');

  out.writeln('}');
  out.writeln('');

  File(outPath)
    ..createSync(recursive: true)
    ..writeAsStringSync(out.toString());

  stdout.writeln('Generated: $outPath');
  stdout.writeln('Routes: ${routes.length}, anchors: ${anchorUsages.length}');
}

Map<String, dynamic> _ensureAndLoadLabels({
  required String labelsPath,
  required List<String> routes,
  required Map<String, Set<String>> anchorsByRoute,
}) {
  final file = File(labelsPath);

  Map<String, dynamic> existing;
  if (file.existsSync()) {
    try {
      final raw = jsonDecode(file.readAsStringSync());
      existing = (raw is Map) ? raw.cast<String, dynamic>() : <String, dynamic>{};
    } catch (_) {
      existing = <String, dynamic>{};
    }
  } else {
    existing = <String, dynamic>{};
  }

  final routesMap = _asStringMap(existing['routes']);
  final anchorsMap = _asNestedStringMap(existing['anchors']);

  for (final r in routes) {
    routesMap.putIfAbsent(r, () => _defaultRouteLabelFromExpr(r));
  }

  for (final r in routes) {
    final ids = anchorsByRoute[r]?.toList() ?? const <String>[];
    final bucket = anchorsMap.putIfAbsent(r, () => <String, String>{});
    for (final id in ids) {
      bucket.putIfAbsent(id, () => _defaultAnchorLabelFromId(id));
    }
  }

  final normalized = <String, dynamic>{
    'routes': routesMap,
    'anchors': anchorsMap,
  };

  file
    ..createSync(recursive: true)
    ..writeAsStringSync(const JsonEncoder.withIndent('  ').convert(normalized));

  return normalized;
}

Map<String, String> _buildRouteLabels({required List<String> routes, required Map<String, dynamic> labels}) {
  final routesMap = _asStringMap(labels['routes']);
  final out = <String, String>{};
  for (final r in routes) {
    final v = routesMap[r];
    if (v != null && v.trim().isNotEmpty) {
      out[r] = v.trim();
    }
  }
  return out;
}

Map<String, Map<String, String>> _buildAnchorLabelsByRoute({
  required List<String> routes,
  required Map<String, Set<String>> anchorsByRoute,
  required Map<String, dynamic> labels,
}) {
  final anchorsMap = _asNestedStringMap(labels['anchors']);
  final out = <String, Map<String, String>>{};
  for (final r in routes) {
    final ids = anchorsByRoute[r]?.toList() ?? const <String>[];
    final bucket = anchorsMap[r] ?? <String, String>{};
    final m = <String, String>{};
    for (final id in ids) {
      final v = bucket[id];
      if (v != null && v.trim().isNotEmpty) {
        m[id] = v.trim();
      }
    }
    out[r] = m;
  }
  return out;
}

Map<String, String> _asStringMap(dynamic v) {
  if (v is Map) {
    return v.map((k, val) => MapEntry(k.toString(), val?.toString() ?? '')).cast<String, String>();
  }
  return <String, String>{};
}

Map<String, Map<String, String>> _asNestedStringMap(dynamic v) {
  if (v is Map) {
    final out = <String, Map<String, String>>{};
    for (final entry in v.entries) {
      final k = entry.key.toString();
      out[k] = _asStringMap(entry.value);
    }
    return out;
  }
  return <String, Map<String, String>>{};
}

String _defaultRouteLabelFromExpr(String routeExpr) {
  final constName = _extractRoutesConstName(routeExpr);
  if (constName == null || constName.isEmpty) {
    return routeExpr;
  }
  final upperTokens = constName.split('_').where((e) => e.trim().isNotEmpty).toList();
  if (upperTokens.isEmpty) return routeExpr;

  final glossary = _glossary();
  // Special-case for APPLICATION: prefer a more meaningful Chinese label.
  if (constName == 'APPLICATION') {
    return glossary['APPLICATION'] ?? '应用主框架';
  }

  final mapped = upperTokens.map((t) => glossary[t] ?? _titleCase(t.toLowerCase())).toList();
  return mapped.join('');
}

String _defaultAnchorLabelFromId(String id) {
  final tokens = id
      .split(RegExp(r'[_\-\s]+'))
      .where((e) => e.trim().isNotEmpty)
      .toList();
  if (tokens.isEmpty) return id;
  final glossary = _glossary();
  final mapped = tokens.map((t) {
    final k = t.toUpperCase();
    return glossary[k] ?? _titleCase(t.toLowerCase());
  }).toList();
  return mapped.join('');
}

String? _extractRoutesConstName(String routeExpr) {
  final m = RegExp(r'Routes\.([A-Z0-9_]+)\b').firstMatch(routeExpr);
  return m?.group(1);
}

String _titleCase(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}

Map<String, String> _glossary() {
  return <String, String>{
    'APPLICATION': '应用主框架',
    'USER': '用户',
    'CENTER': '中心',
    'HOME': '首页',
    'TODAY': '今日',
    'PLAN': '计划',
    'PRACTICE': '练习',
    'QUESTION': '题目',
    'QUESTIONS': '题目',
    'EDIT': '编辑',
    'PROFILE': '资料',
    'SAVE': '保存',
    'BTN': '按钮',
    'BUTTON': '按钮',
    'NAV': '导航',
    'TAB': '标签',
    'DIALOG': '弹窗',
  };
}

class _AnchorUsage {
  final String routeExpr;
  final String id;
  final String filePath;

  _AnchorUsage({required this.routeExpr, required this.id, required this.filePath});
}

/// Extracts the text from `GuideAnchor(` to its matching `)` (best-effort).
String? _extractCallText(String content, int startIndex) {
  final openParenIndex = content.indexOf('(', startIndex);
  if (openParenIndex < 0) return null;

  var depth = 0;
  var inString = false;
  String? stringQuote;
  var escape = false;
  for (var i = openParenIndex; i < content.length; i++) {
    final ch = content[i];

    if (inString) {
      if (escape) {
        escape = false;
        continue;
      }
      if (ch == r'\\') {
        escape = true;
        continue;
      }
      if (ch == stringQuote) {
        inString = false;
        stringQuote = null;
      }
      continue;
    }

    if (ch == "'" || ch == '"') {
      inString = true;
      stringQuote = ch;
      continue;
    }

    if (ch == '(') depth++;
    if (ch == ')') {
      depth--;
      if (depth == 0) {
        return content.substring(startIndex, i + 1);
      }
    }
  }
  return null;
}

/// Extracts a string literal argument like `id: 'xxx'` or `id: "xxx"`.
String? _extractStringArg(String callText, String name) {
  final re = RegExp('$name\\s*:\\s*(?:r)?([\"\\\'])(.*?)\\1', dotAll: true);
  final m = re.firstMatch(callText);
  return m?.group(2);
}

/// Extracts a non-string expression argument like `route: Routes.USER_CENTER`.
/// Stops at the next comma at the same nesting level (best-effort).
String? _extractExprArg(String callText, String name) {
  final idx = callText.indexOf('$name:');
  if (idx < 0) return null;

  var i = idx + name.length + 1; // skip "name:"
  while (i < callText.length && callText[i].trim().isEmpty) i++;

  final start = i;
  var depthParen = 0;
  var depthBrace = 0;
  var depthBracket = 0;
  var inString = false;
  String? stringQuote;

  for (; i < callText.length; i++) {
    final ch = callText[i];

    if (inString) {
      if (ch == stringQuote) {
        inString = false;
        stringQuote = null;
      }
      continue;
    }

    if (ch == "'" || ch == '"') {
      inString = true;
      stringQuote = ch;
      continue;
    }

    if (ch == '(') depthParen++;
    if (ch == ')') {
      if (depthParen > 0) depthParen--;
    }
    if (ch == '{') depthBrace++;
    if (ch == '}') {
      if (depthBrace > 0) depthBrace--;
    }
    if (ch == '[') depthBracket++;
    if (ch == ']') {
      if (depthBracket > 0) depthBracket--;
    }

    final atTopLevel = depthParen == 0 && depthBrace == 0 && depthBracket == 0;
    if (atTopLevel && ch == ',') {
      return callText.substring(start, i).trim();
    }
    if (atTopLevel && ch == ')') {
      return callText.substring(start, i).trim();
    }
  }

  return callText.substring(start).trim();
}