import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class LoginPage extends StatelessWidget {
  // Define the key for the form
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<bool> _validateCredentials(String username, String password) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/credentials.txt');
    List<String> lines = await file.readAsLines();

    for (String line in lines) {
      var parts = line.split(':');
      if (parts.length == 2) {
        if (parts[0] == username && parts[1] == password) {
          return true;
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Attach the form key
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true, // This hides the password
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    bool isValid = await _validateCredentials(
                      _usernameController.text,
                      _passwordController.text,
                    );
                    if (isValid) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Login Successful')),
                      );
                      // Navigate to the next page or perform other actions
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Invalid Credentials')),
                      );
                    }
                  }
                },
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}