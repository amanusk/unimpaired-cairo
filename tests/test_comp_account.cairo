use starknet::{
    contract_address_const, get_block_info, ContractAddress, Felt252TryIntoContractAddress, TryInto,
    Into, OptionTrait, class_hash::Felt252TryIntoClassHash, get_caller_address,
    get_contract_address,
};
use starknet::storage_read_syscall;


use snforge_std::{
    declare, cheat_caller_address, ContractClassTrait, spy_events, SpyOn, EventSpy, EventFetcher,
    Event, EventAssertions, CheatSpan
};


use array::{ArrayTrait, SpanTrait, ArrayTCloneImpl};
use result::ResultTrait;
use serde::Serde;

use box::BoxTrait;
use integer::u256;

use unimpaired_cairo::erc20::mock_erc20::MockERC20;

use unimpaired_cairo::erc20::mock_erc20::MockERC20::{Event::ERC20Event};
use openzeppelin::token::erc20::ERC20Component;


use unimpaired_cairo::erc20::erc20::{IERC20Dispatcher, IERC20DispatcherTrait};
use unimpaired_cairo::comp_account::account::{IAccountDispatcher, IAccountDispatcherTrait};


fn setup() -> (ContractAddress, ContractAddress) {
    let erc20_class_hash = declare("MockERC20").unwrap();

    let account: ContractAddress = contract_address_const::<1>();

    let INITIAL_SUPPLY: u256 = 1000000000;
    let mut calldata = ArrayTrait::new();
    INITIAL_SUPPLY.serialize(ref calldata);
    account.serialize(ref calldata);

    let (erc20_contract_address, _) = erc20_class_hash.deploy(@calldata).unwrap();
    // deploy comp_account

    let account_class_hash = declare("Account").unwrap();

    let account: ContractAddress = contract_address_const::<1>();

    let INITIAL_SUPPLY: u256 = 1000000000;
    let mut calldata = ArrayTrait::new();
    INITIAL_SUPPLY.serialize(ref calldata);
    account.serialize(ref calldata);

    let (contract_address, _) = erc20_class_hash.deploy(@calldata).unwrap();

    (erc20_contract_address, account_address)
}

#[test]
fn test_get_balance() {
    let INITIAL_SUPPLY: u256 = 1000000000;
    let contract_address = setup();
    let erc20 = IERC20Dispatcher { contract_address };

    let account: ContractAddress = contract_address_const::<1>();

    assert(erc20.balance_of(account) == INITIAL_SUPPLY, 'Balance should be > 0');
}

