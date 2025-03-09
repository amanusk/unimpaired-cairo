/// Interface representing `HelloContract`.
/// This interface allows modification and retrieval of the contract balance.

#[starknet::interface]
pub trait IBadler<TContractState> {
    /// Increase contract balance.
    fn increase_balance(ref self: TContractState, amount: felt252);
    /// Retrieve contract balance.
    fn get_balance(self: @TContractState) -> felt252;
}

/// Simple contract for managing balance.
#[starknet::contract]
mod Badler {
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use starknet::{ContractAddress, get_caller_address};

    #[storage]
    struct Storage {
        balance: felt252,
        owner: ContractAddress,
        l1_owner: felt252,
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress, l1_owner: felt252) {
        self.owner.write(owner);
        self.l1_owner.write(l1_owner);
    }

    #[abi(embed_v0)]
    impl BalancerImpl of super::IBadler<ContractState> {
        fn increase_balance(ref self: ContractState, amount: felt252) {
            assert(amount != 0, 'Amount cannot be 0');
            let caller = get_caller_address();
            assert(caller == self.owner.read(), 'ONLY_OWNER');
            self.balance.write(self.balance.read() + amount);
        }

        fn get_balance(self: @ContractState) -> felt252 {
            self.balance.read()
        }
    }


    #[l1_handler]
    fn increase_balance_from_l1(ref self: ContractState, from_address: felt252, amount: felt252) {
        assert(amount != 0, 'Amount cannot be 0');
        self.balance.write(self.balance.read() + amount);
    }
}
