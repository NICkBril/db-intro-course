# Лабораторна робота №6
# iCARus

## 1. Початкова схема

Для виконання лабораторної роботи використано нормалізовану схему з лабораторної роботи №5 (`schema_normalized.sql`).

Окремо створено базу даних icarus_lab6, щоб не змінювати базу попередніх лабораторних робіт. Початкову структуру та тестові дані перенесено до неї.


Початкова схема містила п'ять таблиць:

| Таблиця | Стовпці | PK | FK |
|---|---|---|---|
| `customer` | `customer_id`, `first_name`, `last_name`, `email`, `phone`, `city`, `street`, `house_number` | `customer_id` | — |
| `car_model` | `car_model_id`, `brand`, `model`, `category`, `description`, `daily_rate` | `car_model_id` | — |
| `car` | `car_id`, `car_model_id`, `status` | `car_id` | `car_model_id` -> `car_model` |
| `rental` | `rental_id`, `customer_id`, `car_id`, `start_date`, `end_date`, `price`, `status` | `rental_id` | `customer_id` -> `customer`, `car_id` -> `car` |
| `payment` | `payment_id`, `rental_id`, `amount`, `payment_date`, `status` | `payment_id` | `rental_id` -> `rental` |


## 2. Перша міграція: додавання таблиці `review`

**Назва міграції:** `add_review_table`

На першому етапі до схеми додано нову таблицю `review`, яка зберігає відгуки про конкретні оренди автомобілів.

Таблиця має зв'язок із `rental`: одна оренда може мати декілька відгуків, але кожен відгук належить лише одній оренді.

**Було:**  Таблиці `review` у базі даних не було.

**Стало:**  `review(review_id PK, rental_id FK, rating, comment, created_at)`

Модель Prisma:

```prisma
model review {
  review_id  Int      @id @default(autoincrement())
  rental_id  Int
  rating     Int
  comment    String?
  created_at DateTime @default(now()) @db.Timestamp(6)
  rental     rental   @relation(fields: [rental_id], references: [rental_id], onDelete: NoAction, onUpdate: NoAction)
}
```

У моделі `rental` також додано зворотний зв'язок:

```prisma
review review[]
```

Основна частина SQL-міграції:

```sql
CREATE TABLE "review" (
    "review_id" SERIAL NOT NULL,
    "rental_id" INTEGER NOT NULL,
    "rating" INTEGER NOT NULL,
    "comment" TEXT,
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "review_pkey" PRIMARY KEY ("review_id")
);

ALTER TABLE "review"
ADD CONSTRAINT "review_rental_id_fkey"
FOREIGN KEY ("rental_id")
REFERENCES "rental"("rental_id")
ON DELETE NO ACTION ON UPDATE NO ACTION;
```


## 3. Друга міграція: додавання поля `color`

**Назва міграції:** `add_car_color`

На другому етапі до наявної таблиці `car` додано поле `color`, яке зберігає колір конкретного автомобіля. Це, потенційно, може полегшити пошук для користувача (задати у фільтрах колір і вже по ньому шукати авто).

**Було:**  `car(car_id, car_model_id, status)`

**Стало:**  `car(car_id, car_model_id, status, color)`

У моделі Prisma додано:

```prisma
color String? @db.VarChar(50)
```

Поле зроблено необов'язковим (`String?`), оскільки в таблиці вже були наявні записи, для яких значення кольору не задане.

SQL-міграція:

```sql
ALTER TABLE "car"
ADD COLUMN "color" VARCHAR(50);
```


## 4. Третя міграція: видалення поля `description`

**Назва міграції:** `remove_car_model_description`

На третьому етапі з таблиці `car_model` видалено поле `description`.

Це поле містило текстовий опис моделі автомобіля. У межах цієї лабораторної роботи його вирішено прибрати зі структури бази даних.

**Було:**  `car_model(car_model_id, brand, model, category, description, daily_rate)`

**Стало:**  `car_model(car_model_id, brand, model, category, daily_rate)`

Із моделі Prisma видалено:

```prisma
description String?
```

SQL-міграція:

```sql
ALTER TABLE "car_model"
DROP COLUMN "description";
```


## 5. Підсумок виконаних міграцій

У результаті виконано три окремі зміни структури бази даних:

| № | Назва міграції | Зміна |
|---|---|---|
| 1 | `add_review_table` | Створено таблицю `review` та зв'язок із `rental` |
| 2 | `add_car_color` | Додано необов'язкове поле `color` до `car` |
| 3 | `remove_car_model_description` | Видалено поле `description` із `car_model` |


Усі створені міграції збережено в каталозі `prisma/migrations`. Для кожної міграції Prisma автоматично сформувала SQL-файл `migration.sql`.


## 6. Перевірка роботи Prisma Client

Для перевірки роботи Prisma Client створено скрипт `verify.mts`.

За допомогою нього виконано такі операції:
- отримано одну наявну оренду з таблиці `rental`;
- додано тестовий відгук до таблиці `review`;
- отримано створений відгук разом із пов'язаною орендою;
- отримано список автомобілів із новим полем `color`.

Результат виконання скрипта:

```text
Створений відгук:
{
  review_id: 1,
  rating: 5,
  comment: 'Тестовий відгук для перевірки Prisma Client',
  rental_id: 1
}

Автомобілі та їхні кольори:
[
  { car_id: 1, color: null },
  { car_id: 2, color: null },
  { car_id: 3, color: null },
  { car_id: 4, color: null },
  { car_id: 5, color: null }
]
```
