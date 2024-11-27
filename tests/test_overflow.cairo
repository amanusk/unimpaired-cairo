use starknet::{ContractAddress};


use snforge_std::{declare, ContractClassTrait, DeclareResultTrait};
use unimpaired_cairo::overflow::overflow::{IOverflowDispatcher, IOverflowDispatcherTrait};


fn setup() -> ContractAddress {
    let class_hash = declare("Overflow").unwrap().contract_class();

    let mut calldata = ArrayTrait::new();

    let (contract_address, _) = class_hash.deploy(@calldata).unwrap();

    contract_address
}

#[test]
fn test_overflow() {
    let contract_address = setup();
    let contract = IOverflowDispatcher { contract_address };

    contract.increase_balance(1);
    let value = contract.get_balance();
    assert!(value == 0, "Expected 0, got {}", value);
}

