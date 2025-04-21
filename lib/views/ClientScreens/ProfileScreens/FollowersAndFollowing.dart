import 'package:flutter/material.dart';
import '/controllers/Profiles/profile_controller.dart';
import '/controllers/Profiles/follow_controller.dart';
import '/models/Profiles/profile_response.dart';
import '/models/Profiles/follow_response.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '/controllers/authentication/auth_controller.dart';
import '/models/authentication/login_request_advanced.dart' as advanced;
import '/models/authentication/login_response.dart';

class FollowersAndFollowingScreen extends StatefulWidget {
  final int profileId;
  final String type;
  

  const FollowersAndFollowingScreen(
      {super.key, required this.profileId, required this.type});

  @override
  _FollowersAndFollowingScreenState createState() =>
      _FollowersAndFollowingScreenState();
}

class _FollowersAndFollowingScreenState
    extends State<FollowersAndFollowingScreen> {
  final String profileBaseUrl = dotenv.env['PROFILE_URL'] ?? '';
  final String authbaseUrl = dotenv.env['AUTH_URL'] ?? '';
  final _authBase = dotenv.env['AUTH_URL'] ?? '';
  late int selectedIndex;
  late FollowController _followController;
  late ProfileController _profileController;
  late AuthController _authController;
  List<ProfileResponse> users = [];

    String keycloakUserId = '';
  @override

  void initState() {
    super.initState();
    selectedIndex = widget.type == 'following' ? 1 : 0;
    _followController = FollowController(baseUrl: profileBaseUrl);
    _profileController = ProfileController(baseUrl: profileBaseUrl);
    _authController = AuthController(baseUrl: _authBase);

    _authController.getKeycloakUserId().then((id) {
      keycloakUserId = id;
    });

    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      List<FollowResponse> followList = selectedIndex == 0
          ? await _followController.listFollowers(widget.profileId)
          : await _followController.listFollowed(widget.profileId);

      List<ProfileResponse> profiles = [];
      for (FollowResponse follow in followList) {
        ProfileResponse profile = await _profileController.getProfilebyid(
          selectedIndex == 0
              ? follow.followerId.toString()
              : follow.followedId.toString(),
        );
        profiles.add(profile);
      }

      setState(() {
        users = profiles;
      });
    } catch (e) {
      print('Failed to load users: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguidos y Seguidores'),
        backgroundColor: const Color(0xFF129575),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 23),
            child: Column(
              children: [
                FollowersFollowingTabs(
                  selectedIndex: selectedIndex,
                  onTabSelected: (index) {
                    setState(() {
                      selectedIndex = index;
                      _fetchUsers();
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FollowersFollowingContent(
              users: users,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color.fromARGB(255, 83, 83, 83),
        unselectedItemColor: const Color.fromARGB(255, 83, 83, 83),
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/dashboard');
              break;
            case 1:
              Navigator.pushNamed(context, '/recipe_search');
              break;
            case 2:
              Navigator.pushNamed(context, '/create');
              break;
            case 3:
              Navigator.pushNamed(context, '/shopping_list');
              break;
            case 4:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Publicar'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Compras'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class FollowersFollowingTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const FollowersFollowingTabs({
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildTab('Seguidores', 0),
        _buildTab('Siguiendo', 1),
      ],
    );
  }

  Widget _buildTab(String label, int index) {
    return GestureDetector(
      onTap: () => onTabSelected(index),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: selectedIndex == index
                  ? const Color(0xFF129575)
                  : Colors.grey,
            ),
          ),
          if (selectedIndex == index)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 60,
              color: const Color(0xFF129575),
            ),
        ],
      ),
    );
  }
}

class FollowersFollowingContent extends StatelessWidget {
  final List<ProfileResponse> users;

  const FollowersFollowingContent({
    required this.users,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: user.profilePhoto != null
                ? NetworkImage(user.profilePhoto!)
                : AssetImage('assets/default_profile.png') as ImageProvider,
          ),
          title: Text('${user.firstName} ${user.lastName}'),
          trailing: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF129575), // Background color
              foregroundColor: Colors.white, // Text color
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 1), // Smaller padding
              textStyle: const TextStyle(fontSize: 13), // Smaller font size
            ),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/public_profile',
                arguments: {'profile_id': user.profileId},
              );
            },
            child: const Text('Ver perfil'),
          ),
        );
      },
    );
  }
}
