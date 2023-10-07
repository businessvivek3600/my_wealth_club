import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mycarclub/providers/auth_provider.dart';
import 'package:mycarclub/utils/color.dart';
import 'package:mycarclub/utils/default_logger.dart';
import 'package:mycarclub/utils/text.dart';
import 'package:path_provider/path_provider.dart';

import '../../../database/model/response/commission_wallet_history_model.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:open_file/open_file.dart';

import '../../../sl_container.dart';

class WithdrawRequesthHistoryDetailsPage extends StatefulWidget {
  const WithdrawRequesthHistoryDetailsPage(
      {Key? key, this.commissionWalletHistory})
      : super(key: key);
  final CommissionWalletHistory? commissionWalletHistory;
  @override
  _WithdrawRequesthHistoryDetailsPageState createState() =>
      new _WithdrawRequesthHistoryDetailsPageState();
}

class _WithdrawRequesthHistoryDetailsPageState
    extends State<WithdrawRequesthHistoryDetailsPage> {
  Future<File> createFileOfPdfUrl() async {
    final url = "http://africau.edu/images/default/sample.pdf";
    final filename = url.substring(url.lastIndexOf("/") + 1);
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              titleLargeText('Withdraw Details', context, useGradient: true)),
      body: Container(
        color: redDark,
        child: PDFScreen(),
      ),
    );
  }
}

class PDFViewerScaffold extends StatelessWidget {
  const PDFViewerScaffold({super.key, required this.path});
  final String path;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Document"),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.share), onPressed: () {})
        ],
      ),
      body: PDFScreen(),
    );
  }
}

class PDFScreen extends StatefulWidget {
  const PDFScreen({Key? key}) : super(key: key);

  @override
  PDFScreenState createState() {
    return PDFScreenState();
  }
}

class PDFScreenState extends State<PDFScreen>
    with SingleTickerProviderStateMixin {
  int _tab = 0;

  PrintingInfo? printingInfo;

  var _hasData = false;
  var _pending = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _init() async {
    final info = await Printing.info();
    setState(() {
      printingInfo = info;
    });
    // askName(context).then((value) {
    //   if (value != null) {
    //     setState(() {
    _hasData = true;
    _pending = false;
    // });
    // }
    // });
  }

  void _showPrintedToast(BuildContext context) {
    Fluttertoast.showToast(msg: 'Preparing for print...');
  }

  void _showSharedToast(BuildContext context) {
    Fluttertoast.showToast(msg: 'Sharing...');
  }

  Future<void> _saveAsFile(
    BuildContext context,
    LayoutCallback build,
    PdfPageFormat pageFormat,
  ) async {
    final bytes = await build(pageFormat);

    final appDocDir = await getApplicationDocumentsDirectory();
    final appDocPath = appDocDir.path;
    final file = File('$appDocPath/document.pdf');
    print('Save as file ${file.path} ...');
    await file.writeAsBytes(bytes);
    await OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    pw.RichText.debug = true;
    final actions = <PdfPreviewAction>[
      if (!kIsWeb)
        PdfPreviewAction(icon: const Icon(Icons.save), onPressed: _saveAsFile)
    ];

    return Center(
      child: PdfPreview(
        maxPageWidth: 800,
        build: (format) => generateInvoice(format),
        actions: actions,
        allowPrinting: true,
        allowSharing: true,
        canDebug: false,
        canChangeOrientation: false,
        onPrinted: _showPrintedToast,
        onShared: _showSharedToast,
      ),
    );
  }

  Future<String?> askName(BuildContext context) {
    return showDialog<String>(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          final controller = TextEditingController();

          return AlertDialog(
            title: const Text('Please type your name:'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            content: TextField(
              decoration: const InputDecoration(hintText: '[your name]'),
              controller: controller,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (controller.text != '') {
                    Navigator.pop(context, controller.text);
                  }
                },
                child: const Text('OK'),
              ),
            ],
          );
        });
  }
}

Future<Uint8List> generateInvoice(PdfPageFormat pageFormat) async {
  final lorem = pw.LoremText();

  final products = <Product>[
    Product('Withdraw Amount', lorem.sentence(4), 3.99, 2),
    Product('Processing Charges (5%)', lorem.sentence(6), 15, 2),
    // Product('28375', lorem.sentence(4), 6.95, 3),
    // Product('95673', lorem.sentence(3), 49.99, 4),
    // Product('23763', lorem.sentence(2), 560.03, 1),
    // Product('55209', lorem.sentence(5), 26, 1),
    // Product('09853', lorem.sentence(5), 26, 1),
    // Product('23463', lorem.sentence(5), 34, 1),
    // Product('56783', lorem.sentence(5), 7, 4),
    // Product('78256', lorem.sentence(5), 23, 1),
    // Product('23745', lorem.sentence(5), 94, 1),
    // Product('07834', lorem.sentence(5), 12, 1),
    // Product('23547', lorem.sentence(5), 34, 1),
    // Product('98387', lorem.sentence(5), 7.99, 2),
  ];
  var user = sl.get<AuthProvider>().userData;

  final invoice = Invoice(
    invoiceNumber: '982347',
    products: products,
    customerAddress: '54 rue de Rivoli\n75001 Paris, France',
    customerName: user.customerName ?? '',
    paymentInfo:
        '4509 Wiseman Street\nKnoxville, Tennessee(TN), 37929\n865-372-0425',
    tax: .15,
    baseColor: PdfColor.fromInt(appLogoColor.value),
    // baseColor: PdfColors.teal,
    // accentColor: PdfColors.blueGrey900,
    accentColor: PdfColors.white,
  );

  return await invoice.buildPdf(pageFormat);
}

