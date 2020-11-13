import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_forth_project/user.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<User> users;

  final AppBar appBar = AppBar(
    title: Text(
      'API - List of User',
    ),
  );
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  loadUsers() async {
    try {
      Response response = await Dio().get("https://reqres.in/api/users?page=2");

      setState(() {
        users = List<User>.from(
            response.data['data'].map((data) => User.fromJson(data)));

        // users = response.data['data'];
      });
    } catch (e) {
      print(e);
    }
  }

  Widget printListUser() {
    if (users == null)
      return Container();
    else
      return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final item = users[index];
            return Card(
              child: ListTile(
                title: Text(
                  '${item.first_name + " " + item.last_name}' +
                      '\n${item.email}',
                  maxLines: 20,
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            );
          });
  }

  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: appBar,
      drawer: Container(
        color: Colors.white,
        height: screenHeight,
        width: screenWidth * 0.8,
        child: Column(
          children: [
            FlatButton(
              onPressed: () {
                // For navigation
                Navigator.pushNamed(context, '/row_flex_page');
              },
              child: Text("RowFlex Page"),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          header: WaterDropHeader(),
          footer: CustomFooter(
            builder: (BuildContext context, LoadStatus mode) {
              Widget body;
              if (mode == LoadStatus.idle) {
                body = Text("pull up load");
              } else if (mode == LoadStatus.loading) {
                body = CupertinoActivityIndicator();
              } else if (mode == LoadStatus.failed) {
                body = Text("Load Failed!Click retry!");
              } else if (mode == LoadStatus.canLoading) {
                body = Text("release to load more");
              } else {
                body = Text("No more Data");
              }
              return Container(
                height: 55.0,
                child: Center(child: body),
              );
            },
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: printListUser(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
