import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connect_to_sql_server_directly/connect_to_sql_server_directly.dart'; // Import for connecting to SQL Server

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  runApp(MyApp());
}

class CredentialEditScreen extends StatefulWidget {
  @override
  _CredentialEditScreenState createState() => _CredentialEditScreenState();
}

class _CredentialEditScreenState extends State<CredentialEditScreen> {
  final AuthService authService = AuthService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false; // To toggle password visibility
  bool isInputValid = false;

  String _errorMessage = ''; // Error message text

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                'Image/logo.png', // Provide the correct path to your asset image
                width: 250, // Adjust the width as needed
                height: 200, // Adjust the height as needed
              ),
              SizedBox(height: 16.0),
              Row(
                children: <Widget>[
                  Icon(Icons.person, color: Colors.black), // Username icon
                  SizedBox(width: 8.0), // Add some spacing
                  Expanded(
                    child: TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(), // Add input field border
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.0),
              Row(
                children: <Widget>[
                  Icon(Icons.lock, color: Colors.black), // Password icon
                  SizedBox(width: 8.0), // Add some spacing
                  Expanded(
                    child: TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(), // Add input field border
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      obscureText:
                          !_isPasswordVisible, // Toggle password visibility
                      onChanged: (value) {
                        setState(() {
                          // Update the isInputValid flag when the input changes
                          isInputValid = _usernameController.text.isNotEmpty &&
                              _passwordController.text.isNotEmpty;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Text(
                _errorMessage, // Display error message here
                style: TextStyle(color: Colors.red),
              ),
              ElevatedButton(
                onPressed: isInputValid
                    ? () async {
                        final username = _usernameController.text;
                        final password = _passwordController.text;
                        if (username.isNotEmpty && password.isNotEmpty) {
                          final result =
                              await authService.signin(username, password);
                          if (result == AuthServiceResult.Success) {
                            Navigator.of(context).pushReplacementNamed('/home');
                          } else if (result == AuthServiceResult.UserNotFound) {
                            setState(() {
                              _errorMessage = 'User not registered.';
                            });
                          } else if (result ==
                                  AuthServiceResult.IncorrectPassword ||
                              password == '') {
                            setState(() {
                              _errorMessage = 'Incorrect password.';
                            });
                          }
                        }
                      }
                    : null,
                child: Text('Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum AuthServiceResult {
  Success,
  UserNotFound,
  IncorrectPassword,
}

class AuthService {
  final String _usernameKey = 'username';
  final String _passwordKey = 'password';

  Future<AuthServiceResult> signin(String username, String password) async {
    // Check if the provided username exists in the SQL Server database
    final doesUserExist = await _checkIfUserExists(username);

    if (!doesUserExist) {
      return AuthServiceResult.UserNotFound;
    }

    // Verify the password for the existing username
    final isPasswordValid = await _verifyPassword(username, password);

    if (!isPasswordValid) {
      return AuthServiceResult.IncorrectPassword;
    }

    // If both username and password are valid, proceed with authentication
    // Your authentication logic here...

    // For example, you can store the user's credentials in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
    await prefs.setString(_passwordKey, password);

    return AuthServiceResult.Success;
  }

  Future<bool> _checkIfUserExists(String username) async {
    // Use the 'connect_to_sql_server_directly' package to check if the username exists in your SQL Server database.
    // Replace this with your database query logic.
    // Example query:
    final _connectToSqlServerDirectlyPlugin = ConnectToSqlServerDirectly();
    final connectionResult = await _connectToSqlServerDirectlyPlugin
        .initializeConnection('192.168.1.3', 'Traininng', 'sa', 'JPLjeevan123',
            instance: 'sqlerp');
    final query =
        "SELECT COUNT(*) FROM EmployeeMob WHERE Username = '$username'";
    final result =
        await _connectToSqlServerDirectlyPlugin.getRowsOfQueryResult(query);
    if (result != null && result.isNotEmpty) {
      int countValue = result[0]['']; // Access the value from the map
      if (countValue == 1) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> _verifyPassword(String username, String password) async {
    final _connectToSqlServerDirectlyPlugin = ConnectToSqlServerDirectly();
    final connectionResult = await _connectToSqlServerDirectlyPlugin
        .initializeConnection('192.168.1.3', 'Traininng', 'sa', 'JPLjeevan123',
            instance: 'sqlerp');
    final query =
        "SELECT COUNT(*) FROM EmployeeMob WHERE Username = '$username' AND Password = '$password'";
    final result =
        await _connectToSqlServerDirectlyPlugin.getRowsOfQueryResult(query);
    if (result != null && result.isNotEmpty) {
      int countValue = result[0]['']; // Access the value from the map
      if (countValue == 1) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<Map<String, String?>> getCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_usernameKey);
    final password = prefs.getString(_passwordKey);
    return {'username': username, 'password': password};
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/edit', // Set the initial route to the edit screen
      routes: {
        '/edit': (context) => CredentialEditScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService authService = AuthService();
  late Map<String, String?> credentials;

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    credentials = await authService.getCredentials();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Username: ${credentials['username'] ?? 'Not set'}',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Password: ${credentials['password'] ?? 'Not set'}',
              style: TextStyle(fontSize: 18),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/edit');
              },
              child: Text('Edit Credential'),
            ),
          ],
        ),
      ),
    );
  }
}
