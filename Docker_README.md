# Clone SplashKit Repositories

1. Clone the `splashkit-core` repository

   ```sh
   git clone https://github.com/thoth-tech/splashkit-core.git
   ```


# Install Docker

## Ubuntu

https://docs.docker.com/engine/install/

```sh
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

```

## macOS and Windows

Please follow the instructions from the official [website](https://www.docker.com/products/docker-desktop/).

# To Build
1. Change directory to translator repo/folder.
```sh
cd tools/translator/
```
2. Run the following command in the `splashkit-translator` root directory


```sh
docker compose build
```

# To Run

It is advisable to translate into a limited set of languages. Translating to all available languages
will take some time to complete.

```sh
docker compose run --rm headerdoc cliv,cpp,pascal,python,csharp,docs

Translating SplashKit Core to clib,cpp,pascal,python,csharp,docs
Executing clib translator...
Done!
Output written!

Executing cpp translator...
Done!
Output written!

Executing pascal translator...
Done!
Output written!

Executing python translator...
Done!
Output written!

Executing csharp translator...
Done!
Output written!

Executing docs translator...
Done!
Output written!
Place `api.json` in the `data` directory of the `splashkit.io` repo
```

By default, this expects the splashkit-core folder is located under the same location as the splashkit-translator folder.

```sh
.
├── splashkit-core/tools/translator

```

The translated code will be available under splashkit-core/generated folder on the host machine.