class Invoice {
  Invoice({
    required this.products,
    required this.customerName,
    required this.customerAddress,
    required this.invoiceNumber,
    required this.tax,
    required this.paymentInfo,
    required this.baseColor,
    required this.accentColor,
  });

  final List<Product> products;
  final String customerName;
  final String customerAddress;
  final String invoiceNumber;
  final double tax;
  final String paymentInfo;
  final PdfColor baseColor;
  final PdfColor accentColor;

  static const _darkColor = PdfColors.white;
  static const _lightColor = PdfColors.white;

  PdfColor get _baseTextColor => baseColor.isLight ? _lightColor : _darkColor;

  PdfColor get _accentTextColor => baseColor.isLight ? _lightColor : _darkColor;

  double get _total =>
      products.map<double>((p) => p.total).reduce((a, b) => a + b);

  double get _grandTotal => _total * (1 + tax);

  pw.MemoryImage? _logo;

  pw.MemoryImage? _bgShape;
  final textColor = PdfColor.fromInt(appLogoColor.value);
  Future<Uint8List> buildPdf(PdfPageFormat pageFormat) async {
    // Create a PDF document.
    final doc = pw.Document();

    // _logo = await rootBundle.loadString('assets/images/' + Assets.appLogo_S);
    // _bgShape = await rootBundle.loadString('assets/images/${Assets.appLogo_S}');
    try {
      _logo = pw.MemoryImage(
          (await rootBundle.load('assets/images/appLogo_s.png'))
              .buffer
              .asUint8List());
      _bgShape = pw.MemoryImage(
          (await rootBundle.load('assets/images/bgGraphic.jpg'))
              .buffer
              .asUint8List());
    } catch (e) {
      errorLog('Error: $e');
    }
    // Add page to the PDF
    doc.addPage(
      pw.MultiPage(
        pageTheme: _buildTheme(
          pageFormat,
          await PdfGoogleFonts.robotoRegular(),
          await PdfGoogleFonts.robotoBold(),
          await PdfGoogleFonts.robotoItalic(),
        ),
        header: _buildHeader,
        footer: _buildFooter,
        build: (context) => [
          pw.SizedBox(height: 20),
          _contentHeader(context),
          _contentTable(context),
          pw.SizedBox(height: 20),
          _contentFooter(context),
          pw.SizedBox(height: 20),
          _termsAndConditions(context),
        ],
      ),
    );

    // Return the PDF file content
    return doc.save();
  }

  pw.Widget _buildHeader(pw.Context context) {
    return pw.Column(
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.start,
          children: [
            //invoice texts
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  //Withdrawal Invoice text
                  pw.Container(
                    height: 50,
                    padding: const pw.EdgeInsets.only(left: 20),
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Text(
                      'Withdrawal Invoice',
                      style: pw.TextStyle(
                        color: baseColor,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                  ),
                  pw.Container(
                    decoration: pw.BoxDecoration(
                      borderRadius:
                          const pw.BorderRadius.all(pw.Radius.circular(2)),
                      color: PdfColors.black
                          .flatten(background: PdfColor(1, 1, 1, .1)),
                    ),
                    padding: const pw.EdgeInsets.only(
                        left: 40, top: 10, bottom: 10, right: 20),
                    alignment: pw.Alignment.centerLeft,
                    height: 50,
                    child: pw.DefaultTextStyle(
                      style: pw.TextStyle(
                        color: _accentTextColor,
                        fontSize: 12,
                      ),
                      child: pw.GridView(
                        crossAxisCount: 2,
                        children: [
                          pw.Text('Invoice #'),
                          pw.Text(invoiceNumber),
                          pw.Text('Date:'),
                          pw.Text(_formatDate(DateTime.now())),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //logo
            pw.Expanded(
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Container(
                    alignment: pw.Alignment.topRight,
                    padding: const pw.EdgeInsets.only(bottom: 8, left: 30),
                    height: 72,
                    child: _logo != null ? pw.Image(_logo!) : pw.PdfLogo(),
                  ),
                  // pw.Container(
                  //   color: baseColor,
                  //   padding: pw.EdgeInsets.only(top: 3),
                  // ),
                ],
              ),
            ),
          ],
        ),
        if (context.pageNumber > 1) pw.SizedBox(height: 20)
      ],
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Divider(color: pw.GridPaper.lineColor),
        pw.Text(
          '© 2023 My Wealth Club. All Rights Reserved.',
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.white),
        ),
      ],
    );
  }

