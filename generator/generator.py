import random
from datetime import datetime
from typing import List, Tuple
from faker import Faker
from contextlib import closing

import oracledb
from oracledb.connection import Connection

N = 100


def generate_fake_data() -> List[Tuple]:
    fake = Faker()
    records = []
    for _ in range(N):
        records.append((
            fake.first_name(),
            fake.last_name(),
            random.randint(20, 70),
            fake.city(),
            fake.address(),
            fake.phone_number(),
            datetime.now(),
            datetime.now()
        ))
    return records


def get_oracle_conn() -> Connection:
    conn = oracledb.connect(
        user="AFADEEV",
        password='AFADEEV123',
        host="localhost",
        port=1521,
        service_name="XEPDB1"
    )
    conn.autocommit = False
    return conn


def main() -> None:
    data = generate_fake_data()

    select_query = "SELECT COUNT(*) FROM AFADEEV.USERS"

    insert_query = """
        INSERT INTO AFADEEV.USERS (
            FIRST_NAME,
            LAST_NAME,
            AGE,
            CITY,
            ADDRESS,
            PHONE_NUMBER,
            CREATED_AT,
            UPDATED_AT
        ) VALUES (:1, :2, :3, :4, :5, :6, :7, :8)
    """
    with closing(get_oracle_conn()) as conn, closing(conn.cursor()) as cursor:
        cursor.executemany(insert_query, data)
        conn.commit()

        answer = list(cursor.execute(select_query))
        conn.commit()
        print(answer)


if __name__ == '__main__':
    main()
