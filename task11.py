from sqlalchemy import create_engine, Column, Integer, String, func
from sqlalchemy.orm import declarative_base, sessionmaker

engine = create_engine(f'postgresql://postgres:16311922@localhost/postgres')
Session = sessionmaker(bind=engine)
Base = declarative_base()
session = Session()

class Dish(Base):
    __tablename__ = 'menu'
    __table_args__ = {'schema': 'db_project'}

    dish_id = Column(Integer, primary_key=True)
    dish_name = Column(String)
    description = Column(String)
    price = Column(Integer)

#read
def print_menu():
    for dish in session.query(Dish).all():
        print(f'{dish.dish_name} стоит {dish.price}')

print("==Before insert==")
print_menu()

#create
new_dish = Dish(dish_name='Кровавая Мэри', description='Водка с томатным соком и специями', price = 1000)
session.add(new_dish)
session.commit()
print("==After insert==")
print_menu()
    
#update
print_menu()
dish = session.query(Dish).filter(Dish.dish_name == 'Кровавая Мэри').first()
dish.price += 500
session.commit()
print("==After update==")
print_menu()

# delete
session.delete(session.query(Dish).filter(Dish.dish_name == 'Кровавая Мэри').first())
session.commit()
print("==After delete==")
print_menu()
class Menu_X_booking(Base):
    __tablename__ = 'menu_x_booking'
    __table_args__= {'schema' : 'db_project'}

    dish_id = Column(Integer, primary_key=True)
    order_id = Column(Integer, primary_key=True)
    amount = Column(Integer)
print("==Dish statistics==")
for elem in session.query(func.sum(Menu_X_booking.amount), Menu_X_booking.dish_id).group_by(Menu_X_booking.dish_id).order_by(Menu_X_booking.dish_id).all():
    print(f'Блюдо {elem[1]} заказано {elem[0]} раз')

#def print_order():
#        for elem in session.query(Menu_X_booking).filter(Menu_X_booking.order_id == 1).all():
#            print(f'В первом заказе блюдо номер {elem.dish_id} заказано {elem.amount} раз')

#session.query(Menu_X_booking).filter(Menu_X_booking.order_id == 1 and Menu_X_booking.dish_id == 7).delete()
#session.commit()
#print('Before update')
#print_order()
#new_dish_in_order = Menu_X_booking(dish_id=7, order_id = 1, amount=5)
#session.add(new_dish_in_order)
#session.commit()
#print("After update")
#print_order()
