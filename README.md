<div align="center">
  <a href="https://github.com/KirillTregubov/centipede">
    <img src="https://user-images.githubusercontent.com/31662934/179275707-879bd278-39f1-487c-8139-a1ca11f5ff9a.png" alt="Screenshot of the Centipede game" width="384" height="384">
  </a>
  <h3 align="center">CSC258 Winter 2021 Assembly Centipede Game</h3>

  <p align="center">
    A modified version of the popular 1980 Atari game Centipede built in MIPS assembly.
    <br />
    <a href="https://github.com/KirillTregubov/centipede/issues">Report a Bug</a>
  </p>
</div>

## Software Setup

Ensure you have the Java SE Development Kit (1.5 or later) installed by running `java -version` in a terminal or [download it here](https://www.oracle.com/java/technologies/downloads/).

To run this game you will need a MIPS Assembler and Runtime Simulator. This guide will assume you are using the MARS IDE which you can [download here](https://courses.missouristate.edu/KenVollmar/mars/download.htm).

## Quick Start

1. Open the `centipede.s` file in MARS.
2. Set up the display by clicking on **Tools** in the menu bar and selecting **Bitmap Display**.
   - Set the **Unit Width in Pixels** to `8`.
   - Set the **Unit Height in Pixels** to `8`.
   - Set the **Display Width in Pixels** to `512` (set by default).
   - Set the **Display Height in Pixels** to `512`.
   - Set the **Base address for display** to `0x10008000 ($gp)`.
   - Click the **Connect to MIPS** button once these are set.
3. Set up the keyboard by clicking on **Tools** in the menu bar and selecting **Keyboard and Display MMIO Simulator**.
   - Click the **Connect to MIPS** button.
   - When playing the game, make sure the bottom **KEYBOARD** input field is focused and reflecting your inputs.
4. Assemble the program by clicking on **Run** in the menu bar and selecting **Assemble**, or by clicking <img width="30" alt="the wrench and screwdriver button" src="https://user-images.githubusercontent.com/31662934/179269667-8d65be76-2a39-4ae9-b2f3-6854c4603c20.png"> in the tool bar.
5. Start the game by clicking on **Run** in the menu bar and selecting **Go**, or by clicking <img width="30" alt="the play button" src="https://user-images.githubusercontent.com/31662934/179270236-6963f77f-38a8-4242-a14e-36e0753a42e3.png"> in the tool bar.

## Controls
- `j` - move left
- `k` - move right
- `x` - shoot Dart
- `s` - start and retry
- `q` - quit

## Features
<ol>
<li> Animations
<ol type="a">
  <li>Continually repaints the screen with appropriate assets.</li>
  <li>Draws 10-segment Centipede (with a distinct cyan head segment, green body and zigzag movement), Bug Blaster (orange body with green eyes), Dart (blue block that move upwards), Mushrooms (brown blocks) and Fleas (purple blocks that move downwards).</li>
  <li>Once the Centipede reaches the bottom it invades the Bug Blaster's space.</li>
</ol>
</li>
<li> Core Gameplay Features
<ol type="a">
  <li>Mushrooms are randomly generated when the game starts.</li>
  <li>Fleas randomly spawn at the top and fall down, they have a chance of spawning a Mushroom while falling.</li>
  <li>The Centipede dies after 3 Dart hits, Fleas die and Mushrooms are destroyed after 1 Dart hit.</li>
  <li>Only one Dart can be travelling at a time.</li>
  <li>The Bug Blaster (player) loses a life when the Centipede or a Flea intersect with it.</li>
  <li>Start, Game Over and Retry screens help provide a better experience.</li>
</ol>
</li>
<li> Extra Features
<ol type="a">
  <li>A scoreboard is displayed on the top left of the screen, it increments by 10 when the Centipede dies, by 5 when a Flea dies, by 1 when a Mushroom is destroyed.</li>
  <li>The player has 5 lives and the number of lives is displayed on the top right of the screen, the game ends when all lives are exhausted.</li>
  <li>Important messages are displayed on the screen in text.</li>
</ol>
</li>
<li> Additional Information
<ul>
  <li>The direction constants are: 0 - North, 1 - East, 2 - South, 3 - West.</li>
</ul>
</li>
</ol>

## Known Issues
There is currently a known issue with version 4.5 of MARS (the latest as of writing) where the entire application freezes due to a threading issue - a deadlock caused by a function call. For a more detailed explanation along with a suggested fix, please [visit this article](https://dtconfect.wordpress.com/2013/02/09/mars-mips-simulator-lockup-hackfix/) by [dtConfect](https://github.com/dtConfect).
