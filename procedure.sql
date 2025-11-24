
CREATE OR REPLACE PROCEDURE registrar_error(
    p_tabla VARCHAR,
    p_json TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO errores_carga(tabla, json_data)
    VALUES (p_tabla, p_json);
END;
$$;



CREATE OR REPLACE PROCEDURE public.usp_insertar_lote(IN p_json jsonb)
LANGUAGE plpgsql
AS $$
DECLARE
    rec jsonb;
BEGIN
    ---------------------------------------------------------
    -- PERIODO
    ---------------------------------------------------------
    BEGIN
        INSERT INTO periodo (periodo)
        SELECT DISTINCT "PERIODO"
        FROM jsonb_to_recordset(p_json->'Periodo')
            AS j("PERIODO" int)
        WHERE "PERIODO" IS NOT NULL
        ON CONFLICT (periodo) DO NOTHING;
    EXCEPTION WHEN OTHERS THEN        
        FOR rec IN SELECT value FROM jsonb_array_elements(p_json->'Periodo')
        LOOP
            BEGIN
                INSERT INTO periodo(periodo)
                VALUES ((rec->>'PERIODO')::int)
                ON CONFLICT (periodo) DO NOTHING;
            EXCEPTION WHEN OTHERS THEN
                CALL registrar_error('periodo', rec::text);
            END;
        END LOOP;
    END;


    ---------------------------------------------------------
    -- DEPARTAMENTO
    ---------------------------------------------------------
    BEGIN
        INSERT INTO departamento (cod_depto, cole_depto_ubicacion)
        SELECT DISTINCT "COD_DEPTO", "COLE_DEPTO_UBICACION"
        FROM jsonb_to_recordset(p_json->'Departamento')
            AS j("COD_DEPTO" int, "COLE_DEPTO_UBICACION" varchar(160))
        WHERE "COD_DEPTO" IS NOT NULL
        ON CONFLICT (cod_depto) DO NOTHING;
    EXCEPTION WHEN OTHERS THEN
        FOR rec IN SELECT value FROM jsonb_array_elements(p_json->'Departamento')
        LOOP
            BEGIN
                INSERT INTO departamento(cod_depto, cole_depto_ubicacion)
                VALUES (
                    (rec->>'COD_DEPTO')::int,
                    rec->>'COLE_DEPTO_UBICACION'
                )
                ON CONFLICT (cod_depto) DO NOTHING;
            EXCEPTION WHEN OTHERS THEN
                CALL registrar_error('departamento', rec::text);
            END;
        END LOOP;
    END;


    ---------------------------------------------------------
    -- MUNICIPIO
    ---------------------------------------------------------
    BEGIN
        INSERT INTO municipio (cod_mcpio, cole_mcpio_ubicacion, cod_depto)
        SELECT DISTINCT "COD_MCPIO", "COLE_MCPIO_UBICACION", "COD_DEPTO"
        FROM jsonb_to_recordset(p_json->'Municipio')
            AS j("COD_MCPIO" bigint, "COLE_MCPIO_UBICACION" varchar(160), "COD_DEPTO" int)
        WHERE "COD_MCPIO" IS NOT NULL
        ON CONFLICT (cod_mcpio) DO NOTHING;
    EXCEPTION WHEN OTHERS THEN
        FOR rec IN SELECT value FROM jsonb_array_elements(p_json->'Municipio')
        LOOP
            BEGIN
                INSERT INTO municipio(cod_mcpio, cole_mcpio_ubicacion, cod_depto)
                VALUES (
                    (rec->>'COD_MCPIO')::bigint,
                    rec->>'COLE_MCPIO_UBICACION',
                    (rec->>'COD_DEPTO')::int
                )
                ON CONFLICT (cod_mcpio) DO NOTHING;
            EXCEPTION WHEN OTHERS THEN
                CALL registrar_error('municipio', rec::text);
            END;
        END LOOP;
    END;


    ---------------------------------------------------------
    -- COLEGIO
    ---------------------------------------------------------
    BEGIN
        INSERT INTO colegio (
            cole_cod_dane_establecimiento,
            cole_nombre_establecimiento,
            cole_bilingue,
            cole_calendario,
            cole_caracter,
            cole_genero,
            cole_naturaleza,
            cole_codigo_icfes
        )
        SELECT DISTINCT
            "COLE_COD_DANE_ESTABLECIMIENTO",
            "COLE_NOMBRE_ESTABLECIMIENTO",
            "COLE_BILINGUE",
            "COLE_CALENDARIO",
            "COLE_CARACTER",
            "COLE_GENERO",
            "COLE_NATURALEZA",
            "COLE_CODIGO_ICFES"
        FROM jsonb_to_recordset(p_json->'Colegio')
            AS j(
                "COLE_COD_DANE_ESTABLECIMIENTO" bigint,
                "COLE_NOMBRE_ESTABLECIMIENTO" varchar(285),
                "COLE_BILINGUE" boolean,
                "COLE_CALENDARIO" varchar(10),
                "COLE_CARACTER" varchar(80),
                "COLE_GENERO" varchar(30),
                "COLE_NATURALEZA" varchar(30),
                "COLE_CODIGO_ICFES" bigint
            )
        ON CONFLICT (cole_cod_dane_establecimiento) DO NOTHING;
    EXCEPTION WHEN OTHERS THEN
        FOR rec IN SELECT value FROM jsonb_array_elements(p_json->'Colegio')
        LOOP
            BEGIN
                INSERT INTO colegio(
                    cole_cod_dane_establecimiento,
                    cole_nombre_establecimiento,
                    cole_bilingue,
                    cole_calendario,
                    cole_caracter,
                    cole_genero,
                    cole_naturaleza,
                    cole_codigo_icfes
                )
                VALUES (
                    (rec->>'COLE_COD_DANE_ESTABLECIMIENTO')::bigint,
                    rec->>'COLE_NOMBRE_ESTABLECIMIENTO',
                    CASE WHEN rec ? 'COLE_BILINGUE' AND (rec->>'COLE_BILINGUE') IN ('true','t','1') THEN true
                         WHEN rec ? 'COLE_BILINGUE' AND (rec->>'COLE_BILINGUE') IN ('false','f','0') THEN false
                         ELSE NULL END,
                    NULLIF(rec->>'COLE_CALENDARIO',''),
                    NULLIF(rec->>'COLE_CARACTER',''),
                    NULLIF(rec->>'COLE_GENERO',''),
                    NULLIF(rec->>'COLE_NATURALEZA',''),
                    CASE WHEN rec->>'COLE_CODIGO_ICFES' = '' THEN NULL ELSE (rec->>'COLE_CODIGO_ICFES')::bigint END
                )
                ON CONFLICT (cole_cod_dane_establecimiento) DO NOTHING;
            EXCEPTION WHEN OTHERS THEN
                CALL registrar_error('colegio', rec::text);
            END;
        END LOOP;
    END;


    ---------------------------------------------------------
    -- SEDE
    ---------------------------------------------------------
    BEGIN
        INSERT INTO sede (
            cole_cod_dane_sede,
            cole_cod_dane_establecimiento,
            cole_nombre_sede,
            cole_sede_principal,
            cod_mcpio,
            cole_area_ubicacion,
            cole_jornada
        )
        SELECT DISTINCT
            "COLE_COD_DANE_SEDE",
            "COLE_COD_DANE_ESTABLECIMIENTO",
            "COLE_NOMBRE_SEDE",
            "COLE_SEDE_PRINCIPAL",
            "COD_MCPIO",
            "COLE_AREA_UBICACION",
            "COLE_JORNADA"
        FROM jsonb_to_recordset(p_json->'Sede')
            AS j(
                "COLE_COD_DANE_SEDE" bigint,
                "COLE_COD_DANE_ESTABLECIMIENTO" bigint,
                "COLE_NOMBRE_SEDE" varchar(285),
                "COLE_SEDE_PRINCIPAL" boolean,
                "COD_MCPIO" bigint,
                "COLE_AREA_UBICACION" varchar(40),
                "COLE_JORNADA" varchar(50)
            )
        WHERE "COLE_COD_DANE_SEDE" IS NOT NULL
        ON CONFLICT (cole_cod_dane_sede) DO NOTHING;
    EXCEPTION WHEN OTHERS THEN
        FOR rec IN SELECT value FROM jsonb_array_elements(p_json->'Sede')
        LOOP
            BEGIN
                INSERT INTO sede(
                    cole_cod_dane_sede,
                    cole_cod_dane_establecimiento,
                    cole_nombre_sede,
                    cole_sede_principal,
                    cod_mcpio,
                    cole_area_ubicacion,
                    cole_jornada
                )
                VALUES (
                    (rec->>'COLE_COD_DANE_SEDE')::bigint,
                    CASE WHEN rec->>'COLE_COD_DANE_ESTABLECIMIENTO' = '' THEN NULL ELSE (rec->>'COLE_COD_DANE_ESTABLECIMIENTO')::bigint END,
                    rec->>'COLE_NOMBRE_SEDE',
                    CASE WHEN rec ? 'COLE_SEDE_PRINCIPAL' AND (rec->>'COLE_SEDE_PRINCIPAL') IN ('true','t','1') THEN true
                         WHEN rec ? 'COLE_SEDE_PRINCIPAL' THEN false
                         ELSE NULL END,
                    CASE WHEN rec->>'COD_MCPIO' = '' THEN NULL ELSE (rec->>'COD_MCPIO')::bigint END,
                    NULLIF(rec->>'COLE_AREA_UBICACION',''),
                    NULLIF(rec->>'COLE_JORNADA','')
                )
                ON CONFLICT (cole_cod_dane_sede) DO NOTHING;
            EXCEPTION WHEN OTHERS THEN
                CALL registrar_error('sede', rec::text);
            END;
        END LOOP;
    END;


    ---------------------------------------------------------
    -- ESTUDIANTE
    ---------------------------------------------------------
    BEGIN
        INSERT INTO estudiante (
            estu_consecutivo,
            estu_tipodocumento,
            estu_estudiante,
            estu_fechanacimiento,
            estu_genero,
            estu_nacionalidad,
            estu_privado_libertad,
            estu_estadoinvestigacion
        )
        SELECT DISTINCT
            "ESTU_CONSECUTIVO",
            "ESTU_TIPODOCUMENTO",
            "ESTU_ESTUDIANTE",
            "ESTU_FECHANACIMIENTO",
            "ESTU_GENERO",
            "ESTU_NACIONALIDAD",
            "ESTU_PRIVADO_LIBERTAD",
            "ESTU_ESTADOINVESTIGACION"
        FROM jsonb_to_recordset(p_json->'Estudiante')
            AS j(
                "ESTU_CONSECUTIVO" varchar,
                "ESTU_TIPODOCUMENTO" varchar(35),
                "ESTU_ESTUDIANTE" varchar(285),
                "ESTU_FECHANACIMIENTO" date,
                "ESTU_GENERO" varchar(5),
                "ESTU_NACIONALIDAD" varchar(80),
                "ESTU_PRIVADO_LIBERTAD" boolean,
                "ESTU_ESTADOINVESTIGACION" varchar(50)
            )
        WHERE "ESTU_CONSECUTIVO" IS NOT NULL
        ON CONFLICT (estu_consecutivo) DO NOTHING;
    EXCEPTION WHEN OTHERS THEN
        FOR rec IN SELECT value FROM jsonb_array_elements(p_json->'Estudiante')
        LOOP
            BEGIN
                INSERT INTO estudiante(
                    estu_consecutivo,
                    estu_tipodocumento,
                    estu_estudiante,
                    estu_fechanacimiento,
                    estu_genero,
                    estu_nacionalidad,
                    estu_privado_libertad,
                    estu_estadoinvestigacion
                )
                VALUES (
                    rec->>'ESTU_CONSECUTIVO',
                    NULLIF(rec->>'ESTU_TIPODOCUMENTO',''),
                    NULLIF(rec->>'ESTU_ESTUDIANTE',''),
                    CASE WHEN rec->>'ESTU_FECHANACIMIENTO' = '' THEN NULL ELSE (rec->>'ESTU_FECHANACIMIENTO')::date END,
                    NULLIF(rec->>'ESTU_GENERO',''),
                    NULLIF(rec->>'ESTU_NACIONALIDAD',''),
                    CASE WHEN rec ? 'ESTU_PRIVADO_LIBERTAD' AND (rec->>'ESTU_PRIVADO_LIBERTAD') IN ('true','t','1') THEN true
                         WHEN rec ? 'ESTU_PRIVADO_LIBERTAD' THEN false
                         ELSE NULL END,
                    NULLIF(rec->>'ESTU_ESTADOINVESTIGACION','')
                )
                ON CONFLICT (estu_consecutivo) DO NOTHING;
            EXCEPTION WHEN OTHERS THEN
                CALL registrar_error('estudiante', rec::text);
            END;
        END LOOP;
    END;


    ---------------------------------------------------------
    -- UBICACION_PRESENTACION
    ---------------------------------------------------------
    BEGIN
        INSERT INTO ubicacion_presentacion (estu_consecutivo, cole_cod_dane_sede)
        SELECT DISTINCT "ESTU_CONSECUTIVO", "COLE_COD_DANE_SEDE"
        FROM jsonb_to_recordset(p_json->'Ubicacion_Presentacion')
            AS j("ESTU_CONSECUTIVO" varchar, "COLE_COD_DANE_SEDE" bigint)
        ON CONFLICT DO NOTHING;
    EXCEPTION WHEN OTHERS THEN
        FOR rec IN SELECT value FROM jsonb_array_elements(p_json->'Ubicacion_Presentacion')
        LOOP
            BEGIN
                INSERT INTO ubicacion_presentacion(estu_consecutivo, cole_cod_dane_sede)
                VALUES (
                    rec->>'ESTU_CONSECUTIVO',
                    CASE WHEN rec->>'COLE_COD_DANE_SEDE' = '' THEN NULL ELSE (rec->>'COLE_COD_DANE_SEDE')::bigint END
                );
            EXCEPTION WHEN OTHERS THEN
                CALL registrar_error('ubicacion_presentacion', rec::text);
            END;
        END LOOP;
    END;


    ---------------------------------------------------------
    -- UBICACION_RESIDENCIA
    ---------------------------------------------------------
    BEGIN
        INSERT INTO ubicacion_residencia (estu_consecutivo, cod_mcpio, estu_pais_reside)
        SELECT DISTINCT "ESTU_CONSECUTIVO", "COD_MCPIO", "ESTU_PAIS_RESIDE"
        FROM jsonb_to_recordset(p_json->'Ubicacion_Residencia')
            AS j("ESTU_CONSECUTIVO" varchar, "COD_MCPIO" bigint, "ESTU_PAIS_RESIDE" varchar(130))
        ON CONFLICT DO NOTHING;
    EXCEPTION WHEN OTHERS THEN
        FOR rec IN SELECT value FROM jsonb_array_elements(p_json->'Ubicacion_Residencia')
        LOOP
            BEGIN
                INSERT INTO ubicacion_residencia (estu_consecutivo, cod_mcpio, estu_pais_reside)
                VALUES (
                    rec->>'ESTU_CONSECUTIVO',
                    CASE WHEN rec->>'COD_MCPIO' = '' THEN NULL ELSE (rec->>'COD_MCPIO')::bigint END,
                    NULLIF(rec->>'ESTU_PAIS_RESIDE','')
                );
            EXCEPTION WHEN OTHERS THEN
                CALL registrar_error('ubicacion_residencia', rec::text);
            END;
        END LOOP;
    END;


    ---------------------------------------------------------
    -- FAMILIA
    ---------------------------------------------------------
    BEGIN
        INSERT INTO familia (
            estu_consecutivo,
            fami_cuartoshogar,
            fami_educacionmadre,
            fami_educacionpadre,
            fami_estratovivienda,
            fami_personashogar,
            fami_tieneautomovil,
            fami_tienecomputador,
            fami_tieneinternet,
            fami_tienelavadora
        )
        SELECT DISTINCT
            "ESTU_CONSECUTIVO",
            "FAMI_CUARTOSHOGAR",
            "FAMI_EDUCACIONMADRE",
            "FAMI_EDUCACIONPADRE",
            "FAMI_ESTRATOVIVIENDA",
            "FAMI_PERSONASHOGAR",
            "FAMI_TIENEAUTOMOVIL",
            "FAMI_TIENECOMPUTADOR",
            "FAMI_TIENEINTERNET",
            "FAMI_TIENELAVADORA"
        FROM jsonb_to_recordset(p_json->'Familia')
            AS j(
                "ESTU_CONSECUTIVO" varchar,
                "FAMI_CUARTOSHOGAR" varchar(50),
                "FAMI_EDUCACIONMADRE" varchar(130),
                "FAMI_EDUCACIONPADRE" varchar(130),
                "FAMI_ESTRATOVIVIENDA" varchar(50),
                "FAMI_PERSONASHOGAR" varchar(50),
                "FAMI_TIENEAUTOMOVIL" boolean,
                "FAMI_TIENECOMPUTADOR" boolean,
                "FAMI_TIENEINTERNET" boolean,
                "FAMI_TIENELAVADORA" boolean
            )
        ON CONFLICT DO NOTHING;
    EXCEPTION WHEN OTHERS THEN
        FOR rec IN SELECT value FROM jsonb_array_elements(p_json->'Familia')
        LOOP
            BEGIN
                INSERT INTO familia(
                    estu_consecutivo,
                    fami_cuartoshogar,
                    fami_educacionmadre,
                    fami_educacionpadre,
                    fami_estratovivienda,
                    fami_personashogar,
                    fami_tieneautomovil,
                    fami_tienecomputador,
                    fami_tieneinternet,
                    fami_tienelavadora
                )
                VALUES (
                    rec->>'ESTU_CONSECUTIVO',
                    NULLIF(rec->>'FAMI_CUARTOSHOGAR',''),
                    NULLIF(rec->>'FAMI_EDUCACIONMADRE',''),
                    NULLIF(rec->>'FAMI_EDUCACIONPADRE',''),
                    NULLIF(rec->>'FAMI_ESTRATOVIVIENDA',''),
                    NULLIF(rec->>'FAMI_PERSONASHOGAR',''),
                    CASE WHEN rec ? 'FAMI_TIENEAUTOMOVIL' AND (rec->>'FAMI_TIENEAUTOMOVIL') IN ('true','t','1') THEN true
                         WHEN rec ? 'FAMI_TIENEAUTOMOVIL' THEN false
                         ELSE NULL END,
                    CASE WHEN rec ? 'FAMI_TIENECOMPUTADOR' AND (rec->>'FAMI_TIENECOMPUTADOR') IN ('true','t','1') THEN true
                         WHEN rec ? 'FAMI_TIENECOMPUTADOR' THEN false
                         ELSE NULL END,
                    CASE WHEN rec ? 'FAMI_TIENEINTERNET' AND (rec->>'FAMI_TIENEINTERNET') IN ('true','t','1') THEN true
                         WHEN rec ? 'FAMI_TIENEINTERNET' THEN false
                         ELSE NULL END,
                    CASE WHEN rec ? 'FAMI_TIENELAVADORA' AND (rec->>'FAMI_TIENELAVADORA') IN ('true','t','1') THEN true
                         WHEN rec ? 'FAMI_TIENELAVADORA' THEN false
                         ELSE NULL END
                )
                ON CONFLICT DO NOTHING;
            EXCEPTION WHEN OTHERS THEN
                CALL registrar_error('familia', rec::text);
            END;
        END LOOP;
    END;


    ---------------------------------------------------------
    -- RESULTADOS
    ---------------------------------------------------------
    BEGIN
        INSERT INTO resultados (
            estu_consecutivo,
            periodo,
            desemp_ingles,
            punt_ingles,
            punt_matematicas,
            punt_sociales_ciudadanas,
            punt_c_naturales,
            punt_lectura_critica,
            punt_global
        )
        SELECT DISTINCT
            "ESTU_CONSECUTIVO",
            "PERIODO",
            "DESEMP_INGLES",
            "PUNT_INGLES",
            "PUNT_MATEMATICAS",
            "PUNT_SOCIALES_CIUDADANAS",
            "PUNT_C_NATURALES",
            "PUNT_LECTURA_CRITICA",
            "PUNT_GLOBAL"
        FROM jsonb_to_recordset(p_json->'Resultados')
            AS j(
                "ESTU_CONSECUTIVO" varchar,
                "PERIODO" int,
                "DESEMP_INGLES" varchar(10),
                "PUNT_INGLES" int,
                "PUNT_MATEMATICAS" int,
                "PUNT_SOCIALES_CIUDADANAS" int,
                "PUNT_C_NATURALES" int,
                "PUNT_LECTURA_CRITICA" int,
                "PUNT_GLOBAL" int
            )
        ON CONFLICT DO NOTHING;
    EXCEPTION WHEN OTHERS THEN
        FOR rec IN SELECT value FROM jsonb_array_elements(p_json->'Resultados')
        LOOP
            BEGIN
                INSERT INTO resultados(
                    estu_consecutivo,
                    periodo,
                    desemp_ingles,
                    punt_ingles,
                    punt_matematicas,
                    punt_sociales_ciudadanas,
                    punt_c_naturales,
                    punt_lectura_critica,
                    punt_global
                )
                VALUES (
                    rec->>'ESTU_CONSECUTIVO',
                    CASE WHEN rec->>'PERIODO' = '' THEN NULL ELSE (rec->>'PERIODO')::int END,
                    NULLIF(rec->>'DESEMP_INGLES',''),
                    CASE WHEN rec->>'PUNT_INGLES' = '' THEN NULL ELSE (rec->>'PUNT_INGLES')::int END,
                    CASE WHEN rec->>'PUNT_MATEMATICAS' = '' THEN NULL ELSE (rec->>'PUNT_MATEMATICAS')::int END,
                    CASE WHEN rec->>'PUNT_SOCIALES_CIUDADANAS' = '' THEN NULL ELSE (rec->>'PUNT_SOCIALES_CIUDADANAS')::int END,
                    CASE WHEN rec->>'PUNT_C_NATURALES' = '' THEN NULL ELSE (rec->>'PUNT_C_NATURALES')::int END,
                    CASE WHEN rec->>'PUNT_LECTURA_CRITICA' = '' THEN NULL ELSE (rec->>'PUNT_LECTURA_CRITICA')::int END,
                    CASE WHEN rec->>'PUNT_GLOBAL' = '' THEN NULL ELSE (rec->>'PUNT_GLOBAL')::int END
                )
                ON CONFLICT DO NOTHING;
            EXCEPTION WHEN OTHERS THEN
                CALL registrar_error('resultados', rec::text);
            END;
        END LOOP;
    END;
END;
$$;