  pw.PageTheme _buildTheme(
      PdfPageFormat pageFormat, pw.Font base, pw.Font bold, pw.Font italic) {
    return pw.PageTheme(
      pageFormat: pageFormat,
      theme: pw.ThemeData.withFont(base: base, bold: bold, italic: italic)
          .copyWith(),
      buildBackground: (context) => pw.FullPage(
        ignoreMargins: true,
        child: _bgShape != null
            ? pw.Opacity(
                opacity: 0.9,
                child: pw.Image(_bgShape!, fit: pw.BoxFit.cover),
              )
            : null,
      ),
    );
  }

  pw.Widget _contentHeader(pw.Context context) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Container(
            margin: const pw.EdgeInsets.symmetric(horizontal: 20),
            height: 50,
            child: pw.FittedBox(
              child: pw.Text('Total: ${_formatCurrency(_grandTotal)}',
                  style: pw.TextStyle(
                      color: baseColor, fontStyle: pw.FontStyle.italic)),
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Container(
                height: 70,
                child: pw.RichText(
                    text: pw.TextSpan(
                        text: '$customerName\n',
                        style: pw.TextStyle(
                          color: _darkColor,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                        children: [
                      const pw.TextSpan(
                        text: '\n',
                        style: pw.TextStyle(
                          fontSize: 5,
                        ),
                      ),
                      pw.TextSpan(
                        text: customerAddress,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.normal,
                          fontSize: 10,
                        ),
                      ),
                    ])),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _contentFooter(pw.Context context) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 2,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Thank you for your business',
                style: pw.TextStyle(
                  color: _darkColor,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Container(
                margin: const pw.EdgeInsets.only(top: 20, bottom: 8),
                child: pw.Text(
                  'Payment Info:',
                  style: pw.TextStyle(
                    color: baseColor,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Text(
                paymentInfo,
                style: const pw.TextStyle(
                  fontSize: 8,
                  lineSpacing: 5,
                  color: _darkColor,
                ),
              ),
            ],
          ),
        ),
        pw.Expanded(
          flex: 1,
          child: pw.DefaultTextStyle(
            style: const pw.TextStyle(
              fontSize: 10,
              color: _darkColor,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.DefaultTextStyle(
                  style: pw.TextStyle(
                    fontSize: 16,
                    color: baseColor,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Net Payable: '),
                      pw.Text(_formatCurrency(_total)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _termsAndConditions(pw.Context context) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border(top: pw.BorderSide(color: accentColor)),
                ),
                padding: const pw.EdgeInsets.only(top: 10, bottom: 4),
                child: pw.Text(
                  'Terms & Conditions',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: baseColor,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Text(
                pw.LoremText().paragraph(40),
                textAlign: pw.TextAlign.justify,
                style: const pw.TextStyle(
                  fontSize: 6,
                  lineSpacing: 2,
                  color: _darkColor,
                ),
              ),
            ],
          ),
        ),
        pw.Expanded(
          child: pw.SizedBox(),
        ),
      ],
    );
  }

  pw.Widget _contentTable(pw.Context context) {
    const tableHeaders = [
      'Type',
      // 'Item Description',
      // 'Price',
      // 'Quantity',
      'Amount'
    ];

    return pw.Table.fromTextArray(
      border: pw.TableBorder.all(
          color: accentColor, width: .5, style: pw.BorderStyle.solid),
      cellAlignment: pw.Alignment.centerLeft,
      headerDecoration: pw.BoxDecoration(
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
          color: baseColor),
      headerHeight: 25,
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        // 1: pw.Alignment.centerLeft,
        // 2: pw.Alignment.centerRight,
        // 3: pw.Alignment.center,
        1: pw.Alignment.centerRight,
      },
      headerStyle: pw.TextStyle(
          color: _baseTextColor, fontSize: 10, fontWeight: pw.FontWeight.bold),
      cellStyle: const pw.TextStyle(color: _darkColor, fontSize: 10),
      rowDecoration: pw.BoxDecoration(
          border:
              pw.Border(bottom: pw.BorderSide(color: accentColor, width: .5))),
      headers: List<String>.generate(
          tableHeaders.length, (col) => tableHeaders[col]),
      data: List<List<String>>.generate(
        products.length,
        (row) => List<String>.generate(
            tableHeaders.length, (col) => products[row].getIndex(col)),
      ),
    );
  }
}

String _formatCurrency(double amount) {
  return '\$${amount.toStringAsFixed(2)}';
}

String _formatDate(DateTime date) {
  final format = DateFormat.yMMMd('en_US');
  return format.format(date);
}

class Product {
  const Product(
    this.sku,
    this.productName,
    this.price,
    this.quantity,
  );

  final String sku;
  final String productName;
  final double price;
  final int quantity;
  double get total => price * quantity;

  String getIndex(int index) {
    switch (index) {
      case 0:
        return sku;
      // case 1:
      //   return productName;
      // case 2:
      //   return _formatCurrency(price);
      // case 3:
      //   return quantity.toString();
      case 1:
        return _formatCurrency(total);
    }
    return '';
  }
}
