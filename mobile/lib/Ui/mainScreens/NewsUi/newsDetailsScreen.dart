import 'package:ajuda/Ui/Utils/commanWidget/CommonBackButton.dart';
import 'package:ajuda/Ui/Utils/commanWidget/loader.dart';
import 'package:ajuda/Ui/mainScreens/NewsUi/newsViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../Utils/base_screen.dart';
import '../../Utils/theme/appcolor.dart';
import '../../Utils/view_model.dart';

class NewsDetailsScreen extends StatefulWidget {
  static const String route = "NewsDetailsScreen";

  const NewsDetailsScreen({Key? key}) : super(key: key);

  @override
  State<NewsDetailsScreen> createState() => _NewsDetailsScreenState();
}

class _NewsDetailsScreenState extends State<NewsDetailsScreen> {
  @override
  void initState() {
    super.initState();
    withViewModel<NewsViewModel>(context, (viewModel) {

      viewModel.updateWebView();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NewsViewModel>();
    return BaseScreen<NewsViewModel>(
      color: AppColors.porcelain,
      child: Padding(
        padding:
            const EdgeInsets.only(top: 40.5, right: 13, left: 13, bottom: 31),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(bottom: 7.5),
                  child: CommonBackButton(
                    // onPressed: (){
                    //   provider.clearWebView(context);
                    // },
                  ),
                ),
                Expanded(
                    child:
                        WebViewWidget(controller: provider.webViewController!)
                    /* WebViewWidget(
                    controller: WebViewController()
                      ..setJavaScriptMode(JavaScriptMode.unrestricted)
                      ..setBackgroundColor(AppColors.trans)
                      ..setNavigationDelegate(
                        NavigationDelegate(
                          onProgress: (int progress) {},
                          onPageStarted: (String url) {},
                          onPageFinished: (String url) {
                            print('onPageFinished');
                            print(url);
                            // provider.isLoading = false;
                          },
                          onWebResourceError: (WebResourceError error) {
                            print('error');
                            print(error.description);
                          },
                          onNavigationRequest: (NavigationRequest request) {
                            // if (request.url
                            //     .startsWith('https://www.youtube.com/')) {
                            //   return NavigationDecision.prevent;
                            // }
                            return NavigationDecision.navigate;
                          },
                        ),
                      )
                      ..loadRequest(
                        Uri.parse(
                            provider.newsData[provider.selectIndex].articleUrl),
                      ),
                  ),*/
                    )
              ],
            ),
            Align(
              alignment: Alignment.center,
              child: Visibility(
                visible: provider.isLoading,
                child: CommonLoader(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
