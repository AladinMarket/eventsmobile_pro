import 'package:eventright_pro_user/constant/color_constant.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter/material.dart';

class ReadMore extends StatefulWidget {
  final String? allText;
  final String? title;

  const ReadMore({super.key, this.allText, this.title});

  @override
  State<ReadMore> createState() => _ReadMoreState();
}

class _ReadMoreState extends State<ReadMore> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.whiteColor,
            size: 18,
          ),
        ),
          title: Text(
            widget.title ?? '',
            style: const TextStyle(
              color: AppColors.whiteColor,
              fontSize: 18,
            ),
          )
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16),
            child: HtmlWidget(widget.allText!)
        ),
      ),
    );
  }
}
