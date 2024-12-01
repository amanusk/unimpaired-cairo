use starknet::{contract_address_const, ContractAddress,};


use snforge_std::{declare, ContractClassTrait, DeclareResultTrait, L1HandlerTrait};
use unimpaired_cairo::l1_badler::l1_badler::{IBadlerDispatcherTrait, IBadlerDispatcher};


fn setup() -> ContractAddress {
    let class_hash = declare("Badler").unwrap().contract_class();

    let mut calldata = ArrayTrait::new();
    let owner_address: ContractAddress = contract_address_const::<1>();
    let l1_owner_address: felt252 = 1;

    owner_address.serialize(ref calldata);
    l1_owner_address.serialize(ref calldata);

    let (contract_address, _) = class_hash.deploy(@calldata).unwrap();

    contract_address
}

#[test]
fn test_l1_handler() {
    let contract_address = setup();
    let contract = IBadlerDispatcher { contract_address };

    let l1_attacker_address: felt252 = 2;

    let l1_handle = L1HandlerTrait::new(
        contract_address, 0x03c229a1c7f51f8a8afd2a6290ea9df174d241abeb932797eb06c91a18c920e8
    );
    let value: felt252 = 100;
    let calldata = array![value];

    let res = l1_handle.execute(l1_attacker_address, calldata.span());
    match res {
        Result::Ok(_) => { assert!(true); },
        Result::Err(_) => { assert!(false); },
    }

    let balance = contract.get_balance();
    assert!(balance == value, "Balance not increased");
}

