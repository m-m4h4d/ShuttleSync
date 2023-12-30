from decouple import config
from mysql.connector import connect, Error, connection
import os

os.environ["SqlPort"] = "127.0.0.1"
os.environ["SqlUser"] = "abubakar"
os.environ["SqlPassword"] = "abubakar"


class DataBaseCursor:
    def __init__(self):
        try:
            self.connection = connect(
                host=config("SqlPort"),
                user=config("SqlUser"),
                password=config("SqlPassword"),
            )
        except Error as e:
            print(e)

        self.cursor = self.connection.cursor()
        self.cursor.execute("USE databaseprojpractce")
        print("Connected to MySQL Server")


databaseCursor = DataBaseCursor()
cursor = databaseCursor.cursor
