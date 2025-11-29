part of 'pages.dart';

class MainPage extends StatelessWidget {
  // We receive the "shell" from the router
  final StatefulNavigationShell navigationShell;

  const MainPage({
    super.key, 
    required this.navigationShell
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body is now the "shell", which contains the current page (Home or International)
      body: navigationShell,
      
      bottomNavigationBar: BottomNavigationBar(
        // We ask the shell "Which tab is currently active?"
        currentIndex: navigationShell.currentIndex,
        
        // When clicked, we tell the shell to switch branches
        onTap: (index) {
          navigationShell.goBranch(
            index,
            // A common pattern to support switching to the initial location of the branch
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Domestic",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: "International",
          ),
        ],
      ),
    );
  }
}