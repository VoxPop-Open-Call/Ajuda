import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool _isLoadingFacebook = false;

  set isLoading(value) {
    _isLoading = value;
    notifyListeners();
  }

  set isLoadingFacebook(value) {
    _isLoadingFacebook = value;
    notifyListeners();
  }

  get isLoading => _isLoading;

  get isLoadingFacebook => _isLoadingFacebook;

  ///error message for showing in snackBar
  String? snackBarText;
  VoidCallback? onError;

  void callApi(AsyncCallback api) {
    isLoading = true;
    api().then((_) {
      isLoading = false;
    }).catchError((th, stacktrace) {
      debugPrint("Caught Error while calling api: " + th.toString());
      debugPrint("Type of Exception: " + th.runtimeType.toString());
      debugPrint(stacktrace.toString());
      snackBarText = "Something went wrong, Please try again later";
      onError?.call();
      isLoading = false;
      notifyListeners();
    });
  }
}

void withViewModel<VIEW_MODEL extends ViewModel>(
  BuildContext context,
  void Function(VIEW_MODEL viewModel) function,
) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final provider = Provider.of<VIEW_MODEL>(context, listen: false);
    function.call(provider);
  });
}
