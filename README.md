# Real-time genetic algorithm library for the Godot game engine.

An implementation of rtNEAT by Kenneth O. Stanley for neuroevolution in a real-time, persistent environment within the Godot game engine. Building on concepts from adaptations like <i>"SharpNEAT"</i> and <i>"NEAT for Godot"</i>, this project shifts to a pooled evaluation format. This approach keeps genomes continuously active in the environment, with real-time swapping of underperforming genomes for ongoing optimization. 

This project is written in GDScript for Godot 4.2.1

This project is not final and has missing aspects. (see: <i>"What is missing"</i>)

## FAQ

- Where to find the engine: [https://godotengine.org/]
- Where to find the binary: [link to release]
- How to use this for a project: [link to wiki]
- What are the demos: [link to wiki]

## What is missing...

General:
- Saving and loading genomes
- Saving and loading scenes


Special thanks to Paul Straberger for the first <i>NEAT for Godot</i> implementation.
This project reuses the config loading and low-level datastructures from <i>NEAT for Godot</i>
