pragma solidity >= 0.6;
pragma experimental ABIEncoderV2;

import "https://raw.githubusercontent.com/smartcontractkit/chainlink/master/evm-contracts/src/v0.6/VRFConsumerBase.sol";

contract GachaGame is VRFConsumerBase {
    
    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public randomResult;
    
    uint168 constant pullCost = 1000000000000000;
    uint8 constant pullMinimum = 1;
    
    struct Card {
        string Name;
        uint8 Value;
    }
    
    Card[] private currentCards;
    
    mapping(string => Card) cards;
    mapping(address => uint) balance;
    
    event Pull(Card card);
    
    constructor() VRFConsumerBase(
            0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B, // VRF Coordinator
            0x01BE23585060835E02B77ef475b0Cc51aA1e0709  // LINK Token
        ) public {
        initCards();
        keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
        fee = 0.1 * 10 ** 18; // 0.1 LINK
    }
    
    function getAllPulledCards() public view returns (Card[] memory) {
        return currentCards;
    }
    
    function pay() public payable {
        require(msg.value >= pullCost, "0.001 Ether is the minimum requirement");
        balance[msg.sender] += msg.value / pullCost;
    }
    
    function pull(uint count) public {
        require(balance[msg.sender] >= 1, "You do not have enough funds to pull!");
        require(count >= pullMinimum, "You need to pull a minimum of 1 time");
        require(count <= balance[msg.sender], "You do not have enough funds to pull that many times!");
        
        for(uint i = 0; i < count; i++) {
            balance[msg.sender] -= 1;
            randomNumberGenerator(count);
        }
    }
    
    function checkBalance() public view returns (uint){
        return balance[msg.sender];
    }
    
    function randomNumberGenerator(uint256 count) public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) > fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee, count);
    }
    
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = uint8(randomness);
        gachaPull(randomResult);
    }
    
    function gachaPull(uint randomNumber) private {
        if (randomNumber > 25) {
            currentCards.push(cards["Rare"]);
        } else if (randomNumber >= 5 && randomNumber <= 25) {
            currentCards.push(cards["Super Rare"]);
        } else currentCards.push(cards["Ultra Rare"]);
        
        emit Pull(currentCards[currentCards.length - 1]);
    }
    
    function initCards() private {
        cards["Rare"] = Card({
                Name: "Rare",
                Value: 1
        });
        cards["Super Rare"] = Card({
                Name: "Super Rare",
                Value: 3
        });
        cards["Ultra Rare"] = Card({
                Name: "Ultra Rare",
                Value: 10
        });
    }
    
}
