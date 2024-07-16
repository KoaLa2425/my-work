import 'package:flutter/material.dart';

class LoginExample extends StatelessWidget {
  const LoginExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SingIn on Program'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Container(
          padding: const EdgeInsets.all(10),
          child:  Column(
             crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text('Sing in to My App'),
              ),
              const Text('Username'),
              const TextField(
                decoration:  InputDecoration(
                  labelText: 'username',
                filled: true,
                fillColor: Colors.blueGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                prefixIcon: Icon(Icons.person,color: Colors.white,),
                suffixIcon: Icon(Icons.arrow_right)
                ),
                style: TextStyle(color: Colors.white ),
              ),
              const SizedBox(height: 20,),
              const Text('Password'),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(fillColor: Colors.blueGrey,
                filled: true,
                 border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                prefixIcon: Icon(Icons.lock,color: Colors.white,),
                ),
                style: TextStyle(color: Colors.white,
                 ),
              ),
              const SizedBox(height: 20,),
              ElevatedButton.icon(
                icon: const Icon(Icons.lock),
              onPressed: (){},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 10,
                  bottom: 10,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius:  BorderRadius.all(Radius.circular(15))
                )
              ),
              label: const Text('Sing in'))
              ],
          ),
        ),
      ),
    );
  }
}
