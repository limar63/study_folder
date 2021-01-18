package ru.deliveryClub;

import org.apache.commons.io.FileUtils;
import org.junit.Test;
import org.openqa.selenium.By;
import org.openqa.selenium.NoSuchElementException;
import org.openqa.selenium.OutputType;
import org.openqa.selenium.TakesScreenshot;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

public class FirstTest extends WebDriverSettings {

    Map<String, int[]> manufacturers;
    int checkPrice;
    public Map<String, int[]> getHardwareManufacturer(NodeList nodeList, String hardware,
                                                          String nodeName, String attName) {
        Map<String, int[]> result = new HashMap<>();
        for (int i = 0; i < nodeList.getLength(); i++) {
            String attributeLine = ((Element) nodeList.item(i)).getAttribute(attName);
            NodeList embeddedName = ((Element) nodeList.item(i)).getElementsByTagName(nodeName);
            NodeList embeddedMinPrice = ((Element) nodeList.item(i)).getElementsByTagName("Min");
            NodeList embeddedMaxPrice = ((Element) nodeList.item(i)).getElementsByTagName("Max");
            if (attributeLine.indexOf(hardware) != -1) {
                int[] prices = new int[]{Integer.parseInt(embeddedMinPrice.item(0).getTextContent()) * 10,
                        Integer.parseInt(embeddedMaxPrice.item(0).getTextContent()) * 10, 0};
                result.put(embeddedName.item(0).getTextContent(), prices);
            }

        }
        return result;
    }

