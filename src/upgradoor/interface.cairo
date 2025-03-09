use starknet::{ClassHash, ContractAddress};

/// Interface representing `HelloContract`.
#[starknet::interface]
pub trait IUpgradoor<TContractState> {
    fn set_owner(ref self: TContractState, new_owner: ContractAddress);
    fn get_owner(self: @TContractState) -> ContractAddress;
    fn upgrade(ref self: TContractState, new_class_hash: ClassHash);
    fn change_owner_and_upgrade(
        ref self: TContractState, new_owner: ContractAddress, new_class_hash: ClassHash,
    );
}

