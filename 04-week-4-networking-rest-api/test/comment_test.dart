import 'package:flutter_test/flutter_test.dart';

import 'package:week4_api/data/models/comment.dart';

void main() {
  test('fromJson missing fields uses safe defaults', () {
    final comment = Comment.fromJson({'id': 7});

    expect(comment.id, 7);
    expect(comment.postId, 0);
    expect(comment.name, '');
    expect(comment.email, '');
    expect(comment.body, '');
  });
  test('Comment.fromJson menangani nilai null', () {
    final comment = Comment.fromJson({
      'postId': null,
      'id': null,
      'name': null,
      'email': null,
      'body': null,
    });

    expect(comment.postId, 0);
    expect(comment.id, 0);
    expect(comment.name, '');
    expect(comment.email, '');
    expect(comment.body, '');
  });
}
