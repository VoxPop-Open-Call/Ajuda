import 'dart:convert';

import 'package:ajuda/Ui/Utils/commanWidget/common_validations.dart';
import 'package:ajuda/Ui/Utils/view_model.dart';
import 'package:ajuda/data/repo/home_repo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';

// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../../../data/remote/model/NewsModel/newsmodel.dart';
import '../../Utils/misc_functions.dart';
import '../../Utils/response.dart';

class NewsViewModel extends ViewModel with CommonValidations {
  int _selectIndex = 0;

  int get selectIndex => _selectIndex;

  set selectIndex(int value) {
    _selectIndex = value;
    notifyListeners();
  }

  int _tabIndex = 0;

  int get tabIndex => _tabIndex;

  set tabIndex(int value) {
    _tabIndex = value;
    notifyListeners();
  }

  WebViewController? webViewController;

  updateWebView() async {
    // #docregion platform_features
    // webViewController=WebViewController();
    // webViewController!.reload();
    // notifyListeners();
    if (webViewController == null) {
      late final PlatformWebViewControllerCreationParams params;
      if (WebViewPlatform.instance is WebKitWebViewPlatform) {
        params = WebKitWebViewControllerCreationParams(
          allowsInlineMediaPlayback: true,
          mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
        );
      } else {
        params = const PlatformWebViewControllerCreationParams();
      }

      final WebViewController controller =
          WebViewController.fromPlatformCreationParams(params);
      // #enddocregion platform_features

      controller
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              debugPrint('WebView is loading (progress : $progress%)');
            },
            onPageStarted: (String url) {
              debugPrint('Page started loading: $url');
            },
            onPageFinished: (String url) {
              debugPrint('Page finished loading: $url');
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint(' Page resource error: '
                  'code: ${error.errorCode} '
                  'description: ${error.description} '
                  'errorType: ${error.errorType} '
                  'isForMainFrame: ${error.isForMainFrame}');
            },
            onNavigationRequest: (NavigationRequest request) {
              if (request.url.startsWith('https://www.youtube.com/')) {
                debugPrint('blocking navigation to ${request.url}');
                return NavigationDecision.prevent;
              }
              debugPrint('allowing navigation to ${request.url}');
              return NavigationDecision.navigate;
            },
            onUrlChange: (UrlChange change) {
              debugPrint('url change to ${change.url}');
            },
          ),
        )
        ..addJavaScriptChannel(
          'Toaster',
          onMessageReceived: (JavaScriptMessage message) {},
        )
        ..loadRequest(Uri.parse(newsData[selectIndex].articleUrl));

      // #docregion platform_features
      if (controller.platform is AndroidWebViewController) {
        AndroidWebViewController.enableDebugging(true);
        (controller.platform as AndroidWebViewController)
            .setMediaPlaybackRequiresUserGesture(false);
      }
      // #enddocregion platform_features

      webViewController = controller;
      notifyListeners();
    } else {
      await webViewController!
          .loadRequest(Uri.parse(newsData[selectIndex].articleUrl));
      notifyListeners();
    }
  }

  List<dynamic> newsData = [];
  List<dynamic> tabData = [];

  VoidCallback? getSucces;

  String capitalize(String value) {
    var result = value[0].toUpperCase();
    bool cap = true;
    for (int i = 1; i < value.length; i++) {
      if (value[i - 1] == " " && cap == true) {
        result = result + value[i].toUpperCase();
      } else {
        result = result + value[i];
        cap = false;
      }
    }
    return result;
  }

  getListData(subject) async {
    hideKeyboard();
    callApi(() async {
      ResponseData response = subject == 'todos'
          ? await HomeRepo.getNewsList()
          : await HomeRepo.getNewsSubjectRelatedList(subject);
      if (response.isSuccessFul) {
        newsData = jsonDecode(response.data)
            .map((e) => NewsModel.fromJson(e))
            .toList();

        // onLoginSuccess?.call();
      } else {
        snackBarText = response.message;
        onError?.call();
      }
      notifyListeners();
    });
  }

  getNewsTabData() async {
    hideKeyboard();
    callApi(() async {
      ResponseData response = await HomeRepo.getNewsTab();
      if (response.isSuccessFul) {
        tabData = jsonDecode(response.data);
        tabData.insert(0, 'todos');
        await getListData(tabData[0]);
      } else {
        snackBarText = response.message;
        onError?.call();
      }
      notifyListeners();
    });
  }
}
