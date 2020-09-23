# To Build
Run the following command in the translator directory
` docker build --tag headerdoc -f Dockerfile .`

# To Run
`docker run --rm -v <absolute path to splashkit-core>:/splashkit/ headerdoc ./translate -i /splashkit/ -o /splashkit/generated -g cpp,docs,clib,python,pascal,csharp`
