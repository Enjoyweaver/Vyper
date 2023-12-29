from vyper.interfaces import ERC20

implements: ERC20

event Transfer:
    sender: indexed(address)
    receiver: indexed(address)
    value: uint256

event Approval:
    owner: indexed(address)
    spender: indexed(address)
    value: uint256

name: public(String[32])
symbol: public(String[32])
decimals: public(uint256)

balanceOf: public(HashMap[address, uint256])
allowance: public(HashMap[address, HashMap[address, uint256]])
totalSupply: public(uint256)
minter: address

@external
def __init__(_name: String[32], _symbol: String[32], _decimals: uint256, _supply: uint256):
    init_supply: uint256 = 21_000_000_000 * 10 ** _decimals
    self.name = _name
    self.symbol = _symbol
    self.decimals = _decimals
    self.balanceOf[msg.sender] = init_supply
    self.totalSupply = init_supply
    self.minter = msg.sender
    log Transfer(empty(address), msg.sender, init_supply)

@external
def transfer(_to: address, _value: uint256) -> bool:
    new_receiver_balance: uint256 = self.balanceOf[_to] + _value

    if msg.sender != self.minter and new_receiver_balance > 21_000_000 * 10**18:
        assert False, "Receiver balance would exceed 21 million tokens"

    self.balanceOf[msg.sender] -= _value
    self.balanceOf[_to] += _value
    log Transfer(msg.sender, _to, _value)
    return True

@external
def transferFrom(_from: address, _to: address, _value: uint256) -> bool:
    new_receiver_balance: uint256 = self.balanceOf[_to] + _value

    if msg.sender != self.minter and new_receiver_balance > 21_000_000 * 10**18:
        assert False, "Receiver balance would exceed 21 million tokens"

    self.balanceOf[_from] -= _value
    self.balanceOf[_to] += _value
    self.allowance[_from][msg.sender] -= _value

    log Transfer(_from, _to, _value)
    return True

@external
def approve(_spender: address, _value: uint256) -> bool:
    self.allowance[msg.sender][_spender] = _value
    log Approval(msg.sender, _spender, _value)
    return True
