module 0xCAFE::BaseCoin {
    use std::signer;

    const MODULE_OWNER: address = @0xCAFE;

    // error code
    const ENOT_MODULE_OWNER: u64 = 0;
    const EINSUFFICIENT_BALANCE: u64 = 1;
    const EALREADY_HAS_BALANCE: u64 = 2;


    struct Coin has store {
        value: u64,
    }

    struct Balance has key {
        coin: Coin,
    }

    /// Publish an empty balance resource under `account`'s address. This function must be called before
    /// minting or transferring to the account.
    public fun publish_balance(account: &signer) {
        let empty_coin = Coin { value: 0 };
        move_to(account, Balance { coin: empty_coin });
    }


    public fun mint(module_owner: &signer, mint_addr: address, amount: u64) acquires Balance {
        assert!(signer::address_of(module_owner) == MODULE_OWNER, ENOT_MODULE_OWNER);
        deposit(mint_addr,Coin{value:amount});
    }


    public fun balance_of(account: address): u64 acquires Balance {
        borrow_global<Balance>(account).coin.value
    }

    /// Transfers `amount` of tokens from `from` to `to`.
    public fun transfer(from: &signer, to: address, amount: u64) acquires Balance {
        let check = withdraw(signer::address_of(from), amount);
        deposit(to, check);
    }

    /// Withdraw `amount` number of tokens from the balance under `addr`.
    fun withdraw(addr: address, amount: u64): Coin acquires Balance {
        let balance = balance_of(addr);
        // balance must be greater than the withdraw amount
        assert!(balance >= amount, EINSUFFICIENT_BALANCE);
        let balance_ref = &mut borrow_global_mut<Balance>(addr).coin.value;
        *balance_ref = balance - amount;
        Coin { value: amount }
    }

    /// deposit coin into account
    public fun deposit(addr: address, check: Coin) acquires Balance {

        let balance = balance_of(addr);
        let balance_ref = &mut borrow_global_mut<Balance>(addr).coin.value;
    
        let Coin { value } = check; // unpacks the check

      
        *balance_ref = balance + value;
    }


    // //  this test would abort that call address must be module owner 
    // #[test(account=@0x1)]
    // #[excepted_failure(ENOT_MODULE_OWNER)]
    // fun mint_not_work(account:signer)acquires Balance{
    //     publish_balance(&account);

    //     assert!(signer::address_of(&account)!=MODULE_OWNER,0);
    //     mint(&account, @0x1, 10);
    // }


    
    #[test(account=@0xCAFE)]
    fun mint_check_balance(account:signer)acquires Balance {
        let addr = signer::address_of(&account);
        publish_balance(&account);
        mint(&account, @0xCAFE, 10);
        assert!(balance_of(addr)==10,0);
    }

    #[test(account = @0x1)]
    fun publish_balance_has_zero(account: signer) acquires Balance {
        let addr = signer::address_of(&account);
        publish_balance(&account);
        assert!(balance_of(addr) == 0, 0);
    }


    // #[test(account = @0x1)]
    // #[expected_failure(abort_code = 2)] // Can specify an abort code
    // fun publish_balance_already_exists(account: signer) {
    //     publish_balance(&account);
    //     publish_balance(&account);
    // }
    

    #[test]
    #[expected_failure]
    fun withdraw_dne() acquires Balance {
        // Need to unpack the coin since `Coin` is a resource
        Coin { value: _ } = withdraw(@0x1, 0);
    }

    #[test(account = @0x1)]
    #[expected_failure] // This test should fail
    fun withdraw_too_much(account: signer) acquires Balance {
        let addr = signer::address_of(&account);
        publish_balance(&account);
        Coin { value: _ } = withdraw(addr, 1);
    }

    #[test(account=@0xCAFE)]
    fun withdraw_work(account:signer)acquires Balance{
        let addr = signer::address_of(&account);
        publish_balance(&account);
        mint(&account, @0xCAFE, 50);
        let Coin{value} = withdraw(addr,50);
        assert!(value==50,0);
        assert!(balance_of(addr)==0,0);
    }

}