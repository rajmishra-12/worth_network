import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:worth_network/core/constants/profile_constants.dart';
import 'package:worth_network/core/model/profile/profile_model.dart';
import 'package:worth_network/core/utils/app_localizations.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
  });

  group('French Translations & Localizations Suite', () {
    test('Badge names in French match exact proposed user specifications', () {
      final locFr = AppLocalizations('fr');
      final locEn = AppLocalizations('en');

      // 1. First Action → Première action
      expect(locFr.translateBadgeName('first_action'), 'Première action');
      expect(locFr.translateBadgeName('First Action'), 'Première action');
      expect(locEn.translateBadgeName('first_action'), 'First Action');

      // 2. Rising Star → Étoile montante
      expect(locFr.translateBadgeName('rising_star'), 'Étoile montante');
      expect(locFr.translateBadgeName('Rising Star'), 'Étoile montante');
      expect(locEn.translateBadgeName('rising_star'), 'Rising Star');

      // 3. Trusted Validator → Validateur de confiance
      expect(locFr.translateBadgeName('trusted_validator'), 'Validateur de confiance');
      expect(locFr.translateBadgeName('Trusted Validator'), 'Validateur de confiance');
      expect(locEn.translateBadgeName('trusted_validator'), 'Trusted Validator');

      // 4. Certified Impact → Impact certifié
      expect(locFr.translateBadgeName('certified_impact'), 'Impact certifié');
      expect(locFr.translateBadgeName('Certified Impact'), 'Impact certifié');
      expect(locEn.translateBadgeName('certified_impact'), 'Certified Impact');

      // 5. Community Contributor → Pilier de la communauté
      expect(locFr.translateBadgeName('community_contributor'), 'Pilier de la communauté');
      expect(locFr.translateBadgeName('Community Contributor'), 'Pilier de la communauté');
      expect(locEn.translateBadgeName('community_contributor'), 'Community Contributor');

      // 6. Consistency Champion → Champion de la régularité
      expect(locFr.translateBadgeName('consistency_champion'), 'Champion de la régularité');
      expect(locFr.translateBadgeName('Consistency Champion'), 'Champion de la régularité');
      expect(locEn.translateBadgeName('consistency_champion'), 'Consistency Champion');

      // 7. Reputation Pioneer → Pionnier de la confiance
      expect(locFr.translateBadgeName('reputation_pioneer'), 'Pionnier de la confiance');
      expect(locFr.translateBadgeName('Reputation Pioneer'), 'Pionnier de la confiance');
      expect(locEn.translateBadgeName('reputation_pioneer'), 'Reputation Pioneer');

      // 8. Master Validator → Expert en validation
      expect(locFr.translateBadgeName('master_validator'), 'Expert en validation');
      expect(locFr.translateBadgeName('Master Validator'), 'Expert en validation');
      expect(locEn.translateBadgeName('master_validator'), 'Master Validator');
    });

    test('BadgeModel localizedName and localizedDescription work seamlessly', () {
      final locFr = AppLocalizations('fr');
      final locEn = AppLocalizations('en');

      final badge = BadgeModel(
        id: 'rising_star',
        name: 'Rising Star',
        description: 'Completed 10 verified deeds with high score',
        isEarned: true,
      );

      expect(badge.localizedName(locFr), 'Étoile montante');
      expect(badge.localizedName(locEn), 'Rising Star');
      expect(badge.localizedDescription(locFr), '50+ points de score Worth obtenus grâce à des actions validées');
      expect(badge.localizedDescription(locEn), 'Earned 50+ Worth Score through validated actions');
    });

    test('Category translation translates "Health" to "Santé" and preserves French inputs', () {
      final locFr = AppLocalizations('fr');
      final locEn = AppLocalizations('en');

      expect(locFr.translateCategory('Health'), 'Santé');
      expect(locFr.translateCategory('health'), 'Santé');
      expect(locFr.translateCategory('Santé'), 'Santé');
      expect(locEn.translateCategory('Health'), 'Health');
      expect(locEn.translateCategory('Santé'), 'Health');
    });

    test('Level badge and prefix translations: "LVL 1" → "Niveau 1"', () {
      final locFr = AppLocalizations('fr');
      final locEn = AppLocalizations('en');

      expect('${locFr.translate('level_badge')} 1', 'Niveau 1');
      expect('${locEn.translate('level_badge')} 1', 'LVL 1');
      expect('${locFr.translate('level_prefix')} 1', 'Niveau 1');
      expect('${locEn.translate('level_prefix')} 1', 'Level 1');
    });

    test('Open Link button is localized to "Ouvrir le lien"', () {
      final locFr = AppLocalizations('fr');
      final locEn = AppLocalizations('en');

      expect(locFr.translate('open_link_btn'), 'Ouvrir le lien');
      expect(locEn.translate('open_link_btn'), 'Open Link');
    });

    test('Profile completed message is localized without language mixing', () {
      final locFr = AppLocalizations('fr');
      final locEn = AppLocalizations('en');

      expect(locFr.translate('profile_completed_success'), 'Profil mis à jour avec succès !');
      expect(locEn.translate('profile_completed_success'), 'Profile completed successfully!');
    });

    test('Default bio behaves dynamically without altering user-written biographies', () {
      final locFr = AppLocalizations('fr');
      final locEn = AppLocalizations('en');

      // Default bio in EN
      expect(locFr.formatBio('New to Worth Network! 🚀'), 'Nouveau sur Worth Network ! 🚀');
      expect(locEn.formatBio('New to Worth Network! 🚀'), 'New to Worth Network! 🚀');

      // Default bio in FR
      expect(locFr.formatBio('Nouveau sur Worth Network ! 🚀'), 'Nouveau sur Worth Network ! 🚀');
      expect(locEn.formatBio('Nouveau sur Worth Network ! 🚀'), 'New to Worth Network! 🚀');

      // User custom bio - MUST NOT be changed in either language
      const customBio = 'Active community volunteer and software enthusiast.';
      expect(locFr.formatBio(customBio), customBio);
      expect(locEn.formatBio(customBio), customBio);

      const frenchCustomBio = 'Bénévole engagé dans les causes écologiques et sociales.';
      expect(locFr.formatBio(frenchCustomBio), frenchCustomBio);
      expect(locEn.formatBio(frenchCustomBio), frenchCustomBio);
    });

    test('French date formatting formats dates correctly with French locale', () {
      final testDate = DateTime(2026, 4, 15, 14, 30);

      final formattedEn = DateFormat.yMMMMd('en').format(testDate);
      final formattedFr = DateFormat.yMMMMd('fr').format(testDate);

      expect(formattedEn, 'April 15, 2026');
      expect(formattedFr, '15 avril 2026');
    });

    test('Simplified validation wording and clear explanations in French', () {
      final locFr = AppLocalizations('fr');
      final locEn = AppLocalizations('en');

      // Wording for Person-based vs WORTH team verification
      expect(locFr.translate('validation_type_person'), 'Faire confirmer par la personne aidée');
      expect(locFr.translate('validation_type_independent'), 'Faire vérifier par l’équipe WORTH');
      expect(locFr.translate('validation_type_person_title'), 'Personne aidée');
      expect(locFr.translate('validation_type_independent_title'), 'Équipe WORTH');

      // Explanatory text
      expect(
        locFr.translate('request_independent_validation_desc'),
        'L’équipe WORTH examine les preuves de votre action. Les points sont attribués uniquement après validation.',
      );

      // English equivalents
      expect(locEn.translate('validation_type_person'), 'Confirm with the person helped');
      expect(locEn.translate('validation_type_independent'), 'Verify with the WORTH team');
      expect(locEn.translate('validation_type_person_title'), 'Person Helped');
      expect(locEn.translate('validation_type_independent_title'), 'WORTH Team');
      expect(
        locEn.translate('request_independent_validation_desc'),
        'The WORTH team reviews the evidence of your action. Points are awarded only after validation.',
      );
    });

    test('Admin account type option is not in selectable accountTypes but resolves in getAccountType', () {
      final locFr = AppLocalizations('fr');
      final locEn = AppLocalizations('en');

      // Admin must NOT be in the selectable accountTypes list for users
      expect(ProfileConstants.accountTypes.any((t) => t.key.toLowerCase() == 'admin'), isFalse);

      expect(locFr.translate('account_type_admin'), 'Administrateur');
      expect(locEn.translate('account_type_admin'), 'Administrator');

      final adminOption = ProfileConstants.getAccountType('admin');
      expect(adminOption, isNotNull);
      expect(adminOption!.getLocalizedLabel(locFr), 'Administrateur');
      expect(adminOption.getLocalizedLabel(locEn), 'Administrator');
    });

    test('Account type dropdown builder excludes admin and guarantees zero assertion errors', () {
      final locFr = AppLocalizations('fr');
      final testCases = ['admin', 'Admin', 'ADMIN', 'Administrator', 'particular', 'custom_value', null, ''];

      for (final testValue in testCases) {
        final rawVal = (testValue != null &&
                testValue.trim().isNotEmpty &&
                testValue.trim().toLowerCase() != 'admin' &&
                testValue.trim().toLowerCase() != 'administrator')
            ? testValue.trim()
            : null;
        String? effectiveVal = rawVal;
        if (rawVal != null) {
          final matched = ProfileConstants.accountTypes.cast<AccountTypeOption?>().firstWhere(
            (t) => t != null && (t.key.toLowerCase() == rawVal.toLowerCase() || t.label.toLowerCase() == rawVal.toLowerCase()),
            orElse: () => null,
          );
          if (matched != null) {
            effectiveVal = matched.key;
          }
        }

        final itemsList = <DropdownMenuItem<String>>[
          DropdownMenuItem<String>(
            value: null,
            child: Text(locFr.translate('not_specified')),
          ),
          ...ProfileConstants.accountTypes.map(
            (type) => DropdownMenuItem<String>(
              value: type.key,
              child: Text(type.getLocalizedLabel(locFr)),
            ),
          ),
        ];

        if (effectiveVal != null &&
            effectiveVal.toLowerCase() != 'admin' &&
            !itemsList.any((i) => i.value == effectiveVal)) {
          itemsList.add(
            DropdownMenuItem<String>(
              value: effectiveVal,
              child: Text(effectiveVal),
            ),
          );
        }

        // Admin must never be present in itemsList
        expect(itemsList.any((i) => i.value?.toLowerCase() == 'admin'), isFalse);

        // Flutter DropdownButton assertion check:
        // (initialValue == null && value == null) || items.where((item) => item.value == effectiveVal).length == 1
        if (effectiveVal != null) {
          final matchCount = itemsList.where((i) => i.value == effectiveVal).length;
          expect(matchCount, 1, reason: 'Failed for testValue: $testValue, effectiveVal: $effectiveVal');
        } else {
          // When effectiveVal is null (like for admin inputs), it matches null initialValue
          expect(effectiveVal, isNull);
        }
      }
    });
  });
}
