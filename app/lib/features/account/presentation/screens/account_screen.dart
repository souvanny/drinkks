import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../providers/auth_provider.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../controllers/user_profile_controller.dart';

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
  final _usernameController = TextEditingController();
  int? _selectedGender;
  DateTime? _selectedDate;

  // Champs pour la photo
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Variable pour suivre si des changements ont été faits
  bool _hasChanges = false;

  // Flag pour éviter les écrasements pendant l'édition
  bool _isEditing = false;

  // Stocker les données originales pour comparaison
  UserProfileEntity? _originalProfile;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _usernameController.dispose();
    _aboutMeController.dispose();
    super.dispose();
  }

  void _loadProfileData(UserProfileEntity profile) {
    // Stocker les données originales une seule fois
    _originalProfile ??= profile;

    // Ne pas écraser pendant l'édition
    if (_isEditing) return;

    // Ne mettre à jour que si les valeurs sont différentes et que ce n'est pas en édition
    final newUsername = profile.username ?? '';
    if (_usernameController.text != newUsername && !_isEditing) {
      _usernameController.text = newUsername;
    }

    if (_selectedGender != profile.gender && !_isEditing) {
      _selectedGender = profile.gender;
    }

    if (_selectedDate != profile.birthdate && !_isEditing) {
      _selectedDate = profile.birthdate;
    }

    final newAboutMe = profile.aboutMe ?? '';
    if (_aboutMeController.text != newAboutMe && !_isEditing) {
      _aboutMeController.text = newAboutMe;
    }
  }

  // Méthode pour détecter les changements
  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _hasChanges = true;
      });
      // Upload automatique
      ref
          .read(userProfileControllerProvider.notifier)
          .updatePhoto(image.path);
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
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    // Sauvegarder l'état avant d'ouvrir le datepicker
    final currentUsername = _usernameController.text;
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

    // Restaurer l'état quoi qu'il arrive
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _hasChanges = true;
        _isEditing = true;
        // S'assurer que les autres valeurs restent
        _usernameController.text = currentUsername;
        _selectedGender = currentGender;
      });
    } else {
      // Si annulé, restaurer toutes les valeurs
      setState(() {
        _usernameController.text = currentUsername;
        _selectedGender = currentGender;
        _selectedDate = currentDate;
      });
    }
  }

  // Méthode pour gérer le retour avec confirmation
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
            child: const Text('Quitter'),
          ),
        ],
      ),
    );

    return confirm ?? false;
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
            // Charger les données initiales seulement si ce n'est pas en édition
            // et si ce sont les premières données
            if (!_isEditing) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && !_isEditing) {
                  _loadProfileData(profile);
                }
              });
            }

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
                  onPressed: () => ref.refresh(userProfileControllerProvider.notifier).refresh(),
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

              // Username
              Focus(
                onFocusChange: (hasFocus) {
                  setState(() {
                    _isEditing = hasFocus;
                  });
                },
                child: TextFormField(
                  controller: _usernameController,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    _isEditing = true;
                    _onFieldChanged();
                  },
                  decoration: InputDecoration(
                    labelText: 'Nom d\'utilisateur',
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.person, color: Color(0xFF6366F1)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF1E1E3F),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Genre
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Genre',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
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
                ],
              ),
              const SizedBox(height: 16),

              // Date de naissance
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E3F),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cake, color: Color(0xFF6366F1)),
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
                      const Icon(Icons.arrow_drop_down, color: Color(0xFF6366F1)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Bouton de sauvegarde
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isEditing = false;
                      });

                      await ref
                          .read(userProfileControllerProvider.notifier)
                          .updateProfile(
                        username: _usernameController.text.isNotEmpty
                            ? _usernameController.text
                            : null,
                        gender: _selectedGender,
                        birthdate: _selectedDate,
                      );

                      setState(() {
                        _hasChanges = false;
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
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Enregistrer les modifications',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderOption(String label, int value) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = value;
          _hasChanges = true;
          _isEditing = true;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: _selectedGender == value
              ? const Color(0xFF6366F1)
              : const Color(0xFF1E1E3F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedGender == value
                ? const Color(0xFF6366F1)
                : Colors.transparent,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white),
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
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoTab(UserProfileEntity profile) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF6366F1), width: 3),
              image: _selectedImage != null
                  ? DecorationImage(
                image: FileImage(File(_selectedImage!.path)),
                fit: BoxFit.cover,
              )
                  : (profile.photoUrl != null
                  ? DecorationImage(
                image: NetworkImage(profile.photoUrl!),
                fit: BoxFit.cover,
              )
                  : null),
            ),
            child: _selectedImage == null && profile.photoUrl == null
                ? const Center(
              child: Icon(
                Icons.person,
                size: 80,
                color: Color(0xFF6366F1),
              ),
            )
                : null,
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPhotoButton(
                icon: Icons.photo_library,
                label: 'Galerie',
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              _buildPhotoButton(
                icon: Icons.photo_camera,
                label: 'Appareil photo',
                onTap: () => _pickImage(ImageSource.camera),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
    );
  }
}