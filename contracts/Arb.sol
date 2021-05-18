pragma solidity 0.6.12;

import { FlashLoanReceiverBase } from "../interfaces/FlashLoanReceiverBase.sol";
import { ILendingPool } from "../interfaces/ILendingPool.sol";
import { ILendingPoolAddressesProvider } from "../interfaces/ILendingPoolAddressesProvider.sol";
import { IERC20 } from "../interfaces/IERC20.sol";
import { IUniswapV2Router02 } from "../interfaces/IUniswapV2Router02.sol";
import { ICurveStableSwap } from "../interfaces/ICurveStableSwap.sol";

/** 
    !!!
    Never keep funds permanently on your FlashLoanReceiverBase contract as they could be 
    exposed to a 'griefing' attack, where the stored funds are used by an attacker.
    !!!
 */
contract Arb is FlashLoanReceiverBase {
    string public name = "Arb";

    address payable _owner;

    address public undervalued;
    address public overvalued;
    uint public undervaluedAmountOutMin;
    address public poolAddress;
    ICurveStableSwap public pool;

    int128 public undervaluedIndex;
    int128 public overvaluedIndex;
    bool public isUnderlying;

    IUniswapV2Router02 UniswapV2Router02 = IUniswapV2Router02(
        address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D)
    );

    constructor(
        ILendingPoolAddressesProvider provider,
        address _undervalued,
        address _overvalued,
        int128 _undervaluedIndex,
        int128 _overvaluedIndex,
        uint _undervaluedAmountOutMin,
        address _poolAddress
    ) public FlashLoanReceiverBase(provider) {
        _owner = msg.sender;

        undervalued = _undervalued;
        overvalued = _overvalued;

        undervaluedIndex = _undervaluedIndex;
        overvaluedIndex = _overvaluedIndex;

        undervaluedAmountOutMin = _undervaluedAmountOutMin;

        poolAddress = _poolAddress;
        pool = ICurveStableSwap(_poolAddress);
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "caller is not the owner");
        _;
    }

    function updatePool(
        address _undervalued,
        address _overvalued,
        int128 _undervaluedIndex,
        int128 _overvaluedIndex,
        uint _undervaluedAmountOutMin,
        address _poolAddress
    ) public onlyOwner {
        undervalued = _undervalued;
        overvalued = _overvalued;

        undervaluedIndex = _undervaluedIndex;
        overvaluedIndex = _overvaluedIndex;

        undervaluedAmountOutMin = _undervaluedAmountOutMin;

        poolAddress = _poolAddress;
        pool = ICurveStableSwap(_poolAddress);
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
        IERC20 asset = IERC20(assets[0]);
        uint256 amount = amounts[0];
        uint256 premium = premiums[0];

        require(asset.approve(address(UniswapV2Router02), amount), "approve failed");

        address[] memory path = new address[](2);
        path[0] = UniswapV2Router02.WETH();
        path[1] = undervalued;

        uint[] memory undervaluedAmounts = UniswapV2Router02.swapExactTokensForTokens(
            amount,
            undervaluedAmountOutMin,
            path,
            address(this),
            block.timestamp + 1000
        );

        require(undervaluedAmounts.length > 0, "uniswap trade into undervalued failed");
        uint undervaluedAmount = undervaluedAmounts[1];
        
        IERC20(undervalued).approve(poolAddress, undervaluedAmount);

        uint256 dy = pool.get_dy(undervaluedIndex, overvaluedIndex, undervaluedAmount);
        
        // pool.exchange appears to go through fine
        uint256 overvaluedReceived = pool.exchange(undervaluedIndex, overvaluedIndex, undervaluedAmount, dy.mul(999).div(1000));

        // this doesn't get reached -- not sure why
        require(false, "whyyyyyy");

        IERC20(overvalued).approve(address(UniswapV2Router02), overvaluedReceived);

        address[] memory escapePath = new address[](2);
        escapePath[0] = overvalued;
        escapePath[1] = UniswapV2Router02.WETH();

        uint[] memory _wethAmounts = UniswapV2Router02.swapExactTokensForTokens(
            overvaluedReceived,
            0, // amount
            escapePath,
            address(this),
            block.timestamp + 1000
        );

        IERC20(asset).approve(address(LENDING_POOL), amount.add(premium));

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
        _owner.transfer(_amount);
    }

    function sendToken(uint256 _amount, address _token) public onlyOwner {
        IERC20(_token).transfer(_owner, _amount);
    }

    function friendlyFallback() public payable {}
}
