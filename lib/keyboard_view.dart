import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'korean_composer.dart';

const _channel = MethodChannel('com.example.keyboard12345/ime');

// ── Theme ──────────────────────────────────────────────────────────────────────

class KeyboardTheme {
  final String name;
  final Color swatch;
  final Color background;
  final Color charKey;
  final Color charKeyPressed;
  final Color actionKey;
  final Color actionKeyPressed;
  final Color activeKey;
  final Color activePressedKey;
  final Color charKeyText;
  final Color actionKeyText;

  const KeyboardTheme({
    required this.name,
    required this.swatch,
    required this.background,
    required this.charKey,
    required this.charKeyPressed,
    required this.actionKey,
    required this.actionKeyPressed,
    required this.activeKey,
    required this.activePressedKey,
    required this.charKeyText,
    required this.actionKeyText,
  });

  static const List<KeyboardTheme> presets = [
    KeyboardTheme(
      name: '라이트',
      swatch: Color(0xFFD1D5DB),
      background: Color(0xFFD1D5DB),
      charKey: Color(0xFFFFFFFF),
      charKeyPressed: Color(0xFFCCCCCC),
      actionKey: Color(0xFFADB5BD),
      actionKeyPressed: Color(0xFF9AA3AB),
      activeKey: Color(0xFF6B7280),
      activePressedKey: Color(0xFF505860),
      charKeyText: Color(0xDD000000),
      actionKeyText: Color(0xDD000000),
    ),
    KeyboardTheme(
      name: '다크',
      swatch: Color(0xFF1F2937),
      background: Color(0xFF111827),
      charKey: Color(0xFF374151),
      charKeyPressed: Color(0xFF4B5563),
      actionKey: Color(0xFF1F2937),
      actionKeyPressed: Color(0xFF374151),
      activeKey: Color(0xFF6B7280),
      activePressedKey: Color(0xFF9CA3AF),
      charKeyText: Color(0xFFFFFFFF),
      actionKeyText: Color(0xB3FFFFFF),
    ),
    KeyboardTheme(
      name: '블루',
      swatch: Color(0xFF3B82F6),
      background: Color(0xFFBFDBFE),
      charKey: Color(0xFFEFF6FF),
      charKeyPressed: Color(0xFFBFDBFE),
      actionKey: Color(0xFF3B82F6),
      actionKeyPressed: Color(0xFF2563EB),
      activeKey: Color(0xFF1D4ED8),
      activePressedKey: Color(0xFF1E40AF),
      charKeyText: Color(0xDD000000),
      actionKeyText: Color(0xFFFFFFFF),
    ),
    KeyboardTheme(
      name: '핑크',
      swatch: Color(0xFFEC4899),
      background: Color(0xFFFBCFE8),
      charKey: Color(0xFFFFF0F7),
      charKeyPressed: Color(0xFFFBCFE8),
      actionKey: Color(0xFFEC4899),
      actionKeyPressed: Color(0xFFDB2777),
      activeKey: Color(0xFFBE185D),
      activePressedKey: Color(0xFF9D174D),
      charKeyText: Color(0xDD000000),
      actionKeyText: Color(0xFFFFFFFF),
    ),
    KeyboardTheme(
      name: '민트',
      swatch: Color(0xFF10B981),
      background: Color(0xFFA7F3D0),
      charKey: Color(0xFFECFDF5),
      charKeyPressed: Color(0xFFA7F3D0),
      actionKey: Color(0xFF10B981),
      actionKeyPressed: Color(0xFF059669),
      activeKey: Color(0xFF047857),
      activePressedKey: Color(0xFF065F46),
      charKeyText: Color(0xDD000000),
      actionKeyText: Color(0xFFFFFFFF),
    ),
    KeyboardTheme(
      name: '퍼플',
      swatch: Color(0xFF8B5CF6),
      background: Color(0xFFDDD6FE),
      charKey: Color(0xFFF5F3FF),
      charKeyPressed: Color(0xFFDDD6FE),
      actionKey: Color(0xFF8B5CF6),
      actionKeyPressed: Color(0xFF7C3AED),
      activeKey: Color(0xFF6D28D9),
      activePressedKey: Color(0xFF5B21B6),
      charKeyText: Color(0xDD000000),
      actionKeyText: Color(0xFFFFFFFF),
    ),
  ];
}

// ── Emoji data ────────────────────────────────────────────────────────────────

