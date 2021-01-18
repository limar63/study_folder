package ru.deliveryClub;

import org.junit.After;
import org.junit.Before;
import org.openqa.selenium.chrome.ChromeDriver;

import java.util.HashMap;
import java.util.Map;

//This class is to avoid additional code in main file with @before @after
public class WebDriverSettings {

    public Map<String, Object> vars;
    public ChromeDriver driver;

    @Before //Launches every time before activating @test routine
    public void setUp() {
        System.setProperty("webdriver.chrome.driver", "./src/test/resources/chromedriver");
        driver = new ChromeDriver(); //adding a web driver for chrome and importing
        System.out.println("Starting test");
        vars = new HashMap<String, Object>();
    }
/*
    @After //Launches every time after completing a @test routine
    public void CloseBrowser() {
        driver.quit();
    }
*/

}
