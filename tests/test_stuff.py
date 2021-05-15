# brownie test --interactive -s

def test_stuff(
    arb,
    curve_bbtc_pool,
    curve_hbtc_pool,
    curve_obtc_pool,
    curve_pbtc_pool,
    curve_renbtc_pool,
    curve_sbtc_pool,
    curve_tbtc_pool,
    uniswap_weth_bbtc_pool,
    uniswap_weth_hbtc_pool,
    uniswap_weth_obtc_pool,
    uniswap_weth_pbtc_pool,
    uniswap_weth_renbtc_pool,
    uniswap_weth_sbtc_pool,
    uniswap_weth_tbtc_pool,
    uniswap_weth_wbtc_pool
):
    assert(False)

    ## test accepting, withdrawing ether
    # whale sends eth
    # balance increases
    # doofus withdrawals
    # doofus fails
    # boss withdraws
    # boss prospers

    ## ditto tokens

    ## test myFlashLoanCall
    # only owner stuff for now

    ## test profitability breh
    # idk do it
