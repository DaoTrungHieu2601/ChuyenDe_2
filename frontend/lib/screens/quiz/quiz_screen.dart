import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../services/quiz_wrong_words_store.dart';

enum _QuestionKind { fillLetter, chooseMeaning, listenChooseMeaning, typeWord }

/// Quiz thường: tối thiểu số câu (lặp từ trong chủ đề nếu cần); tối đa tránh bài quá dài.
const int _kQuizTargetCount = 12;
const int _kQuizMaxCount = 24;

class QuizScreen extends StatefulWidget {
  final List<dynamic> words;
  final Map<String, dynamic> topic;
  /// Nguồn từ để lấy các đáp án nghĩa sai (mặc định = [words]). Khi [words] chỉ là tập «từ sai», truyền toàn bộ từ chủ đề.
  final List<dynamic>? meaningDistractorPool;
  /// Bài quiz chỉ gồm [words] (tập con); kết thúc sẽ ghi đè danh sách từ sai bằng tập vẫn sai trong bài này.
  final bool isWrongWordsReview;
  const QuizScreen({
    super.key,
    required this.words,
    required this.topic,
    this.meaningDistractorPool,
    this.isWrongWordsReview = false,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  late List<dynamic> _shuffled;
  /// Chế độ «chỉ từ sai»: mỗi phần tử là dạng câu tương ứng `_shuffled[i]` (không random lại).
  List<_QuestionKind>? _forcedKinds;
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _answered = false;
  /// Sau khi trả lời: chữ điền vào có khớp chỗ khuyết không (null = chưa trả lời).
  bool? _letterCorrect;
  late List<String> _options;
  bool _isFinished = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  /// Khởi tạo tại đây (không dùng `late` + gán trong initState) để hot reload không bị LateInitializationError.
  final TextEditingController _letterController = TextEditingController();
  final TextEditingController _wordTypeController = TextEditingController();
  final FlutterTts _tts = FlutterTts();
  bool _ttsReady = false;
  /// Sau khi trả lời gõ từ: đúng / sai.
  bool? _typedCorrect;

  /// Các `word_id` đã trả lời sai ít nhất một lần trong phiên quiz này (để lưu / cập nhật danh sách ôn).
  final Set<int> _wrongIdsThisQuiz = {};

  /// Mỗi lần vào quiz: vị trí chữ khuyết & phân loại câu hỏi đổi ngẫu nhiên (kể cả cùng một từ lặp lại).
  final int _quizSessionSalt = Random().nextInt(0x7fffffff);

  List<dynamic> _buildQuizWordSequence() {
    final src = widget.words;
    if (src.isEmpty) return [];
    final target = src.length.clamp(_kQuizTargetCount, _kQuizMaxCount);
    final out = <dynamic>[];
    final rnd = Random();
    while (out.length < target) {
      final batch = List<dynamic>.from(src)..shuffle(rnd);
      for (final w in batch) {
        if (out.length >= target) break;
        out.add(w);
      }
    }
    return out;
  }

  /// Mỗi từ sai: đúng một câu / dạng — chọn nghĩa, nghe–chọn nghĩa, gõ Anh, (điền chữ nếu từ có chữ cái để khuyết). Không lặp để đủ 12 câu.
  ({List<dynamic> words, List<_QuestionKind> kinds}) _buildWrongWordsReviewSequence() {
    final src = widget.words;
    if (src.isEmpty) {
      return (words: <dynamic>[], kinds: <_QuestionKind>[]);
    }
    final pairs = <({Map<String, dynamic> w, _QuestionKind k})>[];
    for (final raw in src) {
      final wm = raw as Map<String, dynamic>;
      final en = wm['english'] as String? ?? '';
      final clozeProbe = _englishCloze(en, _clozeSeedForWord(wm, 0));
      final kindsForWord = <_QuestionKind>[
        _QuestionKind.chooseMeaning,
        _QuestionKind.listenChooseMeaning,
        _QuestionKind.typeWord,
      ];
      if (clozeProbe.expectedLetter.isNotEmpty) {
        kindsForWord.insert(0, _QuestionKind.fillLetter);
      }
      for (final k in kindsForWord) {
        pairs.add((w: wm, k: k));
      }
    }
    pairs.shuffle(Random(_quizSessionSalt));
    return (
      words: pairs.map((p) => p.w).toList(),
      kinds: pairs.map((p) => p.k).toList(),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.isWrongWordsReview) {
      final built = _buildWrongWordsReviewSequence();
      _shuffled = built.words;
      _forcedKinds = built.kinds;
    } else {
      _forcedKinds = null;
      _shuffled = _buildQuizWordSequence();
    }
    _animController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _scaleAnim = Tween<double>(begin: 0.95, end: 1.0).animate(CurvedAnimation(parent: _animController, curve: Curves.elasticOut));
    _generateOptions();
    _animController.forward();
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.42);
      await _tts.awaitSpeakCompletion(true);
    } catch (_) {}
    if (mounted) setState(() => _ttsReady = true);
  }

