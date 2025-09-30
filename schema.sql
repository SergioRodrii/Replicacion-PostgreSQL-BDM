
-- TABLA PERIODO
CREATE TABLE IF NOT EXISTS periodo (
    periodo INT PRIMARY KEY
);

-- TABLA DEPARTAMENTO
CREATE TABLE IF NOT EXISTS departamento (
    cod_depto INT PRIMARY KEY,
    cole_depto_ubicacion VARCHAR(160)
);

-- TABLA MUNICIPIO
CREATE TABLE IF NOT EXISTS municipio (
    cod_mcpio BIGINT PRIMARY KEY,
    cole_mcpio_ubicacion VARCHAR(160),
    cod_depto INT REFERENCES departamento(cod_depto)
);

-- TABLA COLEGIO
CREATE TABLE IF NOT EXISTS colegio (
    cole_cod_dane_establecimiento BIGINT PRIMARY KEY,
    cole_nombre_establecimiento VARCHAR(285),
    cole_bilingue BOOLEAN,
    cole_calendario VARCHAR(10),
    cole_caracter VARCHAR(80),
    cole_genero VARCHAR(30),
    cole_naturaleza VARCHAR(30),
    cole_codigo_icfes BIGINT
);

-- TABLA SEDE
CREATE TABLE IF NOT EXISTS sede (
    cole_cod_dane_sede BIGINT PRIMARY KEY,
    cole_cod_dane_establecimiento BIGINT REFERENCES colegio(cole_cod_dane_establecimiento),
    cole_nombre_sede VARCHAR(285),
    cole_sede_principal BOOLEAN,
    cod_mcpio BIGINT REFERENCES municipio(cod_mcpio),
    cole_area_ubicacion VARCHAR(40),
    cole_jornada VARCHAR(50)
);

-- TABLA ESTUDIANTE
CREATE TABLE IF NOT EXISTS estudiante (
    estu_consecutivo VARCHAR(255) PRIMARY KEY,
    estu_tipodocumento VARCHAR(35),
    estu_estudiante VARCHAR(285),
    estu_fechanacimiento DATE,
    estu_genero CHAR(5),
    estu_nacionalidad VARCHAR(80),
    estu_privado_libertad BOOLEAN,
    estu_estadoinvestigacion VARCHAR(50)
);

-- TABLA UBICACION_PRESENTACION
CREATE TABLE IF NOT EXISTS ubicacion_presentacion (
    id_ubicacion_presentacion SERIAL PRIMARY KEY,
    estu_consecutivo VARCHAR(255) REFERENCES estudiante(estu_consecutivo),
    cole_cod_dane_sede BIGINT REFERENCES sede(cole_cod_dane_sede)
);

-- TABLA UBICACION_RESIDENCIA
CREATE TABLE IF NOT EXISTS ubicacion_residencia (
    id_ubicacion_residencia SERIAL PRIMARY KEY,
    estu_consecutivo VARCHAR(255) REFERENCES estudiante(estu_consecutivo),
    cod_mcpio BIGINT REFERENCES municipio(cod_mcpio),
    estu_pais_reside VARCHAR(130)
);

-- TABLA FAMILIA
CREATE TABLE IF NOT EXISTS familia (
    id_familia SERIAL PRIMARY KEY,
    estu_consecutivo VARCHAR(255) REFERENCES estudiante(estu_consecutivo),
    fami_cuartoshogar VARCHAR(50),
    fami_educacionmadre VARCHAR(130),
    fami_educacionpadre VARCHAR(130),
    fami_estratovivienda VARCHAR(50),
    fami_personashogar VARCHAR(50),
    fami_tieneautomovil BOOLEAN,
    fami_tienecomputador BOOLEAN,
    fami_tieneinternet BOOLEAN,
    fami_tienelavadora BOOLEAN
);

-- TABLA RESULTADOS
CREATE TABLE IF NOT EXISTS resultados (
    id_resultado SERIAL PRIMARY KEY,
    estu_consecutivo VARCHAR(255) REFERENCES estudiante(estu_consecutivo),
    periodo INT REFERENCES periodo(periodo),
    desemp_ingles VARCHAR(10),
    punt_ingles INT,
    punt_matematicas INT,
    punt_sociales_ciudadanas INT,
    punt_c_naturales INT,
    punt_lectura_critica INT,
    punt_global INT
);

-- TABLA ERRORES_CARGA
CREATE TABLE IF NOT EXISTS errores_carga (
    id_error SERIAL PRIMARY KEY,
    tabla VARCHAR(100),
    json_data TEXT,
    fecha_error TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
