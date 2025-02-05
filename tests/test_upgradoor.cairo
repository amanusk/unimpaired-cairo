use starknet::{ContractAddress, get_contract_address, ClassHash, contract_address_const};


use snforge_std::{declare, ContractClassTrait, DeclareResultTrait, get_class_hash};
use unimpaired_cairo::upgradoor::interface::{IUpgradoorDispatcher, IUpgradoorDispatcherTrait};
use core::num::traits::Zero;


fn setup() -> (ContractAddress, ClassHash, ClassHash) {
    let orig_class_hash = declare("Upgradoor").unwrap().contract_class();
    let new_class_hash = declare("Upgradoor2").unwrap().contract_class();

    let mut calldata = ArrayTrait::new();
    get_contract_address().serialize(ref calldata);

    let (contract_address, _) = orig_class_hash.deploy(@calldata).unwrap();

    (contract_address, *orig_class_hash.class_hash, *new_class_hash.class_hash)
}

#[test]
fn test_upgradoor_owner() {
    let (contract_address, _, _) = setup();
    let contract = IUpgradoorDispatcher { contract_address };

    let owner = get_contract_address();
    assert!(contract.get_owner() == owner, "Owner should be the deployer");
}

#[test]
fn test_upgradoor_change_owner() {
    let (contract_address, _, _) = setup();
    let contract = IUpgradoorDispatcher { contract_address };

    let account: ContractAddress = contract_address_const::<1>();

    contract.set_owner(account);
    assert!(contract.get_owner() == account, "Owner should have changed");
}

#[test]
fn test_upgradoor_upgrade() {
    let (contract_address, _, new_class_hash) = setup();
    let contract = IUpgradoorDispatcher { contract_address };

    contract.upgrade(new_class_hash);
    let class_hash = get_class_hash(contract_address);
    assert!(class_hash == new_class_hash, "Class hash should have changed");
}

#[test]
fn test_upgradoor_upgrade_and_change() {
    let (contract_address, _, new_class_hash) = setup();
    let contract = IUpgradoorDispatcher { contract_address };

    let account: ContractAddress = contract_address_const::<1>();

    contract.change_owner_and_upgrade(account, new_class_hash);
    let class_hash = get_class_hash(contract_address);
    assert!(class_hash == new_class_hash, "Class hash should have changed");
    assert!(contract.get_owner() == Zero::zero(), "OOps");
}
