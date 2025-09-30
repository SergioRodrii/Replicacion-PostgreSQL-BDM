CREATE OR REPLACE PROCEDURE usp_insertar_lote(p_json jsonb)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Usar bloque para manejo de errores
    BEGIN
        -- 1. Insertar Periodos
        INSERT INTO periodo (periodo)
        SELECT DISTINCT periodo
        FROM jsonb_to_recordset(p_json->'Periodo')
             AS j(periodo int)
        WHERE periodo IS NOT NULL
          AND NOT EXISTS (
              SELECT 1 FROM periodo p WHERE p.periodo = j.periodo
          );

        -- 2. Insertar Departamentos
        INSERT INTO departamento (cod_depto, cole_depto_ubicacion)
        SELECT DISTINCT cod_depto, cole_depto_ubicacion
        FROM jsonb_to_recordset(p_json->'Departamento')
             AS j(cod_depto int, cole_depto_ubicacion varchar(160))
        WHERE cod_depto IS NOT NULL
          AND NOT EXISTS (
              SELECT 1 FROM departamento d WHERE d.cod_depto = j.cod_depto
          );

        -- 3. Insertar Municipios
        INSERT INTO municipio (cod_mcpio, cole_mcpio_ubicacion, cod_depto)
        SELECT DISTINCT cod_mcpio, cole_mcpio_ubicacion, cod_depto
        FROM jsonb_to_recordset(p_json->'Municipio')
             AS j(cod_mcpio bigint, cole_mcpio_ubicacion varchar(160), cod_depto int)
        WHERE cod_mcpio IS NOT NULL
          AND NOT EXISTS (
              SELECT 1 FROM municipio m WHERE m.cod_mcpio = j.cod_mcpio
          );

        -- 4. Insertar Colegios
        INSERT INTO colegio (cole_cod_dane_establecimiento, cole_nombre_establecimiento,
                             cole_bilingue, cole_calendario, cole_caracter,
                             cole_genero, cole_naturaleza, cole_codigo_icfes)
        SELECT DISTINCT cole_cod_dane_establecimiento, cole_nombre_establecimiento,
                        cole_bilingue, cole_calendario, cole_caracter,
                        cole_genero, cole_naturaleza, cole_codigo_icfes
        FROM jsonb_to_recordset(p_json->'Colegio')
             AS j(cole_cod_dane_establecimiento bigint,
                  cole_nombre_establecimiento varchar(285),
                  cole_bilingue boolean,
                  cole_calendario varchar(10),
                  cole_caracter varchar(80),
                  cole_genero varchar(30),
                  cole_naturaleza varchar(30),
                  cole_codigo_icfes bigint)
        WHERE cole_cod_dane_establecimiento IS NOT NULL
          AND NOT EXISTS (
              SELECT 1 FROM colegio c WHERE c.cole_cod_dane_establecimiento = j.cole_cod_dane_establecimiento
          );

        -- 5. Insertar Sedes
        INSERT INTO sede (cole_cod_dane_sede, cole_cod_dane_establecimiento,
                          cole_nombre_sede, cole_sede_principal,
                          cod_mcpio, cole_area_ubicacion, cole_jornada)
        SELECT DISTINCT cole_cod_dane_sede, cole_cod_dane_establecimiento,
                        cole_nombre_sede, cole_sede_principal,
                        cod_mcpio, cole_area_ubicacion, cole_jornada
        FROM jsonb_to_recordset(p_json->'Sede')
             AS j(cole_cod_dane_sede bigint,
                  cole_cod_dane_establecimiento bigint,
                  cole_nombre_sede varchar(285),
                  cole_sede_principal boolean,
                  cod_mcpio bigint,
                  cole_area_ubicacion varchar(40),
                  cole_jornada varchar(50))
        WHERE cole_cod_dane_sede IS NOT NULL
          AND NOT EXISTS (
              SELECT 1 FROM sede s WHERE s.cole_cod_dane_sede = j.cole_cod_dane_sede
          );

        -- 6. Insertar Estudiantes
        INSERT INTO estudiante (estu_consecutivo, estu_tipodocumento, estu_estudiante,
                                estu_fechanacimiento, estu_genero, estu_nacionalidad,
                                estu_privado_libertad, estu_estadoinvestigacion)
        SELECT DISTINCT estu_consecutivo, estu_tipodocumento, estu_estudiante,
                        estu_fechanacimiento, estu_genero, estu_nacionalidad,
                        estu_privado_libertad, estu_estadoinvestigacion
        FROM jsonb_to_recordset(p_json->'Estudiante')
             AS j(estu_consecutivo varchar,
                  estu_tipodocumento varchar(35),
                  estu_estudiante varchar(285),
                  estu_fechanacimiento date,
                  estu_genero varchar(5),
                  estu_nacionalidad varchar(80),
                  estu_privado_libertad boolean,
                  estu_estadoinvestigacion varchar(50))
        WHERE estu_consecutivo IS NOT NULL
          AND NOT EXISTS (
              SELECT 1 FROM estudiante e WHERE e.estu_consecutivo = j.estu_consecutivo
          );

        -- 7. Tablas de relación
        INSERT INTO ubicacion_presentacion (estu_consecutivo, cole_cod_dane_sede)
        SELECT DISTINCT estu_consecutivo, cole_cod_dane_sede
        FROM jsonb_to_recordset(p_json->'Ubicacion_Presentacion')
             AS j(estu_consecutivo varchar, cole_cod_dane_sede bigint);

        INSERT INTO ubicacion_residencia (estu_consecutivo, cod_mcpio, estu_pais_reside)
        SELECT DISTINCT estu_consecutivo, cod_mcpio, estu_pais_reside
        FROM jsonb_to_recordset(p_json->'Ubicacion_Residencia')
             AS j(estu_consecutivo varchar, cod_mcpio bigint, estu_pais_reside varchar(130));

        INSERT INTO familia (estu_consecutivo, fami_cuartoshogar, fami_educacionmadre,
                             fami_educacionpadre, fami_estratovivienda, fami_personashogar,
                             fami_tieneautomovil, fami_tienecomputador,
                             fami_tieneinternet, fami_tienelavadora)
        SELECT DISTINCT estu_consecutivo, fami_cuartoshogar, fami_educacionmadre,
                        fami_educacionpadre, fami_estratovivienda, fami_personashogar,
                        fami_tieneautomovil, fami_tienecomputador,
                        fami_tieneinternet, fami_tienelavadora
        FROM jsonb_to_recordset(p_json->'Familia')
             AS j(estu_consecutivo varchar,
                  fami_cuartoshogar varchar(50),
                  fami_educacionmadre varchar(130),
                  fami_educacionpadre varchar(130),
                  fami_estratovivienda varchar(50),
                  fami_personashogar varchar(50),
                  fami_tieneautomovil boolean,
                  fami_tienecomputador boolean,
                  fami_tieneinternet boolean,
                  fami_tienelavadora boolean);

        INSERT INTO resultados (estu_consecutivo, periodo, desemp_ingles, punt_ingles,
                                punt_matematicas, punt_sociales_ciudadanas, punt_c_naturales,
                                punt_lectura_critica, punt_global)
        SELECT DISTINCT estu_consecutivo, periodo, desemp_ingles, punt_ingles,
                        punt_matematicas, punt_sociales_ciudadanas, punt_c_naturales,
                        punt_lectura_critica, punt_global
        FROM jsonb_to_recordset(p_json->'Resultados')
             AS j(estu_consecutivo varchar,
                  periodo int,
                  desemp_ingles varchar(10),
                  punt_ingles int,
                  punt_matematicas int,
                  punt_sociales_ciudadanas int,
                  punt_c_naturales int,
                  punt_lectura_critica int,
                  punt_global int);

    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Error: %', SQLERRM;
            RAISE;
    END;
END;
$$;
