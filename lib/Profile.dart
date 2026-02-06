import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'image_provider.dart';

import 'Profile_Pages/Account.dart';
import 'Profile_Pages/Data.dart';
import 'Profile_Pages/Message.dart';
import 'Profile_Pages/security.dart';

class Profile extends StatefulWidget {
  const Profile({super.key, required this.userId});

  final String userId;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      Provider.of<ImageProviderModel>(context, listen: false)
          .setImageFile(File(pickedFile.path));
    }
  }

  Future<void> _inviteFriends() async {
    await Share.share(
      "Expense Tracker Pro\n\nDownload: https://github.com/Aryaman-CSE/Expense_tracker",
      subject: "Expense Tracker Pro",
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = Provider.of<ImageProviderModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            CustomPaint(
              size: Size(
                MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height,
              ),
              painter: CurvedRectanglePainter(),
            ),

            // Main content scrollable
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                children: [
                  const SizedBox(height: 18),

                  // Top bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        FloatingActionButton(
                          mini: true,
                          onPressed: () => Navigator.pop(context),
                          backgroundColor:
                              const Color.fromRGBO(66, 150, 144, 1),
                          foregroundColor: Colors.white,
                          elevation: 6,
                          child: const Icon(Icons.arrow_back_ios_new),
                        ),
                        const Spacer(),
                        const Text(
                          "Profile",
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 44),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Profile image
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 110,
                      width: 110,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black12,
                      ),
                      child: ClipOval(
                        child: imageProvider.imageFile != null
                            ? Image.file(
                                imageProvider.imageFile!,
                                fit: BoxFit.cover,
                              )
                            : const Icon(
                                Icons.camera_alt,
                                size: 48,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Card for options
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _profileTile(
                            icon: Icons.person_add_alt_1,
                            iconColor: Colors.green,
                            title: "Invite Friends",
                            onTap: _inviteFriends,
                          ),
                          _divider(),
                          _profileTile(
                            icon: Icons.account_circle_outlined,
                            iconColor: Colors.black,
                            title: "Account Info",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Account(),
                                ),
                              );
                            },
                          ),
                          _divider(),
                          _profileTile(
                            icon: Icons.message_outlined,
                            iconColor: Colors.black,
                            title: "Message Centre",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Message(),
                                ),
                              );
                            },
                          ),
                          _divider(),
                          _profileTile(
                            icon: Icons.security_outlined,
                            iconColor: Colors.black,
                            title: "Login and Security",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Security(),
                                ),
                              );
                            },
                          ),
                          _divider(),
                          _profileTile(
                            icon: Icons.privacy_tip_outlined,
                            iconColor: Colors.black,
                            title: "Data and Privacy",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Data(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return const Divider(height: 1, thickness: 0.6, color: Colors.black12);
  }

  Widget _profileTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: iconColor, size: 28),
      title: Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}

class CurvedRectanglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color.fromRGBO(66, 150, 144, 1)
      ..style = PaintingStyle.fill;

    Path path = Path();
    double curveHeight = size.height * 0.3;

    path.moveTo(0, 0);
    path.lineTo(0, curveHeight);
    path.quadraticBezierTo(
      size.width / 2,
      curveHeight + size.height * 0.1,
      size.width,
      curveHeight,
    );
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
