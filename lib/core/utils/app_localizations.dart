class AppLocalizations {
  final String languageCode;

  AppLocalizations(this.languageCode);

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'WORTH NETWORK',
      
      // Login Page
      'login_title': 'Email or Username',
      'login_placeholder': 'Enter your email or username',
      'password_title': 'Password',
      'password_placeholder': 'Enter your password',
      'remember_me': 'Remember me',
      'forgot_password': 'Forgot Password?',
      'login_button': 'Log In',
      'dont_have_account': "Don't have an account? ",
      'signup_button': 'Sign Up',
      'welcome_back': 'Welcome back!',
      'enter_email_error': 'Please enter your email or username',
      'enter_password_error': 'Please enter your password',
      
      // Onboarding (Welcome Page)
      'credibility_cycle': 'The Credibility Cycle',
      'credibility_cycle_desc': 'Build your real-life reputation through verified actions.',
      'step_action': 'Action',
      'step_action_desc': 'Perform a positive real-world deed.',
      'step_proof': 'Proof',
      'step_proof_desc': 'Upload images, audio, documents, or text.',
      'step_validation': 'Validation',
      'step_validation_desc': 'Get reviewed and confirmed by validators.',
      'step_worth': 'Worth',
      'step_worth_desc': 'Grow your score, unlock badges, and level up.',
      'btn_next': 'Next',
      'btn_get_started': 'Get Started',
      
      'proof_over_posts': 'Proof Over Posts',
      'proof_over_posts_desc': 'A decentralized reputation engine powered by action.',
      'val_perform_actions': 'Perform actions',
      'val_perform_actions_desc': 'Log and organize your day-to-day positive deeds, impact, and mentoring tasks.',
      'val_upload_proof': 'Upload proof',
      'val_upload_proof_desc': 'Use photos, files, or voice records. Every action supports different credibility states.',
      'val_get_validated': 'Get validated',
      'val_get_validated_desc': 'Validators verify authenticity to confirm or certify your logged action.',
      'val_build_reputation': 'Build your reputation',
      'val_build_reputation_desc': 'Enhance your score, advance levels, and earn premium badges for consistency.',
      
      // Home Page
      'no_actions_yet': 'No actions yet',
      'no_actions_desc': 'Be the first to share a real-life action.\nYour worth is built by what you do.',
      'add_first_action_btn': 'Add Your First Action',
      'pull_to_refresh': 'Pull to refresh',
      
      // Settings Page
      'settings_title': 'Settings',
      'sec_account': 'Account',
      'edit_profile_details': 'Edit Profile Details',
      'edit_profile_desc': 'Update username, bio, and profile photo',
      'sec_privacy': 'Privacy Settings',
      'private_profile': 'Private Profile',
      'private_profile_desc': 'Only validated contacts can view actions',
      'hide_reputation_score': 'Hide Reputation Score',
      'hide_reputation_desc': 'Temporarily hide total Worth Score from feed',
      'validation_invitations': 'Validation Invitations',
      'validation_invitations_desc': 'Allow users to invite you to validate deeds',
      'sec_general': 'General',
      'about_worth_concept': 'About Worth Concept',
      'about_worth_desc': 'Learn about credibility scoring engine',
      'privacy_policy': 'Privacy Policy',
      'privacy_policy_desc': 'Read our platform privacy guidelines',
      'logout_btn': 'Log Out',
      'logout_dialog_title': 'Log Out',
      'logout_dialog_desc': 'Are you sure you want to log out of Worth Network?',
      'cancel': 'Cancel',
      'dismiss': 'Dismiss',
      'about_worth_popup_title': 'About Worth Network',
      'about_worth_popup_text': 'WORTH is a social platform built on decentralized credibility.\n\nUnlike other platforms that measure engagement through passive interactions, WORTH emphasizes real-life positive deeds, verified proof, and decentralized validators to compute a confidence-score for reputation.\n\nVersion: 1.0.0 (Production Build)',
    },
    'fr': {
      'app_title': 'RÉSEAU WORTH',
      
      // Login Page
      'login_title': "Email ou Nom d'utilisateur",
      'login_placeholder': "Entrez votre email ou nom d'utilisateur",
      'password_title': 'Mot de passe',
      'password_placeholder': 'Entrez votre mot de passe',
      'remember_me': 'Se souvenir de moi',
      'forgot_password': 'Mot de passe oublié ?',
      'login_button': 'Se connecter',
      'dont_have_account': "Vous n'avez pas de compte ? ",
      'signup_button': "S'inscrire",
      'welcome_back': 'Bon retour !',
      'enter_email_error': "Veuillez entrer votre email ou nom d'utilisateur",
      'enter_password_error': 'Veuillez entrer votre mot de passe',
      
      // Onboarding (Welcome Page)
      'credibility_cycle': 'Le Cycle de Crédibilité',
      'credibility_cycle_desc': 'Développez votre réputation dans la vie réelle grâce à des actions vérifiées.',
      'step_action': 'Action',
      'step_action_desc': 'Effectuez une bonne action concrète.',
      'step_proof': 'Preuve',
      'step_proof_desc': 'Téléchargez des images, des fichiers audio, des documents ou du texte.',
      'step_validation': 'Validation',
      'step_validation_desc': 'Faites-vous évaluer et confirmer par des validateurs.',
      'step_worth': 'Valeur',
      'step_worth_desc': 'Augmentez votre score, débloquez des badges et montez de niveau.',
      'btn_next': 'Suivant',
      'btn_get_started': 'Commencer',
      
      'proof_over_posts': 'La Preuve Avant Tout',
      'proof_over_posts_desc': 'Un moteur de réputation décentralisé alimenté par l\'action.',
      'val_perform_actions': 'Effectuer des actions',
      'val_perform_actions_desc': 'Enregistrez et organisez vos bonnes actions quotidiennes, votre impact et vos tâches de mentorat.',
      'val_upload_proof': 'Télécharger une preuve',
      'val_upload_proof_desc': 'Utilisez des photos, des fichiers ou des enregistrements vocaux. Chaque action prend en charge différents états de crédibilité.',
      'val_get_validated': 'Obtenir une validation',
      'val_get_validated_desc': 'Les validateurs vérifient l\'authenticité pour confirmer ou certifier votre action enregistrée.',
      'val_build_reputation': 'Bâtissez votre réputation',
      'val_build_reputation_desc': 'Améliorez votre score, progressez dans les niveaux et gagnez des badges premium pour votre régularité.',
      
      // Home Page
      'no_actions_yet': 'Aucune action pour le moment',
      'no_actions_desc': 'Soyez le premier à partager une action réelle.\nVotre valeur se construit par ce que vous faites.',
      'add_first_action_btn': 'Ajoutez votre première action',
      'pull_to_refresh': 'Tirer pour rafraîchir',
      
      // Settings Page
      'settings_title': 'Paramètres',
      'sec_account': 'Compte',
      'edit_profile_details': 'Modifier les détails du profil',
      'edit_profile_desc': 'Mettre à jour le nom d\'utilisateur, la biographie et la photo de profil',
      'sec_privacy': 'Paramètres de confidentialité',
      'private_profile': 'Profil privé',
      'private_profile_desc': 'Seuls les contacts validés peuvent voir les actions',
      'hide_reputation_score': 'Masquer le score de réputation',
      'hide_reputation_desc': 'Masquer temporairement le score de valeur total du flux',
      'validation_invitations': 'Invitations à la validation',
      'validation_invitations_desc': 'Autoriser les utilisateurs à vous inviter à valider des actions',
      'sec_general': 'Général',
      'about_worth_concept': 'À propos du concept Worth',
      'about_worth_desc': 'En savoir plus sur le moteur de score de crédibilité',
      'privacy_policy': 'Politique de confidentialité',
      'privacy_policy_desc': 'Lire nos directives de confidentialité de la plateforme',
      'logout_btn': 'Se déconnecter',
      'logout_dialog_title': 'Se déconnecter',
      'logout_dialog_desc': 'Êtes-vous sûr de vouloir vous déconnecter de Worth Network ?',
      'cancel': 'Annuler',
      'dismiss': 'Fermer',
      'about_worth_popup_title': 'À propos de Worth Network',
      'about_worth_popup_text': 'WORTH est une plateforme sociale basée sur la crédibilité décentralisée.\n\nContrairement aux autres plateformes qui mesurent l\'engagement via des interactions passives, WORTH met l\'accent sur les bonnes actions réelles, les preuves vérifiées et les validateurs décentralisés pour calculer un score de confiance pour la réputation.\n\nVersion : 1.0.0 (Version de production)',
    }
  };

  String translate(String key) {
    return _localizedValues[languageCode]?[key] ?? key;
  }
}
