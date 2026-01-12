import 'dart:convert';
import 'package:http/http.dart' as http;

/// CDN base URL for fetching icon data
const String cdnBaseURL =
    'https://ravikovind.github.io/flutter-lucide-animated/v1';

/// Registry data containing list of available icons
class Registry {
  final String version;
  final DateTime updatedAt;
  final int total;
  final List<String> icons;

  Registry({
    required this.version,
    required this.updatedAt,
    required this.total,
    required this.icons,
  });

  factory Registry.fromJson(Map<String, dynamic> json) {
    return Registry(
      version: json['version'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      total: json['total'] as int,
      icons: (json['icons'] as List).cast<String>(),
    );
  }
}

/// Icon animation data from CDN
class IconData {
  final String name;
  final String viewBox;
  final double strokeWidth;
  final String strokeLinecap;
  final String strokeLinejoin;
  final List<ElementData> elements;
  final Map<String, dynamic>? animation;

  IconData({
    required this.name,
    required this.viewBox,
    required this.strokeWidth,
    required this.strokeLinecap,
    required this.strokeLinejoin,
    required this.elements,
    this.animation,
  });

  factory IconData.fromJson(Map<String, dynamic> json) {
    return IconData(
      name: json['name'] as String,
      viewBox: json['viewBox'] as String? ?? '0 0 24 24',
      strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 2.0,
      strokeLinecap: json['strokeLinecap'] as String? ?? 'round',
      strokeLinejoin: json['strokeLinejoin'] as String? ?? 'round',
      elements: (json['elements'] as List)
          .map((e) => ElementData.fromJson(e as Map<String, dynamic>))
          .toList(),
      animation: json['animation'] as Map<String, dynamic>?,
    );
  }
}

/// Individual element data (path, circle, etc.)
class ElementData {
  final String type;
  final Map<String, dynamic> attributes;
  final Map<String, dynamic>? animation;

  ElementData({required this.type, required this.attributes, this.animation});

  factory ElementData.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    final animation = json['animation'] as Map<String, dynamic>?;

    // Extract attributes (everything except type and animation)
    final attributes = Map<String, dynamic>.from(json)
      ..remove('type')
      ..remove('animation');

    return ElementData(
      type: type,
      attributes: attributes,
      animation: animation,
    );
  }
}

/// Fetcher for CDN data
class Fetcher {
  final http.Client _client;
  final String baseUrl;

  Fetcher({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      baseUrl = baseUrl ?? cdnBaseURL;

  /// Fetch the registry of available icons
  Future<Registry> fetchRegistry() async {
    final response = await _client.get(Uri.parse('$baseUrl/registry.json'));

    if (response.statusCode != 200) {
      throw FetcherException(
        'Failed to fetch registry: ${response.statusCode}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return Registry.fromJson(json);
  }

  /// Fetch a single icon's data
  Future<IconData> fetchIcon(String name) async {
    final response = await _client.get(Uri.parse('$baseUrl/icons/$name.json'));

    if (response.statusCode == 404) {
      throw FetcherException('Icon "$name" not found');
    }

    if (response.statusCode != 200) {
      throw FetcherException(
        'Failed to fetch icon "$name": ${response.statusCode}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return IconData.fromJson(json);
  }

  /// Fetch multiple icons
  Future<List<IconData>> fetchIcons(List<String> names) async {
    final results = <IconData>[];
    final errors = <String>[];

    for (final name in names) {
      try {
        final icon = await fetchIcon(name);
        results.add(icon);
      } catch (e) {
        errors.add('$name: $e');
      }
    }

    if (errors.isNotEmpty && results.isEmpty) {
      throw FetcherException('Failed to fetch icons:\n${errors.join('\n')}');
    }

    return results;
  }

  void dispose() {
    _client.close();
  }
}

/// Exception thrown by Fetcher
class FetcherException implements Exception {
  final String message;

  FetcherException(this.message);

  @override
  String toString() => message;
}