const _emojiTabIcons = ['😊', '👋', '❤️', '🐾', '🍔'];
const _emojiData = [
  // Smileys
  [
    '😀','😃','😄','😁','😆','😅','😂','🤣','🥲','🥹','😊','😇','🙂','🙃',
    '😉','😌','😍','🥰','😘','😗','😙','😚','😋','😛','😝','😜','🤪','🤨',
    '🧐','🤓','😎','🥸','🤩','🥳','😏','😒','😞','😔','😟','😕','🫤','😣',
    '😖','😫','😩','🥺','😢','😭','😤','😠','😡','🤬','🤯','😳','🥵','🥶',
    '😱','😨','😰','😥','😓','🤔','🤭','😶','😐','😑','😬','🙄','😯','😦',
    '😧','😮','😲','🥱','😴','🤤','😷','🤒','🤕','🤢','🤮','🤧',
  ],
  // Hands & people
  [
    '👋','🤚','🖐','✋','🖖','👌','🤌','🤏','✌️','🤞','🤟','🤘','🤙','👈',
    '👉','👆','👇','☝️','👍','👎','✊','👊','🤛','🤜','👏','🙌','🫶','👐',
    '🤲','🤝','🙏','💪','🦾','👀','👅','👄','💋','🧑','👦','👧','👨','👩',
    '🧓','👴','👵','👶','🧒','🧑‍💻','🧑‍🎤','🧑‍🍳','🧑‍🎨','🧑‍🚀',
  ],
  // Hearts & symbols
  [
    '❤️','🧡','💛','💚','💙','💜','🖤','🤍','🤎','💔','❤️‍🔥','💕','💞',
    '💓','💗','💖','💘','💝','💟','🔥','⭐','🌟','💫','✨','🎉','🎊','🎈',
    '🎁','🎀','🏆','🥇','💯','💢','💥','💦','💨','💬','💭','💤','🔔','🎵',
    '🎶','🎤','📱','💻','⌚','📷','🎮','🎲','🎯','👾','🕹️','🎧','📣','🔑',
  ],
  // Nature & animals
  [
    '🐶','🐱','🐭','🐹','🐰','🦊','🐻','🐼','🐨','🐯','🦁','🐮','🐷','🐸',
    '🐵','🙈','🙉','🙊','🐔','🐧','🐦','🦆','🦅','🦉','🦇','🐺','🐗','🐴',
    '🦄','🐝','🦋','🐌','🐞','🦗','🌸','🌹','🌺','🌻','🌼','🌷','🍀','🌿',
    '🍃','🌱','🌲','🌳','🌴','🍄','🌊','🌈','🌙','☀️','⛅','❄️','🌧','⛈',
  ],
  // Food & drink
  [
    '🍎','🍐','🍊','🍋','🍌','🍉','🍇','🍓','🫐','🍒','🍑','🥝','🍅','🥑',
    '🍆','🥦','🥕','🌽','🍔','🍟','🍕','🌭','🌮','🌯','🥙','🥚','🍳','🥞',
    '🧇','🥓','🍖','🍗','🧀','🍱','🍣','🍜','🍝','🍛','🍲','🥗','🍿','🍦',
    '🍧','🍨','🍰','🎂','🍭','🍬','🍫','🍩','🍪','☕','🍵','🧋','🥤','🍺',
    '🍻','🥂','🍷','🧃','🥛','🍼',
  ],
];

// ── Keyboard ───────────────────────────────────────────────────────────────────

enum KeyboardMode { english, korean, number, emoji }

class KeyboardView extends StatefulWidget {
  const KeyboardView({super.key});

  @override
  State<KeyboardView> createState() => _KeyboardViewState();
}

class _KeyboardViewState extends State<KeyboardView> {
  KeyboardMode _mode = KeyboardMode.english;
  KeyboardMode _modeBeforeEmoji = KeyboardMode.english;
  bool _capsLock = false;
  final KoreanComposer _composer = KoreanComposer();

  // ── Settings ──────────────────────────────────────────────────────────────
  bool _showingSettings = false;
  bool _hapticEnabled = true;
  bool _soundEnabled = false;
  int _themeIndex = 0;

  // ── Emoji ─────────────────────────────────────────────────────────────────
  int _emojiCategoryIndex = 0;

  // ── Prediction ────────────────────────────────────────────────────────────
  List<String> _wordHistory = [];
  String _wordBuffer = '';

