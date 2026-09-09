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

## PostgreSQL por versión de Odoo

Desde Odoo 20, cada versión corre contra el mismo major de PostgreSQL que usa en
producción, en su propio container. Las versiones anteriores **no se tocan**:
siguen todas en el `db` de siempre, con su data donde está.

| Odoo | PG | Service | Host (desde Odoo) | Puerto en el host | Datadir |
| --- | --- | --- | --- | --- | --- |
| hasta 19 | 15 | `db` | `db` | 5432 | `pg_data` |
| 20, master | 17 | `db17` | `db17` | 5417 | `pg_data_v17` |

La alineación arranca en la 20 a propósito: retrofitear las versiones viejas
obligaría a mudar bases que ya funcionan, sin ganar nada. El mapa completo de
producción (`saas.database`) es 13/15 → PG 13, 16 → PG 14, 17/18 → PG 15,
19 → PG 17, 20 → PG 17; si alguna vez se quiere alinear una versión anterior,
se agrega su service acá y se ajusta el `pg_major_for` del `init.sh` del repo
de versión.

`db` no lleva profile: es la instancia de siempre y arranca con un
`docker compose up -d` pelado. `db17` es **opt-in por profile** (`pg17`), así
quien no trabaja en la 20 no paga un PostgreSQL corriendo al vacío. La levanta el
`init.sh` del repo de versión, que también le prepara el datadir. A mano son
estos tres pasos, y el `mkdir` no es opcional: si el directorio falta, Docker lo
crea como `root` y el `initdb`, que corre como uid 26, no puede escribir.

```sh
mkdir -p ~/odoo/ctx/pg_data_v17 && sudo chown 26:102 ~/odoo/ctx/pg_data_v17
cd ~/odoo/ctx && docker compose --profile pg17 up -d db17
```

`docker compose up -d --remove-orphans` (lo que corre este `init.sh`) **no** la
apaga: compose no trata como huérfano a un service bajo un profile inactivo.

### Bases entre instancias

Dos majors de PostgreSQL no comparten datadir, así que una base del `db` no se ve
desde la 20. La data no se toca — sigue en `pg_data` y en el puerto 5432 — pero
si necesitás una base del otro lado hay que mudarla:

```sh
pg_dump -h localhost -p 5432 -U odoo -Fc mi_base > mi_base.dump
createdb -h localhost -p 5417 -U odoo mi_base
pg_restore -h localhost -p 5417 -U odoo -d mi_base mi_base.dump
```
