# To Build

Run the following command in the `splashkit-translator` root directory

```sh
docker build --tag headerdoc -f Dockerfile .
```

# To Run

```sh
docker run --rm -v <absolute path to splashkit-core>:/splashkit/ headerdoc ./translate -i /splashkit/ -o /splashkit/generated -g cpp,docs,clib,python,pascal,csharp
```
