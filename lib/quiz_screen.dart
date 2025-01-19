// Quiz Screen File (quiz_screen.dart)
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quizapp/result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<dynamic> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;

  @override
  void initState() {
    super.initState();
    fetchQuizData();
  }

  Future<void> fetchQuizData() async {
    try {
      final response =
          await http.get(Uri.parse('https://api.jsonserve.com/Uw5CrX'));
      print('__Response: ${response.body}');
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          questions = data['questions'];
        });
        print('__Responsefewri: ${questions.length}');
      }
    } catch (error) {
      showError('error aya $error');
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void handleAnswer(bool isCorrect) {
    if (isCorrect) {
      setState(() {
        score += 1;
      });
    }
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ResultScreen(score: score, totalQuestions: questions.length),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final question = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question ${currentQuestionIndex + 1}/${questions.length}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text(
              question['description'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...question['options'].map<Widget>((option) {
              return ElevatedButton(
                onPressed: () => handleAnswer(option['is_correct']),
                child: Text(option['description']),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
