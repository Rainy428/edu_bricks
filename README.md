# edu_nodes

Protected nodes for educational Luanti / Minetest worlds.

This mod provides nodes that **students cannot accidentally break**, while teachers can still remove or edit them.

---

## Features

* Protected stage brick
* Protected editable sign
* Protected torches
* Teacher-only pickup system
* Privilege-based permissions
* Click-through prevention when removing wall nodes

---

## Nodes

### Stage Brick

A protected brick block for building lesson stages.

Students cannot dig it.

Teachers can remove it with:

SHIFT + AUX1 + Left Click

---

### Sign

Protected sign with editable text.

Interaction:

| Action               | Result       |
| -------------------- | ------------ |
| Left click           | Read sign    |
| AUX1 + click         | Edit sign    |
| SHIFT + AUX1 + click | Pick up sign |

Maximum text length: **512 characters**

---

### Torch

Protected torch.

Supports floor, wall, and ceiling placement automatically.

Pickup:

SHIFT + AUX1 + Left Click

---

## Privileges

Teachers must have the privilege:

edu_teacher

Grant example:

/grant playername edu_teacher

Singleplayer automatically receives this privilege.

---

## Installation

Place the mod inside:

mods/

Example:

worlds/yourworld/worldmods/edu_nodes

Restart the game or server after installing.

---

## Dependencies

default

This mod reuses models, textures and sounds from the default game.

---

## Controls

Teacher pickup:

SHIFT + AUX1 + Left Click

Sign editing:

AUX1 + Left Click

---

## Purpose

Designed for **educational Luanti worlds** where maps must remain stable during lessons but teachers still need quick editing tools.

Examples:

* programming classes
* game design workshops
* logic lessons
* classroom demonstrations

---

## License

MIT License
