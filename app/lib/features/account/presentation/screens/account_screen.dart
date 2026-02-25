import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../providers/auth_provider.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../controllers/user_profile_controller.dart';
import 'package:flutter/foundation.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _aboutMeController = TextEditingController();

  // Champs pour le premier onglet
  final _displayNameController = TextEditingController();
  int? _selectedGender;
  DateTime? _selectedDate;

  // Champs pour la photo
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // État de chargement pour la photo
  bool _isPhotoLoading = false;

  // Variable pour suivre si des changements ont été faits (UNIQUEMENT pour les champs texte)
  bool _hasChanges = false;

  // Flag pour éviter les écrasements pendant l'édition
  bool _isEditing = false;

  // Stocker les données originales pour comparaison
  UserProfileEntity? _originalProfile;

  // Stocker les modifications en cours pour les préserver pendant le refresh
  Map<String, dynamic> _pendingChanges = {};

  // États de validation
  bool _isDisplayNameValid = true;
  bool _isGenderValid = true;
  bool _isAgeValid = true;
  bool _isAboutMeValid = true;
  bool _isPhotoValid = true;

  String? _displayNameError;
  String? _genderError;
  String? _ageError;

  // Flag pour savoir si la popup de bienvenue a déjà été affichée
  bool _welcomePopupShown = false;

  // Flag pour savoir si les données sont chargées
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Ajouter un listener pour valider en temps réel
    _displayNameController.addListener(_validateDisplayName);
    _aboutMeController.addListener(_validateAboutMe);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _displayNameController.dispose();
    _aboutMeController.dispose();
    super.dispose();
  }

  // Méthodes de validation
  void _validateDisplayName() {
    final displayName = _displayNameController.text;

    if (displayName.isEmpty) {
      _isDisplayNameValid = false;
      _displayNameError = 'Le nom d\'affichage est requis';
    } else {
      final nameRegex = RegExp(r"^[a-zA-Z0-9\s\-']+$");

      if (!nameRegex.hasMatch(displayName)) {
        _isDisplayNameValid = false;
        _displayNameError =
        'Caractères autorisés: lettres, chiffres, espaces, tirets et apostrophes';
      } else if (displayName.length < 2) {
        _isDisplayNameValid = false;
        _displayNameError = 'Le nom doit faire au moins 2 caractères';
      } else if (displayName.length > 50) {
        _isDisplayNameValid = false;
        _displayNameError = 'Le nom ne doit pas dépasser 50 caractères';
      } else {
        _isDisplayNameValid = true;
        _displayNameError = null;
      }
    }

    if (mounted) setState(() {});
  }

  void _validateGender() {
    if (_selectedGender == null || _selectedGender == 0) {
      _isGenderValid = false;
      _genderError = 'Le genre doit être choisi';
    } else if (_selectedGender != 1 && _selectedGender != 2 && _selectedGender != 3) {
      _isGenderValid = false;
      _genderError = 'Genre invalide';
    } else {
      _isGenderValid = true;
      _genderError = null;
    }
  }

  void _validateAge() {
    if (_selectedDate == null) {
      _isAgeValid = false;
      _ageError = 'La date de naissance est requise';
    } else {
      final now = DateTime.now();
      final age = now.year - _selectedDate!.year;
      final hasHadBirthdayThisYear = now.month > _selectedDate!.month ||
          (now.month == _selectedDate!.month && now.day >= _selectedDate!.day);

      final actualAge = hasHadBirthdayThisYear ? age : age - 1;

      if (actualAge < 18) {
        _isAgeValid = false;
        _ageError = 'Vous devez avoir au moins 18 ans';
      } else {
        _isAgeValid = true;
        _ageError = null;
      }
    }
  }

  void _validateAboutMe() {
    _isAboutMeValid = _aboutMeController.text.isNotEmpty;
    if (mounted) setState(() {});
  }

  void _validatePhoto(UserProfileEntity profile) {
    _isPhotoValid = profile.hasPhoto;
  }

  void _validateAll() {
    _validateDisplayName();
    _validateGender();
    _validateAge();
    _validateAboutMe();
  }

  bool get _isFormValid {
    _validateAll();
    return _isDisplayNameValid && _isGenderValid && _isAgeValid;
  }

  bool get _isProfileComplete {
    if (!_isDataLoaded) return true; // Par défaut, on considère que c'est complet avant chargement
    _validateAll();
    return _isDisplayNameValid &&
        _isGenderValid &&
        _isAgeValid &&
        _isAboutMeValid &&
        _isPhotoValid;
  }

  Map<String, bool> _getTabCompletionStatus() {
    if (!_isDataLoaded) {
      return {
        'profile': true,
        'about': true,
        'photo': true,
      };
    }

    return {
      'profile': _isDisplayNameValid && _isGenderValid && _isAgeValid,
      'about': _isAboutMeValid,
      'photo': _isPhotoValid,
    };
  }

  void _loadProfileData(UserProfileEntity profile) {
    // Stocker les données originales une seule fois
    if (_originalProfile == null) {
      _originalProfile = profile;
      _validatePhoto(profile);

      // Marquer que les données sont chargées
      setState(() {
        _isDataLoaded = true;
      });
    }

    // Ne pas écraser s'il y a des modifications en cours
    if (_isEditing || _pendingChanges.isNotEmpty) return;

    // Charger les données uniquement si c'est le premier chargement
    if (_displayNameController.text.isEmpty) {
      _displayNameController.text = profile.displayName ?? '';
    }

    if (_selectedGender == null) {
      _selectedGender = profile.gender;
    }

    if (_selectedDate == null) {
      _selectedDate = profile.birthdate;
    }

    if (_aboutMeController.text.isEmpty) {
      _aboutMeController.text = profile.aboutMe ?? '';
    }

    _validateAll();
  }

  // Sauvegarder les modifications en cours
  void _savePendingChanges() {
    _pendingChanges = {
      'displayName': _displayNameController.text,
      'gender': _selectedGender,
      'birthdate': _selectedDate,
      'aboutMe': _aboutMeController.text,
      'hasChanges': _hasChanges,
    };
  }

  // Restaurer les modifications en cours
  void _restorePendingChanges() {
    if (_pendingChanges.containsKey('displayName')) {
      _displayNameController.text = _pendingChanges['displayName'] as String;
    }
    if (_pendingChanges.containsKey('gender')) {
      _selectedGender = _pendingChanges['gender'] as int?;
    }
    if (_pendingChanges.containsKey('birthdate')) {
      _selectedDate = _pendingChanges['birthdate'] as DateTime?;
    }
    if (_pendingChanges.containsKey('aboutMe')) {
      _aboutMeController.text = _pendingChanges['aboutMe'] as String;
    }
    if (_pendingChanges.containsKey('hasChanges')) {
      _hasChanges = _pendingChanges['hasChanges'] as bool;
    }

    _validateAll();
  }

  // Méthode pour détecter les changements
  void _onFieldChanged() {
    _validateAll();
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
    _savePendingChanges();
  }

  // Afficher la popup de bienvenue
  void _showWelcomePopup() {
    if (_welcomePopupShown) return;

    _welcomePopupShown = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E3F),
        title: const Row(
          children: [
            Icon(Icons.waving_hand, color: Color(0xFF6366F1), size: 28),
            SizedBox(width: 8),
            Text(
              'Bienvenue !',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'C\'est votre première visite sur l\'application !',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pour profiter pleinement de l\'expérience, veuillez compléter votre profil :',
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildRequirementItem(
              'Nom d\'affichage',
              _isDisplayNameValid,
            ),
            _buildRequirementItem(
              'Genre',
              _isGenderValid,
            ),
            _buildRequirementItem(
              'Âge (18 ans minimum)',
              _isAgeValid,
            ),
            _buildRequirementItem(
              'À propos de moi',
              _isAboutMeValid,
            ),
            _buildRequirementItem(
              'Photo de profil',
              _isPhotoValid,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Compris',
              style: TextStyle(color: Color(0xFF6366F1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String label, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.error,
            color: isValid ? Colors.green : Colors.red,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isValid ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBadge(bool isComplete) {
    if (!_isDataLoaded || isComplete) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.error,
        color: Colors.white,
        size: 12,
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _isPhotoLoading = true;
      });
      _savePendingChanges();

      try {
        await ref
            .read(userProfileControllerProvider.notifier)
            .updatePhoto(image.path);

        if (mounted) {
          setState(() {
            _isPhotoLoading = false;
            _isPhotoValid = true; // Photo maintenant valide
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo téléchargée avec succès'),
              backgroundColor: Color(0xFF6366F1),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isPhotoLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E3F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF6366F1)),
              title: const Text('Galerie', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Color(0xFF6366F1)),
              title: const Text('Appareil photo', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            if (_originalProfile?.hasPhoto == true)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Supprimer la photo', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  await _deletePhoto();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _deletePhoto() async {
    try {
      setState(() {
        _selectedImage = null;
        _isPhotoLoading = true;
      });

      // TODO: Appeler l'API de suppression
      await _refreshProfile();

      if (mounted) {
        setState(() {
          _isPhotoLoading = false;
          _isPhotoValid = false; // Photo supprimée
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo supprimée'),
            backgroundColor: Color(0xFF6366F1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPhotoLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final currentDisplayName = _displayNameController.text;
    final currentGender = _selectedGender;
    final currentDate = _selectedDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6366F1),
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E3F),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _validateAge();
        _hasChanges = true;
        _isEditing = true;
        _displayNameController.text = currentDisplayName;
        _selectedGender = currentGender;
      });
    } else {
      setState(() {
        _displayNameController.text = currentDisplayName;
        _selectedGender = currentGender;
        _selectedDate = currentDate;
        _validateAge();
      });
    }
    _savePendingChanges();
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) {
      return true;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E3F),
        title: const Text(
          'Modifications non enregistrées',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Vous avez des modifications non enregistrées. Voulez-vous vraiment quitter ?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Rester',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
            ),
            child: const Text('Quitter', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    return confirm ?? false;
  }

  Future<void> _refreshProfile() async {
    _savePendingChanges();

    try {
      await ref.refresh(userProfileControllerProvider.notifier).refresh();
      _restorePendingChanges();
    } catch (e) {
      _restorePendingChanges();
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(userProfileControllerProvider);
    final tabStatus = _getTabCompletionStatus();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F23),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              if (await _onWillPop()) {
                context.go('/venues');
              }
            },
            tooltip: 'Retour aux bars',
          ),
          title: const Text(
            'Mon Compte',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            if (_isDataLoaded && !_isFormValid && _hasChanges)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.error, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Champs invalides',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFF6366F1),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.person),
                    Positioned(
                      top: -4,
                      right: -8,
                      child: _buildTabBadge(tabStatus['profile']!),
                    ),
                  ],
                ),
                text: 'Profil',
              ),
              Tab(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.description),
                    Positioned(
                      top: -4,
                      right: -8,
                      child: _buildTabBadge(tabStatus['about']!),
                    ),
                  ],
                ),
                text: 'À propos',
              ),
              Tab(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.photo),
                    Positioned(
                      top: -4,
                      right: -8,
                      child: _buildTabBadge(tabStatus['photo']!),
                    ),
                  ],
                ),
                text: 'Photo',
              ),
            ],
          ),
        ),
        body: profileState.when(
          data: (profile) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _loadProfileData(profile);

                // Afficher la popup si first_access est true, que les données sont chargées,
                // que le profil n'est pas complet et que la popup n'a pas déjà été affichée
                if (_isDataLoaded &&
                    profile.firstAccess &&
                    !_isProfileComplete &&
                    !_welcomePopupShown) {
                  _showWelcomePopup();
                }
              }
            });

            return TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(profile),
                _buildAboutMeTab(profile),
                _buildPhotoTab(profile),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Erreur: $err',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                  ),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTab(UserProfileEntity profile) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Informations personnelles',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Email (lecture seule)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E3F),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.email, color: Color(0xFF6366F1), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        profile.id,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // DisplayName avec validation
              Focus(
                onFocusChange: (hasFocus) {
                  setState(() {
                    _isEditing = hasFocus;
                  });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _displayNameController,
                            style: const TextStyle(color: Colors.white),
                            onChanged: (value) {
                              _isEditing = true;
                              _onFieldChanged();
                            },
                            decoration: InputDecoration(
                              labelText: "Nom d'affichage",
                              labelStyle: TextStyle(
                                color: _isDisplayNameValid ? Colors.white70 : Colors.red,
                              ),
                              prefixIcon: Icon(
                                Icons.person,
                                color: _isDisplayNameValid ? Color(0xFF6366F1) : Colors.red,
                              ),
                              suffixIcon: _displayNameController.text.isNotEmpty
                                  ? Icon(
                                _isDisplayNameValid ? Icons.check_circle : Icons.error,
                                color: _isDisplayNameValid ? Colors.green : Colors.red,
                              )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              errorText: _isDisplayNameValid ? null : _displayNameError,
                              errorStyle: const TextStyle(color: Colors.red),
                              filled: true,
                              fillColor: const Color(0xFF1E1E3F),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Genre avec validation
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Genre',
                        style: TextStyle(
                          color: _isGenderValid ? Colors.white70 : Colors.red,
                          fontSize: 16,
                        ),
                      ),
                      if (!_isGenderValid)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Icon(Icons.error, color: Colors.red, size: 16),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildGenderOption('Masculin', 1),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildGenderOption('Féminin', 2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildGenderOption('Ne se prononce pas', 3, fullWidth: true),
                    ],
                  ),
                  if (!_isGenderValid && _genderError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _genderError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Date de naissance avec validation
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Date de naissance',
                        style: TextStyle(
                          color: _isAgeValid ? Colors.white70 : Colors.red,
                          fontSize: 16,
                        ),
                      ),
                      if (!_isAgeValid)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Icon(Icons.error, color: Colors.red, size: 16),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E3F),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isAgeValid ? Colors.transparent : Colors.red,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.cake,
                            color: _isAgeValid ? Color(0xFF6366F1) : Colors.red,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedDate != null
                                  ? 'Date de naissance: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                  : 'Sélectionner votre date de naissance',
                              style: TextStyle(
                                color: _selectedDate != null ? Colors.white : Colors.white60,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: _isAgeValid ? Color(0xFF6366F1) : Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!_isAgeValid && _ageError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _ageError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Bouton de sauvegarde
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isFormValid
                      ? () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isEditing = false;
                      });

                      await ref
                          .read(userProfileControllerProvider.notifier)
                          .updateProfile(
                        displayName: _displayNameController.text.isNotEmpty
                            ? _displayNameController.text
                            : null,
                        gender: _selectedGender,
                        birthdate: _selectedDate,
                      );

                      setState(() {
                        _hasChanges = false;
                        _pendingChanges.clear();
                      });

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profil mis à jour'),
                            backgroundColor: Color(0xFF6366F1),
                          ),
                        );
                      }
                    }
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFormValid ? const Color(0xFF6366F1) : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Enregistrer les modifications',
                    style: TextStyle(fontSize: 16, color: _isFormValid ? Colors.white : Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderOption(String label, int value, {bool fullWidth = false}) {
    final isSelected = _selectedGender == value;
    final hasError = !_isGenderValid;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = value;
          _validateGender();
          _hasChanges = true;
          _isEditing = true;
        });
        _savePendingChanges();
      },
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (hasError ? Colors.red : const Color(0xFF6366F1))
              : const Color(0xFF1E1E3F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? (hasError ? Colors.red : const Color(0xFF6366F1))
                : (hasError ? Colors.red : Colors.transparent),
            width: 1,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white),
              ),
              if (isSelected && hasError)
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(Icons.error, color: Colors.white, size: 14),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutMeTab(UserProfileEntity profile) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'À propos de moi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_isDataLoaded && !_isAboutMeValid)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(Icons.error, color: Colors.red, size: 16),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Focus(
                onFocusChange: (hasFocus) {
                  setState(() {
                    _isEditing = hasFocus;
                  });
                },
                child: TextField(
                  controller: _aboutMeController,
                  maxLines: null,
                  expands: true,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    _isEditing = true;
                    _onFieldChanged();
                  },
                  decoration: InputDecoration(
                    hintText: 'Parle-nous un peu de toi...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _isAboutMeValid ? Colors.transparent : Colors.red,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _isAboutMeValid ? Colors.transparent : Colors.red,
                        width: 1,
                      ),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF1E1E3F),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isAboutMeValid
                    ? () async {
                  setState(() {
                    _isEditing = false;
                  });

                  await ref
                      .read(userProfileControllerProvider.notifier)
                      .updateAboutMe(_aboutMeController.text);

                  setState(() {
                    _hasChanges = false;
                    _pendingChanges.clear();
                  });

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('À propos mis à jour'),
                        backgroundColor: Color(0xFF6366F1),
                      ),
                    );
                  }
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isAboutMeValid ? const Color(0xFF6366F1) : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Enregistrer',
                  style: TextStyle(fontSize: 16, color: _isAboutMeValid ? Colors.white : Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoTab(UserProfileEntity profile) {
    final String? imageUrl = profile.photoUrl != null && profile.hasPhoto
        ? 'http://192.168.1.56:8101' + profile.photoUrl!
        : null;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Affichage de la photo avec loader et badge d'erreur si manquante
          Stack(
            children: [
              _buildPhotoContainer(profile, imageUrl),
              if (_isPhotoLoading) _buildPhotoLoader(),
              if (_isDataLoaded && !_isPhotoValid && !_isPhotoLoading)
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              if (_isDataLoaded && _isPhotoValid && !_isPhotoLoading)
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF6366F1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 30),

          // Boutons Galerie et Appareil photo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPhotoButton(
                icon: Icons.photo_library,
                label: 'Galerie',
                onTap: _isPhotoLoading ? null : () => _pickImage(ImageSource.gallery),
              ),
              _buildPhotoButton(
                icon: Icons.photo_camera,
                label: 'Appareil photo',
                onTap: _isPhotoLoading ? null : () => _pickImage(ImageSource.camera),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Bouton de suppression
          // if ((profile.hasPhoto || _selectedImage != null) && !_isPhotoLoading)
          //   TextButton(
          //     onPressed: _deletePhoto,
          //     style: TextButton.styleFrom(
          //       foregroundColor: Colors.red,
          //     ),
          //     child: const Text('Supprimer la photo'),
          //   ),

          // Message d'erreur si photo manquante
          if (_isDataLoaded && !_isPhotoValid && !_isPhotoLoading)
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                'Une photo de profil est requise',
                style: TextStyle(color: Colors.red),
              ),
            ),

          // Affichage debug de l'URL
          if (imageUrl != null && kDebugMode && !_isPhotoLoading)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                'URL: $imageUrl',
                style: const TextStyle(color: Colors.white54, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoContainer(UserProfileEntity profile, String? imageUrl) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: _isDataLoaded && !_isPhotoValid ? Colors.red : const Color(0xFF6366F1),
          width: 3,
        ),
      ),
      child: ClipOval(
        child: _getPhotoContent(profile, imageUrl),
      ),
    );
  }

  Widget _getPhotoContent(UserProfileEntity profile, String? imageUrl) {
    if (_selectedImage != null) {
      return Image.file(
        File(_selectedImage!.path),
        fit: BoxFit.cover,
      );
    }

    if (imageUrl != null) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: const Color(0xFF1E1E3F),
          child: const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF6366F1),
              strokeWidth: 2,
            ),
          ),
        ),
        errorWidget: (context, url, error) {
          print('Erreur chargement photo: $error');
          return Container(
            color: const Color(0xFF1E1E3F),
            child: const Center(
              child: Icon(
                Icons.broken_image,
                size: 50,
                color: Colors.white54,
              ),
            ),
          );
        },
      );
    }

    return Container(
      color: const Color(0xFF1E1E3F),
      child: const Center(
        child: Icon(
          Icons.person,
          size: 80,
          color: Color(0xFF6366F1),
        ),
      ),
    );
  }

  Widget _buildPhotoLoader() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black54,
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF6366F1),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1.0,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E3F),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF6366F1), size: 30),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}