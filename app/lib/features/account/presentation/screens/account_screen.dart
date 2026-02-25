import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart'; // NOUVEAU
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
  String? _displayNameError;
  String? _genderError;
  String? _ageError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Ajouter un listener pour valider en temps réel
    _displayNameController.addListener(_validateDisplayName);
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
      _isDisplayNameValid = true;
      _displayNameError = null;
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

    setState(() {});
  }

  void _validateGender() {
    if (_selectedGender == null) {
      _isGenderValid = true;
      _genderError = null;
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
      _isAgeValid = true;
      _ageError = null;
    } else {
      final now = DateTime.now();
      final age = now.year - _selectedDate!.year;
      final hasHadBirthdayThisYear =
          now.month > _selectedDate!.month ||
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

  void _validateAll() {
    _validateDisplayName();
    _validateGender();
    _validateAge();
  }

  bool get _isFormValid {
    _validateAll();
    return _isDisplayNameValid && _isGenderValid && _isAgeValid;
  }

  void _loadProfileData(UserProfileEntity profile) {
    // Stocker les données originales une seule fois
    if (_originalProfile == null) {
      _originalProfile = profile;
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

  // Méthode pour détecter les changements (UNIQUEMENT pour les champs texte)
  void _onFieldChanged() {
    _validateAll();
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
    _savePendingChanges();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _isPhotoLoading = true;
        // NE PAS mettre _hasChanges à true
      });
      _savePendingChanges();

      try {
        await ref
            .read(userProfileControllerProvider.notifier)
            .updatePhoto(image.path);

        if (mounted) {
          setState(() {
            _isPhotoLoading = false;
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
            if (!_isFormValid && _hasChanges)
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
            tabs: const [
              Tab(icon: Icon(Icons.person), text: 'Profil'),
              Tab(icon: Icon(Icons.description), text: 'À propos'),
              Tab(icon: Icon(Icons.photo), text: 'Photo'),
            ],
          ),
        ),
        body: profileState.when(
          data: (profile) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _loadProfileData(profile);
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
                      if (_selectedGender != null && !_isGenderValid)
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
                      if (_selectedDate != null && !_isAgeValid)
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
                  child: const Text(
                    'Enregistrer les modifications',
                    style: TextStyle(fontSize: 16, color: Colors.white),
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
    final hasError = !_isGenderValid && _selectedGender != null;

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
            const Text(
              'À propos de moi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
                      borderSide: BorderSide.none,
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
                onPressed: () async {
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
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Enregistrer',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  // ============================================================
// MÉTHODE PRINCIPALE - Photo Tab
// ============================================================
  Widget _buildPhotoTab(UserProfileEntity profile) {
    final String? imageUrl = profile.photoUrl != null && profile.hasPhoto
        ? 'http://192.168.1.56:8101' + profile.photoUrl!
        : null;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Affichage de la photo avec loader
          _buildPhotoWithLoader(profile, imageUrl),

          const SizedBox(height: 30),

          // Boutons Galerie et Appareil photo
          _buildPhotoActionButtons(),

          const SizedBox(height: 20),

          // Bouton de suppression
          _buildDeleteButton(profile),

          // Affichage debug de l'URL
          _buildDebugInfo(imageUrl),
        ],
      ),
    );
  }

// ============================================================
// SOUS-MÉTHODES
// ============================================================

  /// Construit le conteneur de la photo avec le loader et le badge
  Widget _buildPhotoWithLoader(UserProfileEntity profile, String? imageUrl) {
    return Stack(
      children: [
        // La photo elle-même
        _buildPhotoContainer(profile, imageUrl),

        // Loader pendant l'upload/suppression
        if (_isPhotoLoading) _buildPhotoLoader(),

        // Badge de confirmation (check)
        if ((profile.hasPhoto || _selectedImage != null) && !_isPhotoLoading)
          _buildPhotoBadge(),
      ],
    );
  }

  /// Construit le conteneur circulaire de la photo
  Widget _buildPhotoContainer(UserProfileEntity profile, String? imageUrl) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF6366F1), width: 3),
      ),
      child: ClipOval(
        child: _getPhotoContent(profile, imageUrl),
      ),
    );
  }

  /// Retourne le contenu de la photo (image locale, réseau ou icône par défaut)
  Widget _getPhotoContent(UserProfileEntity profile, String? imageUrl) {
    // Cas 1: Image sélectionnée localement (avant upload)
    if (_selectedImage != null) {
      return Image.file(
        File(_selectedImage!.path),
        fit: BoxFit.cover,
      );
    }

    // Cas 2: Image distante (déjà uploadée)
    if (imageUrl != null) {
      return _buildNetworkImage(imageUrl);
    }

    // Cas 3: Pas de photo, icône par défaut
    return _buildDefaultAvatar();
  }

  /// Construit une image réseau avec CachedNetworkImage
  Widget _buildNetworkImage(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => _buildImagePlaceholder(),
      errorWidget: (context, url, error) {
        print('Erreur chargement photo: $error');
        return _buildErrorImage();
      },
    );
  }

  /// Placeholder pendant le chargement de l'image réseau
  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xFF1E1E3F),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF6366F1),
          strokeWidth: 2,
        ),
      ),
    );
  }

  /// Affichage en cas d'erreur de chargement
  Widget _buildErrorImage() {
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
  }

  /// Avatar par défaut (quand pas de photo)
  Widget _buildDefaultAvatar() {
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

  /// Loader superposé pendant l'upload ou la suppression
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

  /// Badge de confirmation (check) quand une photo est présente
  Widget _buildPhotoBadge() {
    return Positioned(
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
    );
  }

  /// Boutons pour choisir la source de l'image (galerie ou appareil photo)
  Widget _buildPhotoActionButtons() {
    return Row(
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
    );
  }

  /// Bouton de suppression de la photo
  Widget _buildDeleteButton(UserProfileEntity profile) {
    if (!(profile.hasPhoto || _selectedImage != null) || _isPhotoLoading) {
      return const SizedBox.shrink(); // Rien à afficher
    }

    return TextButton(
      onPressed: _deletePhoto,
      style: TextButton.styleFrom(
        foregroundColor: Colors.red,
      ),
      child: const Text('Supprimer la photo'),
    );
  }

  /// Informations de debug (URL de la photo)
  Widget _buildDebugInfo(String? imageUrl) {
    if (imageUrl == null || !kDebugMode || _isPhotoLoading) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Text(
        'URL: $imageUrl',
        style: const TextStyle(color: Colors.white54, fontSize: 10),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Bouton individuel pour les actions photo
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