import psycopg2

conn = psycopg2.connect(dbname='postgres', user='postgres', 
                        password='16311922', host='localhost')
cursor = conn.cursor()
cursor.execute('Select * from db_project.client')
for elem in cursor.fetchall():
    print(f'Client\'s full name {elem[1]} {elem[2]}')

cursor.execute('select * from db_project.menu_statistics')
for elem in cursor.fetchall():
    print(f'{elem[3]} всех потраченных на еду денег в "Капризе" {elem[0]} {elem[1]} спустил на {elem[2]}')

#TODO: what to do?
