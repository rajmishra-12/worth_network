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

      // Sign Up Page
      'create_account': 'Create Account',
      'create_account_desc': 'Join Worth Network and start building your reputation',
      'profile_photo_optional': 'Profile Photo (Optional)',
      'change_photo': 'Change photo',
      'add_photo': 'Add photo',
      'full_name_title': 'Full Name',
      'full_name_placeholder': 'Enter your full name',
      'username_title': 'Username',
      'username_placeholder': 'Choose a unique username',
      'email_title': 'Email',
      'email_placeholder': 'Enter your email',
      'confirm_password_title': 'Confirm Password',
      'confirm_password_placeholder': 'Re-enter your password',
      'agree_terms': 'I agree to the ',
      'terms_of_service': 'Terms of Service',
      'and_text': ' and ',
      'already_have_account_signup': 'Already have an account? ',
      'account_created_success': 'Account created successfully!',
      'accept_terms_warning': 'Please accept the terms and conditions',
      'photo_size_warning': 'Profile picture size must be less than 2MB',
      
      // Profile Setup Page
      'complete_profile': 'Complete Your Profile',
      'complete_profile_desc': 'Set up your public persona on Worth Network',
      'bio_title': 'Bio',
      'bio_placeholder': 'Tell the community about yourself...',
      'continue_btn': 'Continue',
      'profile_completed_success': 'Profile completed successfully!',
      
      // Edit Profile Page
      'edit_profile': 'Edit Profile',
      'take_photo': 'Take photo',
      'choose_from_gallery': 'Choose from gallery',
      'save_changes': 'Save Changes',
      'profile_updated_success': 'Profile updated successfully!',
      
      // Profile Page & Stats
      'worth_score': 'Worth Score',
      'validated_actions': 'Validated Actions',
      'reputation_level': 'Reputation Level',
      'badges_achieved': 'Badges Achieved',
      'recent_actions': 'Recent Actions',

      // Actions & Categories
      'select_category': 'Select Category',
      'action_title': 'Action Title',
      'description_title': 'Description',
      'attach_evidence': 'Attach Evidence',
      'search_validator': 'Search validator by name...',
      'submit_action': 'Submit Action',

      // History & Notifications
      'action_history': 'Action History',
      'notifications': 'Notifications',
      'no_notifications': 'No notifications yet',

      // Navigation Tabs
      'nav_home': 'Home',
      'nav_network': 'Network',
      'nav_action': 'Action',
      'nav_profile': 'Profile',

      // Validation Statuses
      'status_certified': 'Certified',
      'status_confirmed': 'Confirmed',
      'status_pending': 'Pending',
      'status_rejected': 'Rejected',
      'status_declared': 'Declared',

      // Categories
      'category_support': 'Support',
      'category_health': 'Health',
      'category_work': 'Work',
      'category_community': 'Community',
      'category_education': 'Education',
      'category_other': 'Other',

      // Actions & Feed Cards
      'delete_action_title': 'Delete Action?',
      'delete_action_desc': 'Are you sure you want to delete this post? This action cannot be undone.',
      'delete_btn': 'Delete',
      'just_now': 'just now',
      'comments_title': 'Comments',
      'add_comment_placeholder': 'Add a comment...',
      'post_btn': 'Post',
      'evidence_title': 'Evidence',
      'validator_title': 'Validator',

      // History & Profile Tabs
      'tab_my_actions': 'My Actions',
      'tab_history': 'History',
      'no_history_yet': 'No history recorded yet',
      'send_validation_request': 'Send Validation Request',
      'user_reputation': 'User Reputation',
      'clear_all': 'Clear All',

      // Network Filters & Search
      'search_users_placeholder': 'Search users...',
      'filter_all': 'All',
      'filter_near_you': 'Near You',
      'filter_top_rated': 'Top Rated',
      'no_users_found': 'No users found',
      'explore_network': 'Explore the network',
      'try_different_search': 'Try a different search term',
      'connect_with_people': 'Connect with people and build your worth',
      'clear_search': 'Clear search',

      // Profile & Stats
      'stats_actions': 'Actions',
      'stats_validated': 'Validated',
      'stats_worth': 'Worth',
      'xp_progress': 'XP Progress',
      'badges_title': 'Badges',
      'log_out': 'Log Out',
      'category_environment': 'Environment',

      // Add Action Page
      'add_action_title': 'Add Action',
      'title_label': 'Title *',
      'title_placeholder': 'e.g., Helped a friend move',
      'category_label': 'Category *',
      'date_label': 'Date *',
      'request_validation_label': 'Request Validation from Person Involved',
      'description_label': 'Description *',
      'describe_placeholder': 'Describe what you did...',
      'add_proof_title': 'Add Proof (Recommended)',
      'add_proof_desc': 'Adding proof increases your action\'s credibility score',
      'proof_photo': 'Photo',
      'proof_photo_desc': 'Take or upload a photo',
      'proof_document': 'Document',
      'proof_document_desc': 'Upload PDF, DOC, or TXT',
      'proof_audio': 'Audio',
      'proof_audio_desc': 'Record audio proof',
      'proof_text': 'Text Note',
      'proof_text_desc': 'Write a text proof',
      'validation_required_title': 'Validation Required',
      'validation_required_desc': 'After posting, send this action to the person involved for validation',
      'action_submitted_success': 'Action submitted successfully!',

      // Notifications Page
      'all_caught_up': 'All caught up!',
      'no_new_notifications': 'No new updates at the moment.',
      'inspect_request': 'Inspect Request',

      // User Detail Page
      'published_actions': 'Published Actions',
      'no_published_actions': 'No actions published yet.',

      // Validation & Action Details Page
      'action_details_title': 'Action Details',
      'validation_requested_banner': 'Validation Requested',
      'validation_requested_sub': 'You are requested to validate this action',
      'validate_btn': 'Validate',
      'requested_validator_label': 'Requested Validator',
      'like_label': 'Like',
      'likes_label': 'Likes',
      'uploaded_proof_title': 'Uploaded Proof (Credibility Evidence)',
      'validate_action_title': 'Validate Action',
      'submitted_proof_title': 'Submitted Proof / Evidence',
      'your_assessment_title': 'Your Assessment',
      'assessment_yes': 'Yes',
      'assessment_partially': 'Partially',
      'assessment_no': 'No',
      'impact_weight_title': 'Impact Weight',
      'impact_weight_desc': 'Assess the significance and confidence of this action',
      'validator_notes_title': 'Validator Notes / Feedback',
      'validator_notes_hint': 'Enter details about your validation check (optional)',
      'submitting_text': 'Submitting...',
      'retry_btn': 'Retry',
      'privacy_policy_coming_soon': 'Privacy Policy details available at worth.network',
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
      'step_proof_desc': 'Téléchargez des images, des audios, des documents ou du texte.',
      'step_validation': 'Validation',
      'step_validation_desc': 'Faites réviser et confirmer vos actions par des meveurs.',
      'step_worth': 'Worth',
      'step_worth_desc': 'Augmentez votre score, débloquez des badges et montez de niveau.',
      'btn_next': 'Suivant',
      'btn_get_started': 'Commencer',
      
      'proof_over_posts': 'Des preuves avant des publications',
      'proof_over_posts_desc': 'Un moteur de réputation décentralisé propulsé par les actions.',
      'val_perform_actions': 'Réalisez des actions',
      'val_perform_actions_desc': 'Consignez et organisez vos bonnes actions quotidiennes.',
      'val_upload_proof': 'Téléchargez des preuves',
      'val_upload_proof_desc': 'Utilisez des photos, fichiers ou enregistrements vocaux.',
      'val_get_validated': 'Faites-vous valider',
      'val_get_validated_desc': 'Les validateurs vérifient l\'authenticité pour confirmer vos actions.',
      'val_build_reputation': 'Développez votre réputation',
      'val_build_reputation_desc': 'Améliorez votre score et débloquez des badges.',
      
      // Home Page
      'no_actions_yet': 'Aucune action pour le moment',
      'no_actions_desc': 'Soyez le premier à partager une action concrète.\nVotre valeur se construit par ce que vous faites.',
      'add_first_action_btn': 'Ajouter votre première action',
      'pull_to_refresh': 'Tirer pour rafraîchir',
      
      // Settings Page
      'settings_title': 'Paramètres',
      'sec_account': 'Compte',
      'edit_profile_details': 'Modifier les détails du profil',
      'edit_profile_desc': 'Mettre à jour le nom, la bio et la photo de profil',
      'sec_privacy': 'Paramètres de confidentialité',
      'private_profile': 'Profil privé',
      'private_profile_desc': 'Seuls les contacts validés peuvent voir les actions',
      'hide_reputation_score': 'Masquer le score de réputation',
      'hide_reputation_desc': 'Masquer temporairement le score Worth du fil',
      'validation_invitations': 'Invitations à la validation',
      'validation_invitations_desc': 'Autoriser les utilisateurs à vous inviter à valider des actions',
      'sec_general': 'Général',
      'about_worth_concept': 'À propos du concept Worth',
      'about_worth_desc': 'En savoir plus sur le moteur de score de crédibilité',
      'privacy_policy': 'Politique de confidentialité',
      'privacy_policy_desc': 'Lire nos directives de confidentialité',
      'logout_btn': 'Se déconnecter',
      'logout_dialog_title': 'Se déconnecter',
      'logout_dialog_desc': 'Êtes-vous sûr de vouloir vous déconnecter de Worth Network ?',
      'cancel': 'Annuler',
      'dismiss': 'Fermer',
      'about_worth_popup_title': 'À propos de Worth Network',
      'about_worth_popup_text': 'WORTH est une plateforme sociale basée sur la crédibilité décentralisée.\n\nVersion : 1.0.0 (Production)',

      // Sign Up Page
      'create_account': 'Créer un compte',
      'create_account_desc': 'Rejoignez Worth Network et commencez à construire votre réputation',
      'profile_photo_optional': 'Photo de profil (Optionnel)',
      'change_photo': 'Changer la photo',
      'add_photo': 'Ajouter une photo',
      'full_name_title': 'Nom complet',
      'full_name_placeholder': 'Entrez votre nom complet',
      'username_title': "Nom d'utilisateur",
      'username_placeholder': "Choisissez un nom d'utilisateur unique",
      'email_title': 'Email',
      'email_placeholder': 'Entrez votre email',
      'confirm_password_title': 'Confirmer le mot de passe',
      'confirm_password_placeholder': 'Réentrez votre mot de passe',
      'agree_terms': "J'accepte les ",
      'terms_of_service': "Conditions d'utilisation",
      'and_text': ' et la ',
      'already_have_account_signup': 'Vous avez déjà un compte ? ',
      'account_created_success': 'Compte créé avec succès !',
      'accept_terms_warning': 'Veuillez accepter les conditions d\'utilisation',
      'photo_size_warning': 'La taille de la photo doit être inférieure à 2 Mo',
      
      // Profile Setup Page
      'complete_profile': 'Complétez votre profil',
      'complete_profile_desc': 'Configurez votre profil public sur Worth Network',
      'bio_title': 'Bio',
      'bio_placeholder': 'Parlez de vous à la communauté...',
      'continue_btn': 'Continuer',
      'profile_completed_success': 'Profil complété avec succès !',
      
      // Edit Profile Page
      'edit_profile': 'Modifier le profil',
      'take_photo': 'Prendre une photo',
      'choose_from_gallery': 'Choisir depuis la galerie',
      'save_changes': 'Enregistrer les modifications',
      'profile_updated_success': 'Profil mis à jour avec succès !',
      
      // Profile Page & Stats
      'worth_score': 'Score Worth',
      'validated_actions': 'Actions validées',
      'reputation_level': 'Niveau de réputation',
      'badges_achieved': 'Badges obtenus',
      'recent_actions': 'Actions récentes',

      // Actions & Categories
      'select_category': 'Sélectionner la catégorie',
      'action_title': "Titre de l'action",
      'description_title': 'Description',
      'attach_evidence': 'Joindre une preuve',
      'search_validator': 'Rechercher un validateur...',
      'submit_action': "Soumettre l'action",

      // History & Notifications
      'action_history': "Historique des actions",
      'notifications': 'Notifications',
      'no_notifications': 'Aucune notification pour le moment',

      // Navigation Tabs
      'nav_home': 'Accueil',
      'nav_network': 'Réseau',
      'nav_action': 'Action',
      'nav_profile': 'Profil',

      // Validation Statuses
      'status_certified': 'Certifié',
      'status_confirmed': 'Confirmé',
      'status_pending': 'En attente',
      'status_rejected': 'Rejeté',
      'status_declared': 'Déclaré',

      // Categories
      'category_support': 'Soutien',
      'category_health': 'Santé',
      'category_work': 'Travail',
      'category_community': 'Communauté',
      'category_education': 'Éducation',
      'category_other': 'Autre',

      // Actions & Feed Cards
      'delete_action_title': "Supprimer l'action ?",
      'delete_action_desc': "Voulez-vous vraiment supprimer cette action ? Cette action est irréversible.",
      'delete_btn': 'Supprimer',
      'just_now': 'À l\'instant',
      'comments_title': 'Commentaires',
      'add_comment_placeholder': 'Ajouter un commentaire...',
      'post_btn': 'Publier',
      'evidence_title': 'Preuve',
      'validator_title': 'Validateur',

      // History & Profile Tabs
      'tab_my_actions': 'Mes actions',
      'tab_history': 'Historique',
      'no_history_yet': 'Aucun historique enregistré',
      'send_validation_request': 'Envoyer la demande de validation',
      'user_reputation': 'Réputation de l\'utilisateur',
      'clear_all': 'Tout effacer',

      // Network Filters & Search
      'search_users_placeholder': 'Rechercher des utilisateurs...',
      'filter_all': 'Tous',
      'filter_near_you': 'Près de chez vous',
      'filter_top_rated': 'Les mieux notés',
      'no_users_found': 'Aucun utilisateur trouvé',
      'explore_network': 'Explorer le réseau',
      'try_different_search': 'Essayez un autre terme de recherche',
      'connect_with_people': 'Connectez-vous avec des personnes',
      'clear_search': 'Effacer la recherche',

      // Profile & Stats
      'stats_actions': 'Actions',
      'stats_validated': 'Validé',
      'stats_worth': 'Worth',
      'xp_progress': 'Progression XP',
      'badges_title': 'Badges',
      'log_out': 'Se déconnecter',
      'category_environment': 'Environnement',

      // Add Action Page
      'add_action_title': 'Ajouter une action',
      'title_label': 'Titre *',
      'title_placeholder': 'ex: Aidé un ami à déménager',
      'category_label': 'Catégorie *',
      'date_label': 'Date *',
      'request_validation_label': 'Demander la validation à la personne concernée',
      'description_label': 'Description *',
      'describe_placeholder': 'Décrivez ce que vous avez fait...',
      'add_proof_title': 'Ajouter une preuve (Recommandé)',
      'add_proof_desc': 'Ajouter une preuve augmente le score de crédibilité',
      'proof_photo': 'Photo',
      'proof_photo_desc': 'Prendre ou télécharger une photo',
      'proof_document': 'Document',
      'proof_document_desc': 'Télécharger un PDF, DOC ou TXT',
      'proof_audio': 'Audio',
      'proof_audio_desc': 'Enregistrer une preuve audio',
      'proof_text': 'Note texte',
      'proof_text_desc': 'Écrire une preuve texte',
      'validation_required_title': 'Validation requise',
      'validation_required_desc': 'Après la publication, envoyez cette action pour validation',
      'action_submitted_success': 'Action soumise avec succès !',

      // Notifications Page
      'all_caught_up': 'Vous êtes à jour !',
      'no_new_notifications': 'Aucune nouvelle mise à jour.',
      'inspect_request': 'Inspecter la demande',

      // User Detail Page
      'published_actions': 'Actions publiées',
      'no_published_actions': 'Aucune action publiée pour le moment.',

      // Validation & Action Details Page
      'action_details_title': "Détails de l'action",
      'validation_requested_banner': 'Validation demandée',
      'validation_requested_sub': 'Vous êtes invité à valider cette action',
      'validate_btn': 'Valider',
      'requested_validator_label': 'Validateur demandé',
      'like_label': "J'aime",
      'likes_label': "J'aime",
      'uploaded_proof_title': 'Preuve téléchargée (Preuve de crédibilité)',
      'validate_action_title': "Valider l'action",
      'submitted_proof_title': 'Preuve / Élément de preuve soumis',
      'your_assessment_title': 'Votre évaluation',
      'assessment_yes': 'Oui',
      'assessment_partially': 'Partiellement',
      'assessment_no': 'Non',
      'impact_weight_title': "Poids de l'impact",
      'impact_weight_desc': "Évaluez l'importance et la confiance de cette action",
      'validator_notes_title': 'Notes / Commentaires du validateur',
      'validator_notes_hint': 'Saisissez les détails de votre vérification (facultatif)',
      'submitting_text': 'Envoi en cours...',
      'retry_btn': 'Réessayer',
      'privacy_policy_coming_soon': 'Détails de la politique de confidentialité sur worth.network',
    }
  };

  String translate(String key) {
    return _localizedValues[languageCode]?[key] ?? _localizedValues['en']?[key] ?? key;
  }
}
