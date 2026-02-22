import 'dart:async';
import 'dart:math' as math;

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../drinkks/exts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../drinkks/theme.dart';
import 'room.dart';

class JoinArgs {
  JoinArgs({
    required this.url,
    required this.token,
    this.e2ee = false,
    this.e2eeKey,
    this.simulcast = true,
    this.adaptiveStream = true,
    this.dynacast = true,
    this.preferredCodec = 'VP8',
    this.enableBackupVideoCodec = true,
  });
  final String url;
  final String token;
  final bool e2ee;
  final String? e2eeKey;
  final bool simulcast;
  final bool adaptiveStream;
  final bool dynacast;
  final String preferredCodec;
  final bool enableBackupVideoCodec;
}

class PreJoinPage extends StatefulWidget {
  const PreJoinPage({
    required this.args,
    super.key,
  });
  final JoinArgs args;
  @override
  State<StatefulWidget> createState() => _PreJoinPageState();
}

class _PreJoinPageState extends State<PreJoinPage> {
  static const _prefKeyEnableVideo = 'prejoin-enable-video';
  static const _prefKeyEnableAudio = 'prejoin-enable-audio';

  // Couleurs du thème sombre
  final Color _backgroundColor = const Color(0xFF0F0F23); // Noir bleuté profond
  final Color _surfaceColor = const Color(0xFF1A1A2E); // Surface légèrement plus claire
  final Color _primaryColor = const Color(0xFF6366F1); // Indigo doux
  final Color _accentColor = const Color(0xFF8B5CF6); // Violet accent
  final Color _textPrimary = Colors.white;
  final Color _textSecondary = const Color(0xFF94A3B8); // Gris bleuté
  final Color _borderColor = Colors.white.withOpacity(0.1);

  List<MediaDevice> _audioInputs = [];
  List<MediaDevice> _videoInputs = [];
  StreamSubscription? _subscription;

  bool _busy = false;
  bool _enableVideo = true;
  bool _enableAudio = true;
  LocalAudioTrack? _audioTrack;
  LocalVideoTrack? _videoTrack;

  MediaDevice? _selectedVideoDevice;
  MediaDevice? _selectedAudioDevice;
  VideoParameters _selectedVideoParameters = VideoParametersPresets.h720_169;

  // Nouvelle méthode pour vérifier et demander les permissions
  Future<bool> _checkAndRequestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    bool cameraGranted = statuses[Permission.camera]?.isGranted ?? false;
    bool microphoneGranted = statuses[Permission.microphone]?.isGranted ?? false;

