
import { loadEnvFile } from "node:process";
loadEnvFile();

import { PrismaClient } from "./generated/prisma/client.ts";

const prisma = new PrismaClient();

async function main() {
    const rental = await prisma.rental.findFirst({
        select: {
            rental_id: true
        }
    });

    if (!rental) {
        throw new Error("У базі немає оренд для перевірки.");
    }

    const review = await prisma.review.create({
        data: {
            rental_id: rental.rental_id,
            rating: 5,
            comment: "Тестовий відгук для перевірки Prisma Client"
        }
    });

    const savedReview = await prisma.review.findUnique({
        where: {
            review_id: review.review_id
        },
        include: {
            rental: true
        }
    });

    if (!savedReview) {
        throw new Error("Не вдалося знайти створений відгук.");
    }

    console.log("Створений відгук:");
    console.log({
        review_id: savedReview.review_id,
        rating: savedReview.rating,
        comment: savedReview.comment,
        rental_id: savedReview.rental.rental_id
    });

    const cars = await prisma.car.findMany({
        select: {
            car_id: true,
            color: true
        }
    });

    console.log("Автомобілі та їхні кольори:");
    console.log(cars);
}

main()
    .catch((error) => {
        console.error(error);
        process.exitCode = 1;
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
