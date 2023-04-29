module 0xCAFE::BaseCoin {
    use std::signer;

    const MODULE_OWNER: address = @0xCAFE;

    // error code
    const ENOT_MODULE_OWNER: u64 = 0;
    const EINSUFFICIENT_BALANCE: u64 = 1;
    const EALREADY_HAS_BALANCE: u64 = 2;
    const EEQUAL_ADDR: u64 = 4;


    struct Coin<phantom CoinType>has store {
        value: u64,
    }

    struct Balance<phantom CoinType>has key {
        coin: Coin<CoinType>,
    }

    /// Publish an empty balance resource under `account`'s address. This function must be called before
    /// minting or transferring to the account.
    public fun publish_balance<CoinType>(account: &signer) {
        let empty_coin = Coin<CoinType> { value: 0 };
        assert!(!exists<Balance<CoinType>>(signer::address_of(account)), EALREADY_HAS_BALANCE);
        move_to(account, Balance { coin: empty_coin });
    }


    public fun mint<CoinType: drop>(mint_addr: address, amount: u64, _witness: CoinType) acquires Balance {
        deposit(mint_addr, Coin<CoinType> { value: amount });
    }


    public fun balance_of<CoinType>(account: address): u64 acquires Balance {
        borrow_global<Balance<CoinType>>(account).coin.value
    }

    spec balance_of {
        pragma aborts_if_is_strict;
        aborts_if !exists<Balance<CoinType>>(account);
    }


    /// Transfers `amount` of tokens from `from` to `to`.
    public fun transfer<CoinType: drop>(from: &signer, to: address, amount: u64) acquires Balance {
        let from_addr = signer::address_of(from);
        assert!(from_addr != to, EEQUAL_ADDR);
        let check = withdraw<CoinType>(from_addr, amount);
        deposit<CoinType>(to, check);
    }

    // verify transfer method  such as polkadot benchmark
    spec transfer {
        let addr_from = signer::address_of(from);

        let balance_from = global<Balance<CoinType>>(addr_from).coin.value;
        let balance_to = global<Balance<CoinType>>(to).coin.value;
        let post balance_from_post = global<Balance<CoinType>>(addr_from).coin.value;
        let post balance_to_post = global<Balance<CoinType>>(to).coin.value;

        ensures balance_from_post == balance_from - amount;
        ensures balance_to_post == balance_to + amount;
    }

    /// Withdraw `amount` number of tokens from the balance under `addr`.
    fun withdraw<CoinType>(addr: address, amount: u64): Coin<CoinType> acquires Balance {
        let balance = balance_of<CoinType>(addr);
        // balance must be greater than the withdraw amount
        assert!(balance >= amount, EINSUFFICIENT_BALANCE);
        let balance_ref = &mut borrow_global_mut<Balance<CoinType>>(addr).coin.value;
        *balance_ref = balance - amount;
        Coin { value: amount }
    }

    spec withdraw {
        let balance = global<Balance<CoinType>>(addr).coin.value;
        aborts_if !exists<Balance<CoinType>>(addr);
        aborts_if balance < amount;

        let post balance_post = global<Balance<CoinType>>(addr).coin.value;
        ensures balance_post == balance - amount;
        ensures result == Coin<CoinType> { value: amount };
    }


    /// deposit coin into account
    public fun deposit<CoinType>(addr: address, check: Coin<CoinType>) acquires Balance {
        let balance = balance_of<CoinType>(addr);
        let balance_ref = &mut borrow_global_mut<Balance<CoinType>>(addr).coin.value;

        let Coin { value } = check; // unpacks the check

        *balance_ref = balance + value;
    }

    spec deposit {
        let balance = global<Balance<CoinType>>(addr).coin.value;
        let check_value = check.value;

        aborts_if !exists<Balance<CoinType>>(addr);
        aborts_if balance + check_value > MAX_U64;

        let post balance_post = global<Balance<CoinType>>(addr).coin.value;
        ensures balance_post == balance + check_value;
    }


    // //  this test would abort that call address must be module owner 
    // #[test(account=@0x1)]
    // #[excepted_failure(ENOT_MODULE_OWNER)]
    // fun mint_not_work(account:signer)acquires Balance{
    //     publish_balance(&account);

    //     assert!(signer::address_of(&account)!=MODULE_OWNER,0);
    //     mint(&account, @0x1, 10);
    // }


    #[test(account = @0xCAFE)]
    fun mint_check_balance<CoinType>(account: signer) acquires Balance {
        let addr = signer::address_of(&account);
        publish_balance<CoinType>(&account);
        mint(@0xCAFE, 10, 0);
        assert!(balance_of<CoinType>(addr) == 10, 0);
    }

    #[test(account = @0x1)]
    fun publish_balance_has_zero<CoinType>(account: signer) acquires Balance {
        let addr = signer::address_of(&account);
        publish_balance<CoinType>(&account);
        assert!(balance_of<CoinType>(addr) == 0, 0);
    }


    // #[test(account = @0x1)]
    // #[expected_failure(abort_code = 2)] // Can specify an abort code
    // fun publish_balance_already_exists(account: signer) {
    //     publish_balance(&account);
    //     publish_balance(&account);
    // }


    #[test]
    #[expected_failure]
    fun withdraw_dne<CoinType>() acquires Balance {
        // Need to unpack the coin since `Coin` is a resource
        Coin<CoinType> { value: _ } = withdraw(@0x1, 0);
    }

    #[test(account = @0x1)]
    #[expected_failure] // This test should fail
    fun withdraw_too_much<CoinType>(account: signer) acquires Balance {
        let addr = signer::address_of(&account);
        publish_balance<CoinType>(&account);
        Coin<CoinType> { value: _ } = withdraw(addr, 1);
    }

    #[test(account = @0xCAFE)]
    fun withdraw_work<CoinType>(account: signer) acquires Balance {
        let addr = signer::address_of(&account);
        publish_balance<CoinType>(&account);
        mint(@0xCAFE, 50, 3);
        let Coin<CoinType> { value } = withdraw(addr, 50);
        assert!(value == 50, 0);
        assert!(balance_of<CoinType>(addr) == 0, 0);
    }
}