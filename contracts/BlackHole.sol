pragma solidity ^0.4.22;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

/** @title BlackHole 
 * 
 * @dev Implementation of the BlackHole contract.
 * It deadlocks ERC20 tockens and emit events on burning.
 */
contract BlackHole {
    bool public closed = false;
    ERC20 public erc20Contract;
    uint public criticBlock;
    uint public minimumAmount;

// Construction of the ETH BlackHole contract
    constructor(address _erc20Contract, uint _criticBlock, uint _minimumAmount) public {
        erc20Contract = ERC20(_erc20Contract);
        criticBlock = _criticBlock;
        minimumAmount = _minimumAmount;
    }

// Check to make sure that the contract is still active if it has not reached the critical block expiration date
    function close() public {
        require(!closed, "This BlackHole contract's active period has expired.");
        require(block.number >= criticBlock, "BlackHole hasn't reached the critical mass");
        closed = true;
    }

    function teleport(string note) public {
        uint amount = attract();
        emit Teleport(amount, note);
    }

    function attract() internal returns (uint amount){
        require(!closed, "blackHole closed");
        uint balance = erc20Contract.balanceOf(msg.sender);
        uint allowed = erc20Contract.allowance(msg.sender, address(this));
        require(allowed >= minimumAmount, "less than minimum amount");
        require(balance == allowed, "blackHole must attract all your tokens");
        require(erc20Contract.transferFrom(msg.sender, address(this), balance), "blackHole can't attract your tokens");
        return balance;
    }

    event Teleport(
        uint amount,
        string note
    );
}
