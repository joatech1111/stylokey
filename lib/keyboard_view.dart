import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'korean_composer.dart';

const _channel = MethodChannel('com.example.keyboard12345/ime');

enum KeyboardMode { english, korean, number }

class KeyboardView extends StatefulWidget {
  const KeyboardView({super.key});

  @override
  State<KeyboardView> createState() => _KeyboardViewState();
}

class _KeyboardViewState extends State<KeyboardView> {
  KeyboardMode _mode = KeyboardMode.english;
  bool _capsLock = false;
  final KoreanComposer _composer = KoreanComposer();

  // ── Double-tap detection for Korean vowels ────────────────────────────────
  String? _lastKey;
  int _lastKeyMs = 0;
  static const _doubleTapMs = 400;

  /// Double-tap upgrade map — 획 추가 (모음 + 자음 모두)
  static const Map<String, String> _keyUpgrade = {
    // 모음 (vowels)
    'ㅏ': 'ㅑ',
    'ㅓ': 'ㅕ',
    'ㅗ': 'ㅛ',
    'ㅜ': 'ㅠ',
    'ㅐ': 'ㅒ',
    'ㅔ': 'ㅖ',
    // 자음 (consonants)
    'ㄱ': 'ㅋ',
    'ㄷ': 'ㅌ',
    'ㅂ': 'ㅍ',
    'ㅅ': 'ㅆ',
    'ㅇ': 'ㅎ',
    'ㅈ': 'ㅊ',
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
    await _channel.invokeMethod('commitText', {'text': text});
  }

  Future<void> _setComposing(String text) async {
    await _channel.invokeMethod('setComposingText', {'text': text});
  }

  /// 더블탭용: 이전 글자(jamo 포함)를 삭제하고 새 글자로 교체
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
    final isDoubleTap = key == _lastKey &&
        (nowMs - _lastKeyMs) < _doubleTapMs &&
        _keyUpgrade.containsKey(key);

    _lastKey = key;
    _lastKeyMs = nowMs;

    if (isDoubleTap) {
      final upgraded = _keyUpgrade[key];
      if (upgraded != null) {
        bool replaced = false;
        if (KoreanComposer.isVowel(key)) {
          replaced = _composer.replaceCurrentVowel(upgraded);
        } else {
          replaced = _composer.replaceCurrentConsonant(upgraded);
        }
        if (replaced) {
          // setComposingText 단독으로는 standalone jamo(ㄱ,ㅋ 등)를
          // Chrome 같은 앱이 이미 commit해버려 교체가 안 됨.
          // finishComposing + deleteSurrounding + setComposing으로 확실히 교체.
          await _replaceComposing(_composer.composing);
          setState(() {});
          return;
        }
        // Nothing to replace in current composing — input the upgraded key directly
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
    }

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
      if (!hadComposing) {
        // Nothing was composing — delete the previous committed char
        await _deleteBack();
      }
      setState(() {});
    } else {
      await _deleteBack();
    }
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
      }
    });
  }

  void _onLangToggle() {
    _commitKoreanAndSwitch(() {
      _mode = _mode == KeyboardMode.korean
          ? KeyboardMode.english
          : KeyboardMode.korean;
    });
  }

  void _onCaps() => setState(() => _capsLock = !_capsLock);

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 285,
      child: Container(
        color: const Color(0xFFD1D5DB),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ..._buildMainRows(),
            _buildBottomRow(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMainRows() {
    final rows = switch (_mode) {
      KeyboardMode.number => _numberRows,
      KeyboardMode.korean => _koreanRows,
      KeyboardMode.english => _englishRows,
    };
    return rows
        .map((row) => _KeyRow(
              keys: row,
              caps: _capsLock && _mode == KeyboardMode.english,
              onKey: _onKey,
            ))
        .toList();
  }

  Widget _buildBottomRow() {
    final langLabel = switch (_mode) {
      KeyboardMode.english => 'Aa',
      KeyboardMode.korean => 'ㄱ',
      KeyboardMode.number => '가',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Row(
        children: [
          _ActionKey(
            onTap: _onRotate,
            flex: 1,
            child: const Icon(Icons.autorenew, size: 20),
          ),
          if (_mode == KeyboardMode.english)
            _ActionKey(
              onTap: _onCaps,
              flex: 1,
              active: _capsLock,
              child: Text(langLabel,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            )
          else
            _ActionKey(
              onTap: _onLangToggle,
              flex: 1,
              child: Text(langLabel,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          _ActionKey(
            onTap: () => _onKey(' '),
            flex: 3,
            child: const Text(' ', style: TextStyle(fontSize: 14)),
          ),
          _ActionKey(
            onTap: _sendAction,
            flex: 1,
            child: const Text('GO',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
          _ActionKey(
            onTap: _onDelete,
            flex: 1,
            child: const Icon(Icons.backspace_outlined, size: 20),
          ),
        ],
      ),
    );
  }
}

// ── Reusable widgets ──────────────────────────────────────────────────────────

class _KeyRow extends StatelessWidget {
  final List<String> keys;
  final bool caps;
  final void Function(String) onKey;

  const _KeyRow({required this.keys, required this.caps, required this.onKey});

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
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _CharKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CharKey({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x55000000),
                offset: Offset(0, 1),
                blurRadius: 1,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black87,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionKey extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final int flex;
  final bool active;

  const _ActionKey({
    required this.child,
    required this.onTap,
    this.flex = 1,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 65,
            decoration: BoxDecoration(
              color: active
                  ? const Color(0xFF6B7280)
                  : const Color(0xFFADB5BD),
              borderRadius: BorderRadius.circular(5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x55000000),
                  offset: Offset(0, 1),
                  blurRadius: 1,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: DefaultTextStyle(
              style: const TextStyle(color: Colors.black87, fontSize: 14),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
