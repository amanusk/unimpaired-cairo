/// Interface representing `HelloContract`.
/// This interface allows modification and retrieval of the contract balance.
#[starknet::interface]
pub trait IOverflow<TContractState> {
    /// Increase contract balance.
    fn increase_balance(ref self: TContractState, amount: felt252);
    /// Retrieve contract balance.
    fn get_balance(self: @TContractState) -> felt252;
}

/// Simple contract for managing balance.
#[starknet::contract]
mod Overflow {
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};

    #[storage]
    struct Storage {
        balance: felt252,
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        let value = 0x800000000000000000000000000000000000000000000000000000000000000
            + 17 * 0x1000000000000000000000000000000000000000000000000;
        self.balance.write(value);
    }

    #[abi(embed_v0)]
    impl OverflowImpl of super::IOverflow<ContractState> {
        fn increase_balance(ref self: ContractState, amount: felt252) {
            assert(amount != 0, 'Amount cannot be 0');
            self.balance.write(self.balance.read() + amount);
        }

        fn get_balance(self: @ContractState) -> felt252 {
            self.balance.read()
        }
    }
}
