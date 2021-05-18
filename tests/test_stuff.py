# brownie test --interactive -s

def test_stuff(
    arb,
    boss,
    weth_address,
    whale
):
    whale.transfer(boss, '1000 ether')
    my_flash_loan_call_tx = arb.myFlashLoanCall(weth_address, 20 * 10 ** 18, { 'from': boss })
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
