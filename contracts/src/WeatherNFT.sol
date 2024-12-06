// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract WeatherNFT is ERC721, Ownable {
    uint256 private _nextTokenId;

    struct WeatherData {
        int256 temperature;
        uint256 humidity;
        uint256 windSpeed;
        string weatherImage;
        string additionalInfo;
    }

    mapping(uint256 => WeatherData[]) private _nftWeatherHistory;
    mapping(uint256 => string) private _nftURITemplate;

    event WeatherUpdated(uint256 indexed tokenId, WeatherData weatherData);

    constructor() ERC721("WeatherNFT", "DWNFT") Ownable(msg.sender) {}

    /// @notice Mint a new NFT
    /// @param to Address of the recipient
    /// @param initialWeather Initial weather data
    /// @param uriTemplate Base URI template for dynamic metadata
    function mint(
        address to,
        WeatherData memory initialWeather,
        string memory uriTemplate
    ) external onlyOwner {
        uint256 tokenId = _nextTokenId; 
        _safeMint(to, tokenId);
        _nftWeatherHistory[tokenId].push(initialWeather);
        _nftURITemplate[tokenId] = uriTemplate;
        _nextTokenId++;
    }

    /// @notice Update the weather data for a given NFT
    /// @param tokenId ID of the NFT
    /// @param newWeather New weather data to update
    function updateWeather(uint256 tokenId, WeatherData memory newWeather) external onlyOwner {
        require(tokenId < _nextTokenId && tokenId >= 0, "Token does not exist");
        _nftWeatherHistory[tokenId].push(newWeather);
        emit WeatherUpdated(tokenId, newWeather);
    }

    /// @notice Get the weather history of an NFT
    /// @param tokenId ID of the NFT
    /// @return List of weather data
    function getWeatherHistory(uint256 tokenId) external view returns (WeatherData[] memory) {
        require(tokenId < _nextTokenId && tokenId >= 0, "Token does not exist");
        return _nftWeatherHistory[tokenId];
    }

    /// @notice Get weather data by timestamp
    /// @param tokenId ID of the NFT
    /// @param index Index of the historical data
    /// @return Weather data at the given timestamp
    function getWeatherByIndex(uint256 tokenId, uint256 index) external view returns (WeatherData memory) {
        require(tokenId < _nextTokenId && tokenId >= 0, "Token does not exist");
        require(index < _nftWeatherHistory[tokenId].length, "Index out of bounds");
        return _nftWeatherHistory[tokenId][index];
    }

    /// @notice Override tokenURI to provide dynamic metadata
    /// @param tokenId ID of the NFT
    /// @return Dynamic URI based on current weather data
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(tokenId < _nextTokenId && tokenId >= 0, "Token does not exist");
        WeatherData memory latestWeather = _nftWeatherHistory[tokenId][_nftWeatherHistory[tokenId].length - 1];
        return string(abi.encodePacked(
            _nftURITemplate[tokenId],
            "?temp=", intToString(latestWeather.temperature),
            "&humidity=", uintToString(latestWeather.humidity),
            "&wind=", uintToString(latestWeather.windSpeed),
            "&info=", latestWeather.additionalInfo
        ));
    }

    /// @notice Utility function to convert an integer to a string
    function intToString(int256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        bool negative = value < 0;
        uint256 temp = uint256(negative ? -value : value);
        bytes memory buffer;
        while (temp != 0) {
            buffer = abi.encodePacked(uint8(48 + temp % 10), buffer);
            temp /= 10;
        }
        return negative ? string(abi.encodePacked("-", buffer)) : string(buffer);
    }

    /// @notice Utility function to convert a uint to a string
    function uintToString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        bytes memory buffer;
        while (temp != 0) {
            buffer = abi.encodePacked(uint8(48 + temp % 10), buffer);
            temp /= 10;
        }
        return string(buffer);
    }
}
