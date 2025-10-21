import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(PostSubmissionApp());
}

class PostSubmissionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Post Submission',
      home: PostSubmissionPage(),
    );
  }
}

class PostSubmissionPage extends StatefulWidget {
  @override
  _PostSubmissionPageState createState() => _PostSubmissionPageState();
}

class _PostSubmissionPageState extends State<PostSubmissionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  bool _isSubmitting = false;

  Future<void> submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final url = Uri.parse('https://reqres.in/api/posts');

    final Map<String, String> postData = {
      'title': _titleController.text,
      'body': _bodyController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(postData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post submitted successfully.')),
        );
        _titleController.clear();
        _bodyController.clear();
      } else {
        throw Exception('Failed to submit post');
      }
    } catch (e) {
      print('Error submitting post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting post. Please try again.')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Submit New Post')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a title'
                    : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _bodyController,
                decoration: InputDecoration(labelText: 'Body'),
                maxLines: 4,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a body'
                    : null,
              ),
              SizedBox(height: 30),
              _isSubmitting
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: submitPost,
                      child: Text('Submit'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
