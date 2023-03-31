import 'package:flutter/material.dart';
import 'package:noticias_modal/pages/list_posts.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Noticias', debugShowCheckedModeBanner: false, home: PostList());
  }
}
