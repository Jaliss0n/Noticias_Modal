import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html_unescape/html_unescape.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class PostList extends StatefulWidget {
  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  List<dynamic> _posts = [];

  Future<List<dynamic>> fetchPosts() async {
    final response = await http
        .get(Uri.parse('https://code8734.com.br/wp-json/wp/v2/posts?_embed'));
    final List<dynamic> responseData = json.decode(response.body);
    return responseData;
  }

  @override
  void initState() {
    initializeDateFormatting('pt_BR', null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text('Lista de Noticias'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
        body: Container(
          color: Color.fromARGB(255, 0, 99, 138),
          child: FutureBuilder<List<dynamic>>(
            future: fetchPosts(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                _posts = snapshot.data!;
                return Container(
                  child: ListView.builder(
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      final post = _posts[index];
                      final authorName = post['_embedded']['author'][0]['name'];
                      final unescape = HtmlUnescape();
                      final content = post['content']['rendered'];
                      final regex = RegExp(r'<[^>]+>');
                      final sanitizedContent =
                          unescape.convert(content.replaceAll(regex, ''));
                      final pubDate = DateTime.parse(post['date']);
                      final formattedDate =
                          DateFormat.yMMMMEEEEd('pt_BR').format(pubDate);
                      final embeddedData = post['_embedded'];
                      final featuredImage = embeddedData != null &&
                              embeddedData['wp:featuredmedia'] != null
                          ? embeddedData['wp:featuredmedia'][0]['source_url']
                          : null;
                      return Container(
                          margin: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20)),
                          child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    gradient: LinearGradient(
                                      colors: [
                                        Color.fromARGB(255, 0, 140, 255),
                                        Color.fromARGB(255, 30, 84, 122)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      ListTile(
                                        title: Text(
                                          post['title']['rendered'],
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(
                                                  bottom: 30, top: 40),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.9,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.4,
                                              decoration: featuredImage != null
                                                  ? BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12.0),
                                                      image: DecorationImage(
                                                        image: NetworkImage(
                                                            featuredImage),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    )
                                                  : null,
                                            ),
                                            Text(
                                              sanitizedContent,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Color.fromARGB(
                                                      255, 239, 239, 239)),
                                            ),
                                            SizedBox(height: 8.0),
                                            Text(
                                              'Por $authorName',
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 255, 255, 255),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              formattedDate,
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255),
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ))));
                    },
                  ),
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              return const Center(
                  child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ));
            },
          ),
        ));
  }
}
