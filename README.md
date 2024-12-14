# Endless Match3

### Description:

This project is my [CS50x](https://cs50.harvard.edu/x/2024/) final submission: a simple yet engaging Match3 puzzle 
game developed with the **Godot Engine** and written in **GDScript**. The game demonstrates the programming and 
problem-solving skills I gained throughout the course.

### Classic gameplay
- Match three or more tiles of the same type to score points.
- Tiles fall into place after matches, with new tiles spawning to keep the board full.

Gameplay video on [YouTube](https://youtube.com/shorts/FJI9hOVIjZY).

![cs50-fp-match3.gif](doc/cs50-fp-match3.gif)

## 🛠️ Installation
1. Visit the game’s [itch.io page](https://raydtutto.itch.io/cs50x-fp-match3).
2. Play directly in your browser (desktop or mobile) or download the game files.

## 🦆 How to Play
1. Start the game from the Homepage:
    - Check your best score.
    - Toggle music on or off.
2. On the Game Board:
    - Swap adjacent tiles by clicking, dragging, or swiping to form matches of three or more.
    - Clear matches to score points while new tiles fall into place.
3. Aim to achieve the highest score possible!

## ✨ Key Features

### Scenes
1. **Homepage**:
    - Displays the best score.
    - Allows users to toggle background music on or off.
2. **Game Board**:
    - Interactive tile-based gameplay with smooth animations.
    - Ability to easily adjust height and columns through the engine without any hassle.

### Controls
- Compatible with both **mouse** (left-click only) and **touchscreen**.
- Users can _swipe_ tiles on touchscreen devices or _click-and-drag_ on desktop.

### Audio
- Looped background music with a toggle option.
- Sound effects play on tile interactions (e.g., touch, click).

### Platform Compatibility
- Works on desktop and mobile devices via **WebAssembly**.
- Optimized for **iPhone**, **iPad**, and web browsers.
- Fully resizable to support both vertical and horizontal orientations without breaking proportions.

### User Experience
- Prevents multiple simultaneous clicks.
- Restricts interaction to left mouse clicks for desktops.
- Disables board interaction during animations to ensure smooth gameplay.
- Ensures the board is not generated without matches.
- Shuffles the board if no possible matches are available.
- Once the maximum score is reached, further score updates are disabled.

## ⚙️ Technologies Used
- **[Godot Engine 4](https://godotengine.org/)** — a free and open-source game engine for creating 2D and 3D games.
- **GDScript** — the scripting language used in Godot to implement game logic.

## 📁 Project Structure
- **/assets**: Sprites, background music and sound effects.
- **/scripts**: GDScript files for core game logic.
- **/scenes**: Godot scene files for Homepage and Game Board.

## 📚 Resources
- https://docs.godotengine.org
- [Bitlytic](https://www.youtube.com/@Bitlytic)
- [Brackeys](https://www.youtube.com/@Brackeys)
- [CocoCode](https://www.youtube.com/@CocoCode)
- [Godotneers](https://www.youtube.com/@godotneers)
- [MisterTaftCreates](https://www.youtube.com/@MisterTaftCreates)

## 🌈 Acknowledgments
- [**CS50 team**](https://cs50.harvard.edu/x/2024/): For offering an exceptional introduction to computer science and programming.
- [**FesliyanStudios.com**](https://www.FesliyanStudios.com): For providing royalty-free music.
- [**Freesound.org**](https://freesound.org): For providing royalty-free sound effects:
  - Rattle Toy infant stuffet animal_1.L.wav by AGFX -- https://freesound.org/s/42938/ -- License: Attribution 4.0
  - Bobby-Car Hooting by HenryG -- https://freesound.org/s/339788/ -- License: Creative Commons 0
  - Squeaky Toy #3 by Breviceps -- https://freesound.org/s/483921/ -- License: Creative Commons 0
  - toy trumpet by Loredenii -- https://freesound.org/s/746573/ -- License: Attribution 4.0
  - Hi-Tech Error Alert 1 by miksmusic -- https://freesound.org/s/497710/ -- License: Attribution 3.0
  - tap.wav by supaFrycook2 -- https://freesound.org/s/242737/ -- License: Attribution 3.0

This project is dedicated to CS50 Rubber Ducky 🦆 Quack!

## 📝 Feedback
Your feedback is highly appreciated! Share your thoughts or report issues on the game’s [itch.io page](https://raydtutto.itch.io/cs50x-fp-match3).

## 📄 License
This project is intended for educational purposes only. All code and artwork are original creations. Audio files are used under their respective licenses.
