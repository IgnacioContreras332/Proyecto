import mysql.connector

def conectar_db():
    try:
        conn = mysql.connector.connect(
            host="localhost",
            user="root",
            password="coai8833",
            database="comedero_db"
        )
        return conn
    except mysql.connector.Error as e:
        print(f"❌ Error al conectar a MySQL: {e}")
        return None