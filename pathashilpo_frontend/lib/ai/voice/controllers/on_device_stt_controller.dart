import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../models/stt_state.dart';

/// Multi-tier Speech-to-Text Controller for Patha-Shilpo.
///
/// Designed to use cloud-assisted ASR when internet is online, and seamlessly
/// fall back to local On-Device Speech Recognition whenever internet is OFF or
/// experiencing network errors / low rural connectivity.
class OnDeviceSttController extends ChangeNotifier {
  static final OnDeviceSttController _instance = OnDeviceSttController._internal();
  factory OnDeviceSttController() => _instance;
  OnDeviceSttController._internal();

  final SpeechToText _speech = SpeechToText();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  SttStatus _status = SttStatus.uninitialized;
  SttStatus get status => _status;

  bool get isListening => _speech.isListening;
  bool get isAvailable => _status != SttStatus.uninitialized && _status != SttStatus.permissionDenied;

  bool _isOffline = false;
  bool get isOffline => _isOffline;

  bool _isFallbackActive = false;
  bool get isFallbackActive => _isFallbackActive;

  List<LocaleName> _locales = [];
  List<LocaleName> get locales => List.unmodifiable(_locales);

  LocaleName? _systemLocale;
  LocaleName? get systemLocale => _systemLocale;

  String _lastSpokenText = '';
  String get lastSpokenText => _lastSpokenText;

  double _soundLevel = 0.0;
  double get soundLevel => _soundLevel;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _initialized = false;

