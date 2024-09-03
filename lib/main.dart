import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: InsertDataScreen(),
    );
  }
}

class InsertDataScreen extends StatefulWidget {
  @override
  _InsertDataScreenState createState() => _InsertDataScreenState();
}

class _InsertDataScreenState extends State<InsertDataScreen> {
  // Controllers to get the user input from the TextFields
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Function to send the input data to the server
  Future<void> insertData() async {
    // Define the URL to your PHP script
    final response = await http.post(
      Uri.parse('http://localhost/Php/insert2_user.php'),
      body: {
        'name': nameController.text, // Get the name from the TextField
        'password':
            passwordController.text, // Get the password from the TextField
      },
    );

    // Check if the server responded successfully
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['success']) {
        // Navigate to the DisplayDataScreen if insertion is successful
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DisplayDataScreen()),
        );
      } else {
        // Show an error message if the insertion failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to insert data')),
        );
      }
    } else {
      // Show an error message if the server connection failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to the server')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Insert Data'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // TextField to get the user's name
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            // TextField to get the user's password
            SizedBox(height: 25),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true, // Hide the password input
            ),
            SizedBox(height: 25),
            // Button to submit the data
            ElevatedButton(
              onPressed: insertData,
              child: Text('Submit'),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DisplayDataScreen()),
                );
              },
              child: Text('Next Page'),
            ),
          ],
        ),
      ),
    );
  }
}

// Screen to display the inserted data
class DisplayDataScreen extends StatefulWidget {
  @override
  _DisplayDataScreenState createState() => _DisplayDataScreenState();
}

class _DisplayDataScreenState extends State<DisplayDataScreen> {
  // Function to fetch data from the server
  Future<List<Map<String, String>>> fetchData() async {
    final response = await http.get(Uri.parse(
        'http://localhost/Php/fetch_user.php')); // Use 127.0.0.1 for iOS

    if (response.statusCode == 200) {
      List<dynamic> users = json.decode(response.body);

      // Converting List<Map<String, dynamic>> to List<Map<String, String>>
      return users.map((user) {
        return {
          'name': user['name'].toString(),
          'password': user['password'].toString(),
        };
      }).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Display Data'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Name: ${snapshot.data![index]['name']}'),
                  subtitle:
                      Text('Password: ${snapshot.data![index]['password']}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