  Future<void> _speakEnglish(String text) async {
    if (text.isEmpty) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Không phát được âm thanh. Thử lại hoặc kiểm tra quyền loa.'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tts.stop();
    _letterController.dispose();
    _wordTypeController.dispose();
    _animController.dispose();
    super.dispose();
  }

  _QuestionKind _questionKindAt(int index) {
    final forced = _forcedKinds;
    if (forced != null && index < forced.length) {
      return forced[index];
    }
    final w = _shuffled[index] as Map<String, dynamic>;
    final en = w['english'] as String? ?? '';
    final seed = _clozeSeedForWord(w, index);
    final cloze = _englishCloze(en, seed);
    final kinds = <_QuestionKind>[
      _QuestionKind.chooseMeaning,
      _QuestionKind.listenChooseMeaning,
      _QuestionKind.typeWord,
    ];
    if (cloze.expectedLetter.isNotEmpty) {
      kinds.insert(0, _QuestionKind.fillLetter);
    }
    return kinds[Random(seed ^ 0xdeadbeef).nextInt(kinds.length)];
  }

  String _kindLabel(_QuestionKind k) {
    switch (k) {
      case _QuestionKind.fillLetter:
        return 'Điền chữ còn thiếu';
      case _QuestionKind.chooseMeaning:
        return 'Chọn nghĩa Tiếng Việt';
      case _QuestionKind.listenChooseMeaning:
        return 'Nghe — chọn nghĩa';
      case _QuestionKind.typeWord:
        return 'Gõ từ tiếng Anh';
    }
  }

  ({Color background, Color foreground, IconData icon}) _kindChipStyle(_QuestionKind k) {
    switch (k) {
      case _QuestionKind.fillLetter:
        return (
          background: AppColors.primary.withOpacity(0.12),
          foreground: AppColors.primary,
          icon: Icons.edit_note_rounded,
        );
      case _QuestionKind.chooseMeaning:
        return (
          background: Colors.orange.withOpacity(0.12),
          foreground: Colors.orange.shade800,
          icon: Icons.translate_rounded,
        );
      case _QuestionKind.listenChooseMeaning:
        return (
          background: const Color(0xFF7C4DFF).withOpacity(0.12),
          foreground: const Color(0xFF5E35B1),
          icon: Icons.headphones_rounded,
        );
      case _QuestionKind.typeWord:
        return (
          background: AppColors.success.withOpacity(0.14),
          foreground: const Color(0xFF2E7D32),
          icon: Icons.keyboard_alt_outlined,
        );
    }
  }

