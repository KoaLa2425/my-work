import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formkey = GlobalKey<FormState>();
  final _navigatorController = GlobalKey<NavigatorState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorController,
      onGenerateRoute: (setting) {
        return MaterialPageRoute(
            builder: (context) => Scaffold(
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formkey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              'https://cdn-icons-png.flaticon.com/512/5087/5087579.png',
                              width: 150,
                              height: 150,
                            ),
                            TextFormField(controller: _usernameController,
                            decoration: const InputDecoration(labelText: "Username"),
                            validator: (value){
                              if (value!.isEmpty){
                                return 'Pleaes Enter your Username';
                              }
                              return null;
                            } ,
                            ),
                            TextFormField(controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(labelText: "Password",),
                            validator: (value){
                              if (value!.isEmpty){
                                return 'Pleaes Enter your Password';
                              }
                              return null;
                            } ,
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(onPressed: () {
                              if (_formkey.currentState!.validate()){

                              }
                            }, 
                            child: const Text('LogIn'),)
                          ],
                        ),
                      ),
                    ),
                  ),


                ),
                
                );
      },
    );
  }
}
