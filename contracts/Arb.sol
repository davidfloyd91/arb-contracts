pragma solidity 0.6.12;

import { FlashLoanReceiverBase } from "../interfaces/FlashLoanReceiverBase.sol";
import { ILendingPool } from "../interfaces/ILendingPool.sol";
import { ILendingPoolAddressesProvider } from "../interfaces/ILendingPoolAddressesProvider.sol";
import { IERC20 } from "../interfaces/IERC20.sol";

/** 
    !!!
    Never keep funds permanently on your FlashLoanReceiverBase contract as they could be 
    exposed to a 'griefing' attack, where the stored funds are used by an attacker.
    !!!
 */
contract Arb is FlashLoanReceiverBase {
    string public name = "Arb";
    address payable _owner;

    constructor(ILendingPoolAddressesProvider provider) public FlashLoanReceiverBase(provider) {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "caller is not the owner");
        _;
    }

    /**
        This function is called after your contract has received the flash loaned amount
     */
    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    )
        external
        override
        returns (bool)
    {

        //
        // This contract now has the funds requested.
        // Your logic goes here.
        //
        
        // At the end of your logic above, this contract owes
        // the flashloaned amounts + premiums.
        // Therefore ensure your contract has enough to repay
        // these amounts.
        
        // Approve the LendingPool contract allowance to *pull* the owed amount
        for (uint i = 0; i < assets.length; i++) {
            uint amountOwing = amounts[i].add(premiums[i]);
            IERC20(assets[i]).approve(address(LENDING_POOL), amountOwing);
        }
        
        return true;
    }
    
    function myFlashLoanCall(address _address, uint256 _amount) public onlyOwner {
        address receiverAddress = address(this);

        address[] memory assets = new address[](1);
        assets[0] = address(_address);

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = _amount;

        uint256[] memory modes = new uint256[](1);
        modes[0] = 0; // no debt

        address onBehalfOf = address(this);
        bytes memory params = "";
        uint16 referralCode = 0;

        LENDING_POOL.flashLoan(
            receiverAddress,
            assets,
            amounts,
            modes,
            onBehalfOf,
            params,
            referralCode
        );
    }

    function sendEther(uint256 _amount) public {
        _owner.transfer(_amount);
    }

    function sendToken(uint256 _amount, address _token) public {
        IERC20(_token).transfer(_owner, _amount);
    }

    function friendlyFallback() public payable {}
}
