import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:login_page/cropclassification.dart';
import 'package:login_page/login.dart';
import 'package:login_page/sarimagecolor.dart';

class HomePage extends StatefulWidget {
  final bool isPhoneRegistration;
  const HomePage({super.key, required this.isPhoneRegistration});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = '';
  String profileImageUrl = '';
  bool isLoading = true;
  bool isDarkMode = false; // Toggle for dark mode
  bool isMenuOpen = false; // Track if the dropdown menu is open

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String email = user.email!;
        String documentId =
            widget.isPhoneRegistration ? email.substring(0, 10) : email;

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(documentId)
            .get();

        if (userDoc.exists) {
          setState(() {
            username = userDoc['Username'] ?? 'Unknown User';
            profileImageUrl = userDoc['Image'] ?? '';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> logOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  void toggleDarkMode() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  void navigateToScreen(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removed debug banner
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          actions: [
            IconButton(
              icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
              onPressed: toggleDarkMode,
            ),
            PopupMenuButton<String>(
              position: PopupMenuPosition.under,
              offset:
                  Offset(0, 40), // Adjusts how far the menu is below the AppBar
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (profileImageUrl.isNotEmpty)
                    CircleAvatar(
                      backgroundImage: NetworkImage(profileImageUrl),
                      radius: 16,
                    ),
                  const SizedBox(width: 8),
                  Container(
                    constraints: BoxConstraints(
                      maxWidth:
                          150, // Control the width of the profile text container
                    ),
                    child: Text(
                      username.isNotEmpty ? username : 'Loading...',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Icon(isMenuOpen
                      ? Icons.arrow_drop_up
                      : Icons
                          .arrow_drop_down), // Change arrow based on menu state
                ],
              ),
              onSelected: (value) {
                setState(() {
                  isMenuOpen = false; // Close the menu when an item is selected
                });
                if (value == 'signout') logOut();
              },
              onCanceled: () {
                setState(() {
                  isMenuOpen = false; // Close the menu when it is canceled
                });
              },
              onOpened: () {
                setState(() {
                  isMenuOpen = true; // Open the menu when triggered
                });
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'profile',
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text('Profile'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'signout',
                  child: ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Sign Out'),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: GridView(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio:
                        1 / 2, // Adjusted aspect ratio for taller cards
                  ),
                  children: [
                    _buildCard(
                      'SAR Image Colorization(pix2pix , GAN)',
                      'assets/images/satellite.png',
                      SARImageColorizationPage(),
                    ),
                    _buildCard(
                      'Crop Classification(VGG-16 , Deep Learning)',
                      'assets/images/crop.jpg',
                      CropClassificationPage(),
                    ),
                    // uncomment the below code for next mile stone
                    // _buildCard(
                    //   'Flood Detection',
                    //   'assets/images/floods.jpg',
                    //   FloodDetectionPage(),
                    // ),
                    // _buildCard(
                    //   'Disaster Managment',
                    //   'assets/images/disaster2.jpg',
                    //   DisasterManagementPage(),
                    // ),
                  ],
                ),
              ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFooterIcon(Icons.home, 'Home', () {}),
              _buildFooterIcon(Icons.search, 'Search', () {}),
              _buildFooterIcon(Icons.notifications, 'Notifications', () {}),
              _buildFooterIcon(Icons.account_circle, 'Account', () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String title, String imagePath, Widget screen) {
    return GestureDetector(
      onTap: () => navigateToScreen(screen),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover, // Cover the entire card with the image
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Optional: Dark overlay for better contrast
              Container(
                color: Colors.black.withOpacity(0.4),
                padding: const EdgeInsets.all(10),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterIcon(IconData icon, String label, VoidCallback onTap) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(icon, size: 30),
              onPressed: onTap,
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
