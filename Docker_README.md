# Clone SplashKit Repositories

1. Clone the `splashkit-core` repository

   ```sh
   git clone https://github.com/thoth-tech/splashkit-core.git
   ```

2. Clone the `splashkit-translator` repository

   ```sh
   git clone https://github.com/thoth-tech/splashkit-translator.git
   ```

# Install Docker

## Ubuntu

https://docs.docker.com/engine/install/

```sh
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
```

## macOS and Windows

Please follow the instructions from the official [website](https://www.docker.com/products/docker-desktop/).

# To Build

Run the following command in the `splashkit-translator` root directory

```sh
docker compose build
```

# To Run

It is advisable to translate into a limited set of languages. Translating to all available languages
will take some time to complete.

```sh
docker compose run --rm headerdoc python,csharp

Translating SplashKit Core to python,csharp
Executing python translator...
Done!
Output written!

Executing csharp translator...
Done!
Output written!
```

By default, this expects the `splaskit-core` folder is located under the same
location as the `splashkit-translator` folder.

```sh
.
├── splashkit-core
└── splashkit-translator
```

The translated code will be available under `splashkit-code/generated` folder on the host machine.
