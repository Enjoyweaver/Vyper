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

# NOTE: By declaring `balanceOf` as public, vyper automatically generates a 'balanceOf()' getter
#       method to allow access to account balances.
#       The _KeyType will become a required parameter for the getter and it will return _ValueType.
#       See: https://vyper.readthedocs.io/en/v0.1.0-beta.8/types.html?highlight=getter#mappings
balanceOf: public(HashMap[address, uint256])
# By declaring `allowance` as public, vyper automatically generates the `allowance()` getter
allowance: public(HashMap[address, HashMap[address, uint256]])
# By declaring `totalSupply` as public, we automatically create the `totalSupply()` getter
totalSupply: public(uint256)
minter: address


@external
def __init__(_name: String[32], _symbol: String[32], _decimals: uint256, _supply: uint256):
    init_supply: uint256 = 21_000_000_000 * 10 ** _decimals
    self.name = _name
    self.symbol = _symbol
    self.decimals = 18  # Set the decimals to 18
    self.balanceOf[msg.sender] = init_supply
    self.totalSupply = init_supply
    self.minter = msg.sender
    log Transfer(empty(address), msg.sender, init_supply)



@external
def transfer(_to: address, _value: uint256) -> bool:
    """
    @dev Transfer token for a specified address
    @param _to The address to transfer to.
    @param _value The amount to be transferred.
    """
    # Calculate the new balance of the receiver
    new_receiver_balance: uint256 = self.balanceOf[_to] + _value

    # Ensure the receiver's balance won't exceed 21 million tokens
    if new_receiver_balance > 21_000_000 * 10**18:
        assert False, "Receiver balance would exceed 21 million tokens"

    # Deduct the tokens from the sender and add to the receiver
    self.balanceOf[msg.sender] -= _value
    self.balanceOf[_to] += _value
    log Transfer(msg.sender, _to, _value)
    return True

@external
def transferFrom(_from: address, _to: address, _value: uint256) -> bool:
    """
    @dev Transfer tokens from one address to another.
    @param _from address The address which you want to send tokens from
    @param _to address The address which you want to transfer to
    @param _value uint256 the amount of tokens to be transferred
    """
    # Calculate the new balance of the receiver
    new_receiver_balance: uint256 = self.balanceOf[_to] + _value

    # Ensure the receiver's balance won't exceed 21 million tokens
    if new_receiver_balance > 21_000_000 * 10**18:
        assert False, "Receiver balance would exceed 21 million tokens"

    # Deduct the tokens from the sender and add to the receiver
    self.balanceOf[_from] -= _value
    self.balanceOf[_to] += _value

    # Deduct the allowance from the sender
    self.allowance[_from][msg.sender] -= _value

    log Transfer(_from, _to, _value)
    return True


@external
def approve(_spender : address, _value : uint256) -> bool:
    """
    @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
         Beware that changing an allowance with this method brings the risk that someone may use both the old
         and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
         race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
         https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    @param _spender The address which will spend the funds.
    @param _value The amount of tokens to be spent.
    """
    self.allowance[msg.sender][_spender] = _value
    log Approval(msg.sender, _spender, _value)
    return True
