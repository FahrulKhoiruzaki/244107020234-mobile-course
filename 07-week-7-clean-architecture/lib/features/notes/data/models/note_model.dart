import '../../domain/entities/note.dart';

class NoteModel {
  const NoteModel({
    this.id,
    required this.title,
    this.body = '',
    required this.updatedAt,
    this.dirty = false,
  });

  final int? id;
  final String title;
  final String body;
  final DateTime updatedAt;
  final bool dirty;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'updated_at': updatedAt.toIso8601String(),
      'dirty': dirty ? 1 : 0,
    };
  }

  factory NoteModel.fromMap(Map<String, Object?> map) {
    final rawDate = map['updated_at'];
    final parsedDate = rawDate is String ? DateTime.tryParse(rawDate) : null;
    final rawDirty = map['dirty'];
    final dirtyValue = rawDirty is num && rawDirty.toInt() == 1;

    return NoteModel(
      id: (map['id'] as num?)?.toInt(),
      title: map['title'] is String ? map['title']! as String : '',
      body: map['body'] is String ? map['body']! as String : '',
      updatedAt: parsedDate ?? DateTime.fromMillisecondsSinceEpoch(0),
      dirty: dirtyValue,
    );
  }

  Note toEntity() {
    return Note(
      id: id,
      title: title,
      body: body,
      updatedAt: updatedAt,
      dirty: dirty,
    );
  }
}
