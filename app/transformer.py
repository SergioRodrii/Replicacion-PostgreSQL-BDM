import json
import pandas as pd
from datetime import datetime

def parse_int(value):
    try:
        if pd.isna(value) or str(value).strip() == "":
            return None
        return int(value)
    except ValueError:
        return None

def parse_bigint(value):
    return parse_int(value)

def parse_varchar(value):
    if pd.isna(value) or str(value).strip() == "":
        return None
    return str(value).strip()

def parse_bool(value):
    if pd.isna(value) or str(value).strip() == "":
        return None
    if str(value).lower() in ["1", "true", "s", "si"]:
        return True
    if str(value).lower() in ["0", "false", "n", "no"]:
        return False
    return None

def parse_date(value):
    if pd.isna(value) or str(value).strip() == "":
        return None
    try:
        return datetime.strptime(str(value), "%Y-%m-%d").date()
    except ValueError:
        try:
            return datetime.strptime(str(value), "%d/%m/%Y").date()
        except ValueError:
            return None


def transform_to_json(chunk: pd.DataFrame):
    data = {
        "Periodo": [],
        "Departamento": [],
        "Municipio": [],
        "Colegio": [],
        "Sede": [],
        "Estudiante": [],
        "Ubicacion_Presentacion": [],
        "Ubicacion_Residencia": [],
        "Familia": [],
        "Resultados": []
    }

    for _, row in chunk.iterrows():
        data["Periodo"].append({
            "PERIODO": parse_int(row.get("PERIODO"))
        })

        data["Departamento"].append({
            "COD_DEPTO": parse_int(row.get("ESTU_COD_RESIDE_DEPTO")),
            "COLE_DEPTO_UBICACION": parse_varchar(row.get("ESTU_DEPTO_RESIDE"))
        })

        data["Municipio"].append({
            "COD_MCPIO": parse_bigint(row.get("ESTU_COD_RESIDE_MCPIO")),
            "COLE_MCPIO_UBICACION": parse_varchar(row.get("ESTU_MCPIO_RESIDE")),
            "COD_DEPTO": parse_int(row.get("ESTU_COD_RESIDE_DEPTO"))
        })

        data["Colegio"].append({
            "COLE_COD_DANE_ESTABLECIMIENTO": parse_bigint(row.get("COLE_COD_DANE_ESTABLECIMIENTO")),
            "COLE_NOMBRE_ESTABLECIMIENTO": parse_varchar(row.get("COLE_NOMBRE_ESTABLECIMIENTO")),
            "COLE_BILINGUE": parse_bool(row.get("COLE_BILINGUE")),
            "COLE_CALENDARIO": parse_varchar(row.get("COLE_CALENDARIO")),
            "COLE_CARACTER": parse_varchar(row.get("COLE_CARACTER")),
            "COLE_GENERO": parse_varchar(row.get("COLE_GENERO")),
            "COLE_NATURALEZA": parse_varchar(row.get("COLE_NATURALEZA")),
            "COLE_CODIGO_ICFES": parse_bigint(row.get("COLE_CODIGO_ICFES"))
        })

        data["Sede"].append({
            "COLE_COD_DANE_SEDE": parse_bigint(row.get("COLE_COD_DANE_SEDE")),
            "COLE_COD_DANE_ESTABLECIMIENTO": parse_bigint(row.get("COLE_COD_DANE_ESTABLECIMIENTO")),
            "COLE_NOMBRE_SEDE": parse_varchar(row.get("COLE_NOMBRE_SEDE")),
            "COLE_SEDE_PRINCIPAL": parse_bool(row.get("COLE_SEDE_PRINCIPAL")),
            "COD_MCPIO": parse_bigint(row.get("ESTU_COD_RESIDE_MCPIO")),
            "COLE_AREA_UBICACION": parse_varchar(row.get("COLE_AREA_UBICACION")),
            "COLE_JORNADA": parse_varchar(row.get("COLE_JORNADA"))
        })

        data["Estudiante"].append({
            "ESTU_CONSECUTIVO": parse_varchar(row.get("ESTU_CONSECUTIVO")),
            "ESTU_TIPODOCUMENTO": parse_varchar(row.get("ESTU_TIPODOCUMENTO")),
            "ESTU_ESTUDIANTE": parse_varchar(row.get("ESTU_ESTUDIANTE")),
            "ESTU_FECHANACIMIENTO": parse_date(row.get("ESTU_FECHANACIMIENTO")),
            "ESTU_GENERO": parse_varchar(row.get("ESTU_GENERO")),
            "ESTU_NACIONALIDAD": parse_varchar(row.get("ESTU_NACIONALIDAD")),
            "ESTU_PRIVADO_LIBERTAD": parse_bool(row.get("ESTU_PRIVADO_LIBERTAD")),
            "ESTU_ESTADOINVESTIGACION": parse_varchar(row.get("ESTU_ESTADOINVESTIGACION"))
        })

        data["Ubicacion_Presentacion"].append({
            "ESTU_CONSECUTIVO": parse_varchar(row.get("ESTU_CONSECUTIVO")),
            "COLE_COD_DANE_SEDE": parse_bigint(row.get("COLE_COD_DANE_SEDE"))
        })

        data["Ubicacion_Residencia"].append({
            "ESTU_CONSECUTIVO": parse_varchar(row.get("ESTU_CONSECUTIVO")),
            "COD_MCPIO": parse_bigint(row.get("COD_MCPIO")),
            "ESTU_PAIS_RESIDE": parse_varchar(row.get("ESTU_PAIS_RESIDE"))
        })

        data["Familia"].append({
            "ESTU_CONSECUTIVO": parse_varchar(row.get("ESTU_CONSECUTIVO")),
            "FAMI_CUARTOSHOGAR": parse_varchar(row.get("FAMI_CUARTOSHOGAR")),
            "FAMI_EDUCACIONMADRE": parse_varchar(row.get("FAMI_EDUCACIONMADRE")),
            "FAMI_EDUCACIONPADRE": parse_varchar(row.get("FAMI_EDUCACIONPADRE")),
            "FAMI_ESTRATOVIVIENDA": parse_varchar(row.get("FAMI_ESTRATOVIVIENDA")),
            "FAMI_PERSONASHOGAR": parse_varchar(row.get("FAMI_PERSONASHOGAR")),
            "FAMI_TIENEAUTOMOVIL": parse_bool(row.get("FAMI_TIENEAUTOMOVIL")),
            "FAMI_TIENECOMPUTADOR": parse_bool(row.get("FAMI_TIENECOMPUTADOR")),
            "FAMI_TIENEINTERNET": parse_bool(row.get("FAMI_TIENEINTERNET")),
            "FAMI_TIENELAVADORA": parse_bool(row.get("FAMI_TIENELAVADORA"))
        })

        data["Resultados"].append({
            "ESTU_CONSECUTIVO": parse_varchar(row.get("ESTU_CONSECUTIVO")),
            "PERIODO": parse_int(row.get("PERIODO")),
            "DESEMP_INGLES": parse_varchar(row.get("DESEMP_INGLES")),
            "PUNT_INGLES": parse_int(row.get("PUNT_INGLES")),
            "PUNT_MATEMATICAS": parse_int(row.get("PUNT_MATEMATICAS")),
            "PUNT_SOCIALES_CIUDADANAS": parse_int(row.get("PUNT_SOCIALES_CIUDADANAS")),
            "PUNT_C_NATURALES": parse_int(row.get("PUNT_C_NATURALES")),
            "PUNT_LECTURA_CRITICA": parse_int(row.get("PUNT_LECTURA_CRITICA")),
            "PUNT_GLOBAL": parse_int(row.get("PUNT_GLOBAL"))
        })

    return json.dumps(data, default=str, ensure_ascii=False)
