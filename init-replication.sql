
CREATE ROLE replicator WITH
    LOGIN
    REPLICATION
    PASSWORD 'replicator_password';

SELECT pg_create_physical_replication_slot('replica_slot');

GRANT CONNECT ON DATABASE saber11 TO replicator;
GRANT USAGE ON SCHEMA public TO replicator;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO replicator;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO replicator;

