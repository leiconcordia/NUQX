import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/custom_footer_with_nav.dart';
import '../widgets/custom_header_with_title.dart';
import '../utils/custom_page_route.dart';
import 'confirmationticket_screen.dart';
import 'registrar_screen.dart';

class RequestDocumentScreen extends StatefulWidget {
  final String userName;
  final String? initialName;
  final String? initialStudentId;
  final String? initialDepartment;
  final String? initialConcern;

  const RequestDocumentScreen({
    super.key,
    required this.userName,
    this.initialName,
    this.initialStudentId,
    this.initialDepartment,
    this.initialConcern,
  });

  @override
  State<RequestDocumentScreen> createState() => _RequestDocumentScreenState();
}

class _RequestDocumentScreenState extends State<RequestDocumentScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController studentIdController;
  late TextEditingController amountController;
  late TextEditingController notesController;

  String selectedDocType = "Good Moral";
  String selectedPurpose = "Others";

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialName ?? '');
    studentIdController = TextEditingController(
      text: widget.initialStudentId ?? '',
    );
    amountController = TextEditingController(text: "₱100.00");
    notesController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    studentIdController.dispose();
    amountController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                const CustomHeaderWithTitle(title: "Request Document"),
                Positioned(
                  left: 14.w,
                  top: 17.h,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        noAnimationRoute(
                          RegistrarScreen(userName: widget.userName),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDropdown(
                          "Document Type*",
                          ["Good Moral", "Transcript of Records", "Diploma"],
                          selectedDocType,
                          (value) => setState(() => selectedDocType = value!),
                        ),
                        SizedBox(height: 16.h),
                        _buildTextField("Student ID*", studentIdController),
                        SizedBox(height: 16.h),
                        _buildTextField("Full Name*", nameController),
                        SizedBox(height: 16.h),
                        _buildDropdown(
                          "Purpose of Request*",
                          ["Scholarship", "Employment", "Others"],
                          selectedPurpose,
                          (value) => setState(() => selectedPurpose = value!),
                        ),
                        SizedBox(height: 16.h),
                        _buildTextField("Amount*", amountController),
                        SizedBox(height: 16.h),
                        _buildTextField("Additional Notes", notesController),
                        SizedBox(height: 24.h),
                        _buildSubmitButton(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            CustomFooterWithNav(userName: widget.userName, activeTab: 'home',),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              vertical: 16.h,
              horizontal: 16.w,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.r),
              borderSide: BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.r),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.r),
              borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String value,
    void Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 6.h),
        DropdownButtonFormField<String>(
          value: value,
          dropdownColor: Colors.white, // Ensures dropdown popup is white
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              vertical: 16.h,
              horizontal: 16.w,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.r),
              borderSide: BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.r),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.r),
              borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
            ),
          ),
          items:
              items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item, style: TextStyle(fontSize: 14.sp)),
                );
              }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            noAnimationRoute(
              ConfirmationTicketScreen(
                userName: widget.userName,
                name: nameController.text,
                studentId: studentIdController.text,
                department: selectedDocType,
                concern: selectedPurpose,
              ),
            ),
            (route) => false,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade900,
          padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
        child: Text(
          "Submit",
          style: TextStyle(color: Colors.white, fontSize: 16.sp),
        ),
      ),
    );
  }
}
