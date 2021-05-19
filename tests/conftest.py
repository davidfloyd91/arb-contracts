import pytest
from brownie import Contract, accounts

# need to change this all the time
@pytest.fixture
def undervalued_amount_out_min():
    yield 0

@pytest.fixture
def arb(
    Arb,
    boss,
    provider_address,
    wbtc_address
):
    yield Arb.deploy(
        provider_address,
        "0x6b3595068778dd592e39a122f4f5a5cf09c90fe2",
        0,
        0,
        True,
        { 'from': boss }
    )

@pytest.fixture
def boss():
    yield accounts[0]

@pytest.fixture
def goober():
    yield accounts[1]

@pytest.fixture
def provider_address():
    yield '0xb53c1a33016b2dc2ff3653530bff1848a515c8c5'

@pytest.fixture
def whale():
    yield accounts.at('0xf977814e90da44bfa03b6295a0616a897441acec', { 'force': True })

#########
# coins #
#########

@pytest.fixture
def weth_address():
    yield "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"

# @pytest.fixture
# def bbtc_address():
#     yield "0x9BE89D2a4cd102D8Fecc6BF9dA793be995C22541"

# @pytest.fixture
# def hbtc_address():
#     yield "0x0316EB71485b0Ab14103307bf65a021042c6d380"

# @pytest.fixture
# def obtc_address():
#     yield "0x8064d9Ae6cDf087b1bcd5BDf3531bD5d8C537a68"

# @pytest.fixture
# def pbtc_address():
#     yield "0x5228a22e72ccC52d415EcFd199F99D0665E7733b"

@pytest.fixture
def renbtc_address():
    yield "0xeb4c2781e4eba804ce9a9803c67d0893436bb27d"

# @pytest.fixture
# def sbtc_address():
#     yield "0xfe18be6b3bd88a2d2a7f928d00292e7a9963cfc6"

# @pytest.fixture
# def tbtc_address():
#     yield "0x8dAEBADE922dF735c38C80C7eBD708Af50815fAa"

@pytest.fixture
def wbtc_address():
    yield "0x2260fac5e5542a773aa44fbcfedf7c193bc2c599"

@pytest.fixture
def weth(weth_address):
    yield Contract(weth_address)

# @pytest.fixture
# def bbtc(bbtc_address):
#     yield Contract(bbtc_address)

# @pytest.fixture
# def hbtc(hbtc_address):
#     yield Contract(hbtc_address)

# @pytest.fixture
# def obtc(obtc_address):
#     yield Contract(obtc_address)

# @pytest.fixture
# def pbtc(pbtc_address):
#     yield Contract(pbtc_address)

@pytest.fixture
def renbtc(renbtc_address):
    yield Contract(renbtc_address)

# @pytest.fixture
# def sbtc(sbtc_address):
#     yield Contract(sbtc_address)

# @pytest.fixture
# def tbtc(tbtc_address):
#     yield Contract(tbtc_address)

@pytest.fixture
def wbtc(wbtc_address):
    yield Contract(wbtc_address)


#########
# curve #
#########

@pytest.fixture
def curve_address_provider_address():
    yield "0x0000000022d53366457f9d5e68ec105046fc4383"

# @pytest.fixture
# def curve_bbtc_pool_address():
#     yield "0x071c661B4DeefB59E2a3DdB20Db036821eeE8F4b"

# @pytest.fixture
# def curve_hbtc_pool_address():
#     yield "0x4CA9b3063Ec5866A4B82E437059D2C43d1be596F"

# @pytest.fixture
# def curve_obtc_pool_address():
#     yield "0xd81dA8D904b52208541Bade1bD6595D8a251F8dd"

# @pytest.fixture
# def curve_pbtc_pool_address():
#     yield "0x7F55DDe206dbAD629C080068923b36fe9D6bDBeF"

@pytest.fixture
def curve_renbtc_pool_address():
    yield "0x93054188d876f558f4a66B2EF1d97d16eDf0895B"

