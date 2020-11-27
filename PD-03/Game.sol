pragma solidity >= 0.7;
pragma experimental ABIEncoderV2;

contract GachaGame {
    
    uint168 constant pullCost = 1000000000000000;
    uint8 constant pullMinimum = 1;
    
    struct Card {
        string Name;
        uint8 Value;
    }
    
    Card[] private currentCards;
    
    uint balance;
    
    mapping(string => Card) cards;
    
    event Pull(address sender, uint count, uint newBalance);
    
    constructor() {
        initCards();
    }
    
    function getAllPulledCards() public view returns (Card[] memory) {
        return currentCards;
    }
    
    function pay() public payable {
        require(msg.value >= pullCost, "0.001 Ether is the minimum requirement");
        balance += msg.value / pullCost;
    }
    
    function pull(uint count) public returns (Card[] memory) {
        require(balance >= 1, "You do not have enough funds to pull!");
        require(count >= pullMinimum, "You need to pull a minimum of 1 time");
        require(count <= balance, "You do not have enough funds to pull that many times!");
        
        for(uint i = 0; i < count; i++) {
            Card memory card = gachaPull(i);
            currentCards.push(card);
            balance -= 1;
        }
        
        emit Pull(msg.sender, count, balance);
        
        return currentCards;
    }
    
    function checkBalance() public view returns (uint){
        return balance;
    }
    
    function randomNumberGenerator(uint count) private view returns (uint8) {
        uint8 randomnumber = uint8(uint(keccak256(abi.encodePacked(block.timestamp, count, block.difficulty))) % 100);
        return randomnumber;
    }
    
    function gachaPull(uint count) private view returns (Card memory card) {
        uint8 randomNumber = randomNumberGenerator(count);
        
        if (randomNumber > 25) {
            return cards["Rare"];
        } else if (randomNumber >= 5 && randomNumber <= 25) {
            return cards["Super Rare"];
        } 
        return cards["Ultra Rare"];
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