  Widget _buildQuestionKindChip() {
    final k = _kind;
    final s = _kindChipStyle(k);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: s.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: s.foreground.withOpacity(0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(s.icon, size: 17, color: s.foreground),
          const SizedBox(width: 8),
          Text(
            _kindLabel(k),
            style: TextStyle(color: s.foreground, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _normalizeTypedEnglish(String s) {
    return s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  _QuestionKind get _kind => _questionKindAt(_currentIndex);

  int _clozeSeedForWord(Map<String, dynamic> word, int indexInQuiz) {
    final en = word['english'] as String? ?? '';
    final id = word['id'];
    final idPart = id is int ? id * 100003 : id.hashCode;
    // indexInQuiz: mỗi lần từ xuất hiện trong bài có thể khuyết chỗ khác; _quizSessionSalt: mỗi lần mở quiz khác nhau.
    return idPart ^ en.hashCode ^ (indexInQuiz * 2654435761) ^ _quizSessionSalt;
  }

  /// Một chữ cái (A–Z, a–z) thay bằng `_`; [expectedLetter] rỗng nếu không có chữ để khuyết.
  ({String display, String expectedLetter}) _englishCloze(String english, int seed) {
    final letterIndices = <int>[];
    for (var i = 0; i < english.length; i++) {
      final u = english.codeUnitAt(i);
      if ((u >= 65 && u <= 90) || (u >= 97 && u <= 122)) {
        letterIndices.add(i);
      }
    }
    if (letterIndices.isEmpty) return (display: english, expectedLetter: '');
    final pick = letterIndices[Random(seed).nextInt(letterIndices.length)];
    final expected = english.substring(pick, pick + 1);
    final display = english.replaceRange(pick, pick + 1, '_');
    return (display: display, expectedLetter: expected);
  }

  int _clozeSeed(Map<String, dynamic> word) => _clozeSeedForWord(word, _currentIndex);

  void _noteWrongForCurrentWord() {
    final w = _shuffled[_currentIndex];
    final id = w['id'];
    if (id is int) _wrongIdsThisQuiz.add(id);
  }

  void _generateOptions() {
    final pool = widget.meaningDistractorPool ?? widget.words;
    final word = _shuffled[_currentIndex] as Map<String, dynamic>;
    final correct = word['vietnamese'] as String? ?? '';
    final curEn = word['english'] as String? ?? '';

    final seen = <String>{correct};
    final pick = <String>[];

    final viSet = <String>{};
    for (final w in pool) {
      final v = w['vietnamese'];
      if (v is String && v != correct) viSet.add(v);
    }
    final viList = viSet.toList()..shuffle(Random());
    for (final v in viList) {
      if (pick.length >= 3) break;
      seen.add(v);
      pick.add(v);
    }

    if (pick.length < 3) {
      for (final w in pool) {
        if (pick.length >= 3) break;
        final en = w['english'] as String?;
        if (en == null || en == curEn) continue;
        final fake = '($en)';
        if (seen.contains(fake)) continue;
        seen.add(fake);
        pick.add(fake);
      }
    }

    var n = 0;
    while (pick.length < 3) {
      final pad = '(·$n·)';
      n++;
      if (seen.contains(pad)) continue;
      seen.add(pad);
      pick.add(pad);
    }

    _options = [correct, ...pick.take(3)]..shuffle(Random());
  }

  void _submitFillLetter() {
    if (_answered) return;
    if (_questionKindAt(_currentIndex) != _QuestionKind.fillLetter) return;

    // Web: chữ trong ô nhập đôi khi chưa ghi vào controller khi còn focus — bỏ focus rồi đọc sau frame.
    FocusManager.instance.primaryFocus?.unfocus();
    FocusScope.of(context).unfocus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _answered) return;
      if (_questionKindAt(_currentIndex) != _QuestionKind.fillLetter) return;

      final word = _shuffled[_currentIndex];
      final english = word['english'] as String? ?? '';
      final cloze = _englishCloze(english, _clozeSeed(word));
      final typed = _letterController.text.trim();

      if (cloze.expectedLetter.isNotEmpty && typed.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Vui lòng điền chữ còn thiếu'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }

      final ch = typed.isNotEmpty ? typed.substring(0, 1) : '';
      final letterOk = cloze.expectedLetter.isEmpty || ch.toLowerCase() == cloze.expectedLetter.toLowerCase();
      if (!letterOk) _noteWrongForCurrentWord();

      setState(() {
        _answered = true;
        _letterCorrect = letterOk;
        if (letterOk) _score++;
      });
    });
  }

  void _submitTypedWord() {
    if (_answered) return;
    if (_questionKindAt(_currentIndex) != _QuestionKind.typeWord) return;

    FocusManager.instance.primaryFocus?.unfocus();
    FocusScope.of(context).unfocus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _answered) return;
      if (_questionKindAt(_currentIndex) != _QuestionKind.typeWord) return;

      final word = _shuffled[_currentIndex];
      final english = word['english'] as String? ?? '';
      final typed = _wordTypeController.text;

      if (typed.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Vui lòng nhập từ tiếng Anh'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }

      final ok = _normalizeTypedEnglish(typed) == _normalizeTypedEnglish(english);
      if (!ok) _noteWrongForCurrentWord();

      setState(() {
        _answered = true;
        _typedCorrect = ok;
        if (ok) _score++;
      });
    });
  }

  void _selectAnswer(int index) {
    if (_answered) return;
    final k = _kind;
    if (k != _QuestionKind.chooseMeaning && k != _QuestionKind.listenChooseMeaning) return;
    final word = _shuffled[_currentIndex];
    final isCorrect = _options[index] == word['vietnamese'] as String;
    if (!isCorrect) _noteWrongForCurrentWord();
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      _letterCorrect = null;
      if (isCorrect) _score++;
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _shuffled.length - 1) {
      _animController.reset();
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _answered = false;
        _letterCorrect = null;
        _typedCorrect = null;
      });
      _letterController.clear();
      _wordTypeController.clear();
      _generateOptions();
      _animController.forward();
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    final auth = context.read<AuthService>();
    final token = auth.token!;
    final api = ApiService(token);
    final topicId = widget.topic['id'];
    final uid = auth.user?['id'];
    await api.saveQuizResult(widget.topic['id'], _score, _shuffled.length);

