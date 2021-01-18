pragma solidity >= 0.6;
pragma experimental ABIEncoderV2;

import "https://raw.githubusercontent.com/provable-things/ethereum-api/master/provableAPI_0.6.sol";
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/master/contracts/math/SafeMath.sol";
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/master/contracts/access/Ownable.sol";

/// @title A game to get cards
/// @author James
contract GachaGame is usingProvable, Ownable  {
    
    using SafeMath for uint256;
    
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
    bytes32 public queryId;
    
    constructor() public payable {
        provable_setProof(proofType_Ledger); 
        initCards();
    }
    
    function createCard(string memory rarity, uint8 value) public onlyOwner payable {
        cards[rarity] = Card({
                Name: rarity,
                Value: value
        });
    }
    
    modifier requireEnoughDeposit {
        require(msg.value >= pullCost, "0.001 Ether is the minimum requirement");
        _;
    }
    
    /// @notice Get all cards that were pulled during the contracts lifetime
    /// @dev Could change to a mapping to return the cards originating from the current user.
    /// @return a list of cards
    function getAllPulledCards() public view returns (Card[] memory) {
        return currentCards;
    }
    
    /// @notice Add funds to the account
    function pay() public requireEnoughDeposit payable {
        balance[msg.sender] = balance[msg.sender].add(msg.value / pullCost);
    }
    
    /// @notice Retrieve cards
    function pull() public requireEnoughDeposit payable {
        require(msg.value / pullCost >= 1, "You do not have enough funds to pull!");
        require(msg.value / pullCost <= 10, "You are not allowed to pull more than 10 times in a single turn");
        balance[msg.sender] = balance[msg.sender].add(msg.value / pullCost);
        uint count = balance[msg.sender];
        require(count >= pullMinimum, "You need to pull a minimum of 1 time");
        
        balance[msg.sender] = balance[msg.sender].sub(count);
        
        for(uint i = 0; i < count; i++) {
            queryId=provable_newRandomDSQuery(
            0,          // QUERY_EXECUTION_DELAY
            1,    // NUM_RANDOM_BYTES_REQUESTED
            200000      // GAS_FOR_CALLBACK
        );
        }
    }
    
    /// @notice Check the current funds of the current account.
    /// @return A value which represent the balance of the account
    function checkBalance() public view returns (uint){
        return balance[msg.sender];
    }
    
    function __callback(bytes32  _queryId,string memory _result,bytes memory _proof ) override public {
        require(msg.sender == provable_cbAddress());
        if (provable_randomDS_proofVerify__returnCode(_queryId,_result,_proof)== 0) {
            gachaPull(uint256(keccak256(abi.encodePacked(_result))) % 200);
        }
    }
    
    /// @notice Randomly select a card to return to the user and add it to the list of cards.
    /// @param randomNumber A number which is used to determine the card to add to the list and give back to the user.
    function gachaPull(uint randomNumber) private {
        if (randomNumber > 25) {
            currentCards.push(cards["Rare"]);
        } else if (randomNumber >= 5 && randomNumber <= 25) {
            currentCards.push(cards["Super Rare"]);
        } else currentCards.push(cards["Ultra Rare"]);
        
        emit Pull(currentCards[currentCards.length - 1]);
    }
    
    /// @notice Load all possible cards that can get retrieved
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
    
    function close() public {
      selfdestruct(msg.sender);
    }
    
}