  static const _commonKoreanWords = [
    '안녕하세요', '감사합니다', '괜찮아요', '알겠습니다', '네', '아니요',
    '좋아요', '사랑해요', '보고싶어요', '잘자요', '잘지내요', '화이팅',
    'ㅋㅋ', 'ㅎㅎ', 'ㅋㅋㅋ', '오케이', '맞아요', '모르겠어요',
    '뭐해요', '언제봐요', '조심해요', '파이팅', '축하해요', '미안해요',
    '잠깐만요', '왜요', '어떻게', '누구예요', '얼마예요',
    '수고하셨습니다', '잘부탁드립니다', '어서오세요',
  ];

  List<String> get _suggestions {
    if (_mode == KeyboardMode.emoji || _mode == KeyboardMode.number) return [];

    final composing =
        _mode == KeyboardMode.korean ? _composer.composing : '';

    if (composing.length >= 1) {
      final candidates = [..._wordHistory, ..._commonKoreanWords];
      final matches = candidates
          .where((w) => w.startsWith(composing) && w != composing)
          .toSet()
          .take(3)
          .toList();
      if (matches.isNotEmpty) return matches;
    }

    return _wordHistory.take(3).toList();
  }

  KeyboardTheme get _theme => KeyboardTheme.presets[_themeIndex];

