pragma solidity 0.6.12;

import { FlashLoanReceiverBase } from "../interfaces/FlashLoanReceiverBase.sol";
import { IERC20 } from "../interfaces/IERC20.sol";
import { ILendingPool } from "../interfaces/ILendingPool.sol";
import { ILendingPoolAddressesProvider } from "../interfaces/ILendingPoolAddressesProvider.sol";
import { IUniswapV2Router02 } from "../interfaces/IUniswapV2Router02.sol";

/** 
    !!!
    Never keep funds permanently on your FlashLoanReceiverBase contract as they could be 
    exposed to a 'griefing' attack, where the stored funds are used by an attacker.
    !!!
 */
contract Arb is FlashLoanReceiverBase {
    string public name = "Arb";

    address payable public owner;

    address zeroAddress;
    uint zeroOutMin;
    IERC20 zeroAsset;

    address oneAddress;
    uint oneOutMin;
    IERC20 oneAsset;

    address twoAddress;
    uint twoOutMin;
    IERC20 twoAsset;

    IUniswapV2Router02 UniswapV2Router02 = IUniswapV2Router02(
        address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D)
    );

    event GotZeroAssetBack(uint amount, uint owed);

    constructor(
        ILendingPoolAddressesProvider provider
    ) public FlashLoanReceiverBase(provider) {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "caller is not the owner");
        _;
    }

    function updateParams(
        address _zeroAddress,
        uint _zeroOutMin,
        address _oneAddress,
        uint _oneOutMin,
        address _twoAddress,
        uint _twoOutMin
    ) private {
        zeroAddress = _zeroAddress;
        zeroOutMin = _zeroOutMin;
        zeroAsset = IERC20(_zeroAddress);

        oneAddress = _oneAddress;
        oneOutMin = _oneOutMin;
        oneAsset = IERC20(_oneAddress);

        twoAddress = _twoAddress;
        twoOutMin = _twoOutMin;
        twoAsset = IERC20(_twoAddress);
    }

    function getFlashLoan(
        uint _zeroAmount,
        address _zeroAddress,
        uint _zeroOutMin,
        address _oneAddress,
        uint _oneOutMin,
        address _twoAddress,
        uint _twoOutMin
    ) public onlyOwner {
        updateParams(
            _zeroAddress,
            _zeroOutMin,
            _oneAddress,
            _oneOutMin,
            _twoAddress,
            _twoOutMin
        );

        address receiverAddress = address(this);

        address[] memory assets = new address[](1);
        assets[0] = address(_zeroAddress);

        uint[] memory amounts = new uint[](1);
        amounts[0] = _zeroAmount;

        uint[] memory modes = new uint[](1);
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

    function executeOperation(
        address[] calldata assets,
        uint[] calldata amounts,
        uint[] calldata premiums,
        address initiator,
        bytes calldata params
    )
        external
        override
        returns (bool)
    {
        uint zeroAmount = amounts[0];
        uint premium = premiums[0];

        require(zeroAddress == assets[0], "zeroAddress does not match received asset");

        zeroAsset.approve(address(UniswapV2Router02), zeroAmount);
        address[] memory zeroOnePath = new address[](2);
        zeroOnePath[0] = zeroAddress;
        zeroOnePath[1] = oneAddress;

        uint[] memory oneAmounts = UniswapV2Router02.swapExactTokensForTokens(
            zeroAmount,
            oneOutMin,
            zeroOnePath,
            address(this),
            block.timestamp + 1000000
        );

        uint oneAmount = oneAmounts[1];

        oneAsset.approve(address(UniswapV2Router02), oneAmount);
        address[] memory oneTwoPath = new address[](2);
        oneTwoPath[0] = oneAddress;
        oneTwoPath[1] = twoAddress;

        uint[] memory twoAmounts = UniswapV2Router02.swapExactTokensForTokens(
            oneAmount,
            twoOutMin,
            oneTwoPath,
            address(this),
            block.timestamp + 1000000
        );

        uint twoAmount = twoAmounts[1];

        twoAsset.approve(address(UniswapV2Router02), twoAmount);
        
        address[] memory twoZeroPath = new address[](2);
        twoZeroPath[0] = twoAddress;
        twoZeroPath[1] = zeroAddress;

        uint[] memory _zeroAmounts = UniswapV2Router02.swapExactTokensForTokens(
            twoAmount,
            zeroOutMin,
            twoZeroPath,
            address(this),
            block.timestamp + 1000000
        );

        uint owed = zeroAmount.add(premium);

        emit GotZeroAssetBack(_zeroAmounts[1], owed);

        zeroAsset.approve(address(LENDING_POOL), owed);

        return true;
    }

    function updateOwner(address payable _owner) public onlyOwner {
        owner = _owner;
    }

    function withdrawEther(uint _amount) public onlyOwner {
        owner.transfer(_amount);
    }

    function withdrawToken(uint _amount, address _token) public onlyOwner {
        IERC20(_token).transfer(owner, _amount);
    }

    fallback() external payable {}
}
