import 'package:flutter_test/flutter_test.dart';
import 'package:worth_network/core/utils/app_localizations.dart';

void main() {
  group('AppLocalizations Tests for Independent Validation & Potential Reward', () {
    test('English translations exist for all required keys', () {
      final loc = AppLocalizations('en');

      expect(loc.translate('validation_method_label'), 'Validation Method');
      expect(loc.translate('validation_type_person'), 'Person-based Validator');
      expect(loc.translate('validation_type_independent'), 'Independent Action');
      expect(loc.translate('request_independent_validation'), 'Request Independent Validation');
      expect(loc.translate('potential_reward_label'), 'Potential reward');
      expect(loc.translate('points_awarded_after_validation'), 'Points are awarded only after validation.');
      expect(loc.translate('earned_reward_label'), 'Earned reward');
      expect(loc.translate('action_validated_reward_earned'), 'Validated • Points awarded');
      expect(loc.translate('validation_rejected_label'), 'Validation Rejected');
      expect(loc.translate('action_rejected_no_points'), 'Rejected • No points awarded');
      expect(loc.translate('independent_validations_admin_title'), 'Independent Validation Requests');
      expect(loc.translate('approve_action_btn'), 'Approve Action');
      expect(loc.translate('reject_action_btn'), 'Reject Request');
      expect(loc.translate('cannot_validate_own_action'), 'You cannot review or approve your own action.');
    });

    test('French translations exist for all required keys', () {
      final loc = AppLocalizations('fr');

      expect(loc.translate('validation_method_label'), 'Méthode de validation');
      expect(loc.translate('validation_type_person'), 'Validateur bénéficiaire');
      expect(loc.translate('validation_type_independent'), 'Action indépendante');
      expect(loc.translate('request_independent_validation'), 'Demander une validation indépendante');
      expect(loc.translate('potential_reward_label'), 'Récompense potentielle');
      expect(loc.translate('points_awarded_after_validation'), 'Les points ne sont attribués qu\'après validation.');
      expect(loc.translate('earned_reward_label'), 'Récompense obtenue');
      expect(loc.translate('action_validated_reward_earned'), 'Validée • Points attribués');
      expect(loc.translate('validation_rejected_label'), 'Validation rejetée');
      expect(loc.translate('action_rejected_no_points'), 'Rejetée • Aucun point attribué');
      expect(loc.translate('independent_validations_admin_title'), 'Demandes de validation indépendante');
      expect(loc.translate('approve_action_btn'), 'Approuver l\'action');
      expect(loc.translate('reject_action_btn'), 'Rejeter la demande');
      expect(loc.translate('cannot_validate_own_action'), 'Vous ne pouvez pas réviser ou approuver votre propre action.');
    });
  });
}
