import 'package:flutter/material.dart';

class ErrorEmpty extends StatelessWidget {
  const ErrorEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 200,
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.error_outline,size: 100,),
          Text("找不到数据")
        ],
      ),
    );
  }
}
