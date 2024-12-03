# SplashKit Translator

<p align="left">
    <img width="150px" src="https://github.com/thoth-tech/.github/blob/main/images/splashkit.png"/>
</p>

### [Splashkit](https://github.com/splashkit/splashkit-translator) Stats

[![GitHub contributors](https://img.shields.io/github/contributors/splashkit/splashkit-translator?label=Contributors&color=F5A623)](https://github.com/splashkit/splashkit-translator/graphs/contributors)
[![GitHub issues](https://img.shields.io/github/issues/splashkit/splashkit-translator?label=Issues&color=F5A623)](https://github.com/splashkit/splashkit-translator/issues)
[![GitHub pull requests](https://img.shields.io/github/issues-pr/splashkit/splashkit-translator?label=Pull%20Requests&color=F5A623)](https://github.com/splashkit/splashkit-translator/pulls)
[![Forks](https://img.shields.io/github/forks/splashkit/splashkit-translator?label=Forks&color=F5A623)](https://github.com/splashkit/splashkit-translator/network/members)
[![Stars](https://img.shields.io/github/stars/splashkit/splashkit-translator?label=Stars&color=F5A623)](https://github.com/splashkit/splashkit-translator/stargazers)

### [Thoth Tech](https://github.com/thoth-tech/splashkit-translator) Stats

Thoth Tech is a people-focused educational technology company dedicated to empowering students and educators through innovative tools. As a capstone company in Deakin University's capstone subjects, Thoth Tech provides real-world learning opportunities and contributes significantly to projects like SplashKit, enhancing its capabilities and resources.

[![GitHub contributors](https://img.shields.io/github/contributors/thoth-tech/splashkit-translator?label=Contributors&color=F5A623)](https://github.com/thoth-tech/splashkit-translator/graphs/contributors)
[![GitHub issues](https://img.shields.io/github/issues/thoth-tech/splashkit-translator?label=Issues&color=F5A623)](https://github.com/thoth-tech/splashkit-translator/issues)
[![GitHub pull requests](https://img.shields.io/github/issues-pr/thoth-tech/splashkit-translator?label=Pull%20Requests&color=F5A623)](https://github.com/thoth-tech/splashkit-translator/pulls)
[![Forks](https://img.shields.io/github/forks/thoth-tech/splashkit-translator?label=Forks&color=F5A623)](https://github.com/thoth-tech/splashkit-translator/network/members)
[![Stars](https://img.shields.io/github/stars/thoth-tech/splashkit-translator?label=Stars&color=F5A623)](https://github.com/thoth-tech/splashkit-translator/stargazers)

The **SplashKit Translator** is a tool designed to convert the **SplashKit Core** C++ library into multiple programming languages, creating the necessary files and structures to make SplashKit accessible across different languages. This tool also generates the `api.json` file, which is used by **SKM (SplashKit Manager)** and the **SplashKit website** to provide API documentation and assist with managing the SDK.

## About

The SplashKit Translator simplifies the process of making the SplashKit library available in various programming languages by automating the translation of its C++ source code. Currently, it supports translation into the following languages:

- **YAML**
- **SKLIBC**
- **CPP (C++)**
- **Additional Languages** (Specify as needed)

This translator is essential for expanding the reach of SplashKit, enabling developers to use the SDK in their preferred language while maintaining consistency in functionality and API documentation.

## Features

- **Multi-Language Translation**: Converts SplashKit’s C++ codebase into multiple languages, ensuring compatibility and ease of use for developers in various environments.
- **Automated API Generation**: Creates an `api.json` file that serves as the core for SKM and the SplashKit website, providing a comprehensive reference for all available functions and classes.
- **Docker Support**: Easily set up and run the translator on any platform with Docker, simplifying the development and testing processes.

## Getting Started

For detailed instructions on setting up, building, and running the translator, refer to the **[CONTRIBUTING.md](CONTRIBUTING.md)** file. This file contains:

- Instructions for setting up dependencies across different operating systems.
- Details on running the translator with Docker for cross-platform compatibility.
- Documentation guidelines for maintaining consistent and comprehensive comments and attributes within the SplashKit codebase.

## Basic Usage

To translate SplashKit, navigate to the appropriate directory and run the translator with the desired input and output settings. Here’s a quick overview:

1. **Validate a Header File**:

   ```bash
   ./translate --validate --input /path/to/splashkit/coresdk/src/coresdk/audio.h
   ```

2. **Translate into Multiple Languages**:

   ```bash
   ./translate -i /path/to/splashkit -o ~/Desktop/translated -g YAML,SKLIBC,CPP
   ```

For a complete list of options and additional usage details, check the **[CONTRIBUTING.md](CONTRIBUTING.md)** file.

## Contributing

Contributions are welcome! If you would like to add support for additional languages, improve the translation accuracy, or enhance functionality, please follow the guidelines in **[CONTRIBUTING.md](CONTRIBUTING.md)**. Here, you’ll find information on:

- Code structure and organization
- Guidelines for documenting and structuring functions, enums, structs, and more
- Known issues and troubleshooting tips for contributors
