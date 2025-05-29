# Adhoc development context

This repository holds the context that odoo run in your computer

## Some tools that we use

dbeaver: friendly psql client with GUI [DBeaver](doc/dbeaver.md "Universal Database Tool")

devcontainercli: terminal client for devcontainer  [Dev Container](doc/devcontainercli.md "Dev Container Cli")

## Skip some services

You can comment some services, just comment them and run

```sh
docker compose up -d --remove-orphans
```
