// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() {
  runApp(MyApp());
}

String query = '''
   query {
    popular_artists {
      artists {
        name       
      }
    }
  }
''';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    HttpLink httpLink = HttpLink(uri: "https://metaphysics-staging.artsy.net");

    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(cache: InMemoryCache(), link: httpLink),
    );

    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: Text("Test"),
            ),
            body: Query(
              options: QueryOptions(
                documentNode: gql(query),
              ),
              builder: (result, {fetchMore, refetch}) {
                if (result.hasException)
                  return ErrorPage(error: result.exception.toString());
                if (result.loading) return LoadingPage();
                List artists = result.data['popular_artists']['artists'];
                return ListView.builder(
                  itemCount: artists.length,
                  itemBuilder: (_, index) => Text(artists[index]['name']),
                );
              },
            )),
      ),
    );
  }
}

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(
            height: 8,
          ),
          Text("Loading... Please Wait"),
        ],
      ),
    );
  }
}

class ErrorPage extends StatelessWidget {
  final String error;

  ErrorPage({@required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("An error occurred: $error"),
    );
  }
}
