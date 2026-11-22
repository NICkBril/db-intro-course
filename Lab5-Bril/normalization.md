# Лабораторна робота №5
# iCARus

## 1. Початкова схема

Це схема з лабораторної роботи №2 (файл `schema.sql`):

| Таблиця | Стовпці | PK | FK |
|---|---|---|---|
| `customer` | `customer_id`, `first_name`, `last_name`, `email`, `phone`, `address` | `customer_id` | — |
| `car_model` | `car_model_id`, `brand`, `model`, `category`, `description`, `daily_rate` | `car_model_id` | — |
| `car` | `car_id`, `car_model_id`, `status` | `car_id` | `car_model_id` -> `car_model` |
| `rental` | `rental_id`, `customer_id`, `car_id`, `start_date`, `end_date`, `price`, `status` | `rental_id` | `customer_id` -> `customer`, `car_id` -> `car` |
| `payment` | `payment_id`, `rental_id`, `amount`, `payment_date`, `status` | `payment_id` | `rental_id` -> `rental` |

## 2. Ключі та функціональні залежності

`customer`: Ключі: `customer_id` (PK), `email` (альтернативний, UNIQUE).

```
customer_id -> first_name, last_name, email, phone, address
email       -> customer_id, first_name, last_name, phone, address
```

`car_model`: Ключі: `car_model_id` (PK).

```
car_model_id   -> brand, model, category, description, daily_rate
```

Атрибути `brand`, `model` та `category` окремо не визначають інші атрибути таблиці. Наприклад, одна марка може мати автомобілі різних категорій, а одна категорія може містити моделі з різними тарифами.

`car`: Ключ: `car_id`.

```
car_id -> car_model_id, status
```

`rental`: Ключ: `rental_id`.

```
rental_id -> customer_id, car_id, start_date, end_date, price, status
```

`payment`: Ключ: `payment_id`.

```
payment_id -> rental_id, amount, payment_date, status
```

`rental.price` зберігається окремо від `car_model.daily_rate`, оскільки фіксує вартість конкретної оренди, яка не повинна змінюватися у разі зміни стандартного тарифу моделі автомобіля. У таблиці `rental` цей атрибут безпосередньо залежить від `rental_id` і не визначається іншими неключовими атрибутами, тому транзитивної залежності немає.

## 3. Нормальні форми початкової схеми

| Таблиця | 1НФ | 2НФ | 3НФ | Пояснення |
|---|---|---|---|---|
| `customer` | ❌ | — | — | `address` містить місто та вулицю в одному полі (`'Kyiv...'`), значення не атомарне |
| `car_model` | ✅ | ✅ | ✅ | PK одноатрибутний, часткові залежності від його складових відсутні |
| `car` | ✅ | ✅ | ✅ | кожен неключовий атрибут залежить лише від `car_id` |
| `rental` | ✅ | ✅ | ✅ | PK одноатрибутний, неключові атрибути не залежать один від одного |
| `payment` | ✅ | ✅ | ✅ | PK одноатрибутний, неключові атрибути не залежать один від одного |

Таблиця `customer` порушує 1НФ через неатомарне поле `address`, тому схема в початковому вигляді не відповідає 1НФ. Решта таблиць уже в 3НФ. Часткових залежностей немає, бо всі первинні ключі одноатрибутні,  транзитивних залежностей немає.

## 4. Кроки нормалізації

### 4.1. Крок 1: 1НФ (таблиця `customer`)

**Було:** `customer(customer_id PK, first_name, last_name, email UNIQUE, phone, address)`

**Стало:** `customer(customer_id PK, first_name, last_name, email UNIQUE, phone, city, street, house_number)`

Поле `address` розділяється на три атомарні атрибути (`city`, `street`, `house_number`) і видаляється.

```sql
ALTER TABLE customer ADD COLUMN city VARCHAR(100);
ALTER TABLE customer ADD COLUMN street VARCHAR(100);
ALTER TABLE customer ADD COLUMN house_number VARCHAR(20);

UPDATE customer SET city = 'Kyiv', street = 'Khreshchatyk St', house_number = '22' WHERE customer_id = 1;
UPDATE customer SET city = 'Lviv', street = 'Horodotska St', house_number = '15' WHERE customer_id = 2;
UPDATE customer SET city = 'Odesa', street = 'Pushkinska St', house_number = '18' WHERE customer_id = 3;
UPDATE customer SET city = 'Kharkiv', street = 'Poltavskyi Shliakh St', house_number = '30' WHERE customer_id = 4;
UPDATE customer SET city = 'Dnipro', street = 'Naberezhna Peremohy St', house_number = '32' WHERE customer_id = 5;

ALTER TABLE customer ALTER COLUMN city SET NOT NULL;
ALTER TABLE customer ALTER COLUMN street SET NOT NULL;
ALTER TABLE customer ALTER COLUMN house_number SET NOT NULL;

ALTER TABLE customer DROP COLUMN address;
```

**Функціональні залежності після кроку:**

```
customer_id -> first_name, last_name, email, phone, city, street, house_number
email       -> customer_id, first_name, last_name, phone, city, street, house_number
```

### 4.2. Крок 2: 2НФ

Часткова залежність можлива лише від частини складеного ключа. Усі первинні ключі одноатрибутні, тож таблиці вже в 2НФ.

### 4.3. Крок 3: 3НФ

Для кожної таблиці перевірено, чи не залежить неключовий атрибут від іншого неключового:

- `customer`: `city`, `street`, `house_number` та `phone` не визначають один одного. `email` є альтернативним ключем.
- `car_model`: `category` не визначає `daily_rate`, `brand` не визначає `category`
- `car`, `rental`, `payment`: ланцюгів виду "неключовий -> неключовий" немає

Транзитивних залежностей не виявлено, змін не потрібно.

## 5. Фінальна схема

Усі таблиці в 3НФ. Змінилися лише `customer` (`address` розділено на `city`, `street`, `house_number`).

```sql
CREATE TABLE customer (
    customer_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    city VARCHAR(100) NOT NULL,
    street VARCHAR(100) NOT NULL,
    house_number VARCHAR(20) NOT NULL
);
```

Таблиці `car`, `rental`, `payment` та ENUM-типи залишилися без змін. Повний скрипт із `DROP TABLE` і `CREATE TABLE` для всіх таблиць лежить у `schema_normalized.sql`, а дані для нової структури в `test_data_normalized.sql`.

**Оновлена ER-діаграма:** [`ERmodel_normalized.mmd`](ERmodel_normalized.mmd), експорт: [`ERmodel_normalized.png`](ERmodel_normalized.png). Зміни порівняно з лабораторною №1: у `Customer` поле `address` розділено на `city`, `street` та `houseNumber`. ідентифікатори й зовнішні ключі позначено типом `int` (як у схемі).