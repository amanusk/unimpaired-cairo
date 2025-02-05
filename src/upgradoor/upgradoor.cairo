/// Simple contract for managing balance.
#[starknet::contract]
mod Upgradoor {
    use core::starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use core::starknet::{
        ContractAddress, get_caller_address, ClassHash, SyscallResultTrait, get_contract_address,
    };
    use crate::upgradoor::interface::{IUpgradoor, IUpgradoorDispatcher, IUpgradoorDispatcherTrait};
    use core::num::traits::Zero;

    #[storage]
    struct Storage {
        owner: ContractAddress,
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.owner.write(owner);
    }

    #[abi(embed_v0)]
    impl UpgradoorImpl of IUpgradoor<ContractState> {
        fn set_owner(ref self: ContractState, new_owner: ContractAddress) {
            assert!(get_caller_address() == self.owner.read(), "NOT_OWNER");
            self.owner.write(new_owner);
        }

        fn get_owner(self: @ContractState) -> ContractAddress {
            self.owner.read()
        }

        fn upgrade(ref self: ContractState, new_class_hash: ClassHash) {
            assert!(new_class_hash.is_non_zero(), "INVALID_CLASS_HASH");
            assert!(get_caller_address() == self.owner.read(), "NOT_OWNER");
            starknet::syscalls::replace_class_syscall(new_class_hash).unwrap_syscall();
        }

        fn change_owner_and_upgrade(
            ref self: ContractState, new_owner: ContractAddress, new_class_hash: ClassHash,
        ) {
            let address = get_contract_address();
            let contract = IUpgradoorDispatcher { contract_address: address };
            self.upgrade(new_class_hash);
            contract.set_owner(new_owner);
        }
    }
}
