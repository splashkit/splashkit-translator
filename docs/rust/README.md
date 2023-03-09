# Rust Usage

## Summary

This article covers how to setup Rust, import and link the `splashkit.rs` file and start development.

## Setup Rust

### Ubuntu

#### Install Rust

```shell
curl https://sh.rustup.rs -sSf | sh

source $HOME/.cargo/env
```

#### Install Cmake

```shell
sudo apt install build-essential cmake
```

## Linking the library

Create a reference to the `splashkit.rs` file. Note the directory is relative to the current folder directory.

```rust
#[path = "./splashkit-core/generated/rust/splashkit.rs"]
```

Reference the module that will be used.

```rust
mod splashkit;
```

Add a using statement so you do not require referencing the module repeatedly.

```rust
use splashkit::say_yay();
```

## Test

TBC
