use starknet::ContractAddress;

#[starknet::interface]
pub trait IWritoor<TContractState> {
    /// Increase contract balance.
    fn transfer(ref self: TContractState, target: ContractAddress, amount: u256);
    /// Retrieve contract balance.
    fn get_balance(self: @TContractState, account: ContractAddress) -> u256;
    fn mint(ref self: TContractState, account: ContractAddress, amount: u256);
}

/// Simple contract for managing balance.
#[starknet::contract]
mod Writoor {
    use starknet::storage::{
        Map, StorageMapReadAccess, StorageMapWriteAccess, StoragePointerReadAccess,
        StoragePointerWriteAccess,
    };
    use starknet::{ContractAddress, get_caller_address};

    #[storage]
    struct Storage {
        owner: ContractAddress,
        balances: Map<ContractAddress, u256>,
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.owner.write(owner);
    }

    #[abi(embed_v0)]
    impl WritoorImpl of super::IWritoor<ContractState> {
        fn transfer(ref self: ContractState, target: ContractAddress, amount: u256) {
            let mut caller_balance = self.balances.read(get_caller_address());
            let mut target_balance = self.balances.read(target);
            self.handle_balance(ref caller_balance, ref target_balance, amount);
        }

        fn get_balance(self: @ContractState, account: ContractAddress) -> u256 {
            self.balances.read(account)
        }

        fn mint(ref self: ContractState, account: ContractAddress, amount: u256) {
            assert!(get_caller_address() == self.owner.read(), "NOT OWNER");
            self.balances.write(account, self.balances.read(account) + amount);
        }
    }

    #[generate_trait]
    impl InnerTraitImpl of InnerTrait {
        fn handle_balance(
            ref self: ContractState,
            ref caller_balance: u256,
            ref target_balance: u256,
            amount: u256,
        ) {
            caller_balance = caller_balance - amount;
            target_balance = target_balance + amount;
        }
    }
}
