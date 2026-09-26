import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:worth_network/core/bloc_observer/locale_cubit.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/utils/app_localizations.dart';

class TermsOfUsePage extends StatelessWidget {
  const TermsOfUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, String>(
      builder: (context, localeCode) {
        final loc = AppLocalizations(localeCode);
        return Scaffold(
          backgroundColor: AppColors.white100,
          appBar: AppBar(
            backgroundColor: AppColors.white100,
            title: Text(loc.translate('terms_of_use_eula_title')),
          ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// HEADER
                const Text(
                  'Terms of Use / End-User License Agreement (EULA)\n'
                  'Application: “Trop c’est Trop”',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 24),

                /// -------- ENGLISH --------
                _sectionTitle('ENGLISH'),

                _article(
                  1,
                  'Acceptance of the Terms (Mandatory)',
                  '''
By creating an account or using the application “Trop c’est Trop” (the “Application”), you confirm that you have read, understood, and explicitly accepted these Terms of Use / End-User License Agreement (“Terms”).

Acceptance of these Terms is mandatory.
If you do not agree, you must not create an account or use the Application.
''',
                ),

                _article(
                  2,
                  'License to Use the Application',
                  '''
The Application is licensed, not sold.

The publisher grants you a personal, non-exclusive, non-transferable, revocable license to use the Application for personal and non-commercial purposes, in accordance with these Terms.
''',
                ),

                _article(
                  3,
                  'User Conduct – Zero Tolerance Policy',
                  '''
The Application enforces a strict zero-tolerance policy.

You are strictly prohibited from publishing, sharing, transmitting, or promoting any content that includes or relates to:

• Hate speech or hateful conduct  
• Harassment, threats, or intimidation  
• Abuse, bullying, or discriminatory behavior  
• Sexual, pornographic, or explicit content  
• Violent, self-harm, or graphic content  
• Illegal activities or encouragement of illegal acts  

🚫 Zero tolerance means no warnings are required before action is taken.
''',
                ),

                _article(
                  4,
                  'Reporting, Moderation, and Enforcement',
                  '''
Users may be reported, blocked, muted, or banned at any time.

The publisher reserves the right to:
• Remove any content without notice  
• Suspend or permanently terminate accounts  
• Restrict access to all or part of the Application  

These actions may be taken at the sole discretion of the publisher, without prior notice and without compensation.
''',
                ),

                _article(
                  5,
                  'User-Generated Content Responsibility',
                  '''
You are solely responsible for the content you publish.

The publisher does not guarantee real-time moderation and cannot be held responsible for user-generated content, except as required by applicable law.
''',
                ),

                _article(
                  6,
                  'No Medical or Emergency Use',
                  '''
The Application:
• Is not a medical device  
• Does not provide medical or psychological diagnosis  
• Is not an emergency service  

In case of emergency or immediate danger, contact local emergency services immediately (112 / 15 / 3114 or equivalent).
''',
                ),

                _article(
                  7,
                  'Termination',
                  '''
The publisher may terminate your access to the Application at any time if you violate these Terms or applicable laws.

Upon termination, your license to use the Application ends immediately.
''',
                ),

                _article(
                  8,
                  'Changes to the Terms',
                  '''
These Terms may be updated at any time.

Users will always have access to the latest version in the Application settings. Continued use of the Application constitutes acceptance of the updated Terms.
''',
                ),

                _article(
                  9,
                  'Governing Law',
                  '''
These Terms are governed by French law.

Any dispute shall fall under the jurisdiction of the competent French courts.
''',
                ),

                const SizedBox(height: 32),

                /// -------- FRENCH --------
                _sectionTitle('FRANÇAIS'),

                _article(
                  1,
                  'Acceptation obligatoire',
                  '''
En créant un compte ou en utilisant l’application « Trop c’est Trop » (ci-après « l’Application »), vous reconnaissez avoir lu, compris et accepté expressément les présentes Conditions d’utilisation / Licence Utilisateur Final (« Conditions »).

L’acceptation de ces Conditions est obligatoire.
En cas de refus, vous ne devez pas utiliser l’Application.
''',
                ),

                _article(
                  2,
                  'Licence d’utilisation',
                  '''
L’Application est concédée sous licence et non vendue.

L’éditeur vous accorde une licence personnelle, non exclusive, non transférable et révocable, uniquement pour un usage personnel et non commercial, dans le respect des présentes Conditions.
''',
                ),

                _article(
                  3,
                  'Règles de conduite – Tolérance zéro',
                  '''
L’Application applique une politique de tolérance zéro stricte.

Il est strictement interdit de publier, partager ou diffuser tout contenu comprenant notamment :

• Discours haineux ou incitant à la haine  
• Harcèlement, menaces ou intimidations  
• Abus, cyberharcèlement ou discrimination  
• Contenus sexuels, pornographiques ou explicites  
• Contenus violents, d’automutilation ou choquants  
• Activités illégales ou incitation à des actes illégaux  

🚫 Aucun avertissement préalable n’est requis avant sanction.
''',
                ),

                _article(
                  4,
                  'Signalement, modération et sanctions',
                  '''
Les utilisateurs peuvent être signalés, bloqués ou bannis à tout moment.

L’éditeur se réserve le droit de :
• Supprimer tout contenu sans préavis  
• Suspendre ou supprimer définitivement un compte  
• Restreindre l’accès à l’Application  

Ces mesures peuvent être prises sans notification préalable et sans indemnisation.
''',
                ),

                _article(
                  5,
                  'Responsabilité des contenus',
                  '''
Chaque utilisateur est seul responsable des contenus qu’il publie.

L’éditeur ne garantit pas une modération en temps réel et décline toute responsabilité, dans les limites légales, concernant les contenus générés par les utilisateurs.
''',
                ),

                _article(
                  6,
                  'Absence de service médical ou d’urgence',
                  '''
L’Application :
• N’est pas un dispositif médical  
• Ne fournit aucun diagnostic médical ou psychologique  
• Ne remplace pas les services d’urgence  

En cas d’urgence ou de danger immédiat, contactez les secours : 112 / 15 / 3114.
''',
                ),

                _article(
                  7,
                  'Résiliation',
                  '''
Tout manquement aux présentes Conditions peut entraîner la suppression immédiate du compte, sans préavis.
''',
                ),

                _article(
                  8,
                  'Modification des Conditions',
                  '''
Les Conditions peuvent être modifiées à tout moment.

La version en vigueur est toujours accessible dans les paramètres de l’Application. L’utilisation continue vaut acceptation.
''',
                ),

                _article(
                  9,
                  'Droit applicable',
                  '''
Les présentes Conditions sont soumises au droit français.

Tout litige relève des juridictions françaises compétentes.
''',
                ),

                const SizedBox(height: 32),

                /// FOOTER
                Text(
                  'Last updated: ${DateTime.now().toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  },
);
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _article(int number, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Article $number – $title',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
