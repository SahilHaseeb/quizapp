import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:xml/xml.dart';
import '../models/question.dart';

class ParseResult {
  final String title;
  final List<Question> validQuestions;
  final List<String> errors;

  ParseResult({
    required this.title,
    required this.validQuestions,
    required this.errors,
  });
}

class QuizParser {
  /// Extract raw text from file bytes based on file extension
  static String extractText({
    required List<int> bytes,
    required String fileName,
  }) {
    final lowerName = fileName.toLowerCase();
    if (lowerName.endsWith('.pdf')) {
      return _extractFromPdf(bytes);
    } else if (lowerName.endsWith('.docx')) {
      return _extractFromDocx(bytes);
    } else if (lowerName.endsWith('.doc')) {
      throw const FormatException(
        'Old .doc format is not supported. Please save the file as .docx and try again.',
      );
    } else {
      throw const FormatException(
        'Only PDF and Word (.docx) files are supported.',
      );
    }
  }

  static String _extractFromPdf(List<int> bytes) {
    try {
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      final String text = extractor.extractText();
      document.dispose();

      if (text.trim().isEmpty) {
        throw const FormatException(
          'No readable text found. Scanned or image-only PDFs are not supported.',
        );
      }
      return text;
    } catch (e) {
      if (e is FormatException) rethrow;
      throw FormatException(
        'Failed to read PDF file: ${e.toString()}',
      );
    }
  }

  static String _extractFromDocx(List<int> bytes) {
    try {
      final archive = ZipDecoder().decodeBytes(bytes);
      ArchiveFile? documentXmlFile;
      for (final file in archive) {
        if (file.name == 'word/document.xml') {
          documentXmlFile = file;
          break;
        }
      }

      if (documentXmlFile == null) {
        throw const FormatException('Invalid DOCX file structure.');
      }

      final content = documentXmlFile.content as List<int>;
      final xmlString = utf8.decode(content);
      final xmlDoc = XmlDocument.parse(xmlString);

      final StringBuffer sb = StringBuffer();
      final paragraphs = xmlDoc.findAllElements('w:p');
      for (final p in paragraphs) {
        final textNodes = p.findAllElements('w:t');
        final paragraphText = textNodes.map((t) => t.innerText).join('');
        if (paragraphText.trim().isNotEmpty) {
          sb.writeln(paragraphText.trim());
        }
      }

      final text = sb.toString();
      if (text.trim().isEmpty) {
        throw const FormatException('No text content found in DOCX file.');
      }
      return text;
    } catch (e) {
      if (e is FormatException) rethrow;
      throw FormatException(
        'Failed to read Word (.docx) file: ${e.toString()}',
      );
    }
  }