    public void getXML() {
        try {
            // creating a constructor of file class and
            // parsing an XML file
            File file = new File("./src/test/resources/source.xml");

            // Defines a factory API that enables
            // applications to obtain a parser that produces
            // DOM object trees from XML documents.
            DocumentBuilderFactory dbf
                    = DocumentBuilderFactory.newInstance();

            // we are creating an object of builder to parse
            // the  xml file.
            DocumentBuilder db = dbf.newDocumentBuilder();
            Document doc = db.parse(file);

            /*here normalize method Puts all Text nodes in
            the full depth of the sub-tree underneath this
            Node, including attribute nodes, into a "normal"
            form where only structure separates
            Text nodes, i.e., there are neither adjacent
            Text nodes nor empty Text nodes. */
            doc.getDocumentElement().normalize();
            System.out.println(
                    "Root element: "
                            + doc.getDocumentElement().getNodeName());

            // Here nodeList contains all the nodes with
            // name geek.
            NodeList manufacturerList
                    = doc.getElementsByTagName("Manufacturer");

            manufacturers = getHardwareManufacturer
                    (manufacturerList, "notebook","Name", "products");
            checkPrice = Integer.parseInt(doc.getElementsByTagName("Max").item(0).getTextContent()) * 10;
        }

        // This exception block catches all the exception
        // raised.
        // For example if we try to access a element by a
        // TagName that is not there in the XML etc.
        catch (Exception e) {
            System.out.println(e);
        }
    }
        /*@Test //Making connection towards Junit and adding import of junit
    public void firstTest() {
        driver.get("https://market.yandex.ru");
        String title = driver.getTitle();
        //Assert.assertTrue(title.equals("Доставка еды из ресторанов Самары от 45 минут! Delivery Club"));
    }*/
    @Test
    public void SecondTest() throws IOException {
        driver.get("https://market.yandex.ru/");
        driver.findElement(By.cssSelector(".\\_6RmNBByo8N")).click();
        driver.findElement(By.cssSelector(".\\_2ACm4NQBiK > #header-search")).click();
        driver.findElement(By.cssSelector(".\\_2ACm4NQBiK > #header-search")).sendKeys("Сан");
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        driver.findElement(By.cssSelector(".hKCM_OMVVX")).click();
        driver.findElement(By.cssSelector(".\\_2mDuxQdhnq .\\_1qOETCp-Ym")).click();
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        driver.findElement(By.cssSelector(".APNRGSRDhZ:nth-child(3)")).click();
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        driver.findElement(By.cssSelector("#\\39 1540057-tab")).click();
        driver.findElement(By.cssSelector("[href=\"/catalog--noutbuki/54544/list?hid=91013\"]")).click();
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        driver.findElement(By.cssSelector(".\\_3_phr-spJh:nth-child(3) .\\_1YeOF5Jcfi")).click();
        //line = line.substring(0, line.length() - 3);





        getXML();
        String keyDiag = "";
        int maxDiag = 0;
        for (Map.Entry mapElement : manufacturers.entrySet()) {
            String key = (String)mapElement.getKey();
            int[] valueArray = ((int[])mapElement.getValue());


            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            driver.findElement(By.name("Поле поиска")).sendKeys(key);
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            driver.findElementByXPath("//span[text()='" + key + "']").click();
            try {
                Thread.sleep(4000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            driver.findElementByXPath("//*[contains(@id,'glpricefrom')]")
                    .sendKeys(Integer.toString(valueArray[0]));
            try {
                Thread.sleep(2000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            if (valueArray[0] > checkPrice) {
                driver.findElementByXPath("//*[contains(@id,'glpriceto')]")
                        .sendKeys(Integer.toString(checkPrice));
            } else {
                driver.findElementByXPath("//*[contains(@id,'glpriceto')]")
                        .sendKeys(Integer.toString(valueArray[1]));
            }

            /* На сайте, в процессе написания тестов, этот пункт убрали и теперь данный шаг не работает :/
            try {
                Thread.sleep(7500);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            driver.findElementByXPath("//button[text()='по рейтингу']").click();
            */
            try {
                Thread.sleep(4000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }

            try {
                driver.findElementByXPath("//article[3]/div[4]/div/h3/a/span").click();
            } catch (NoSuchElementException e) {
                driver.findElementByXPath("//nav/label").click();
                driver.findElementByXPath("//p/button").click();
                driver.findElementByXPath("//li[2]/p/button").click();
                continue;
            }
            try {
                Thread.sleep(2500);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            String currentHandle = driver.getWindowHandle();
            Set<String> allHandles = driver.getWindowHandles();
            for (String handle : allHandles) {
                if (!handle.equals(currentHandle)) driver.switchTo().window(handle);
            }
            try {
                Thread.sleep(2000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            driver.findElementByXPath("//div[5]/div/div/div/ul/li[2]/div/a/span").click();
            File scrFile = ((TakesScreenshot)driver).getScreenshotAs(OutputType.FILE);
            FileUtils.copyFile(scrFile, new File("./src/test/resources/screenshots/screenshot" + key + ".png"));
            String line = driver.findElementByXPath("//div[3]/div/div/div/div/div[5]/dl/dd").getText();
            //line = line.substring(0, line.length() - 3);
            float localDiag;
            System.out.println(line);
            if (line.charAt(3) == '\"' || line.charAt(3) == 'д') {
                localDiag = Float.parseFloat(line.substring(0, 3));
            } else {
                localDiag = Float.parseFloat(line.substring(0, 4));
            }
            localDiag = localDiag * 10;
            valueArray[2] = Math.round(localDiag);
            System.out.println(valueArray[2]);
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            currentHandle = driver.getWindowHandle();
            driver.close();
            for (String handle : allHandles) {
                if (!handle.equals(currentHandle)) driver.switchTo().window(handle);
            }
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            if (maxDiag < valueArray[2]) {
                maxDiag = valueArray[2];
                keyDiag = key;
            }

            driver.findElementByXPath("//span[text()='" + key + "']").click();
            try {
                Thread.sleep(2000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            driver.findElementByXPath("//nav/label").click();
            driver.findElementByXPath("//p/button").click();
            driver.findElementByXPath("//li[2]/p/button").click();

        }
        System.out.println(keyDiag + " размер диагонали " + ((float) maxDiag / 10));

    }


//<span class="_1qOETCp-Ym">Продолжить с новым регионом</span>

}
