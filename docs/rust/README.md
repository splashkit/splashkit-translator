# Rust Usage

## Summary
This article covers how to setup Rust, import and link the Splashkit.rs file and start development.

## Setup Rust
### Ubuntu
#### Install Rust
- curl https://sh.rustup.rs -sSf | sh
- source $HOME/.cargo/env
### Install Cmake
- sudo apt install build-essential
- sudo apt install cmake

## Linking the library

Create a reference to the splashkit.rs file. Note the directory is relative to the current folder directory.
```Rust
#[path = "./splashkit-core/generated/rust/splashkit.rs"]
```

Reference the module that will be used.
```Rust
mod splashkit;
```

Add a using statement so you do not require referencing the module repeatedly.
```Rust
use splashkit::say_yay();
```

## Test
TBC