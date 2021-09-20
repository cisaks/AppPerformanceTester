package helpers;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

import com.github.javafaker.Faker;

public class DataGenerator {
    
    public static String getRandomEmail(){
        Faker faker = new Faker();
        String email = faker.name().firstName().toLowerCase() + faker.random().nextInt(0,1000) + "@email.com";
        return email;
    }

    public static String getRandomName(){
        Faker faker = new Faker();
        String name = faker.name().fullName();
        return name;
    }

    public static String getCurrentDate(){
        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("uuuu-MM-dd");
        String date = dateFormatter.format(LocalDate.now()).toString();
        return date;
    }

}