  /// Parse structured text into questions & errors
  static ParseResult parseText({
    required String rawText,
    required String defaultTitle,
  }) {
    final List<String> errors = [];
    final List<Question> validQuestions = [];

    // Normalize text
    final normalized = rawText
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll('\u00A0', ' ')
        .trim();

    final lines = normalized.split('\n');

    String title = defaultTitle;
    // Look for Subject/Title header in top 10 lines
    for (int i = 0; i < lines.length && i < 10; i++) {
      final line = lines[i].trim();
      final subjectMatch =
          RegExp(r'^(?:Subject|Title)\s*[:\-]\s*(.+)$', caseSensitive: false)
              .firstMatch(line);
      if (subjectMatch != null) {
        final matchedTitle = subjectMatch.group(1)?.trim();
        if (matchedTitle != null && matchedTitle.isNotEmpty) {
          title = matchedTitle;
        }
        break;
      }
    }

    // Question start regex: Q1., Q1:, Q1), 1., 1), Question 1:, etc.
    final qHeaderRegex = RegExp(
      r'^\s*(?:Q(?:uestion)?\s*\d+[\.\:\)\-]?|\d+[\.\:\)])\s*(.*)$',
      caseSensitive: false,
    );

    // Option start regex: A), A., A:, (A), etc.
    final optionRegex = RegExp(
      r'^\s*(?:\(?([A-D])[\.\:\)\-]?)\s+(.*)$',
      caseSensitive: false,
    );

    // Answer regex: Answer: A, Ans: B, Correct Answer: C, etc.
    final answerRegex = RegExp(
      r'^\s*(?:Correct\s*)?Ans(?:wer)?\s*[:\-\s]\s*([A-D])',
      caseSensitive: false,
    );

    // Explanation regex: Explanation: ..., Exp: ...
    final expRegex = RegExp(
      r'^\s*(?:Exp(?:lanation)?)\s*[:\-\s]\s*(.*)$',
      caseSensitive: false,
    );

    _RawQuestionBlock? currentBlock;
    int questionCounter = 0;

    void finalizeCurrentBlock() {
      if (currentBlock == null) return;
      questionCounter++;
      final numLabel = 'Question $questionCounter';

      final blockErr = currentBlock!.validate(numLabel);
      if (blockErr == null) {
        validQuestions.add(currentBlock!.toQuestion(questionCounter));
      } else {
        errors.add(blockErr);
      }
      currentBlock = null;
    }

    String currentField = ''; // 'Q', 'A', 'B', 'C', 'D', 'ANS', 'EXP'

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Check for Question start
      final qMatch = qHeaderRegex.firstMatch(trimmed);
      if (qMatch != null) {
        finalizeCurrentBlock();
        final initialText = qMatch.group(1)?.trim() ?? '';
        currentBlock = _RawQuestionBlock();
        currentBlock!.questionText = initialText;
        currentField = 'Q';
        continue;
      }

      // Check for Option start
      final optMatch = optionRegex.firstMatch(trimmed);
      if (optMatch != null && currentBlock != null) {
        final letter = optMatch.group(1)!.toUpperCase();
        final text = optMatch.group(2)?.trim() ?? '';
        currentBlock!.options[letter] = text;
        currentField = letter;
        continue;
      }

      // Check for Answer
      final ansMatch = answerRegex.firstMatch(trimmed);
      if (ansMatch != null && currentBlock != null) {
        currentBlock!.answerLetter = ansMatch.group(1)!.toUpperCase();
        currentField = 'ANS';
        continue;
      }

      // Check for Explanation
      final expMatch = expRegex.firstMatch(trimmed);
      if (expMatch != null && currentBlock != null) {
        currentBlock!.explanation = expMatch.group(1)?.trim() ?? '';
        currentField = 'EXP';
        continue;
      }

      // Wrapped line continuation
      if (currentBlock != null) {
        if (currentField == 'Q') {
          currentBlock!.questionText +=
              currentBlock!.questionText.isEmpty ? trimmed : ' $trimmed';
        } else if (['A', 'B', 'C', 'D'].contains(currentField)) {
          final existing = currentBlock!.options[currentField] ?? '';
          currentBlock!.options[currentField] =
              existing.isEmpty ? trimmed : '$existing $trimmed';
        } else if (currentField == 'EXP') {
          currentBlock!.explanation +=
              currentBlock!.explanation.isEmpty ? trimmed : ' $trimmed';
        }
      }
    }

    finalizeCurrentBlock();

    return ParseResult(
      title: title,
      validQuestions: validQuestions,
      errors: errors,
    );
  }
}

class _RawQuestionBlock {
  String questionText = '';
  final Map<String, String> options = {};
  String? answerLetter;
  String explanation = '';

  String? validate(String questionLabel) {
    if (questionText.trim().isEmpty) {
      return '$questionLabel: Missing question text.';
    }

    final missingOpts = <String>[];
    for (final opt in ['A', 'B', 'C', 'D']) {
      if (!options.containsKey(opt) || options[opt]!.trim().isEmpty) {
        missingOpts.add(opt);
      }
    }

    if (missingOpts.isNotEmpty) {
      return '$questionLabel: Missing option(s): ${missingOpts.join(', ')}.';
    }

    if (answerLetter == null ||
        !['A', 'B', 'C', 'D'].contains(answerLetter)) {
      return '$questionLabel: Missing or invalid correct answer (must be A, B, C, or D).';
    }

    return null; // Valid!
  }

  Question toQuestion(int index) {
    final optList = [
      options['A']!.trim(),
      options['B']!.trim(),
      options['C']!.trim(),
      options['D']!.trim(),
    ];

    int correctIndex = 0;
    if (answerLetter == 'B') correctIndex = 1;
    if (answerLetter == 'C') correctIndex = 2;
    if (answerLetter == 'D') correctIndex = 3;

    return Question(
      id: 'custom_q_${index}_${DateTime.now().millisecondsSinceEpoch}',
      questionText: questionText.trim(),
      options: optList,
      correctAnswerIndex: correctIndex,
      explanation: explanation.trim().isNotEmpty
          ? explanation.trim()
          : 'The correct answer is Option $answerLetter.',
    );
  }
}
