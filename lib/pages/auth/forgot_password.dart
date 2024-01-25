import "package:flutter/material.dart";
import "package:flutter_svg/svg.dart";
import "package:heartless/backend/controllers/patient_controller.dart";
import "package:heartless/main.dart";
import 'package:heartless/shared/models/patient.dart';
import "package:heartless/shared/provider/auth_notifier.dart";
import 'package:heartless/widgets/miscellaneous/left_trailing_button.dart';
import 'package:heartless/widgets/miscellaneous/right_trailing_button.dart';
import "package:heartless/shared/provider/widget_provider.dart";
import 'package:heartless/widgets/auth/text_input.dart';

class ForgotPassPage extends StatefulWidget {
  const ForgotPassPage({super.key});

  @override
  State<ForgotPassPage> createState() => _ForgotPassPageState();
}

class _ForgotPassPageState extends State<ForgotPassPage> {
  final PatientController _patientController = PatientController();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _phoneController.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double svgHeight = 0.15 * screenHeight;
    double screenWidth = MediaQuery.of(context).size.width;
    WidgetNotifier widgetNotifier =
        Provider.of<WidgetNotifier>(context, listen: false);
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);

    void goBack() {
      Navigator.pop(
          context); //! idk what happens if this is the first page i.e. nothing to pop
    }

    void goToVerificationPage() {
      Navigator.pushNamed(context, '/verification'); // todo : add correct name
    }

    Future<void> submitForm() async {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        Patient? patient = Patient();
        patient.email = _emailController.text;
        patient.phone = _phoneController.text;
        authNotifier.setPatient(patient);
        bool success = false;
        if (widgetNotifier.emailPhoneToggle) {
          success = await _patientController.sendResetEmail(authNotifier);
        } else {
          success = await _patientController.sendResetEmail(authNotifier);
        }
        if (success) {
          goToVerificationPage();
        }
      }
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Positioned(
              left: 0,
              bottom: 0,
              child: SvgPicture.asset(
                'assets/Icons/blueHeart.svg',
                height: screenHeight * 0.2,
              ),
            ),
            // Positioned(
            //   left: 20,
            //   top: 40,
            //   child: IconButton(
            //     icon: const Icon(Icons.brightness_6), // Icon to toggle theme
            //     onPressed: () {
            //       themeProvider.toggleThemeMode();
            //     },
            //   ),
            // ),
            Container(
              height: screenHeight,
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 120,
                  ),
                  SvgPicture.asset(
                    'assets/illustrations/forgot_pass.svg',
                    height: svgHeight,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Forgot Your Password?',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: screenWidth * 0.8,
                    child: Text(
                      '''Enter your email we will send you a confirmation code''',
                      style: Theme.of(context).textTheme.labelMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: TextFieldInput(
                      textEditingController: _emailController,
                      hintText: 'Enter your email',
                      labelText: 'email',
                      startIcon: 'assets/Icons/Email.svg',
                      textInputType: TextInputType.emailAddress,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                            onTap: goBack, child: const LeftButton()),
                        GestureDetector(
                            onTap: submitForm,
                            child: const RightButton(text: 'Reset')),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
