**NOTE: Originally created as a school group project for CS 21 of Computer Science in UP Diliman, adapted and maintained as part of my personal portfolio.**

# Minecraft Eyyy – Arch-242 Assembly Project

## Team Members
- Alcancia, Dean Robin A. 
- Dianito, Levie M. 
- Dollison, Hedelito III M. 
- Junio, Ivan Ahron L.

## Contributions
All team members participated equally in both Part A and Part B of the project.

---
## How to Use

### Part A1 – Assembling a File

You can assemble a `.asm` file using `Assemble.py` for convenience. Just replace the parameters of the assemble function to your `.asm` file and your desired output format. It will output a `instr.txt` file ready to use in Logisim with a "v3.0 hex bytes" header. However, all `.byte` directives will be in a separate `mem.txt` file.

### Part A2 and A3 - Running Snake

To run the assembly emulator for Part A2, you can open a terminal and use this command call:

```bash
python parta2/Part_A2.py <.asm file>
```

As an example, you can use this to run the assembly Snake game for Part A3:

```bash
python parta2/Part_A2.py parta3/Snake.asm
```

Move the snake with W,A,S,D keys, and eat the apple to score up. Hitting the border or the snake's body loses the game.   
When you reach the max score of 15, the game will freeze (shutdown) to indicate winning. (Press Q to quit.)

### Part B - Arch 242 Snake Simulator

When using branch instructions, immediate PC values are supported, however Two-byte Instructions count as 2 PC increments. So it is generally advisable to use labels instead. There is also a working simulation of snake preloaded into the `Part_B.circ` file with input buttons.
