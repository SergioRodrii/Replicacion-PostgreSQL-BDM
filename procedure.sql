
CREATE OR REPLACE PROCEDURE public.usp_insertar_lote(IN p_json jsonb)
LANGUAGE plpgsql
AS $$
BEGIN
    BEGIN


        INSERT INTO periodo (periodo)
        SELECT DISTINCT "PERIODO"
        FROM jsonb_to_recordset(p_json->'Periodo')
            AS j("PERIODO" int)
        WHERE "PERIODO" IS NOT NULL
        ON CONFLICT (periodo) DO NOTHING;


        INSERT INTO departamento (cod_depto, cole_depto_ubicacion)
        SELECT DISTINCT "COD_DEPTO", "COLE_DEPTO_UBICACION"
        FROM jsonb_to_recordset(p_json->'Departamento')
            AS j("COD_DEPTO" int, "COLE_DEPTO_UBICACION" varchar(160))
        WHERE "COD_DEPTO" IS NOT NULL
        ON CONFLICT (cod_depto) DO NOTHING;


        INSERT INTO municipio (cod_mcpio, cole_mcpio_ubicacion, cod_depto)
        SELECT DISTINCT "COD_MCPIO", "COLE_MCPIO_UBICACION", "COD_DEPTO"
        FROM jsonb_to_recordset(p_json->'Municipio')
            AS j("COD_MCPIO" bigint, "COLE_MCPIO_UBICACION" varchar(160), "COD_DEPTO" int)
        WHERE "COD_MCPIO" IS NOT NULL
        ON CONFLICT (cod_mcpio) DO NOTHING;


        INSERT INTO colegio (cole_cod_dane_establecimiento, cole_nombre_establecimiento,
                            cole_bilingue, cole_calendario, cole_caracter,
                            cole_genero, cole_naturaleza, cole_codigo_icfes)
        SELECT DISTINCT "COLE_COD_DANE_ESTABLECIMIENTO", "COLE_NOMBRE_ESTABLECIMIENTO",
                        "COLE_BILINGUE", "COLE_CALENDARIO", "COLE_CARACTER",
                        "COLE_GENERO", "COLE_NATURALEZA", "COLE_CODIGO_ICFES"
        FROM jsonb_to_recordset(p_json->'Colegio')
            AS j("COLE_COD_DANE_ESTABLECIMIENTO" bigint,
                 "COLE_NOMBRE_ESTABLECIMIENTO" varchar(285),
                 "COLE_BILINGUE" boolean,
                 "COLE_CALENDARIO" varchar(10),
                 "COLE_CARACTER" varchar(80),
                 "COLE_GENERO" varchar(30),
                 "COLE_NATURALEZA" varchar(30),
                 "COLE_CODIGO_ICFES" bigint)
        WHERE "COLE_COD_DANE_ESTABLECIMIENTO" IS NOT NULL
        ON CONFLICT (cole_cod_dane_establecimiento) DO NOTHING;


        INSERT INTO sede (cole_cod_dane_sede, cole_cod_dane_establecimiento,
                        cole_nombre_sede, cole_sede_principal,
                        cod_mcpio, cole_area_ubicacion, cole_jornada)
        SELECT DISTINCT "COLE_COD_DANE_SEDE", "COLE_COD_DANE_ESTABLECIMIENTO",
                        "COLE_NOMBRE_SEDE", "COLE_SEDE_PRINCIPAL",
                        "COD_MCPIO", "COLE_AREA_UBICACION", "COLE_JORNADA"
        FROM jsonb_to_recordset(p_json->'Sede')
            AS j("COLE_COD_DANE_SEDE" bigint,
                 "COLE_COD_DANE_ESTABLECIMIENTO" bigint,
                 "COLE_NOMBRE_SEDE" varchar(285),
                 "COLE_SEDE_PRINCIPAL" boolean,
                 "COD_MCPIO" bigint,
                 "COLE_AREA_UBICACION" varchar(40),
                 "COLE_JORNADA" varchar(50))
        WHERE "COLE_COD_DANE_SEDE" IS NOT NULL
        ON CONFLICT (cole_cod_dane_sede) DO NOTHING;


        INSERT INTO estudiante (
            estu_consecutivo, estu_tipodocumento, estu_estudiante,
            estu_fechanacimiento, estu_genero, estu_nacionalidad,
            estu_privado_libertad, estu_estadoinvestigacion
        )
        SELECT DISTINCT "ESTU_CONSECUTIVO", "ESTU_TIPODOCUMENTO", "ESTU_ESTUDIANTE",
                        "ESTU_FECHANACIMIENTO", "ESTU_GENERO", "ESTU_NACIONALIDAD",
                        "ESTU_PRIVADO_LIBERTAD", "ESTU_ESTADOINVESTIGACION"
        FROM jsonb_to_recordset(p_json->'Estudiante')
            AS j("ESTU_CONSECUTIVO" varchar,
                 "ESTU_TIPODOCUMENTO" varchar(35),
                 "ESTU_ESTUDIANTE" varchar(285),
                 "ESTU_FECHANACIMIENTO" date,
                 "ESTU_GENERO" varchar(5),
                 "ESTU_NACIONALIDAD" varchar(80),
                 "ESTU_PRIVADO_LIBERTAD" boolean,
                 "ESTU_ESTADOINVESTIGACION" varchar(50))
        WHERE "ESTU_CONSECUTIVO" IS NOT NULL
        ON CONFLICT (estu_consecutivo) DO NOTHING;


        INSERT INTO ubicacion_presentacion (estu_consecutivo, cole_cod_dane_sede)
        SELECT DISTINCT "ESTU_CONSECUTIVO", "COLE_COD_DANE_SEDE"
        FROM jsonb_to_recordset(p_json->'Ubicacion_Presentacion')
            AS j("ESTU_CONSECUTIVO" varchar, "COLE_COD_DANE_SEDE" bigint);

        INSERT INTO ubicacion_residencia (estu_consecutivo, cod_mcpio, estu_pais_reside)
        SELECT DISTINCT "ESTU_CONSECUTIVO", "COD_MCPIO", "ESTU_PAIS_RESIDE"
        FROM jsonb_to_recordset(p_json->'Ubicacion_Residencia')
            AS j("ESTU_CONSECUTIVO" varchar, "COD_MCPIO" bigint, "ESTU_PAIS_RESIDE" varchar(130));


        INSERT INTO familia (estu_consecutivo, fami_cuartoshogar, fami_educacionmadre,
                            fami_educacionpadre, fami_estratovivienda, fami_personashogar,
                            fami_tieneautomovil, fami_tienecomputador,
                            fami_tieneinternet, fami_tienelavadora)
        SELECT DISTINCT "ESTU_CONSECUTIVO", "FAMI_CUARTOSHOGAR", "FAMI_EDUCACIONMADRE",
                        "FAMI_EDUCACIONPADRE", "FAMI_ESTRATOVIVIENDA", "FAMI_PERSONASHOGAR",
                        "FAMI_TIENEAUTOMOVIL", "FAMI_TIENECOMPUTADOR",
                        "FAMI_TIENEINTERNET", "FAMI_TIENELAVADORA"
        FROM jsonb_to_recordset(p_json->'Familia')
            AS j("ESTU_CONSECUTIVO" varchar,
                 "FAMI_CUARTOSHOGAR" varchar(50),
                 "FAMI_EDUCACIONMADRE" varchar(130),
                 "FAMI_EDUCACIONPADRE" varchar(130),
                 "FAMI_ESTRATOVIVIENDA" varchar(50),
                 "FAMI_PERSONASHOGAR" varchar(50),
                 "FAMI_TIENEAUTOMOVIL" boolean,
                 "FAMI_TIENECOMPUTADOR" boolean,
                 "FAMI_TIENEINTERNET" boolean,
                 "FAMI_TIENELAVADORA" boolean);


        INSERT INTO resultados (estu_consecutivo, periodo, desemp_ingles, punt_ingles,
                                punt_matematicas, punt_sociales_ciudadanas, punt_c_naturales,
                                punt_lectura_critica, punt_global)
        SELECT DISTINCT "ESTU_CONSECUTIVO", "PERIODO", "DESEMP_INGLES", "PUNT_INGLES",
                        "PUNT_MATEMATICAS", "PUNT_SOCIALES_CIUDADANAS", "PUNT_C_NATURALES",
                        "PUNT_LECTURA_CRITICA", "PUNT_GLOBAL"
        FROM jsonb_to_recordset(p_json->'Resultados')
            AS j("ESTU_CONSECUTIVO" varchar,
                 "PERIODO" int,
                 "DESEMP_INGLES" varchar(10),
                 "PUNT_INGLES" int,
                 "PUNT_MATEMATICAS" int,
                 "PUNT_SOCIALES_CIUDADANAS" int,
                 "PUNT_C_NATURALES" int,
                 "PUNT_LECTURA_CRITICA" int,
                 "PUNT_GLOBAL" int);

    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Error: %', SQLERRM;
            RAISE;
    END;
END;
$$;
