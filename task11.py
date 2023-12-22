from sqlalchemy import create_engine, Column, Integer, String, text
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

#create
new_dish = Dish(dish_name='Кровавая Мэри', description='Водка с томатным соком и специями', price = 1000)
session.add(new_dish)
session.commit()

#read
for dish in session.query(Dish).filter(Dish.price > 1000).all():
    print(f'{dish.dish_name} стоит {dish.price}')
    
#update
dish = session.query(Dish).filter(Dish.dish_name == 'Кровавая Мэри').first()
dish.price += 500
session.commit()

# delete
session.delete(session.query(Dish).filter(Dish.dish_name == 'Кровавая Мэри').first())
session.commit()
