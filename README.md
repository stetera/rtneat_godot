# Real-time genetic algorithm library for the Godot game engine.

An implementation of rtNEAT by Kenneth O. Stanley for neuroevolution in a real-time, persistent environment within the Godot game engine. Building on concepts from adaptations like <i>"SharpNEAT"</i> and <i>"NEAT for Godot"</i>, this project shifts to a pooled evaluation format. This approach keeps genomes continuously active in the environment, with real-time swapping of underperforming genomes for ongoing optimization. 

This project is written in GDScript for Godot 4.2.1
This project is tied to the Bachelors Thesis "Real-time genetic algorithm library for the Godot game engine" (TalTech, 2024)

## FAQ

See the wiki for general information: [wiki](https://github.com/stetera/rtneat_godot/wiki)

- About the engine see the official site [Godot](https://godotengine.org/) or the wiki [overview](https://github.com/stetera/rtneat_godot/wiki/About-Godot)
- How to use this for a project: [Usage](https://github.com/stetera/rtneat_godot/wiki/Usage)
- What are the demos: [Demos](https://github.com/stetera/rtneat_godot/wiki/About-the-Demos)

## What is missing...

- Saving and loading genomes
- Saving and loading scenes
- Binary with saving and loading


Special thanks to Paul Straberger for the first <i>NEAT for Godot</i> implementation.
This project reuses the config loading and low-level datastructures from <i>NEAT for Godot</i>
