import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const  Positioned.fill(
      child: ColoredBox(
        color: Colors.black54,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