# @pytest.fixture
# def curve_sbtc_pool_address():
#     yield "0x7fC77b5c7614E1533320Ea6DDc2Eb61fa00A9714"

# @pytest.fixture
# def curve_tbtc_pool_address():
#     yield "0xC25099792E9349C7DD09759744ea681C7de2cb66"

# @pytest.fixture
# def curve_bbtc_pool(curve_bbtc_pool_address):
#     yield Contract(curve_bbtc_pool_address)

# @pytest.fixture
# def curve_hbtc_pool(curve_hbtc_pool_address):
#     yield Contract(curve_hbtc_pool_address)

# @pytest.fixture
# def curve_obtc_pool(curve_obtc_pool_address):
#     yield Contract(curve_obtc_pool_address)

# @pytest.fixture
# def curve_pbtc_pool(curve_pbtc_pool_address):
#     yield Contract(curve_pbtc_pool_address)

# @pytest.fixture
# def curve_renbtc_pool(curve_renbtc_pool_address):
#     yield Contract(curve_renbtc_pool_address)

# @pytest.fixture
# def curve_sbtc_pool(curve_sbtc_pool_address):
#     yield Contract(curve_sbtc_pool_address)

# @pytest.fixture
# def curve_tbtc_pool(curve_tbtc_pool_address):
#     yield Contract(curve_tbtc_pool_address)

@pytest.fixture
def curve_sbtc_pool_renbtc_index():
    yield 0

@pytest.fixture
def curve_sbtc_pool_wbtc_index():
    yield 1


###########
# uniswap #
###########

@pytest.fixture
def uniswap_v2_router():
    yield Contract("0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D")

@pytest.fixture
def uniswap_factory_contract():
    yield Contract("0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f")

@pytest.fixture
def uniswap_lending_pool_address_provider():
    yield Contract("0x24a42fD28C976A61Df5D00D0599C34c4f90748c8")

@pytest.fixture
def uniswap_lending_pool(uniswap_lending_pool_address_provider):
    lending_pool_address = uniswap_lending_pool_address_provider.getLendingPool()
    yield Contract(lending_pool_address)

# @pytest.fixture
# def uniswap_weth_bbtc_pool(uniswap_factory_contract, weth, bbtc):
#     pool_address = uniswap_factory_contract.getPair(weth, bbtc)
#     yield Contract(pool_address)

# @pytest.fixture
# def uniswap_weth_hbtc_pool(uniswap_factory_contract, weth, hbtc):
#     pool_address = uniswap_factory_contract.getPair(weth, hbtc)
#     yield Contract(pool_address)

# @pytest.fixture
# def uniswap_weth_obtc_pool(uniswap_factory_contract, weth, obtc):
#     pool_address = uniswap_factory_contract.getPair(weth, obtc)
#     yield Contract(pool_address)

# @pytest.fixture
# def uniswap_weth_pbtc_pool(uniswap_factory_contract, weth, pbtc):
#     pool_address = uniswap_factory_contract.getPair(weth, pbtc)
#     yield Contract(pool_address)

@pytest.fixture
def uniswap_weth_renbtc_pool(uniswap_factory_contract, weth, renbtc):
    pool_address = uniswap_factory_contract.getPair(weth, renbtc)
    yield Contract(pool_address)

# @pytest.fixture
# def uniswap_weth_sbtc_pool(uniswap_factory_contract, weth, sbtc):
#     pool_address = uniswap_factory_contract.getPair(weth, sbtc)
#     yield Contract(pool_address)

# @pytest.fixture
# def uniswap_weth_tbtc_pool(uniswap_factory_contract, weth, tbtc):
#     pool_address = uniswap_factory_contract.getPair(weth, tbtc)
#     yield Contract(pool_address)

@pytest.fixture
def uniswap_weth_wbtc_pool(uniswap_factory_contract, weth, wbtc):
    pool_address = uniswap_factory_contract.getPair(weth, wbtc)
    yield Contract(pool_address)
