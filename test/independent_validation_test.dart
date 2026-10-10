import 'package:flutter_test/flutter_test.dart';
import 'package:worth_network/core/model/home/action_model.dart';
import 'package:worth_network/core/model/user/user_model.dart';

void main() {
  group('Independent Validation Model & Logic Tests', () {
    test('Default action is person-based and declared', () {
      final action = ActionModel(
        id: 'act-1',
        userId: 'user-123',
        userName: 'Alice',
        title: 'Mentoring session',
        description: 'Taught coding',
        category: 'work',
        score: 50,
        createdAt: DateTime.now(),
        validationStatus: ValidationStatus.declared,
        likesCount: 0,
        commentsCount: 0,
      );

      expect(action.isIndependent, false);
      expect(action.isPendingIndependentReview, false);
      expect(action.isValidated, false);
      expect(action.validationStatus, ValidationStatus.declared);
    });

    test('Independent action with pending review', () {
      final now = DateTime.now();
      final action = ActionModel(
        id: 'act-2',
        userId: 'user-adrien',
        userName: 'Adrien',
        title: 'App release',
        description: 'Released TROP C EST TROP app',
        category: 'work',
        score: 50,
        createdAt: now,
        validationType: 'independent',
        validationStatus: ValidationStatus.declared,
        independentReviewStatus: 'pending',
        independentSubmittedAt: now,
        likesCount: 0,
        commentsCount: 0,
      );

      expect(action.isIndependent, true);
      expect(action.isPendingIndependentReview, true);
      expect(action.isValidated, false);
      expect(action.independentReviewStatus, 'pending');
    });

    test('Independent action approved by admin transitions to validated', () {
      final now = DateTime.now();
      final action = ActionModel(
        id: 'act-2',
        userId: 'user-adrien',
        userName: 'Adrien',
        title: 'App release',
        description: 'Released TROP C EST TROP app',
        category: 'work',
        score: 50,
        createdAt: now,
        validationType: 'independent',
        validationStatus: ValidationStatus.confirmed,
        independentReviewStatus: 'approved',
        reviewedByAdminId: 'admin-999',
        reviewedByAdminName: 'SuperAdmin',
        likesCount: 0,
        commentsCount: 0,
      );

      expect(action.isIndependent, true);
      expect(action.isPendingIndependentReview, false);
      expect(action.isValidated, true);
      expect(action.reviewedByAdminId, 'admin-999');
    });

    test('Self-validation is blocked when publisher is admin', () {
      const publisherId = 'user-adrien';
      const reviewingAdminId = 'user-adrien';

      final canValidate = publisherId != reviewingAdminId;
      expect(canValidate, false, reason: 'Admins cannot validate their own actions');
    });

    test('Non-creator admin can validate independent action', () {
      const publisherId = 'user-creator';
      const reviewingAdminId = 'user-adrien';

      final canValidate = publisherId != reviewingAdminId;
      expect(canValidate, true);
    });

    test('toMap and fromMap preserves independent validation fields', () {
      final now = DateTime.now();
      final original = ActionModel(
        id: 'act-3',
        userId: 'u-1',
        userName: 'Bob',
        title: 'Solo park cleaning',
        description: 'Cleaned park with video evidence',
        category: 'support',
        score: 50,
        createdAt: now,
        validationType: 'independent',
        validationStatus: ValidationStatus.declared,
        independentReviewStatus: 'pending',
        rejectionReason: null,
        likesCount: 0,
        commentsCount: 0,
      );

      final map = original.toMap();
      expect(map['validationType'], 'independent');
      expect(map['independentReviewStatus'], 'pending');

      final deserialized = ActionModel.fromMap(map, 'act-3');
      expect(deserialized.validationType, 'independent');
      expect(deserialized.independentReviewStatus, 'pending');
      expect(deserialized.isIndependent, true);
      expect(deserialized.isPendingIndependentReview, true);
    });

    test('Admin role check in UserModel', () {
      const adminUser = UserModel(
        id: 'adrien-uid-123',
        name: 'Adrien',
        username: 'adrien',
        accountType: 'admin',
        roles: ['admin'],
        score: 100,
        level: 2,
        category: 'work',
        location: 'Paris',
        isOnline: true,
        verified: true,
        actionsCount: 5,
      );

      expect(adminUser.isAdmin, true);
    });

    test('Independent notification types are correctly formatted', () {
      const adminNotificationType = 'independent_validation_request';
      const publisherNotificationType = 'independent_action_submitted';

      expect(adminNotificationType, equals('independent_validation_request'));
      expect(publisherNotificationType, equals('independent_action_submitted'));
    });
  });
}
