%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace Balance:
    func increase_balance(amount : Uint256):
    end

    func get_balance() -> (res : Uint256):
    end

    func get_id() -> (res : felt):
    end
end

@external
func test_balance{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals

    # Deploy the contract with a given calldata array, and store its address back to a local variable
    local contract_address : felt
    %{ ids.contract_address = deploy_contract("./src/balance.cairo", [100, 0, 1]).contract_address %}

    # Perform some contract reads and writes
    let (res) = Balance.get_balance(contract_address=contract_address)
    assert res.low = 100
    assert res.high = 0

    let (id) = Balance.get_id(contract_address=contract_address)
    assert id = 1

    Balance.increase_balance(contract_address=contract_address, amount=Uint256(50, 0))
    let (res) = Balance.get_balance(contract_address=contract_address)
    assert res.low = 150
    assert res.high = 0

    # Play around with cheatcodes to mock functionality/state
    %{ mock_call(ids.contract_address, "get_balance", [17, 38]) %}
    let (res) = Balance.get_balance(contract_address)
    assert res.low = 17
    assert res.high = 38

    # Try going back to actually reading state
    %{ clear_mock_call(ids.contract_address, "get_balance") %}
    let (res) = Balance.get_balance(contract_address=contract_address)
    assert res.low = 150
    assert res.high = 0

    # Check out more cheatcodes:
    # https://docs.swmansion.com/protostar/docs/tutorials/guides/testing#cheatcodes

    return ()
end
