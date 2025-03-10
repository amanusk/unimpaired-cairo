use snforge_std::{CheatSpan, ContractClassTrait, DeclareResultTrait, cheat_caller_address, declare};
use starknet::{ContractAddress, get_contract_address};
use unimpaired_cairo::writoor::writoor::{IWritoorDispatcher, IWritoorDispatcherTrait};


fn setup() -> ContractAddress {
    let class_hash = declare("Writoor").unwrap().contract_class();
    let owner = get_contract_address();

    let mut calldata = ArrayTrait::new();

    owner.serialize(ref calldata);

    let (contract_address, _) = class_hash.deploy(@calldata).unwrap();

    contract_address
}

#[test]
fn test_mint() {
    let contract_address = setup();
    let contract = IWritoorDispatcher { contract_address };

    let target_address: ContractAddress = 1.try_into().unwrap();
    contract.mint(target_address, 10_u256);
    assert!(contract.get_balance(target_address) == 10_u256, "Wrong balance");
}


#[test]
fn test_transfer() {
    let contract_address = setup();
    let contract = IWritoorDispatcher { contract_address };

    let sender_address: ContractAddress = 1.try_into().unwrap();
    contract.mint(sender_address, 10_u256);

    let target_address: ContractAddress = 2.try_into().unwrap();

    cheat_caller_address(contract_address, 1.try_into().unwrap(), CheatSpan::TargetCalls(1));
    let amount: u256 = 1;
    contract.transfer(target_address, amount);

    let balance_after = contract.get_balance(contract_address);
    assert!(balance_after == 0_u256, "Balance Changes");
}

