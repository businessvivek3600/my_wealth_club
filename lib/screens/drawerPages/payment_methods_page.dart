import 'package:flutter/material.dart';
import '/providers/auth_provider.dart';
import '/sl_container.dart';
import '/utils/color.dart';
import '/utils/picture_utils.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({Key? key}) : super(key: key);

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  TextEditingController usdtt_address = TextEditingController();
  TextEditingController usdtb_address = TextEditingController();
  TextEditingController account_holder_name = TextEditingController();
  TextEditingController account_number = TextEditingController();
  TextEditingController ifsc_code = TextEditingController();
  TextEditingController bank = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController emailOTP = TextEditingController();

  initiate() {
    var provider = sl.get<AuthProvider>();
    provider.commissionWithdrawal().then((value) {
      setState(() {
        usdtt_address = TextEditingController(text: provider.usdtt_address);
        usdtb_address = TextEditingController(text: provider.usdtb_address);
        account_holder_name =
            TextEditingController(text: provider.account_holder_name);
        account_number = TextEditingController(text: provider.account_number);
        ifsc_code = TextEditingController(text: provider.ifsc_code);
        bank = TextEditingController(text: provider.bank);
        address = TextEditingController(text: provider.address);
      });
    });
  }

  @override
  void initState() {
    initiate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(title: titleLargeText('Payment Methods', context)),
      body: Container(
        height: double.maxFinite,
        width: double.maxFinite,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: userAppBgImageProvider(context),
            fit: BoxFit.cover,
            opacity: 0.7,
          ),
        ),
        child: buildBody(size.height),
      ),
      bottomNavigationBar: buildBottomButton(context),
    );
  }

  Padding buildBottomButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10, bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        // height: 70,
        padding: const EdgeInsets.all(2),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(),
                onPressed: () {
                  var provider = sl.get<AuthProvider>();
                  provider.updateCommissionWithdrawal(
                      usdtt_address.text,
                      usdtb_address.text,
                      account_holder_name.text,
                      account_number.text,
                      ifsc_code.text,
                      bank.text,
                      address.text,
                      emailOTP.text);
                },
                child:
                    bodyMedText('Update', context, textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBody(double height) {
    return Consumer<AuthProvider>(
      builder: (context, provider, child) {
        return !provider.loadingCommissionWithdrawal
            ? ListView(
                padding: EdgeInsets.all(8),
                children: [
                  fieldTitle('USDT BEP20 Address'),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          enabled: true,
                          controller: usdtb_address,
                          cursorColor: Colors.white,
                          style: TextStyle(color: Colors.white),
                          decoration:
                              InputDecoration(hintText: 'USDT BEP20 Address'),
                        ),
                      ),
                    ],
                  ),
                  height20(height * 0.01),
                  fieldTitle('USDT TRC20 Address'),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          enabled: true,
                          controller: usdtt_address,
                          cursorColor: Colors.white,
                          style: TextStyle(color: Colors.white),
                          decoration:
                              InputDecoration(hintText: 'USDT TRC20 Address'),
                        ),
                      ),
                    ],
                  ),
                  height20(height * 0.02),
                  bodyMedText(
                      'Bank withdrawals are only available to UAE, UK and Europe members !!',
                      context,
                      color: appLogoColor),
                  height20(height * 0.01),
                  fieldTitle('Account Holder Name'),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          enabled: true,
                          controller: account_holder_name,
                          cursorColor: Colors.white,
                          style: TextStyle(color: Colors.white),
                          decoration:
                              InputDecoration(hintText: 'Account Holder Name'),
                        ),
                      ),
                    ],
                  ),
                  height20(height * 0.01),
                  fieldTitle('Account/IBAN'),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          enabled: true,
                          controller: account_number,
                          cursorColor: Colors.white,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(hintText: 'Account/IBAN'),
                        ),
                      ),
                    ],
                  ),
                  height20(height * 0.01),
                  fieldTitle('Sort Code/ Swift Code/ BIC'),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          enabled: true,
                          controller: ifsc_code,
                          cursorColor: Colors.white,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              hintText: 'Sort Code/ Swift Code/ BIC'),
                        ),
                      ),
                    ],
                  ),
                  height20(height * 0.01),
                  fieldTitle('Bank Name'),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          enabled: true,
                          controller: bank,
                          cursorColor: Colors.white,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(hintText: 'Bank Name'),
                        ),
                      ),
                    ],
                  ),
                  height20(height * 0.01),
                  fieldTitle('Account Holder Address'),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          enabled: true,
                          controller: address,
                          cursorColor: Colors.white,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                              hintText: 'Account Holder Address'),
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Colors.white),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                          onPressed: () => sl
                              .get<AuthProvider>()
                              .getCommissionWithdrawalsEmailOtp(),
                          child: Text('Get Email OTP',
                              style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline)))
                    ],
                  ),
                  Divider(color: Colors.white),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      fieldTitle('Email OTP (One Time Password)'),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          enabled: true,
                          controller: emailOTP,
                          cursorColor: Colors.white,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'ex:- 123456',
                          ),
                        ),
                      ),
                    ],
                  ),
                  height20(height * 0.01),
                  height20(height * 0.01),
                  height20(height * 0.01),
                ],
              )
            : Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
      },
    );
  }

  Widget fieldTitle(String title) {
    return Column(
      children: [
        Row(
          children: [
            bodyLargeText(title, context, color: Colors.white70),
          ],
        ),
        height10(),
      ],
    );
  }
}
