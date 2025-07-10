import 'package:flutter/material.dart';
import 'package:quiz/config/supabase_config.dart';

class CreateQuizScreen extends StatefulWidget {
  const CreateQuizScreen({super.key});

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  bool isAdmin = false;

  List<QuestionData> questions = [];

  @override
  void initState() {
    super.initState();
    checkAdmin();
  }

  Future<void> checkAdmin() async {
    final userId = supabase.auth.currentUser!.id;

    final profile = await supabase
        .from('profiles')
        .select('is_admin')
        .eq('id', userId)
        .single();

    setState(() {
      isAdmin = profile['is_admin'] == true;
    });
  }

  Future<void> createQuiz() async {
    if (!isAdmin) {
      return;
    }

    if (titleController.text.isEmpty || questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Title and at least one question required")),
      );
      return;
    }

    try {
      final quizRes = await supabase
          .from('quizzes')
          .insert({
            'title': titleController.text,
            'description': descController.text,
            'created_by': supabase.auth.currentUser!.id,
            'is_active': true,
          })
          .select()
          .single();

      final quizId = quizRes['id'];

      for (var q in questions) {
        if (q.textController.text.isEmpty) {
          throw Exception("Question text cannot be empty");
        }
        if (q.choices.isEmpty) {
          throw Exception("Each question must have at least one choice");
        }
        if (!q.choices.any((c) => c.isCorrect)) {
          throw Exception("Each question must have one correct choice");
        }

        final questionRes = await supabase
            .from('questions')
            .insert({
              'quiz_id': quizId,
              'question_text': q.textController.text,
            })
            .select()
            .single();

        final questionId = questionRes['id'];

        for (var c in q.choices) {
          if (c.textController.text.isEmpty) {
            throw Exception("Choice text cannot be empty");
          }

          await supabase.from('choices').insert({
            'question_id': questionId,
            'choice_text': c.textController.text,
            'is_correct': c.isCorrect,
          });
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Quiz created successfully!")));
      titleController.clear();
      descController.clear();
      setState(() {
        questions.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isAdmin) {
      return const Scaffold(
        body: Center(child: Text("Not authorized")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Create Quiz")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Quiz Title')),
            TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    questions.add(QuestionData());
                  });
                },
                child: const Text("Add Question")),
            const SizedBox(height: 16),
            ...questions.map((q) => buildQuestion(q)).toList(),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: createQuiz, child: const Text("Submit Quiz")),
          ],
        ),
      ),
    );
  }

  Widget buildQuestion(QuestionData q) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: q.textController,
              decoration: const InputDecoration(labelText: 'Question Text'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  q.choices.add(ChoiceData());
                });
              },
              child: const Text("Add Choice"),
            ),
            ...q.choices.map((c) => buildChoice(q, c)).toList(),
          ],
        ),
      ),
    );
  }

  Widget buildChoice(QuestionData q, ChoiceData c) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: c.textController,
            decoration: const InputDecoration(labelText: 'Choice Text'),
          ),
        ),
        Checkbox(
          value: c.isCorrect,
          onChanged: (value) {
            setState(() {
              for (var choice in q.choices) {
                choice.isCorrect = false;
              }
              c.isCorrect = value ?? false;
            });
          },
        ),
        const Text("Correct"),
      ],
    );
  }
}

class QuestionData {
  final textController = TextEditingController();
  List<ChoiceData> choices = [];

  QuestionData();
}

class ChoiceData {
  final textController = TextEditingController();
  bool isCorrect = false;

  ChoiceData();
}
