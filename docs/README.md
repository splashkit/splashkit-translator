# SplashKit Translator

## Summary
The SplashKit translator is a Ruby application that translates C++ input files (*.h) into a target language. The translator outputs a file in the target language that provides an interface between the target language and the SplashKit library. This file needs to be included as a reference/import/header in your project and allows access to the SplashKit methods. This provides a link to the SplashKit installation on the current machine. To a SplashKit project via a translated langauge SplashKit _must_ be installed.

## Contents
Current supported languages are:
- C#
- Pascal
- Python
- [Rust](/Rust/README.md)

## Usage
1. Install [SplashKit](SplashKit.io)
2. Clone SplashKit-translator and SplashKit-core repositories
3. Translate SplashKit-Core libraries to target language.
4. Create new project in target language.
5. Reference/import/include translator output in new project.
6. Run project.

## Docker

This project can be setup on any platform through the use of Docker containers. A docker file can be found in the root of the repository, information on how to get setup and running with can be found in [Docker_README.md](https://github.com/thoth-tech/splashkit-translator/blob/master/Docker_README.md)