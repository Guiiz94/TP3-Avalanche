// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/WeatherNFT.sol";

contract WeatherNFTTest is Test {
    WeatherNFT private weatherNFT;

    address private owner = address(0x123);
    address private user = address(0x456);

    function setUp() public {
        vm.prank(owner);
        weatherNFT = new WeatherNFT();
    }

    function testMintNFT() public {
        vm.startPrank(owner);

        WeatherNFT.WeatherData memory initialWeather = WeatherNFT.WeatherData({
            temperature: 20,
            humidity: 50,
            windSpeed: 10,
            weatherImage: "image_url",
            additionalInfo: "Sunny"
        });

        string memory uriTemplate = "https://api.example.com/metadata";

        weatherNFT.mint(user, initialWeather, uriTemplate);

        assertEq(weatherNFT.ownerOf(0), user);

        WeatherNFT.WeatherData[] memory history = weatherNFT.getWeatherHistory(0);
        assertEq(history.length, 1);
        assertEq(history[0].temperature, 20);
        assertEq(history[0].humidity, 50);
        assertEq(history[0].windSpeed, 10);
        assertEq(history[0].weatherImage, "image_url");
        assertEq(history[0].additionalInfo, "Sunny");

        vm.stopPrank();
    }

    function testUpdateWeather() public {
        vm.startPrank(owner);

        WeatherNFT.WeatherData memory initialWeather = WeatherNFT.WeatherData({
            temperature: 20,
            humidity: 50,
            windSpeed: 10,
            weatherImage: "image_url",
            additionalInfo: "Sunny"
        });
        weatherNFT.mint(user, initialWeather, "https://api.example.com/metadata");

        // Mise à jour des données météo
        WeatherNFT.WeatherData memory newWeather = WeatherNFT.WeatherData({
            temperature: 25,
            humidity: 60,
            windSpeed: 15,
            weatherImage: "new_image_url",
            additionalInfo: "Cloudy"
        });
        weatherNFT.updateWeather(0, newWeather);

        // Vérification de l'historique
        WeatherNFT.WeatherData[] memory history = weatherNFT.getWeatherHistory(0);
        assertEq(history.length, 2);
        assertEq(history[1].temperature, 25);
        assertEq(history[1].humidity, 60);
        assertEq(history[1].windSpeed, 15);
        assertEq(history[1].weatherImage, "new_image_url");
        assertEq(history[1].additionalInfo, "Cloudy");

        vm.stopPrank();
    }

    function testTokenURI() public {
        vm.startPrank(owner);

        WeatherNFT.WeatherData memory initialWeather = WeatherNFT.WeatherData({
            temperature: 20,
            humidity: 50,
            windSpeed: 10,
            weatherImage: "image_url",
            additionalInfo: "Sunny"
        });
        weatherNFT.mint(user, initialWeather, "https://api.example.com/metadata");

        // Test de l'URI générée
        string memory expectedURI = "https://api.example.com/metadata?temp=20&humidity=50&wind=10&info=Sunny";
        assertEq(weatherNFT.tokenURI(0), expectedURI);

        vm.stopPrank();
    }

    function testFailMintByNonOwner() public {
        vm.startPrank(user); // Simule un appel par un utilisateur non autorisé

        // Tentative de mint (doit échouer)
        WeatherNFT.WeatherData memory initialWeather = WeatherNFT.WeatherData({
            temperature: 20,
            humidity: 50,
            windSpeed: 10,
            weatherImage: "image_url",
            additionalInfo: "Sunny"
        });

        weatherNFT.mint(user, initialWeather, "https://api.example.com/metadata");

        vm.stopPrank();
    }

    function testFailUpdateByNonOwner() public {
        vm.startPrank(owner);

        WeatherNFT.WeatherData memory initialWeather = WeatherNFT.WeatherData({
            temperature: 20,
            humidity: 50,
            windSpeed: 10,
            weatherImage: "image_url",
            additionalInfo: "Sunny"
        });
        weatherNFT.mint(user, initialWeather, "https://api.example.com/metadata");

        vm.stopPrank();

        vm.startPrank(user); // Simule un appel par un utilisateur non autorisé

        // Tentative de mise à jour (doit échouer)
        WeatherNFT.WeatherData memory newWeather = WeatherNFT.WeatherData({
            temperature: 25,
            humidity: 60,
            windSpeed: 15,
            weatherImage: "new_image_url",
            additionalInfo: "Cloudy"
        });

        weatherNFT.updateWeather(0, newWeather);

        vm.stopPrank();
    }
}
