import 'package:flutter_test/flutter_test.dart';
import 'package:finder/models/item_model.dart';

void main() {
  test('new payload: status, original text and review fields', () {
    final item = ItemModel.fromApi({
      'id': 'p1', 'title': 'محفظة', 'description': 'وصف', 'originalTitle': 'Wallet',
      'originalDescription': 'Desc', 'sourceLang': 'en', 'status': 'pending',
      'category': 'Keys', 'isLost': true, 'location': 'Erbil', 'createdAtMs': 1,
      'aiRisk': 42, 'aiReasons': ['spam-ish'],
    });
    expect(item.isPending, isTrue);
    expect(item.isPublic, isFalse);
    expect(item.isTranslated, isTrue);
    expect(item.originalTitle, 'Wallet');
    expect(item.aiRisk, 42);
    expect(item.aiReasons, ['spam-ish']);
  });

  test('old payload (no status fields) is an active, untranslated post', () {
    final item = ItemModel.fromApi({
      'id': 'p2', 'title': 'Keys', 'description': 'Lost keys', 'category': 'Keys',
      'isLost': true, 'location': '', 'createdAtMs': 1, 'status': 'resolved',
    });
    expect(item.isResolved, isTrue);
    expect(item.status, 'resolved');
    expect(item.isTranslated, isFalse);
    expect(item.originalTitle, 'Keys');
  });

  test('copyWith keeps status and isResolved consistent', () {
    final base = ItemModel.fromApi({'id': 'p', 'title': 't', 'description': 'd', 'category': 'Keys', 'isLost': false, 'location': '', 'createdAtMs': 1, 'status': 'active'});
    expect(base.copyWith(isResolved: true).status, 'resolved');
    expect(base.copyWith(status: 'rejected', rejectionReason: 'blurry').isRejected, isTrue);
    expect(base.copyWith(status: 'rejected', rejectionReason: 'blurry').copyWith(clearRejectionReason: true).rejectionReason, isNull);
  });
}
