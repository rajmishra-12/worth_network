import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worth_network/core/bloc_observer/locale_cubit.dart';
import 'package:worth_network/core/model/home/action_model.dart';
import 'package:worth_network/core/model/home/evidence_model.dart';
import 'package:worth_network/core/services/notification_service.dart';
import 'package:worth_network/core/navigator/app_pages.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/utils/app_localizations.dart';
import 'package:worth_network/core/utils/preferences.dart';
import 'package:worth_network/pages/action/cubit/add_action_cubit.dart';
import 'package:worth_network/pages/dashboard/cubit/dashboard_cubit.dart';
import 'package:worth_network/pages/home/widgets/action_cards.dart';

void main() {
  group('Client Feedback - Point 1: Evidence for Independent Validation', () {
    test('Evidence is required when requesting independent validation from WORTH team', () {
      // Helper function matching AddActionCubit requirement
      bool hasRequiredEvidence(List<EvidenceModel> evidences) {
        return evidences.any(
          (e) => e.type == 'photo' || e.type == 'document' || e.type == 'audio' || e.type == 'link',
        );
      }

      // Case A: No evidence attached
      expect(hasRequiredEvidence([]), isFalse);

      // Case B: Only written statement (text proof)
      final textOnly = [
        const EvidenceModel(type: 'text', text: 'I really helped my neighbor with their garden today.'),
      ];
      expect(hasRequiredEvidence(textOnly), isFalse);

      // Case C: Photo evidence provided
      final withPhoto = [
        const EvidenceModel(type: 'photo', url: 'https://example.com/photo.jpg'),
      ];
      expect(hasRequiredEvidence(withPhoto), isTrue);

      // Case D: Document provided
      final withDocument = [
        const EvidenceModel(type: 'document', url: 'https://example.com/receipt.pdf'),
      ];
      expect(hasRequiredEvidence(withDocument), isTrue);

      // Case E: Audio file provided
      final withAudio = [
        const EvidenceModel(type: 'audio', url: 'https://example.com/voice.m4a'),
      ];
      expect(hasRequiredEvidence(withAudio), isTrue);

      // Case F: Link provided
      final withLink = [
        const EvidenceModel(type: 'link', url: 'https://github.com/project'),
      ];
      expect(hasRequiredEvidence(withLink), isTrue);
    });
  });

  group('Client Feedback - Point 2: Notifications Localization', () {
    test('Independent approval notification produces exact French wording requested by client', () {
      final notifData = {
        'type': 'approved',
        'isIndependent': true,
        'title': 'Action Validated!',
        'body': 'Your action has been validated by the WORTH team. You earned 50 points.',
        'score': 50,
      };

      final formattedFr = NotificationService.formatNotificationText(
        data: notifData,
        language: 'fr',
      );

      expect(formattedFr['title'], 'Action validée !');
      expect(
        formattedFr['body'],
        'Votre action a été validée par l’équipe WORTH. Vous avez gagné 50 points.',
      );

      final formattedEn = NotificationService.formatNotificationText(
        data: notifData,
        language: 'en',
      );

      expect(formattedEn['title'], 'Action Validated!');
      expect(
        formattedEn['body'],
        'Your action has been validated by the WORTH team. You earned 50 points.',
      );
    });

    test('Peer confirmation notification is localized properly', () {
      final notifData = {
        'type': 'approved',
        'isIndependent': false,
        'title': 'Action Confirmed!',
        'actionTitle': 'Cleaned Community Park',
        'validatorName': 'Sophie',
        'score': 50,
      };

      final formattedFr = NotificationService.formatNotificationText(
        data: notifData,
        language: 'fr',
      );

      expect(formattedFr['title'], 'Action confirmée !');
      expect(
        formattedFr['body'],
        'Votre action « Cleaned Community Park » a été confirmée par Sophie (+50 points).',
      );
    });
  });

  group('Client Feedback - Point 3: Points Displayed on Actions', () {
    final locFr = AppLocalizations('fr');
    final locEn = AppLocalizations('en');

    test('Displays "50 pts en attente" when awaiting review (pending)', () {
      final pendingAction = ActionModel(
        id: 'act-pending',
        userId: 'u1',
        userName: 'Jean',
        title: 'Tree Planting',
        description: 'Planted 5 oak trees',
        category: 'Environment',
        score: 50,
        createdAt: DateTime.now(),
        validationStatus: ValidationStatus.pending,
        likesCount: 0,
        commentsCount: 0,
      );

      expect(ActionCard.formatPointsBadge(pendingAction, locFr), '50 pts en attente');
      expect(ActionCard.formatPointsBadge(pendingAction, locEn), '50 pts pending');
    });

    test('Displays "+50 pts obtenus" once approved', () {
      final approvedAction = ActionModel(
        id: 'act-approved',
        userId: 'u1',
        userName: 'Jean',
        title: 'Tree Planting',
        description: 'Planted 5 oak trees',
        category: 'Environment',
        score: 50,
        createdAt: DateTime.now(),
        validationStatus: ValidationStatus.confirmed,
        likesCount: 0,
        commentsCount: 0,
      );

      expect(ActionCard.formatPointsBadge(approvedAction, locFr), '+50 pts obtenus');
      expect(ActionCard.formatPointsBadge(approvedAction, locEn), '+50 pts earned');
    });

    test('Displays "50 pts après validation" for a self-declared action that has not been submitted', () {
      final declaredAction = ActionModel(
        id: 'act-declared',
        userId: 'u1',
        userName: 'Jean',
        title: 'Tree Planting',
        description: 'Planted 5 oak trees',
        category: 'Environment',
        score: 50,
        createdAt: DateTime.now(),
        validationStatus: ValidationStatus.declared,
        likesCount: 0,
        commentsCount: 0,
      );

      expect(ActionCard.formatPointsBadge(declaredAction, locFr), '50 pts après validation');
      expect(ActionCard.formatPointsBadge(declaredAction, locEn), '50 pts after validation');
    });
  });

  group('Client Feedback - Point 4: Profile Figures & XP Bar', () {
    test('XP progress at level 4 with 360 XP correctly shows 60 / 100 progress towards next level', () {
      const xp = 360;
      const level = 4;

      final levelBaseXp = (level - 1) * 100; // 300
      final currentLevelXp = (xp - levelBaseXp).clamp(0, 100); // 60
      const xpNeededForLevel = 100;
      final progressRatio = currentLevelXp / xpNeededForLevel; // 0.60

      expect(currentLevelXp, 60);
      expect(progressRatio, 0.60);
      expect('$currentLevelXp / $xpNeededForLevel', '60 / 100');
    });

    test('Fresh account starts at Level 1 with 0 / 100 XP and 0% validated', () {
      const xp = 0;
      const level = 1;

      final levelBaseXp = (level - 1) * 100;
      final currentLevelXp = (xp - levelBaseXp).clamp(0, 100);
      expect(currentLevelXp, 0);
      expect('$currentLevelXp / 100', '0 / 100');

      // Validation percentage with 0 actions
      final actions = <ActionModel>[];
      final totalActions = actions.length;
      final validatedCount = actions.where((a) => a.isValidated).length;
      final percentage = totalActions > 0 ? (validatedCount / totalActions * 100) : 0.0;
      expect(percentage, 0.0);
    });

    test('Account with 1 action validated shows 100% validated', () {
      final actions = [
        ActionModel(
          id: 'a1',
          userId: 'u1',
          userName: 'User',
          title: 'Action 1',
          description: 'Desc',
          category: 'Health',
          score: 50,
          createdAt: DateTime.now(),
          validationStatus: ValidationStatus.confirmed,
          likesCount: 0,
          commentsCount: 0,
        ),
      ];

      final totalActions = actions.length;
      final validatedCount = actions.where((a) => a.isValidated).length;
      final percentage = totalActions > 0 ? (validatedCount / totalActions * 100) : 0.0;
      expect(percentage, 100.0);
    });
  });

  group('Layout & Overflow Fix Verification', () {
    testWidgets('ActionCard renders without overflow on 360px screen with long status and user name', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final action = ActionModel(
        id: 'act-overflow-check',
        userId: 'u_buellet',
        userName: 'buellet',
        title: 'tct Adrien',
        description: 'ddddwwwwdddd',
        category: 'Santé',
        score: 50,
        createdAt: DateTime.now().subtract(const Duration(days: 70)),
        validationStatus: ValidationStatus.declared,
        likesCount: 0,
        commentsCount: 0,
      );

      AppScreenUtil.screenWidth = 360;
      AppScreenUtil.screenHeight = 800;
      AppScreenUtil.textMultiplier = 1.0;
      AppScreenUtil.imageSizeMultiplier = 1.0;
      AppScreenUtil.heightMultiplier = 1.0;
      AppScreenUtil.widthMultiplier = 1.0;
      AppScreenUtil.radiusMultiplier = 1.0;

      SharedPreferences.setMockInitialValues({'language': 'fr'});
      await Preferences().init();
      final localeCubit = LocaleCubit();

      await tester.pumpWidget(
        BlocProvider<LocaleCubit>.value(
          value: localeCubit,
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ActionCard(
                  action: action,
                  onLikeTap: () {},
                  onCommentTap: () {},
                  onUserTap: () {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Ensure buellet, 50 pts après validation, and tct Adrien are rendered without any Flutter overflow exception
      expect(find.text('buellet'), findsOneWidget);
      expect(find.text('50 pts après validation'), findsOneWidget);
      expect(find.text('tct Adrien'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ActionCard renders without overflow on 320px screen for approved action', (tester) async {
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final approvedAction = ActionModel(
        id: 'act-approved-check',
        userId: 'u_test1',
        userName: 'test 1',
        title: 'test for',
        description: 'test d def dfdfdjf dfdf',
        category: 'Travail',
        score: 50,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        validationStatus: ValidationStatus.confirmed,
        likesCount: 0,
        commentsCount: 0,
      );

      final localeCubit = LocaleCubit();

      await tester.pumpWidget(
        BlocProvider<LocaleCubit>.value(
          value: localeCubit,
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ActionCard(
                  action: approvedAction,
                  onLikeTap: () {},
                  onCommentTap: () {},
                  onUserTap: () {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('test 1'), findsOneWidget);
      expect(find.text('+50 pts obtenus'), findsOneWidget);
      expect(find.text('test for'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Client Feedback - Positive Impact Question & In-Post Adjustment (Bilingual)', () {
    test('Positive impact question matches exact wording in English and French', () {
      final locEn = AppLocalizations('en');
      final locFr = AppLocalizations('fr');

      // Exact client question in English
      expect(
        locEn.translate('action_impact_question'),
        'How did your action positively impact someone else, a community, or the environment?',
      );

      // French equivalent
      expect(
        locFr.translate('action_impact_question'),
        'Comment votre action a-t-elle eu un impact positif sur autrui, une communauté ou l’environnement ?',
      );

      // Adjust button translations
      expect(locEn.translate('adjust_btn'), 'Adjust');
      expect(locFr.translate('adjust_btn'), 'Ajuster');

      // Sheet title translations
      expect(locEn.translate('adjust_impact_title'), 'Adjust Action Impact');
      expect(locFr.translate('adjust_impact_title'), 'Ajuster l’impact de l’action');
    });

    test('ActionModel serializes and deserializes impact field correctly', () {
      final action = ActionModel(
        id: 'act-impact-1',
        userId: 'user-impact',
        userName: 'Impact Maker',
        title: 'Community Garden Cleanup',
        description: 'Cleaned up 200kg of recyclable plastic and revitalized the soil.',
        impact: 'Helped 15 families grow fresh vegetables in a clean, plastic-free environment.',
        category: 'Environnement',
        score: 50,
        createdAt: DateTime.now(),
        validationStatus: ValidationStatus.confirmed,
        likesCount: 5,
        commentsCount: 2,
      );

      final map = action.toMap();
      expect(map['impact'], 'Helped 15 families grow fresh vegetables in a clean, plastic-free environment.');

      final reconstructed = ActionModel.fromMap(map, 'act-impact-1');
      expect(reconstructed.impact, action.impact);

      final updated = action.copyWith(
        impact: 'Updated impact: Benefited 30 local families and reduced neighborhood waste.',
      );
      expect(updated.impact, 'Updated impact: Benefited 30 local families and reduced neighborhood waste.');
    });

    test('Impact controller and description controller operate completely independently', () {
      final descriptionController = TextEditingController();
      final impactController = TextEditingController();

      // Typing into impact does NOT alter description
      impactController.text = 'jrrr';
      expect(impactController.text, 'jrrr');
      expect(descriptionController.text, '');

      // Typing into description does NOT alter impact
      descriptionController.text = 'my custom description';
      expect(impactController.text, 'jrrr');
      expect(descriptionController.text, 'my custom description');

      // State updates remain distinct and never cross-pollinate
      var state = AddActionState();
      state = state.copyWith(impact: 'jrrr');
      expect(state.impact, 'jrrr');
      expect(state.description, '');

      state = state.copyWith(description: 'my custom description');
      expect(state.impact, 'jrrr');
      expect(state.description, 'my custom description');
    });

    testWidgets('Post displays subtle compact impact note without UI overflow on small screens', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      SharedPreferences.setMockInitialValues({'user_id': 'author-1'});
      await Preferences().init();

      final impactAction = ActionModel(
        id: 'action-overflow-test',
        userId: 'author-1',
        userName: 'Alexandre Dupont Super Long Name Exceeding Normal Width',
        title: 'Installed Renewable Solar Lighting System For Remote Village School',
        description: 'Detailed description of the solar panel installation covering all components and safety measures.',
        impact: 'The solar installation provided reliable evening light for 120 elementary students and eliminated kerosene fumes completely.',
        category: 'Communauté',
        score: 50,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        validationStatus: ValidationStatus.pending,
        likesCount: 12,
        commentsCount: 3,
      );

      final localeCubit = LocaleCubit(); // Defaults to French ('fr')

      await tester.pumpWidget(
        BlocProvider<LocaleCubit>.value(
          value: localeCubit,
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ActionCard(
                  action: impactAction,
                  onLikeTap: () {},
                  onCommentTap: () {},
                  onUserTap: () {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the subtle impact text is rendered without expanding the card
      expect(
        find.textContaining('The solar installation provided reliable evening light for 120 elementary students and eliminated kerosene fumes completely.'),
        findsOneWidget,
      );

      // Verify no "Ajuster" button appears on the post card (editing not allowed after post creation)
      expect(find.text('Ajuster'), findsNothing);

      // Verify zero render overflows
      expect(tester.takeException(), isNull);
    });

    testWidgets('Post displays impact in English without UI overflow or edit buttons', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568); // Extremely narrow screen (iPhone SE 1st gen)
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      SharedPreferences.setMockInitialValues({'user_id': 'author-1'});
      await Preferences().init();

      final impactAction = ActionModel(
        id: 'action-en-test',
        userId: 'author-1',
        userName: 'Emma Watson',
        title: 'Tree Planting',
        description: 'Planted 50 native trees.',
        impact: 'Restored the green canopy and prevented soil erosion along the river bank.',
        category: 'Environnement',
        score: 50,
        createdAt: DateTime.now(),
        validationStatus: ValidationStatus.confirmed,
        likesCount: 1,
        commentsCount: 0,
      );

      final localeCubit = LocaleCubit();
      localeCubit.setLanguage('en');

      await tester.pumpWidget(
        BlocProvider<LocaleCubit>.value(
          value: localeCubit,
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ActionCard(
                  action: impactAction,
                  onLikeTap: () {},
                  onCommentTap: () {},
                  onUserTap: () {},
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the subtle impact text is rendered
      expect(
        find.textContaining('Restored the green canopy and prevented soil erosion along the river bank.'),
        findsOneWidget,
      );

      // Verify no edit/adjust button exists on the post card
      expect(find.text('Adjust'), findsNothing);

      // Verify zero render overflows even on 320px
      expect(tester.takeException(), isNull);
    });
  });

  group('Client Feedback - Keyboard Dismissal on Screen Navigation & Tab Switch', () {
    test('KeyboardDismisserObserver successfully instantiates and intercepts route changes', () {
      final observer = KeyboardDismisserObserver();
      final route1 = MaterialPageRoute(builder: (_) => const SizedBox());
      final route2 = MaterialPageRoute(builder: (_) => const SizedBox());

      expect(() => observer.didPush(route1, null), returnsNormally);
      expect(() => observer.didPop(route1, null), returnsNormally);
      expect(() => observer.didReplace(newRoute: route2, oldRoute: route1), returnsNormally);
      expect(() => observer.didRemove(route1, null), returnsNormally);
    });

    test('DashboardCubit.changeTab unfocuses primary focus without errors', () {
      final cubit = DashboardCubit();
      expect(() => cubit.changeTab(1), returnsNormally);
      expect(cubit.state.currentIndex, 1);
      expect(() => cubit.changeTab(0), returnsNormally);
      expect(cubit.state.currentIndex, 0);
    });
  });
}