  /// Initializes the speech recognizer and starts connectivity monitoring.
  Future<bool> initialize() async {
    if (_initialized) return true;

    await _checkConnectivity();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final wasOffline = _isOffline;
      _isOffline = results.contains(ConnectivityResult.none) || results.isEmpty;
      if (wasOffline != _isOffline) {
        notifyListeners();
      }
    });

    try {
      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        _status = SttStatus.permissionDenied;
        _errorMessage = 'Microphone permission was denied';
        notifyListeners();
        return false;
      }

      final available = await _speech.initialize(
        onStatus: _handleStatus,
        onError: _handleError,
        debugLogging: kDebugMode,
      );

      if (available) {
        _locales = await _speech.locales();
        _systemLocale = await _speech.systemLocale();
        _status = SttStatus.ready;
        _initialized = true;
      } else {
        _status = SttStatus.error;
        _errorMessage = 'Speech recognizer unavailable on this device';
      }
      notifyListeners();
      return available;
    } catch (e) {
      _status = SttStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> _checkConnectivity() async {
    try {
      final results = await Connectivity().checkConnectivity();
      _isOffline = results.contains(ConnectivityResult.none) || results.isEmpty;
    } catch (_) {
      _isOffline = true;
    }
  }

  /// Resolve best matching locale code for user's language.
  String resolveLocaleId(String? preferredLangCode) {
    if (_locales.isEmpty) return 'en_IN';

    final String raw =
        (preferredLangCode ?? 'en').toLowerCase().replaceAll('-', '_');
    final String prefix = raw.split('_').first; // 'en', 'hi', 'bn'

    // 1. Priority: Exact match (e.g. 'en_in' == 'en_in')
    for (final loc in _locales) {
      final String id = loc.localeId.toLowerCase().replaceAll('-', '_');
      if (id == raw) return loc.localeId;
    }

    // 2. Priority: Match the same language with Indian region (e.g. en_in, hi_in, bn_in)
    final String inLocale = '${prefix}_in';
    for (final loc in _locales) {
      final String id = loc.localeId.toLowerCase().replaceAll('-', '_');
      if (id == inLocale) return loc.localeId;
    }

    // 3. Priority: Any locale starting with the language prefix (e.g. en_us, en_gb for 'en')
    for (final loc in _locales) {
      final String id = loc.localeId.toLowerCase().replaceAll('-', '_');
      if (id.startsWith(prefix)) return loc.localeId;
    }

    // 4. System locale if it matches language prefix
    if (_systemLocale != null) {
      final String sysId =
          _systemLocale!.localeId.toLowerCase().replaceAll('-', '_');
      if (sysId.startsWith(prefix)) return _systemLocale!.localeId;
    }

    // 5. Safe fallback
    return _systemLocale?.localeId ?? _locales.first.localeId;
  }

  /// Start speech recognition with automatic offline on-device fallback.
  Future<bool> startListening({
    required ValueChanged<SttResult> onResult,
    String? preferredLocale,
    ValueChanged<double>? onSoundLevelChange,
  }) async {
    if (!_initialized) {
      final ok = await initialize();
      if (!ok) return false;
    }

    await _checkConnectivity();

    if (_speech.isListening) {
      await stopListening();
    }

    _lastSpokenText = '';
    _errorMessage = null;
    _status = SttStatus.listening;
    _isFallbackActive = _isOffline;
    notifyListeners();

    final targetLocaleId = resolveLocaleId(preferredLocale);

    // If internet is OFF, immediately activate on-device fallback
    if (_isOffline) {
      return _listenOnDevice(
        targetLocaleId: targetLocaleId,
        onResult: onResult,
        // Normalised on the way through: the plugin reports a dB-ish
        // value (about -2..10 on Android), and forwarding it raw made
        // the mic button scale by 4x. Callers get 0..1, always.
        onSoundLevelChange: onSoundLevelChange == null
            ? null
            : (double level) =>
                onSoundLevelChange((level / 10.0).clamp(0.0, 1.0)),
      );
    }

    // If internet is ON, attempt online recognition, falling back to on-device if network drops
    try {
      await _speech.listen(
        onResult: (SpeechRecognitionResult res) {
          _lastSpokenText = res.recognizedWords;
          final result = SttResult(
            text: res.recognizedWords,
            isFinal: res.finalResult,
            confidence: res.confidence > 0 ? res.confidence : 0.95,
            languageCode: targetLocaleId,
          );
          onResult(result);
          notifyListeners();
        },
        onSoundLevelChange: (level) {
          _soundLevel = (level / 10.0).clamp(0.0, 1.0);
          onSoundLevelChange?.call(_soundLevel);
          notifyListeners();
        },
        listenOptions: SpeechListenOptions(
          partialResults: true,
          listenMode: ListenMode.dictation,
          listenFor: const Duration(seconds: 45),
          pauseFor: const Duration(seconds: 4),
          localeId: targetLocaleId,
        ),
      );
      return true;
    } catch (e) {
      // Automatic Fallback: network error or offline mid-session -> fallback to on-device
      _isFallbackActive = true;
      notifyListeners();
      return _listenOnDevice(
        targetLocaleId: targetLocaleId,
        onResult: onResult,
        // Normalised on the way through: the plugin reports a dB-ish
        // value (about -2..10 on Android), and forwarding it raw made
        // the mic button scale by 4x. Callers get 0..1, always.
        onSoundLevelChange: onSoundLevelChange == null
            ? null
            : (double level) =>
                onSoundLevelChange((level / 10.0).clamp(0.0, 1.0)),
      );
    }
  }

  Future<bool> _listenOnDevice({
    required String targetLocaleId,
    required ValueChanged<SttResult> onResult,
    ValueChanged<double>? onSoundLevelChange,
  }) async {
    try {
      await _speech.listen(
        onResult: (SpeechRecognitionResult res) {
          _lastSpokenText = res.recognizedWords;
          final result = SttResult(
            text: res.recognizedWords,
            isFinal: res.finalResult,
            confidence: res.confidence > 0 ? res.confidence : 0.9,
            languageCode: targetLocaleId,
          );
          onResult(result);
          notifyListeners();
        },
        onSoundLevelChange: (level) {
          _soundLevel = (level / 10.0).clamp(0.0, 1.0);
          onSoundLevelChange?.call(_soundLevel);
          notifyListeners();
        },
        listenOptions: SpeechListenOptions(
          onDevice: true,
          partialResults: true,
          listenMode: ListenMode.dictation,
          cancelOnError: false,
          listenFor: const Duration(seconds: 45),
          pauseFor: const Duration(seconds: 4),
          localeId: targetLocaleId,
        ),
      );
      return true;
    } catch (err) {
      _status = SttStatus.error;
      _errorMessage = err.toString();
      notifyListeners();
      return false;
    }
  }

  /// Stops listening and commits the final recognized text.
  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
      _status = SttStatus.done;
      _soundLevel = 0.0;
      notifyListeners();
    }
  }

  /// Cancels the speech recognition session without committing.
  Future<void> cancelListening() async {
    if (_speech.isListening) {
      await _speech.cancel();
      _status = SttStatus.ready;
      _soundLevel = 0.0;
      notifyListeners();
    }
  }

  void _handleStatus(String status) {
    if (status == 'listening') {
      _status = SttStatus.listening;
    } else if (status == 'notListening' || status == 'done') {
      _status = SttStatus.done;
      _soundLevel = 0.0;
    }
    notifyListeners();
  }

  void _handleError(SpeechRecognitionError error) {
    // If error was a network error during online listening, automatically trigger on-device fallback
    if (!_isOffline && error.errorMsg.toLowerCase().contains('network')) {
      _isOffline = true;
      _isFallbackActive = true;
      notifyListeners();
      return;
    }
    _status = SttStatus.error;
    _errorMessage = error.errorMsg;
    _soundLevel = 0.0;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }
}
