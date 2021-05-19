pragma solidity 0.6.12;

import { FlashLoanReceiverBase } from "../interfaces/FlashLoanReceiverBase.sol";
import { ILendingPool } from "../interfaces/ILendingPool.sol";
import { ILendingPoolAddressesProvider } from "../interfaces/ILendingPoolAddressesProvider.sol";
import { IERC20 } from "../interfaces/IERC20.sol";
import { IUniswapV2Router02 } from "../interfaces/IUniswapV2Router02.sol";

/** 
    !!!
    Never keep funds permanently on your FlashLoanReceiverBase contract as they could be 
    exposed to a 'griefing' attack, where the stored funds are used by an attacker.
    !!!
 */
contract Arb is FlashLoanReceiverBase {
    string public name = "Arb";

    address payable owner;

    address private sampo;
    uint private sampoOutMin;
    uint private assetOutMin;
    bool uniToSushi;

    IUniswapV2Router02 UniswapV2Router02 = IUniswapV2Router02(
        address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D)
    );

    IUniswapV2Router02 SushiV2Router02 = IUniswapV2Router02(
        address(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F)
    );

    event GotWeth(uint wethAmount, uint256 owed);

    constructor(
        ILendingPoolAddressesProvider provider,
        address _sampo,
        uint _sampoOutMin,
        uint _assetOutMin,
        bool _uniToSushi
    ) public FlashLoanReceiverBase(provider) {
        owner = msg.sender;
        sampo = _sampo;
        sampoOutMin = _sampoOutMin;
        assetOutMin = _assetOutMin;
        uniToSushi = _uniToSushi;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "caller is not the owner");
        _;
    }

    function updateParams(
        address _sampo,
        uint _sampoOutMin,
        uint _assetOutMin,
        bool _uniToSushi
    ) public onlyOwner {
        sampo = _sampo;
        sampoOutMin = _sampoOutMin;
        assetOutMin = _assetOutMin;
        uniToSushi = _uniToSushi;
    }

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
        IUniswapV2Router02 inPool;
        IUniswapV2Router02 outPool;

        if (uniToSushi) {
            inPool = UniswapV2Router02;
            outPool = SushiV2Router02;
        } else {
            inPool = SushiV2Router02;
            outPool = UniswapV2Router02;
        }

        IERC20 asset = IERC20(assets[0]);
        uint256 amount = amounts[0];
        uint256 premium = premiums[0];

        asset.approve(address(inPool), amount);

        address[] memory path = new address[](2);
        path[0] = address(asset); // inPool.WETH();
        path[1] = sampo;

        uint[] memory sampoAmounts = inPool.swapExactTokensForTokens(
            amount,
            sampoOutMin,
            path,
            address(this),
            block.timestamp + 1000
        );

        uint sampoAmount = sampoAmounts[1];

        IERC20(sampo).approve(address(outPool), sampoAmount);

        address[] memory escapePath = new address[](2);
        escapePath[0] = sampo;
        escapePath[1] = address(asset); // outPool.WETH();

        uint[] memory assetAmounts = outPool.swapExactTokensForTokens(
            sampoAmount,
            assetOutMin,
            escapePath,
            address(this),
            block.timestamp + 1000
        );

        uint assetAmount = assetAmounts[1];

        uint256 owed = amount.add(premium);

        emit GotWeth(assetAmount, owed);

        asset.approve(address(LENDING_POOL), owed);

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

    function sendEther(uint256 _amount) public onlyOwner {
        owner.transfer(_amount);
    }

    function sendToken(uint256 _amount, address _token) public onlyOwner {
        IERC20(_token).transfer(owner, _amount);
    }

    function friendlyFallback() public payable {}
}
