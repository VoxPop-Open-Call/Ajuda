import 'package:ajuda/Ui/Utils/alert.dart';
import 'package:ajuda/Ui/Utils/loading.dart';
import 'package:ajuda/Ui/Utils/theme/appcolor.dart';
import 'package:ajuda/Ui/Utils/view_model.dart';
import 'package:flutter/material.dart';

import '../../my_app.dart';

class BaseScreen<VIEW_MODEL extends ViewModel> extends StatefulWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final BottomNavigationBar? bottomNavigationBar;
  final Widget? bottomSheet;
  final Color? color;

  const BaseScreen({
    Key? key,
    this.appBar,
    this.bottomNavigationBar,
    this.bottomSheet,
    required this.child,
    this.color,
  }) : super(key: key);

  @override
  State<BaseScreen<VIEW_MODEL>> createState() => _BaseScreenState<VIEW_MODEL>();
}

class _BaseScreenState<VIEW_MODEL extends ViewModel>
    extends State<BaseScreen<VIEW_MODEL>> {
  @override
  void initState() {
    withViewModel<VIEW_MODEL>(context, (viewModel) {
      viewModel.onError = () {
        Alert.showSnackBar(
            navigatorKey.currentContext!, viewModel.snackBarText!);
      };
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  widget.color??AppColors.white,
      bottomSheet: widget.bottomSheet,
      bottomNavigationBar: widget.bottomNavigationBar,
      appBar: widget.appBar,

      body: Stack(
        children: [
          widget.child,
          LoadingIndicatorConsumer<VIEW_MODEL>(),
        ],
      ),

    );
  }
}
