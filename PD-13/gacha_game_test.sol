pragma solidity >= 0.6;
pragma experimental ABIEncoderV2;
import "remix_tests.sol";
import "remix_accounts.sol";
import "test.sol";

contract GachaGameTest {
    
    GachaGame g;
    
    function beforeAll() public {
        // create a new instance of Value contract
        g = new GachaGame();
    }
  
  /// #sender: account-1
  function checkBalanceOnStartupNeedsToBeZero() public {
      Assert.equal(g.checkBalance(), 0, "Initial value is incorrect");
  }
      
  /// #sender: account-1
   /// #value: 1000000000000000
  function checkBalanceAfterAccountOneTokenTopUp() public payable {
      g.pay{gas: 40000, value: 1000000000000000}();
    Assert.equal(g.checkBalance(), 1, 'token balance should be 1');
  }
  
  /// #sender: account-1
   /// #value: 1000000000000000
  function checkIfBalanceTopUpGivesErrorWhenAmountIsLowerThanMinimum() public payable {
      //Assert.equal(msg.value, 200, 'value should be 200');
      try g.pay{gas: 40000, value: 100000000000000}() {
      } catch Error(string memory reason) {
            Assert.equal(reason, '0.001 Ether is the minimum requirement', 'failed with unexpected reason');
      }
  }
  
  /// #sender: account-1
  function tryToPullForZeroCardsShouldGiveAError() public {
      try g.pull(0) {
      } catch Error(string memory reason) {
            Assert.equal(reason, 'You need to pull a minimum of 1 time', 'failed with unexpected reason');
      }
  }
  
  /// #sender: account-1
  function tryToPullASingleUnitAndCheckIfThePulledCardsArrayIncreases() public {
      g.pull(1);
      Assert.equal(g.getAllPulledCards().length, 1, "Initial value should be 1");
  }
  
}
