# SplashKit C# Translator

Instruction on how to run Splashkit C# Translator's output and use it to a c# project.

# Contents

- [Splashkit C# Translator](#splashkit-c-translator)
- [Contents](#contents)
- [Splashkit C# Translator Guidelines](#csharp-translator-guidelines)
    - [Commands](#commands)
    - [Running](#running)
    - [Integrating C# file](#integrate-c-file)



# Csharp Translator Guidelines



## Commands

Command used to run Splashkit Translator to C#

sudo docker run --rm -v /home/<username>/splashkit-core:/splashkit headerdoc ./translate -i /splashkit/ -o /splashkit/generated -g csharp

The output will show up in splashkit/generated in a C# file which can be executed as a normal C# file. 

## Running

 For ubuntu : 

 - Update local system : sudo apt-get update
 - Install mono-runtime to run Compiled C# File : sudo apt-get install mono-runtime
 - Install mono-mcs to Compile C# file : sudo apt-get install mono-mcs
 - Change location to where C# is located : cd <location>
 - Compile C# File : mcs <filename>
 - Run Compiled C# File : mono <filename>

## Integrate C# file


