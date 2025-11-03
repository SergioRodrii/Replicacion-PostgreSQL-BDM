import logging

def load_to_sql(conn, json_data: str):
    try:
        cursor = conn.cursor()
        cursor.execute("CALL usp_insertar_lote(%s);", [json_data])
        conn.commit()
        cursor.close()
    except Exception as e:
        logging.error("Error al ejecutar el procedimiento almacenado en PostgreSQL: %s", e, exc_info=True)
        conn.rollback()
