import pytest
from brownie import Contract

@pytest.fixture
def arb_contract(
    Arb,
    owner,
    lending_pool_address_provider_contract
):
    yield owner.deploy(
        Arb,
        lending_pool_address_provider_contract
    )

@pytest.fixture
def lending_pool_address_provider_address():
    yield "0xb53c1a33016b2dc2ff3653530bff1848a515c8c5"

@pytest.fixture
def lending_pool_address_provider_contract(lending_pool_address_provider_address):
    yield Contract(lending_pool_address_provider_address)

############
# accounts #
############

@pytest.fixture
def owner(accounts):
    yield accounts[0]

@pytest.fixture
def whale(accounts):
    yield accounts.at("0x73bceb1cd57c711feac4224d062b0f6ff338501e", True)

@pytest.fixture
def wbtc_whale(accounts):
    yield accounts.at("0xbf72da2bd84c5170618fbe5914b0eca9638d5eb5", True)

@pytest.fixture
def very_bad_man(accounts):
    yield accounts[1]

@pytest.fixture
def puppet(accounts):
    yield accounts[2]

##########
# assets #
##########

@pytest.fixture
def uni_address():
    yield "0x1f9840a85d5af5bf1d1762f925bdaddc4201f984"

@pytest.fixture
def uni_contract(uni_address):
    yield Contract(uni_address)

@pytest.fixture
def wbtc_address():
    yield "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599"

@pytest.fixture
def wbtc_contract(wbtc_address):
    yield Contract(wbtc_address)

@pytest.fixture
def weth_address():
    yield "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"

@pytest.fixture
def weth_contract(weth_address):
    yield Contract(weth_address)
