import 'package:flutter/material.dart';

class LoadingWidget extends StatefulWidget {
  const LoadingWidget({super.key});

  @override
  __LoadingState createState() => __LoadingState();
}

class __LoadingState extends State<LoadingWidget> {
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
        color: Colors.transparent,
        // at first show shade, if loading takes longer than 0,5s show spinner
        child: FutureBuilder(
            future: Future.delayed(const Duration(milliseconds: 100), () => true),
            builder: (context, snapshot) {
              return !snapshot.hasData
                  ? const SizedBox()
                  : Center(
                      child: Container(
                      color: Colors.yellow,
                      padding: const EdgeInsets.all(7),
                      width: 150,
                      height: 50,
                      child: const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                        CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                        Text('Loading..')
                      ]),
                    ));
            }));
  }
}
