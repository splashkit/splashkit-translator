# Clone SplashKit Repositories
1. Clone the SplashKit-Core Repository
    git clone https://github.com/thoth-tech/splashkit-core.git

2. Clone the SplashKit-Translator Repository
    git clone https://github.com/thoth-tech/splashkit-translator.git

# Install Docker
https://docs.docker.com/engine/install/

## Ubuntu
```sh
sudo apt-get update
```
```sh 
sudo apt-get install docker-ce docker-ce-cli containerd.io
```

# To Build

Run the following command in the `splashkit-translator` root directory

```sh
docker build --tag headerdoc -f Dockerfile .
```

# To Run

```sh
docker run --rm -v <absolute path to splashkit-core>:/splashkit/ headerdoc ./translate -i /splashkit/ -o /splashkit/generated -g cpp,docs,clib,python,pascal,csharp
```