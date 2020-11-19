pragma solidity >= 0.6;
pragma experimental ABIEncoderV2;

contract GachaGame {
    
    uint8 constant pullCost = 1;
    uint8 constant pullMinimum = 1;
    
    struct Card {
        string Name;
        uint8 Value;
    }
    
    Card[] private cards;
    Card[] private currentCards;
    
    uint balance;
    
    constructor() {
        initCards();
    }
    
    function getAllPulledCards() public view returns (Card[] memory) {
        return currentCards;
    }
    
    function pay() public payable {
        require(msg.value >= 1 ether, "1 Ether is the minimum requirement");
        balance += msg.value / 1 ether;
    }
    
    function pull(uint count) public returns (Card[] memory) {
        require(balance >= pullCost, "You do not have enough funds to pull!");
        require(count >= pullMinimum, "You need to pull a minimum of 1 time");
        require(count <= balance, "You do not have enough funds to pull that many times!");
        
        for(uint i = 0; i < count; i++) {
            currentCards.push(cards[0]);
            balance -= pullCost;
        }
        
        return currentCards;
    }
    
    function checkBalance() public view returns (uint){
        return balance;
    }
    
    function randomNumberGenerator() private view returns (uint8) {
        uint8 randomnumber = uint8(uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, block.timestamp))) % 100);
        return randomnumber;
    }
    
    function gachaPull() private view returns (Card memory card) {
        uint8 randomNumber = randomNumberGenerator();
        
        if (randomNumber > 25) {
            return cards[0];
        } else if (randomNumber >= 5 && randomNumber <= 25) {
            return cards[1];
        } 
        return cards[2];
    }
    
    function initCards() private {
        cards.push(
            Card({
                Name: "Rare",
                Value: 1
            })
        );
        cards.push(
            Card({
                Name: "Super Rare",
                Value: 3
            })
        );
        cards.push(
            Card({
                Name: "Ultra Rare",
                Value: 10
            })
        );
    }
    
}
