
-- Crear usuario de replicación
CREATE ROLE replicator WITH
    LOGIN
    REPLICATION
    PASSWORD 'replicator_password';

-- Crear un slot físico de replicación
SELECT pg_create_physical_replication_slot('replica_slot');

-- Dar permisos básicos por si se usan consultas de solo lectura en el futuro
GRANT CONNECT ON DATABASE saber11 TO replicator;
GRANT USAGE ON SCHEMA public TO replicator;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO replicator;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO replicator;

