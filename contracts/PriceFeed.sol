pragma solidity >=0.5.16;

contract PriceFeed {

    string public name;
    uint80 public roundID;
    int public price;
    uint public startedAt;
    uint public timeStamp;
    uint80 public answeredInRound;
    uint public decimals;

    constructor(string memory _name) public {
        name = _name;
        roundID = 0;
        price = 1000000000000000000;
        startedAt = 0;
        timeStamp = 0;
        answeredInRound = 0;
        decimals = 18;
    }

    function setPrice(int _price) external {
        price = _price;
    }

    function setDecimals(uint _decimal) external {
        decimals = _decimal;
    }

    function latestRoundData() external view returns (uint80, int, uint, uint, uint80) {
        return (roundID, price, startedAt, timeStamp, answeredInRound);
    }
}