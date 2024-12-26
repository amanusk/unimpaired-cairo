use starknet::{contract_address_const, ContractAddress};


use snforge_std::{
    declare, cheat_caller_address, ContractClassTrait, CheatSpan, EventSpyAssertionsTrait,
    DeclareResultTrait, spy_events,
};


use openzeppelin_token::erc20::ERC20Component;

use unimpaired_cairo::erc20::erc20::{IERC20Dispatcher, IERC20DispatcherTrait};


fn setup() -> ContractAddress {
    let erc20_class_hash = declare("MockERC20").unwrap().contract_class();

    let account: ContractAddress = contract_address_const::<1>();

    let INITIAL_SUPPLY: u256 = 1000000000;
    let mut calldata = ArrayTrait::new();
    INITIAL_SUPPLY.serialize(ref calldata);
    account.serialize(ref calldata);

    let (contract_address, _) = erc20_class_hash.deploy(@calldata).unwrap();

    contract_address
}

#[test]
fn test_get_balance() {
    let INITIAL_SUPPLY: u256 = 1000000000;
    let contract_address = setup();
    let erc20 = IERC20Dispatcher { contract_address };

    let account: ContractAddress = contract_address_const::<1>();

    assert(erc20.balance_of(account) == INITIAL_SUPPLY, 'Balance should be > 0');
}

#[test]
fn test_transfer() {
    let contract_address = setup();
    let erc20 = IERC20Dispatcher { contract_address };

    let target_account: ContractAddress = contract_address_const::<2>();

    let balance_before = erc20.balance_of(target_account);
    assert(balance_before == 0, 'Invalid balance');

    cheat_caller_address(contract_address, 1.try_into().unwrap(), CheatSpan::TargetCalls(1));

    let transfer_value: u256 = 100;
    erc20.transfer(target_account, transfer_value);

    let balance_after = erc20.balance_of(target_account);
    assert(balance_after == transfer_value, 'No value transfered');
}

#[test]
fn test_transfer_event() {
    let contract_address = setup();
    let erc20 = IERC20Dispatcher { contract_address };

    let target_account: ContractAddress = contract_address_const::<2>();
    let sender_account: ContractAddress = contract_address_const::<1>();

    cheat_caller_address(contract_address, sender_account, CheatSpan::TargetCalls(1));

    let mut spy = spy_events();

    let transfer_value: u256 = 100;
    erc20.transfer(target_account, transfer_value);

    spy
        .assert_emitted(
            @array![
                (
                    contract_address,
                    ERC20Component::Event::Transfer(
                        ERC20Component::Transfer {
                            from: sender_account, to: target_account, value: transfer_value,
                        },
                    ),
                ),
            ],
        );
}

#[test]
#[should_panic(expected: ('ERC20: insufficient balance',))]
fn should_panic_transfer() {
    let contract_address = setup();
    let erc20 = IERC20Dispatcher { contract_address };

    let target_account: ContractAddress = contract_address_const::<2>();

    let balance_before = erc20.balance_of(target_account);
    assert(balance_before == 0, 'Invalid balance');

    cheat_caller_address(contract_address, 1.try_into().unwrap(), CheatSpan::TargetCalls(1));

    let transfer_value: u256 = 1000000001;

    erc20.transfer(target_account, transfer_value);
}

