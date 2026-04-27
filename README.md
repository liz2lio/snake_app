# Snake & Match

Reviving the most popular cellular game in the 90s but with an extra challenge.

Play here << https://liz2lio.github.io/snake_app >>

Game Objectives:
The primary goal is to achieve the highest possible score by balancing survival with strategic color-matching. You must navigate a high-speed environment where the snake's physical length is both a score multiplier and an obstacle.

Core Game Mechanics
1. Movement and Navigation 
    + Desktop users can use keyboard arrow keys for navigation while mobile users can use a D-Pad keypad
    + No wall boundaries. The snake can exit the opposite side

2. Scoring and Collection
    + "Food" spawns at random coordinates with a changing color palette.
    + Each food item exists for only 10 seconds. If not consumed within the timeframe, it despawns and relocates
    + Every successful consumption awards 10 points and appends a segment to the snake

3. The "Triple-Match" Strategy
    + If the snake consumes 3 items of the same color in a row, the player is awarded 50 points
    + Upon triple match, those 3 segments are purged from the snake's body. This shortens the snake, making it easier to navigate and reducing the risk of self-collision

4. Progress Difficulty 
    + The game employs a linear speed increase. Every time a food is eaten, the snake's base movement increases.
    + Level selection:
        -Easy - Relaxed movement for beginners
        -Moderate - The standard competitive experience
        -Hard - High-velocity start for expert players.

5. Persistence and Competitive Edge
    + High-Score tracking - the system utilizes local storage to persist the player's personal best.
    + Game State Saving - Your current game progress is automatically saved to local storage, allowing you to continue playing even after closing and reopening the browser. The save state includes your snake's position, score, speed, and more. The game resumes from where you left off when you return.

Build With
    + Flutter - Cross-platform UI toolkit
    + Flame Engine - a Flutter game engin
    + Share Preferences - For local data persistence
    + Dart - For high-performance, object-oriented logic

Project Structure
lib/
├── main.dart               # Entry point & Overlay management
├── snake_game.dart         # Core Game Engine & Logic
└── src/
    ├── config.dart         # Game constants (speed, colors, sizing)
    └── widgets/            # Decoupled UI Components
        ├── game_controls.dart  # Clustered D-Pad
        ├── game_menu.dart      # Start/GameOver/Win Screens
        └── score_card.dart     # Reactive HUD Score

How to Run Locally
1. Clone the repo:
   git clone https://github.com/liz2lio/snake_app.git

2. Install dependencies:
   flutter pub get

3. Run on Web:
   flutter run -d chrome

Key Challenge:
Navigating the snake by swiping was not very responsive and timely. I also had challenges designing the keypad because it does't appear in the correct area. Initially, it doesn't show up at all. Used Co-pilot to resolve this issue but the keypads were still out of place, so fixed the coordinates.