    if (uid is int && topicId is int) {
      await QuizWrongWordsStore.saveWrongWordIds(uid, topicId, Set<int>.from(_wrongIdsThisQuiz));
    }

    if (!mounted) return;
    setState(() => _isFinished = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isFinished) return _buildResult();
    final word = _shuffled[_currentIndex];
    final english = word['english'] as String? ?? '';
    final cloze = _englishCloze(english, _clozeSeed(word));
    final correctIndex = (_kind == _QuestionKind.chooseMeaning || _kind == _QuestionKind.listenChooseMeaning)
        ? _options.indexOf(word['vietnamese'] as String)
        : -1;
    final progress = (_currentIndex + 1) / _shuffled.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // Top bar
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                      child: const Icon(Icons.close, size: 20, color: AppColors.textDark),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${_currentIndex + 1} / ${_shuffled.length}',
                            style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppColors.border,
                            valueColor: const AlwaysStoppedAnimation(Colors.orange),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.orange, size: 16),
                        const SizedBox(width: 4),
                        Text('$_score', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Question card
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 6))],
                  ),
                  child: Column(
                    children: [
                      _buildQuestionKindChip(),
                      const SizedBox(height: 20),
                      if (_kind == _QuestionKind.fillLetter) ...[
                        if (!_answered)
                          Text(cloze.display,
                              style: const TextStyle(
                                  fontSize: 38, fontWeight: FontWeight.bold, color: AppColors.textDark, letterSpacing: 1.0))
                        else ...[
                          Text(word['english'],
                              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                          if (word['pronunciation'] != null) ...[
                            const SizedBox(height: 6),
                            Text(word['pronunciation'], style: const TextStyle(color: AppColors.primary, fontSize: 17)),
                          ],
                        ],
                        const SizedBox(height: 8),
                        Text(
                          word['vietnamese'] ?? '',
                          style: TextStyle(
                            color: AppColors.textGrey.withOpacity(0.9),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ] else if (_kind == _QuestionKind.typeWord) ...[
                        if (!_answered) ...[
                          Text(
                            'Nghĩa tiếng Việt',
                            style: TextStyle(color: AppColors.textGrey.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            word['vietnamese'] ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textDark, height: 1.25),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _wordTypeController,
                            enabled: !_answered,
                            autocorrect: false,
                            enableSuggestions: false,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.visiblePassword,
                            textCapitalization: TextCapitalization.none,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textDark),
                            onSubmitted: (_) => _submitTypedWord(),
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Gõ từ tiếng Anh',
                              filled: true,
                              fillColor: AppColors.background,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.border)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.border)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Colors.orange, width: 1.5),
                              ),
                            ),
                          ),
                        ] else ...[
                          Text(word['english'] as String? ?? '',
                              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                          if (word['pronunciation'] != null) ...[
                            const SizedBox(height: 6),
                            Text('${word['pronunciation']}', style: const TextStyle(color: AppColors.primary, fontSize: 17)),
                          ],
                          if (_typedCorrect == false) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Bạn nhập: "${_wordTypeController.text.trim()}"',
                              style: const TextStyle(color: AppColors.secondary, fontSize: 14, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ] else if (_kind == _QuestionKind.listenChooseMeaning) ...[
                        if (!_answered) ...[
                          Icon(Icons.headphones_rounded, size: 52, color: Colors.orange.withOpacity(0.9)),
                          const SizedBox(height: 14),
                          Text(
                            'Nghe phát âm, sau đó chọn nghĩa tiếng Việt ở bên dưới',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textGrey.withOpacity(0.95), fontSize: 15, height: 1.35),
                          ),
                          const SizedBox(height: 22),
                          FilledButton.icon(
                            onPressed: _ttsReady && english.isNotEmpty ? () => _speakEnglish(english) : null,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.volume_up_rounded, size: 22),
                            label: Text(_ttsReady ? 'Phát âm thanh' : 'Đang chuẩn bị…', style: const TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ] else ...[
                          Text(word['english'] as String? ?? '',
                              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                          if (word['pronunciation'] != null) ...[
                            const SizedBox(height: 6),
                            Text('${word['pronunciation']}', style: const TextStyle(color: AppColors.primary, fontSize: 17)),
                          ],
                        ],
                      ] else ...[
                        Text(word['english'] as String? ?? '',
                            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        if (word['pronunciation'] != null) ...[
                          const SizedBox(height: 6),
                          Text('${word['pronunciation']}', style: const TextStyle(color: AppColors.primary, fontSize: 17)),
                        ],
                      ],
                      if (_kind == _QuestionKind.fillLetter && cloze.expectedLetter.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Chữ thiếu:',
                              style: TextStyle(color: AppColors.textGrey.withOpacity(0.9), fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 52,
                              child: TextField(
                                controller: _letterController,
                                enabled: !_answered,
                                textAlign: TextAlign.center,
                                maxLength: 1,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.done,
                                textCapitalization: TextCapitalization.none,
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark),
                                onSubmitted: (_) => _submitFillLetter(),
                                decoration: InputDecoration(
                                  counterText: '',
                                  contentPadding: const EdgeInsets.only(bottom: 8),
                                  isDense: true,
                                  hintText: '?',
                                  hintStyle: TextStyle(color: AppColors.textGrey.withOpacity(0.4), fontSize: 28),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: AppColors.border, width: 2),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.orange, width: 2),
                                  ),
                                  disabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: _answered && _letterCorrect == false ? AppColors.secondary : AppColors.success,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        ),
                        if (_answered && _letterCorrect == false)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              'Đáp án đúng: "${cloze.expectedLetter}"',
                              style: const TextStyle(color: AppColors.secondary, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              Expanded(
                child: (_kind == _QuestionKind.chooseMeaning || _kind == _QuestionKind.listenChooseMeaning)
                    ? ListView.separated(
                        itemCount: 4,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          Color bgColor = AppColors.card;
                          Color borderColor = AppColors.border;
                          Color textColor = AppColors.textDark;
                          IconData? trailingIcon;

                          if (_answered) {
                            if (i == correctIndex) {
                              bgColor = AppColors.success.withOpacity(0.1);
                              borderColor = AppColors.success;
                              textColor = AppColors.success;
                              trailingIcon = Icons.check_circle_rounded;
                            } else if (i == _selectedAnswer) {
                              bgColor = AppColors.secondary.withOpacity(0.1);
                              borderColor = AppColors.secondary;
                              textColor = AppColors.secondary;
                              trailingIcon = Icons.cancel_rounded;
                            }
                          }

                          return GestureDetector(
                            onTap: () => _selectAnswer(i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: borderColor, width: 1.5),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: borderColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        ['A', 'B', 'C', 'D'][i],
                                        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                      child: Text(_options[i],
                                          style: TextStyle(color: textColor, fontWeight: FontWeight.w500, fontSize: 15))),
                                  if (trailingIcon != null) Icon(trailingIcon, color: textColor, size: 22),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : _kind == _QuestionKind.fillLetter
                        ? _buildFillLetterBottomArea()
                        : _buildTypeWordBottomArea(),
              ),

              if (_answered)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16, top: 8),
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _nextQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        _currentIndex < _shuffled.length - 1 ? 'Tiếp theo →' : 'Xem kết quả',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFillLetterBottomArea() {
    if (_answered) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Nhấn «Tiếp theo» để sang câu sau',
            style: TextStyle(color: AppColors.textGrey.withOpacity(0.85), fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _submitFillLetter,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Kiểm tra', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeWordBottomArea() {
    if (_answered) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Nhấn «Tiếp theo» để sang câu sau',
            style: TextStyle(color: AppColors.textGrey.withOpacity(0.85), fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _submitTypedWord,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Kiểm tra', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  Widget _buildResult() {
    final percent = (_score / _shuffled.length * 100).round();
    final isGood = percent >= 70;
    final xpEarned = _score * 5;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isGood ? [Colors.orange, const Color(0xFFFF6B6B)] : [Colors.grey[400]!, Colors.grey[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  children: [
                    Text(isGood ? '🎉' : '📝', style: const TextStyle(fontSize: 64)),
                    const SizedBox(height: 16),
                    Text(isGood ? 'Xuất sắc!' : 'Cố lên!',
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('$_score / ${_shuffled.length} câu đúng',
                        style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 16)),
                    if (_wrongIdsThisQuiz.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Đã lưu ${_wrongIdsThisQuiz.length} từ vào «Chỉ từ sai» — mở lại chủ đề để ôn.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white.withOpacity(0.88), fontSize: 14, height: 1.35),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          widget.isWrongWordsReview
                              ? 'Bạn đã làm đúng hết — danh sách «từ sai» cho chủ đề này đã được xóa.'
                              : 'Không có từ sai — danh sách «từ sai» đã được làm mới (trống).',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white.withOpacity(0.88), fontSize: 14, height: 1.35),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 6),
                          Text('+$xpEarned XP', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Score circle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildResultStat('Điểm số', '$percent%', Colors.orange),
                  const SizedBox(width: 16),
                  _buildResultStat('Đúng', '$_score câu', AppColors.success),
                  const SizedBox(width: 16),
                  _buildResultStat('Sai', '${_shuffled.length - _score} câu', AppColors.secondary),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Quay lại', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
