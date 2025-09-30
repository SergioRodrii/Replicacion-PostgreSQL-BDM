# Replicación de PostgreSQL con Docker Compose

Este proyecto implementa replicación en tiempo real de PostgreSQL utilizando contenedores Docker. Consta de un primario y una réplica configurados, ideal para fines educativos y de pruebas.

## Características

- PostgreSQL 15 basado en imágenes `alpine`.
- Configuración automática de roles de replicación.
- Inicialización de la base de datos `saber11` con su esquema de tablas.
- Réplica en modo solo lectura.
- Sincronización en tiempo real mediante *streaming replication*.

## Requisitos

- Docker
- Docker Compose

## Instalación

1. Clona el repositorio:
   ```bash
   git clone https://github.com/SergioRodrii/Replicacion-PostgreSQL-BDM
   
2. Accede al directorio del proyecto:
   ```bash
   cd BDM-Replicacion 

3. Levanta el cluster:
   ```bash
   docker-compose up -d

## Uso

1. Conéctarse al primario:
   ```bash
   docker exec -it postgres_primary psql -U postgres -d saber11

2. Inserta datos de prueba:
   ```bash
   INSERT INTO Periodo (PERIODO) VALUES (20251);

3. Conéctarse a la réplica:
   ```bash
   docker exec -it postgres_replica psql -U postgres -d saber11

4. Verifica los datos:
   ```bash
   SELECT * FROM Periodo;

## Estructura del proyecto

- docker-compose.yml: Orquestación de contenedores primario y réplica.

- config/postgresql.conf: Configuración del servidor primario.

- config/pg_hba.conf: Reglas de acceso y replicación.

- init-replication.sql: Creación del usuario de replicación.

- schema.sql: Esquema de la base de datos saber11.


## Comandos útiles

1. Ver logs del primario:
   ```bash
   docker logs postgres_primary

2. Ver logs de la réplica:
   ```bash
   docker logs postgres_replica

3. Cerrar y limpiar:
   ```bash
   docker compose down -v