import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';

import 'materialColor.dart';

class PDFScreen extends StatefulWidget {
  final String asset;
  final String filename;

  PDFScreen({Key key, this.asset, this.filename}) : super(key: key);

  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int pages = 0;
  int currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  String pathPDF = "";

  Future<File> fromAsset(String asset, String filename) async {
    // To open from assets, you can copy them to the app storage folder, and the access them "locally"
    Completer<File> completer = Completer();

    try {
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/$filename");
      var data = await rootBundle.load(asset);
      var bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      print(e);
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

  Future getAsset() async {
    var f = await fromAsset(widget.asset, widget.filename);
    setState(() {
      pathPDF = f.path;
    });
    return pathPDF;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getAsset(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            // Future hasn't finished yet, return a placeholder
            return Scaffold(
              body: Container(
                child: Center(
                  child: SpinKitSpinningLines(
                    color: materialColor(RosePink.primary),
                    size: 75,
                  ),
                ),
              ),
            );
          } else {
          return Scaffold(
            appBar: AppBar(
              //title: Text("Document"),
              actions: <Widget>[
                // IconButton(
                //   icon: Icon(Icons.share),
                //   onPressed: () {},
                // ),
              ],
            ),
            body: Stack(
              children: <Widget>[
                PDFView(
                  filePath: pathPDF,
                  enableSwipe: true,
                  swipeHorizontal: false,
                  autoSpacing: false,
                  pageFling: true,
                  pageSnap: true,
                  defaultPage: currentPage,
                  fitPolicy: FitPolicy.BOTH,
                  preventLinkNavigation: false,
                  // if set to true the link is handled in flutter
                  onRender: (_pages) {
                    setState(() {
                      pages = _pages;
                      isReady = true;
                    });
                  },
                  onError: (error) {
                    setState(() {
                      errorMessage = error.toString();
                    });
                    print(error.toString());
                  },
                  onPageError: (page, error) {
                    setState(() {
                      errorMessage = '$page: ${error.toString()}';
                    });
                    print('$page: ${error.toString()}');
                  },
                  onViewCreated: (PDFViewController pdfViewController) {
                    _controller.complete(pdfViewController);
                  },
                  onLinkHandler: (String uri) {
                    print('goto uri: $uri');
                  },
                  onPageChanged: (int page, int total) {
                    print('page change: $page/$total');
                    setState(() {
                      currentPage = page;
                    });
                  },
                ),
                errorMessage.isEmpty
                    ? !isReady
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : Container()
                    : Center(
                        child: Text(errorMessage),
                      )
              ],
            ),
            floatingActionButton: FutureBuilder<PDFViewController>(
              future: _controller.future,
              builder: (context, AsyncSnapshot<PDFViewController> snapshot) {
                if (snapshot.hasData) {
                  return FloatingActionButton.extended(
                    label: currentPage + 1 == pages ? Text("Go to top") : Text("Go to $pages"),
                    onPressed: () async {
                      if(currentPage + 1 == pages) {
                        await snapshot.data.setPage(0);
                      } else {
                        await snapshot.data.setPage(pages);
                      }
                    },
                  );
                }

                return Container();
              },
            ),
          );
        }});
  }
}
