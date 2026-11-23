
-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "car_status" AS ENUM ('available', 'rented', 'maintenance', 'unavailable');

-- CreateEnum
CREATE TYPE "rental_status" AS ENUM ('active', 'finished', 'cancelled', 'scheduled');

-- CreateEnum
CREATE TYPE "payment_status" AS ENUM ('paid', 'cancelled', 'pending_confirmation');

-- CreateTable
CREATE TABLE "customer" (
    "customer_id" INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    "first_name" VARCHAR(100) NOT NULL,
    "last_name" VARCHAR(100) NOT NULL,
    "email" VARCHAR(100) NOT NULL,
    "phone" VARCHAR(20) NOT NULL,
    "city" VARCHAR(100) NOT NULL,
    "street" VARCHAR(100) NOT NULL,
    "house_number" VARCHAR(20) NOT NULL,

    CONSTRAINT "customer_pkey" PRIMARY KEY ("customer_id"),
    CONSTRAINT "customer_email_key" UNIQUE ("email")
);

-- CreateTable
CREATE TABLE "car_model" (
    "car_model_id" INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    "brand" VARCHAR(100) NOT NULL,
    "model" VARCHAR(100) NOT NULL,
    "category" VARCHAR(50) NOT NULL,
    "description" TEXT,
    "daily_rate" NUMERIC(10, 2) NOT NULL,

    CONSTRAINT "car_model_pkey" PRIMARY KEY ("car_model_id"),
    CONSTRAINT "car_model_daily_rate_check" CHECK ("daily_rate" >= 0)
);

-- CreateTable
CREATE TABLE "car" (
    "car_id" INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    "car_model_id" INTEGER NOT NULL,
    "status" "car_status" NOT NULL DEFAULT 'available',

    CONSTRAINT "car_pkey" PRIMARY KEY ("car_id"),
    CONSTRAINT "car_car_model_id_fkey"
        FOREIGN KEY ("car_model_id")
        REFERENCES "car_model"("car_model_id")
);

-- CreateTable
CREATE TABLE "rental" (
    "rental_id" INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    "customer_id" INTEGER NOT NULL,
    "car_id" INTEGER NOT NULL,
    "start_date" TIMESTAMP NOT NULL,
    "end_date" TIMESTAMP NOT NULL,
    "price" NUMERIC(10, 2) NOT NULL,
    "status" "rental_status" NOT NULL DEFAULT 'scheduled',

    CONSTRAINT "rental_pkey" PRIMARY KEY ("rental_id"),
    CONSTRAINT "rental_customer_id_fkey"
        FOREIGN KEY ("customer_id")
        REFERENCES "customer"("customer_id"),
    CONSTRAINT "rental_car_id_fkey"
        FOREIGN KEY ("car_id")
        REFERENCES "car"("car_id"),
    CONSTRAINT "rental_check" CHECK ("end_date" > "start_date"),
    CONSTRAINT "rental_price_check" CHECK ("price" >= 0)
);

-- CreateTable
CREATE TABLE "payment" (
    "payment_id" INTEGER GENERATED ALWAYS AS IDENTITY NOT NULL,
    "rental_id" INTEGER NOT NULL,
    "amount" NUMERIC(10, 2) NOT NULL,
    "payment_date" TIMESTAMP NOT NULL,
    "status" "payment_status" NOT NULL DEFAULT 'pending_confirmation',

    CONSTRAINT "payment_pkey" PRIMARY KEY ("payment_id"),
    CONSTRAINT "payment_rental_id_fkey"
        FOREIGN KEY ("rental_id")
        REFERENCES "rental"("rental_id"),
    CONSTRAINT "payment_amount_check" CHECK ("amount" > 0)
);

