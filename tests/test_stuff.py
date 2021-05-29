from brownie import history, reverts

# brownie test --interactive -s -v

def test_update_owner(
    arb_contract,
    owner,
    puppet,
    very_bad_man
):
    assert(arb_contract.owner() == owner)
    with reverts():
        arb_contract.updateOwner(very_bad_man, {'from': very_bad_man})
    assert(arb_contract.owner() == owner)
    arb_contract.updateOwner(puppet, {'from': owner})
    assert(arb_contract.owner() == puppet)
    with reverts():
        arb_contract.updateOwner(owner, {'from': owner})
    arb_contract.updateOwner(owner, {'from': puppet})
    assert(arb_contract.owner() == owner)

def test_receive_and_witdraw_ether(
    arb_contract,
    owner,
    very_bad_man,
    whale
):
    receive_amount = 1_000_000 * 10 ** 18
    arb_contract_balance_before = arb_contract.balance()
    whale.transfer(arb_contract, receive_amount)
    arb_contract_balance_after = arb_contract.balance()
    assert(arb_contract_balance_after - arb_contract_balance_before == receive_amount)
    with reverts():
        arb_contract.withdrawEther(receive_amount, {'from': very_bad_man})
    owner_balance_before = owner.balance()
    arb_contract.withdrawEther(receive_amount, {'from': owner})
    owner_balance_after = owner.balance()
    assert(owner_balance_after - owner_balance_before == receive_amount)

def test_receive_and_withdraw_tokens(
    arb_contract,
    owner,
    wbtc_address,
    wbtc_contract,
    wbtc_whale,
    very_bad_man
):
    receive_amount = 1_000 * 10 ** 8
    arb_contract_balance_before = wbtc_contract.balanceOf(arb_contract)
    wbtc_contract.transfer(arb_contract, receive_amount, {'from': wbtc_whale})
    arb_contract_balance_after = wbtc_contract.balanceOf(arb_contract)
    assert(arb_contract_balance_after - arb_contract_balance_before == receive_amount)
    with reverts():
        arb_contract.withdrawToken(receive_amount, wbtc_address, {'from': very_bad_man})
    owner_balance_before = wbtc_contract.balanceOf(owner)
    arb_contract.withdrawToken(receive_amount, wbtc_address, {'from': owner})
    owner_balance_after = wbtc_contract.balanceOf(owner)
    assert(owner_balance_after - owner_balance_before == receive_amount)

def test_flash_loan(arb_contract, owner, uni_address, wbtc_address, weth_address):
    with reverts("SafeERC20: low-level call failed"):
        arb_contract.getFlashLoan(
            100_000 * 10 ** 6,
            wbtc_address,
            0,
            uni_address,
            0,
            weth_address,
            0,
            {'from': owner}
        )
    
    print("GotZeroAssetBack:", history[-1].events['GotZeroAssetBack'])
