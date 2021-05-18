pragma solidity 0.6.12;

interface ICurveStableSwap {
    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external returns (uint256);

    function get_dy(int128 i, int128 j, uint256 dx) external view returns (uint256);
}