    if (!cameraGranted || !microphoneGranted) {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            backgroundColor: _surfaceColor,
            title: const Text(
              'Permissions requises',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'L\'application a besoin des permissions caméra et microphone pour la visioconférence. '
                  'Veuillez les activer dans les paramètres.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: _textSecondary,
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    unawaited(_initStateAsync());
  }

  Future<void> _initStateAsync() async {
    // Vérifier les permissions avant de continuer
    bool hasPermissions = await _checkAndRequestPermissions();
    if (!hasPermissions) {
      return;
    }

    await _readPrefs();
    _subscription = Hardware.instance.onDeviceChange.stream.listen(_loadDevices);
    final devices = await Hardware.instance.enumerateDevices();
    await _loadDevices(devices);
  }

  Future<void> _loadDevices(List<MediaDevice> devices) async {
    _audioInputs = devices.where((d) => d.kind == 'audioinput').toList();
    _videoInputs = devices.where((d) => d.kind == 'videoinput').toList();

    if (_selectedAudioDevice != null && !_audioInputs.contains(_selectedAudioDevice)) {
      _selectedAudioDevice = null;
    }
    if (_audioInputs.isEmpty) {
      await _audioTrack?.stop();
      _audioTrack = null;
    }
    if (_selectedVideoDevice != null && !_videoInputs.contains(_selectedVideoDevice)) {
      _selectedVideoDevice = null;
    }
    if (_videoInputs.isEmpty) {
      await _videoTrack?.stop();
      _videoTrack = null;
    }

    if (_enableAudio && _audioInputs.isNotEmpty) {
      if (_selectedAudioDevice == null) {
        _selectedAudioDevice = _audioInputs.first;
        Future.delayed(const Duration(milliseconds: 100), () async {
          if (!mounted) return;
          await _changeLocalAudioTrack();
          if (mounted) setState(() {});
        });
      }
    }

    if (_enableVideo && _videoInputs.isNotEmpty) {
      if (_selectedVideoDevice == null) {
        _selectedVideoDevice = _videoInputs.first;
        Future.delayed(const Duration(milliseconds: 100), () async {
          if (!mounted) return;
          await _changeLocalVideoTrack();
          if (mounted) setState(() {});
        });
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _setEnableVideo(value) async {
    _enableVideo = value;
    await _writePrefs();
    if (!_enableVideo) {
      await _videoTrack?.stop();
      _videoTrack = null;
      _selectedVideoDevice = null;
    } else {
      // Vérifier les permissions avant d'activer la caméra
      PermissionStatus cameraStatus = await Permission.camera.status;
      if (!cameraStatus.isGranted) {
        bool granted = await _checkAndRequestPermissions();
        if (!granted) {
          setState(() {
            _enableVideo = false;
          });
          return;
        }
      }

      if (_selectedVideoDevice == null && _videoInputs.isNotEmpty) {
        _selectedVideoDevice = _videoInputs.first;
      }
      await _changeLocalVideoTrack();
    }
    setState(() {});
  }

  Future<void> _setEnableAudio(value) async {
    _enableAudio = value;
    await _writePrefs();
    if (!_enableAudio) {
      await _audioTrack?.stop();
      _audioTrack = null;
      _selectedAudioDevice = null;
    } else {
      // Vérifier les permissions avant d'activer le micro
      PermissionStatus microphoneStatus = await Permission.microphone.status;
      if (!microphoneStatus.isGranted) {
        bool granted = await _checkAndRequestPermissions();
        if (!granted) {
          setState(() {
            _enableAudio = false;
          });
          return;
        }
      }

      if (_selectedAudioDevice == null && _audioInputs.isNotEmpty) {
        _selectedAudioDevice = _audioInputs.first;
      }
      await _changeLocalAudioTrack();
    }
    setState(() {});
  }

  Future<void> _changeLocalAudioTrack() async {
    if (!_enableAudio) return;
    try {
      if (_audioTrack != null) {
        await _audioTrack!.stop();
        _audioTrack = null;
      }

      if (_selectedAudioDevice != null) {
        _audioTrack = await LocalAudioTrack.create(
          AudioCaptureOptions(
            deviceId: _selectedAudioDevice!.deviceId,
          ),
        );
        await _audioTrack!.start();
      }
    } catch (e) {
      print('Erreur lors de la création du track audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur audio: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _changeLocalVideoTrack() async {
    if (!_enableVideo) return;
    try {
      if (_videoTrack != null) {
        await _videoTrack!.stop();
        _videoTrack = null;
      }

      if (_selectedVideoDevice != null) {
        _videoTrack = await LocalVideoTrack.createCameraTrack(CameraCaptureOptions(
          deviceId: _selectedVideoDevice!.deviceId,
          params: _selectedVideoParameters,
        ));
        await _videoTrack!.start();
      }
    } catch (e) {
      print('Erreur lors de la création du track vidéo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur vidéo: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Désactiver la vidéo en cas d'erreur
        setState(() {
          _enableVideo = false;
        });
      }
    }
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  _join(BuildContext context) async {
    _busy = true;

    setState(() {});

    final args = widget.args;

    try {
      // Vérifier les permissions avant de rejoindre
      bool hasPermissions = await _checkAndRequestPermissions();
      if (!hasPermissions) {
        setState(() {
          _busy = false;
        });
        return;
      }

      //create new room
      const cameraEncoding = VideoEncoding(
        maxBitrate: 5 * 1000 * 1000,
        maxFramerate: 30,
      );

      const screenEncoding = VideoEncoding(
        maxBitrate: 3 * 1000 * 1000,
        maxFramerate: 15,
      );

      E2EEOptions? e2eeOptions;
      if (args.e2ee && args.e2eeKey != null) {
        final keyProvider = await BaseKeyProvider.create();
        e2eeOptions = E2EEOptions(keyProvider: keyProvider);
        await keyProvider.setKey(args.e2eeKey!);
      }

      final room = Room(
        roomOptions: RoomOptions(
          adaptiveStream: args.adaptiveStream,
          dynacast: args.dynacast,
          defaultAudioPublishOptions: const AudioPublishOptions(
            name: 'custom_audio_track_name',
          ),
          defaultCameraCaptureOptions: const CameraCaptureOptions(
              maxFrameRate: 30,
              params: VideoParameters(
                dimensions: VideoDimensions(1280, 720),
              )),
          defaultScreenShareCaptureOptions: const ScreenShareCaptureOptions(
              useiOSBroadcastExtension: true,
              params: VideoParameters(
                dimensions: VideoDimensionsPresets.h1080_169,
              )),
          defaultVideoPublishOptions: VideoPublishOptions(
            simulcast: args.simulcast,
            videoCodec: args.preferredCodec,
            backupVideoCodec: BackupVideoCodec(
              enabled: args.enableBackupVideoCodec,
            ),
            videoEncoding: cameraEncoding,
            screenShareEncoding: screenEncoding,
          ),
          encryption: e2eeOptions,
        ),
      );
      // Create a Listener before connecting
      final listener = room.createListener();

      await room.prepareConnection(args.url, args.token);

      // Try to connect to the room
      // This will throw an Exception if it fails for any reason.
      await room.connect(
        args.url,
        args.token,
        fastConnectOptions: FastConnectOptions(
          microphone: TrackOption(track: _audioTrack),
          camera: TrackOption(track: _videoTrack),
        ),
      );

      if (!context.mounted) return;
      await Navigator.push<void>(
        context,
        MaterialPageRoute(builder: (_) => RoomPage(room, listener)),
      );
    } catch (error) {
      print('Could not connect $error');
      if (!context.mounted) return;
      await context.showErrorDialog(error);
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  void _actionBack(BuildContext context) async {
    await _setEnableVideo(false);
    await _setEnableAudio(false);
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _readPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _enableVideo = prefs.getBool(_prefKeyEnableVideo) ?? true;
      _enableAudio = prefs.getBool(_prefKeyEnableAudio) ?? true;
    });
  }

  Future<void> _writePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyEnableVideo, _enableVideo);
    await prefs.setBool(_prefKeyEnableAudio, _enableAudio);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _surfaceColor,
        elevation: 0,
        title: const Text(
          'Configuration',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => _actionBack(context),
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Aperçu vidéo
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Container(
                    width: 320,
                    height: 240,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _borderColor,
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        color: _surfaceColor,
                        child: _videoTrack != null
                            ? VideoTrackRenderer(
                          renderMode: VideoRenderMode.auto,
                          _videoTrack!,
                        )
                            : Container(
                          alignment: Alignment.center,
                          child: LayoutBuilder(
                            builder: (ctx, constraints) => Icon(
                              Icons.videocam_off,
                              color: _primaryColor.withOpacity(0.5),
                              size: math.min(constraints.maxHeight, constraints.maxWidth) * 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Section Caméra
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _borderColor,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Caméra',
                            style: TextStyle(
                              color: _textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Switch(
                            value: _enableVideo,
                            onChanged: (value) => _setEnableVideo(value),
                            activeColor: _primaryColor,
                            activeTrackColor: _primaryColor.withOpacity(0.3),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_enableVideo) ...[
                        DropdownButtonHideUnderline(
                          child: DropdownButton2<MediaDevice>(
                            isExpanded: true,
                            hint: Text(
                              'Sélectionner une caméra',
                              style: TextStyle(color: _textSecondary),
                            ),
                            items: _videoInputs
                                .map((MediaDevice item) => DropdownMenuItem<MediaDevice>(
                              value: item,
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _textPrimary,
                                ),
                              ),
                            ))
                                .toList(),
                            value: _selectedVideoDevice,
                            onChanged: (MediaDevice? value) async {
                              if (value != null) {
                                _selectedVideoDevice = value;
                                await _changeLocalVideoTrack();
                                setState(() {});
                              }
                            },
                            buttonStyleData: ButtonStyleData(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _borderColor),
                                color: _backgroundColor,
                              ),
                            ),
                            menuItemStyleData: const MenuItemStyleData(
                              height: 48,
                            ),
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: _surfaceColor,
                                border: Border.all(color: _borderColor),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonHideUnderline(
                          child: DropdownButton2<VideoParameters>(
                            isExpanded: true,
                            hint: Text(
                              'Résolution vidéo',
                              style: TextStyle(color: _textSecondary),
                            ),
                            items: [
                              VideoParametersPresets.h480_43,
                              VideoParametersPresets.h540_169,
                              VideoParametersPresets.h720_169,
                              VideoParametersPresets.h1080_169,
                            ]
                                .map((VideoParameters item) => DropdownMenuItem<VideoParameters>(
                              value: item,
                              child: Text(
                                '${item.dimensions.width}x${item.dimensions.height}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _textPrimary,
                                ),
                              ),
                            ))
                                .toList(),
                            value: _selectedVideoParameters,
                            onChanged: (VideoParameters? value) async {
                              if (value != null) {
                                _selectedVideoParameters = value;
                                await _changeLocalVideoTrack();
                                setState(() {});
                              }
                            },
                            buttonStyleData: ButtonStyleData(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _borderColor),
                                color: _backgroundColor,
                              ),
                            ),
                            menuItemStyleData: const MenuItemStyleData(
                              height: 48,
                            ),
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: _surfaceColor,
                                border: Border.all(color: _borderColor),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Section Microphone
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _borderColor,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Microphone',
                            style: TextStyle(
                              color: _textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Switch(
                            value: _enableAudio,
                            onChanged: (value) => _setEnableAudio(value),
                            activeColor: _primaryColor,
                            activeTrackColor: _primaryColor.withOpacity(0.3),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_enableAudio)
                        DropdownButtonHideUnderline(
                          child: DropdownButton2<MediaDevice>(
                            isExpanded: true,
                            hint: Text(
                              'Sélectionner un microphone',
                              style: TextStyle(color: _textSecondary),
                            ),
                            items: _audioInputs
                                .map((MediaDevice item) => DropdownMenuItem<MediaDevice>(
                              value: item,
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _textPrimary,
                                ),
                              ),
                            ))
                                .toList(),
                            value: _selectedAudioDevice,
                            onChanged: (MediaDevice? value) async {
                              if (value != null) {
                                _selectedAudioDevice = value;
                                await _changeLocalAudioTrack();
                                setState(() {});
                              }
                            },
                            buttonStyleData: ButtonStyleData(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _borderColor),
                                color: _backgroundColor,
                              ),
                            ),
                            menuItemStyleData: const MenuItemStyleData(
                              height: 48,
                            ),
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: _surfaceColor,
                                border: Border.all(color: _borderColor),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Bouton Rejoindre
                ElevatedButton(
                  onPressed: _busy ? null : () => _join(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_busy)
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      Text(
                        _busy ? 'Connexion...' : 'Rejoindre la conversation',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}