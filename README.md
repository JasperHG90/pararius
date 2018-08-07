# Pararius updater

```bash
docker build . -t jhginn/pararius
```

```bash
docker run -v /Users/jasperginn/JDocs/pararius/data:/root/data --env-file env.list jhginn/pararius
```

```bash
docker run -v /Users/jasperginn/JDocs/pararius/data:/root/data -it --entrypoint /bin/bash jhginn/pararius
```