  // ── Init ──────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hapticEnabled = prefs.getBool('haptic') ?? true;
      _soundEnabled = prefs.getBool('sound') ?? false;
      _themeIndex = prefs.getInt('theme') ?? 0;
      _wordHistory = prefs.getStringList('wordHistory') ?? [];
    });
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  void _triggerFeedback() {
    if (_hapticEnabled) _channel.invokeMethod('vibrate');
    if (_soundEnabled) _channel.invokeMethod('playKeySound');
  }

  // ── Word history ──────────────────────────────────────────────────────────

  void _trackCommit(String text) {
    for (var i = 0; i < text.length; i++) {
      final ch = text[i];
      if (ch == ' ' || ch == '\n') {
        if (_wordBuffer.length >= 2) _addToHistory(_wordBuffer);
        _wordBuffer = '';
      } else {
        _wordBuffer += ch;
      }
    }
  }

  void _addToHistory(String word) {
    final w = word.trim();
    if (w.length < 2) return;
    _wordHistory.remove(w);
    _wordHistory.insert(0, w);
    if (_wordHistory.length > 30) _wordHistory = _wordHistory.sublist(0, 30);
    _saveWordHistory();
  }

  Future<void> _saveWordHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('wordHistory', _wordHistory);
  }

  // ── Tap detection ─────────────────────────────────────────────────────────
  String? _lastKey;
  int _lastKeyMs = 0;
  int _tapCount = 0;
  static const _doubleTapMs = 500;

  /// 2번 탭 → 획 추가 (격음/장음)
  static const Map<String, String> _keyUpgrade = {
    'ㅏ': 'ㅑ', 'ㅓ': 'ㅕ', 'ㅗ': 'ㅛ', 'ㅜ': 'ㅠ', 'ㅐ': 'ㅒ', 'ㅔ': 'ㅖ',
    'ㄱ': 'ㅋ', 'ㄷ': 'ㅌ', 'ㅂ': 'ㅍ', 'ㅅ': 'ㅆ', 'ㅇ': 'ㅎ', 'ㅈ': 'ㅊ',
  };

  /// 3번 탭 → 된소리
  static const Map<String, String> _keyUpgrade3 = {
    'ㄱ': 'ㄲ',
    'ㄷ': 'ㄸ',
    'ㅂ': 'ㅃ',
    'ㅈ': 'ㅉ',
  };

  // ── Layout definitions ────────────────────────────────────────────────────

  static const _numberRows = [
    ['1', '2', '3', '*', '+', '/'],
    ['4', '5', '6', '#', '-', '='],
    ['7', '8', '9', '0', '@', '.'],
  ];

  static const _koreanRows = [
    ['ㄱ', 'ㄴ', 'ㄷ', 'ㅏ', 'ㅓ'],
    ['ㄹ', 'ㅁ', 'ㅂ', 'ㅡ', 'ㅣ'],
    ['ㅅ', 'ㅇ', 'ㅈ', 'ㅗ', 'ㅜ'],
  ];

  static const _englishRows = [
    ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
    ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', "'"],
    ['@', 'z', 'x', 'c', 'v', 'b', 'n', 'm', '?', ',!'],
  ];

  // ── IME communication ─────────────────────────────────────────────────────

  Future<void> _commitText(String text) async {
    if (text.isEmpty) return;
    _trackCommit(text);
    await _channel.invokeMethod('commitText', {'text': text});
  }

  Future<void> _setComposing(String text) async {
    await _channel.invokeMethod('setComposingText', {'text': text});
  }

  Future<void> _replaceComposing(String text) async {
    await _channel.invokeMethod('replaceComposing', {'text': text});
  }

  Future<void> _deleteBack() async {
    await _channel.invokeMethod('deleteSurroundingText');
  }

  Future<void> _sendAction() async {
    await _channel.invokeMethod('performEditorAction');
  }

  // ── Key handlers ──────────────────────────────────────────────────────────

  void _onKey(String key) {
    if (_mode == KeyboardMode.korean) {
      _handleKorean(key);
    } else {
      final toSend = (_mode == KeyboardMode.english && _capsLock)
          ? key.toUpperCase()
          : key;
      _commitText(toSend);
    }
  }

  Future<void> _handleKorean(String key) async {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final isRepeat = key == _lastKey && (nowMs - _lastKeyMs) < _doubleTapMs;

    if (isRepeat) {
      _tapCount++;
    } else {
      _tapCount = 1;
    }
    _lastKey = key;
    _lastKeyMs = nowMs;

    // ── 3번 탭: 된소리 (ㅈ→ㅉ) ────────────────────────────────────────────
    if (_tapCount == 3 && _keyUpgrade3.containsKey(key)) {
      final upgraded3 = _keyUpgrade3[key]!;
      final replaced = _composer.replaceCurrentConsonant(upgraded3);
      if (replaced) {
        await _replaceComposing(_composer.composing);
        setState(() {});
        return;
      }
      // 받침 위치에서는 ㅉ 불가 → 독립 자음으로 입력
      _composer.input(upgraded3);
      final pending = _composer.pending;
      if (pending.isNotEmpty) {
        await _commitText(pending);
        _composer.clearPending();
      }
      await _setComposing(_composer.composing);
      setState(() {});
      return;
    }

    // ── 2번 탭: 획 추가 (ㅈ→ㅊ 등) ──────────────────────────────────────
    if (_tapCount == 2 && _keyUpgrade.containsKey(key)) {
      final upgraded = _keyUpgrade[key]!;
      bool replaced = false;
      if (KoreanComposer.isVowel(key)) {
        replaced = _composer.replaceCurrentVowel(upgraded);
      } else {
        replaced = _composer.replaceCurrentConsonant(upgraded);
      }
      if (replaced) {
        await _replaceComposing(_composer.composing);
        setState(() {});
        return;
      }
      _composer.input(upgraded);
      final pending = _composer.pending;
      if (pending.isNotEmpty) {
        await _commitText(pending);
        _composer.clearPending();
      }
      await _setComposing(_composer.composing);
      setState(() {});
      return;
    }

    // ── 1번 탭 (또는 4번 이상): 일반 입력 ────────────────────────────────
    _composer.input(key);
    final pending = _composer.pending;
    if (pending.isNotEmpty) {
      await _commitText(pending);
      _composer.clearPending();
    }
    await _setComposing(_composer.composing);
    setState(() {});
  }

  Future<void> _onDelete() async {
    if (_mode == KeyboardMode.korean) {
      final hadComposing = _composer.backspace();
      final pending = _composer.pending;
      if (pending.isNotEmpty) {
        await _commitText(pending);
        _composer.clearPending();
      }
      await _setComposing(_composer.composing);
      if (!hadComposing) await _deleteBack();
      setState(() {});
    } else {
      await _deleteBack();
    }
  }

  Future<void> _onSuggestionTap(String word) async {
    _triggerFeedback();
    if (_mode == KeyboardMode.korean) {
      final committed = _composer.commitAll();
      if (committed.isNotEmpty) {
        await _channel.invokeMethod('commitText', {'text': committed});
      }
      await _setComposing('');
    }
    _wordBuffer = '';
    _addToHistory(word);
    await _channel.invokeMethod('commitText', {'text': '$word '});
    setState(() {});
  }

  Future<void> _commitKoreanAndSwitch(void Function() switchFn) async {
    if (_mode == KeyboardMode.korean) {
      final text = _composer.commitAll();
      if (text.isNotEmpty) await _commitText(text);
      await _setComposing('');
    }
    setState(switchFn);
  }

  void _onRotate() {
    _commitKoreanAndSwitch(() {
      switch (_mode) {
        case KeyboardMode.number:
          _mode = KeyboardMode.korean;
        case KeyboardMode.korean:
          _mode = KeyboardMode.english;
        case KeyboardMode.english:
          _mode = KeyboardMode.number;
        case KeyboardMode.emoji:
          _mode = _modeBeforeEmoji;
      }
    });
  }

  void _onLangToggle() {
    if (_mode == KeyboardMode.emoji) {
      setState(() => _mode = _modeBeforeEmoji);
      return;
    }
    _commitKoreanAndSwitch(() {
      _mode = _mode == KeyboardMode.korean
          ? KeyboardMode.english
          : KeyboardMode.korean;
    });
  }

  void _onCaps() => setState(() => _capsLock = !_capsLock);

  void _toggleEmoji() {
    if (_mode == KeyboardMode.emoji) {
      setState(() => _mode = _modeBeforeEmoji);
    } else {
      _commitKoreanAndSwitch(() {
        _modeBeforeEmoji = _mode;
        _mode = KeyboardMode.emoji;
      });
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 317,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: _theme.background,
        child: _showingSettings
            ? _buildSettingsPanel()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_mode != KeyboardMode.emoji) _buildSuggestionBar(),
                  if (_mode == KeyboardMode.emoji)
                    Expanded(child: _buildEmojiGrid())
                  else
                    ..._buildMainRows(),
                  _buildBottomRow(),
                ],
              ),
      ),
    );
  }

  // ── Suggestion bar ────────────────────────────────────────────────────────

  Widget _buildSuggestionBar() {
    final suggestions = _suggestions;
    return SizedBox(
      height: 32,
      child: suggestions.isEmpty
          ? Center(
              child: Text(
                '예측 입력',
                style: TextStyle(
                  fontSize: 11,
                  color: _theme.charKeyText.withOpacity(0.3),
                ),
              ),
            )
          : Row(
              children: suggestions
                  .map((w) => Expanded(
                        child: GestureDetector(
                          onTap: () => _onSuggestionTap(w),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 4),
                            decoration: BoxDecoration(
                              color: _theme.charKey,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 1,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              w,
                              style: TextStyle(
                                  fontSize: 13, color: _theme.charKeyText),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
    );
  }

  // ── Emoji panel ───────────────────────────────────────────────────────────

  Widget _buildEmojiGrid() {
    return Column(
      children: [
        // Category tabs
        SizedBox(
          height: 38,
          child: Row(
            children: List.generate(_emojiTabIcons.length, (i) {
              final selected = i == _emojiCategoryIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _emojiCategoryIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    decoration: BoxDecoration(
                      color: selected
                          ? _theme.charKey.withOpacity(0.5)
                          : Colors.transparent,
                      border: Border(
                        bottom: BorderSide(
                          color: selected
                              ? _theme.actionKey
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _emojiTabIcons[i],
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        // Emoji grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(2),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              childAspectRatio: 1,
            ),
            itemCount: _emojiData[_emojiCategoryIndex].length,
            itemBuilder: (_, i) {
              final emoji = _emojiData[_emojiCategoryIndex][i];
              return GestureDetector(
                onTap: () {
                  _triggerFeedback();
                  _channel.invokeMethod('commitText', {'text': emoji});
                },
                child: Container(
                  alignment: Alignment.center,
                  child: Text(emoji, style: const TextStyle(fontSize: 22)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Settings panel ────────────────────────────────────────────────────────

  Widget _buildSettingsPanel() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back,
                      size: 20, color: _theme.actionKeyText),
                  onPressed: () => setState(() => _showingSettings = false),
                ),
                Text('설정',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _theme.charKeyText)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text('키보드 스킨',
                style: TextStyle(
                    fontSize: 13,
                    color: _theme.charKeyText.withOpacity(0.6))),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(KeyboardTheme.presets.length, (i) {
                final t = KeyboardTheme.presets[i];
                final selected = i == _themeIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() => _themeIndex = i);
                    _saveInt('theme', i);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: t.swatch,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? Colors.black54
                            : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(selected ? 0.3 : 0.1),
                          blurRadius: selected ? 6 : 2,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: selected
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }),
            ),
          ),
          const Divider(height: 16),
          SwitchListTile(
            dense: true,
            title: Text('진동',
                style:
                    TextStyle(fontSize: 15, color: _theme.charKeyText)),
            value: _hapticEnabled,
            onChanged: (v) {
              setState(() => _hapticEnabled = v);
              _saveBool('haptic', v);
            },
          ),
          SwitchListTile(
            dense: true,
            title: Text('키 클릭 소리',
                style:
                    TextStyle(fontSize: 15, color: _theme.charKeyText)),
            value: _soundEnabled,
            onChanged: (v) {
              setState(() => _soundEnabled = v);
              _saveBool('sound', v);
            },
          ),
        ],
      ),
    );
  }

  // ── Keyboard rows ─────────────────────────────────────────────────────────

  List<Widget> _buildMainRows() {
    final rows = switch (_mode) {
      KeyboardMode.number => _numberRows,
      KeyboardMode.korean => _koreanRows,
      KeyboardMode.english => _englishRows,
      KeyboardMode.emoji => _koreanRows,
    };
    return rows
        .map((row) => _KeyRow(
              keys: row,
              caps: _capsLock && _mode == KeyboardMode.english,
              onKey: _onKey,
              onKeyDown: _triggerFeedback,
              theme: _theme,
            ))
        .toList();
  }

  Widget _buildBottomRow() {
    final isEmoji = _mode == KeyboardMode.emoji;
    final langLabel = switch (_mode) {
      KeyboardMode.english => 'Aa',
      KeyboardMode.korean => 'ㄱ',
      KeyboardMode.number => '가',
      KeyboardMode.emoji => 'Aa',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Row(
        children: [
          _ActionKey(
            onTap: _onRotate,
            onTapDown: _triggerFeedback,
            theme: _theme,
            flex: 1,
            child:
                Icon(Icons.autorenew, size: 20, color: _theme.actionKeyText),
          ),
          if (!isEmoji)
            _ActionKey(
              onTap: _mode == KeyboardMode.english ? _onCaps : _onLangToggle,
              onTapDown: _triggerFeedback,
              theme: _theme,
              flex: 1,
              active: _mode == KeyboardMode.english && _capsLock,
              child: Text(langLabel,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _theme.actionKeyText)),
            ),
          _ActionKey(
            onTap: () => _onKey(' '),
            onTapDown: _triggerFeedback,
            theme: _theme,
            flex: isEmoji ? 4 : 3,
            child: const Text(' ', style: TextStyle(fontSize: 14)),
          ),
          // Emoji toggle
          _ActionKey(
            onTap: _toggleEmoji,
            onTapDown: _triggerFeedback,
            theme: _theme,
            active: isEmoji,
            flex: 1,
            child: Text(
              isEmoji ? '⌨️' : '😊',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          _ActionKey(
            onTap: () => setState(() => _showingSettings = true),
            onTapDown: _triggerFeedback,
            theme: _theme,
            flex: 1,
            child:
                Icon(Icons.settings, size: 18, color: _theme.actionKeyText),
          ),
          _ActionKey(
            onTap: _sendAction,
            onTapDown: _triggerFeedback,
            theme: _theme,
            flex: 1,
            child: Text('GO',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _theme.actionKeyText)),
          ),
          _ActionKey(
            onTap: _onDelete,
            onTapDown: _triggerFeedback,
            theme: _theme,
            flex: 1,
            repeatOnHold: true,
            child: Icon(Icons.backspace_outlined,
                size: 20, color: _theme.actionKeyText),
          ),
        ],
      ),
    );
  }
}

// ── Reusable widgets ───────────────────────────────────────────────────────────

class _KeyRow extends StatelessWidget {
  final List<String> keys;
  final bool caps;
  final void Function(String) onKey;
  final VoidCallback onKeyDown;
  final KeyboardTheme theme;

  const _KeyRow({
    required this.keys,
    required this.caps,
    required this.onKey,
    required this.onKeyDown,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
      child: Row(
        children: keys
            .map((k) => Expanded(
                  child: _CharKey(
                    label: caps ? k.toUpperCase() : k,
                    onTap: () => onKey(k),
                    onTapDown: onKeyDown,
                    theme: theme,
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _CharKey extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final VoidCallback onTapDown;
  final KeyboardTheme theme;

  const _CharKey({
    required this.label,
    required this.onTap,
    required this.onTapDown,
    required this.theme,
  });

  @override
  State<_CharKey> createState() => _CharKeyState();
}

class _CharKeyState extends State<_CharKey> {
  bool _pressed = false;
  OverlayEntry? _popupEntry;

  @override
  void dispose() {
    _popupEntry?.remove();
    _popupEntry = null;
    super.dispose();
  }

  void _showPopup() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final overlay = Overlay.of(context);
    final pos = box.localToGlobal(Offset.zero);
    final sz = box.size;
    // Clamp so popup never goes above the Flutter view top
    final popupTop = (pos.dy - 66).clamp(4.0, double.infinity);
    _popupEntry = OverlayEntry(
      builder: (_) => Positioned(
        left: pos.dx - 6,
        top: popupTop,
        width: sz.width + 12,
        height: 62,
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: widget.theme.charKey,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 28,
                color: widget.theme.charKeyText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(_popupEntry!);
  }

  void _hidePopup() {
    _popupEntry?.remove();
    _popupEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: GestureDetector(
        onTapDown: (_) {
          widget.onTapDown();
          setState(() => _pressed = true);
          _showPopup();
        },
        onTapUp: (_) {
          setState(() => _pressed = false);
          _hidePopup();
        },
        onTapCancel: () {
          setState(() => _pressed = false);
          _hidePopup();
        },
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 60),
          height: 65,
          transform: _pressed
              ? (Matrix4.identity()..translate(0.0, 1.5))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color:
                _pressed ? widget.theme.charKeyPressed : widget.theme.charKey,
            borderRadius: BorderRadius.circular(5),
            boxShadow: _pressed
                ? const []
                : const [
                    BoxShadow(
                      color: Color(0x55000000),
                      offset: Offset(0, 2),
                      blurRadius: 2,
                    ),
                  ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 18,
              color: widget.theme.charKeyText,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionKey extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final VoidCallback onTapDown;
  final KeyboardTheme theme;
  final int flex;
  final bool active;
  final bool repeatOnHold;

  const _ActionKey({
    required this.child,
    required this.onTap,
    required this.onTapDown,
    required this.theme,
    this.flex = 1,
    this.active = false,
    this.repeatOnHold = false,
  });

  @override
  State<_ActionKey> createState() => _ActionKeyState();
}

class _ActionKeyState extends State<_ActionKey> {
  bool _pressed = false;
  Timer? _repeatTimer;

  @override
  void dispose() {
    _repeatTimer?.cancel();
    super.dispose();
  }

  void _startRepeat() {
    // 400ms 후 첫 반복 시작, 이후 50ms 간격으로 반복
    _repeatTimer = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      widget.onTap();
      _repeatTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
        if (!mounted) {
          _repeatTimer?.cancel();
          return;
        }
        widget.onTapDown(); // haptic
        widget.onTap();
      });
    });
  }

  void _cancelRepeat() {
    _repeatTimer?.cancel();
    _repeatTimer = null;
  }

  Color get _bgColor {
    if (_pressed) {
      return widget.active
          ? widget.theme.activePressedKey
          : widget.theme.actionKeyPressed;
    }
    return widget.active ? widget.theme.activeKey : widget.theme.actionKey;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: widget.flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: GestureDetector(
          onTapDown: (_) {
            widget.onTapDown();
            setState(() => _pressed = true);
            if (widget.repeatOnHold) _startRepeat();
          },
          onTapUp: (_) {
            setState(() => _pressed = false);
            if (widget.repeatOnHold) _cancelRepeat();
          },
          onTapCancel: () {
            setState(() => _pressed = false);
            if (widget.repeatOnHold) _cancelRepeat();
          },
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 60),
            height: 65,
            transform: _pressed
                ? (Matrix4.identity()..translate(0.0, 1.5))
                : Matrix4.identity(),
            decoration: BoxDecoration(
              color: _bgColor,
              borderRadius: BorderRadius.circular(5),
              boxShadow: _pressed
                  ? const []
                  : const [
                      BoxShadow(
                        color: Color(0x55000000),
                        offset: Offset(0, 2),
                        blurRadius: 2,
                      ),
                    ],
            ),
            alignment: Alignment.center,
            child: DefaultTextStyle(
              style: TextStyle(
                  color: widget.theme.actionKeyText, fontSize: 14),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
