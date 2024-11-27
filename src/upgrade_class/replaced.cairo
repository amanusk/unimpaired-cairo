#[starknet::contract]
mod Replaced {
    use starknet::ContractAddress;


    #[storage]
    struct Storage {
        Owner: ContractAddress,
    }

    #[event]
    #[derive(Drop, PartialEq, starknet::Event)]
    enum Event {
        Replaced: Replaced,
    }

    /// Emitted when the contracts gets updated
    #[derive(Drop, PartialEq, starknet::Event)]
    struct Replaced {
        #[key]
        from: ContractAddress,
        #[key]
        to: ContractAddress,
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.Owner = owner;
    }

    #[embeddable_as(ReplacedImpl)]
    impl ERC20<
        TContractState, +HasComponent<TContractState>
    > of interface::IERC20<ComponentState<TContractState>> {
        /// Returns the value of tokens in existence.
        fn total_supply(self: @ComponentState<TContractState>) -> u256 {
            self.ERC20_total_supply.read()
        }

}
