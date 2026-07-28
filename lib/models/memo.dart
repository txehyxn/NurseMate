import 'dart:convert';
import 'dart:typed_data';

class Memo {
  const Memo({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.highlights = const [],
    this.photos = const [],
  });

  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<MemoHighlight> highlights;
  final List<MemoPhoto> photos;

  Map<String, Object> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'highlights': highlights.map((highlight) => highlight.toJson()).toList(),
      'photos': photos.map((photo) => photo.toJson()).toList(),
    };
  }

  factory Memo.fromJson(Map<String, Object?> json) {
    final content = json['content']! as String;
    final highlights = _mapList(
      json['highlights'],
      MemoHighlight.fromJson,
    ).where((highlight) => highlight.isValidFor(content)).toList();
    final photos = _mapList(json['photos'], MemoPhoto.fromJson);

    return Memo(
      id: json['id']! as String,
      title: json['title']! as String,
      content: content,
      createdAt: DateTime.parse(json['createdAt']! as String),
      updatedAt: DateTime.parse(json['updatedAt']! as String),
      highlights: highlights,
      photos: photos,
    );
  }
}

class MemoHighlight {
  const MemoHighlight({required this.start, required this.end});

  final int start;
  final int end;

  bool isValidFor(String text) {
    return start >= 0 && end > start && end <= text.length;
  }

  Map<String, Object> toJson() => {'start': start, 'end': end};

  factory MemoHighlight.fromJson(Map<String, Object?> json) {
    return MemoHighlight(
      start: (json['start'] as num).toInt(),
      end: (json['end'] as num).toInt(),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MemoHighlight && other.start == start && other.end == end;
  }

  @override
  int get hashCode => Object.hash(start, end);
}

class MemoPhoto {
  const MemoPhoto({
    required this.id,
    required this.base64Data,
    required this.mimeType,
  });

  final String id;
  final String base64Data;
  final String mimeType;

  Uint8List get bytes => base64Decode(base64Data);

  Map<String, Object> toJson() {
    return {'id': id, 'base64Data': base64Data, 'mimeType': mimeType};
  }

  factory MemoPhoto.fromJson(Map<String, Object?> json) {
    return MemoPhoto(
      id: json['id']! as String,
      base64Data: json['base64Data']! as String,
      mimeType: (json['mimeType'] as String?) ?? 'image/jpeg',
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MemoPhoto &&
        other.id == id &&
        other.base64Data == base64Data &&
        other.mimeType == mimeType;
  }

  @override
  int get hashCode => Object.hash(id, base64Data, mimeType);
}

List<T> _mapList<T>(
  Object? value,
  T Function(Map<String, Object?> json) fromJson,
) {
  if (value is! List) return <T>[];
  return value
      .whereType<Map>()
      .map((item) => fromJson(item.cast<String, Object?>()))
      .toList();
}
