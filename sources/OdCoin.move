module 0xCAFE::OdCoin{
    use std::signer;
    use 0xCAFE::BaseCoin;

    struct MyOdCoin has drop{}

    const ENOT_COD:u64 = 0;

    public fun setup_and_mint(account:&signer,amount:u64){
        BaseCoin::publish_balance<MyOdCoin>(account);
        BaseCoin::mint<MyOdCoin>(signer::address_of(account),amount,MyOdCoin{});
    }

    public fun transfer(from:&signer,to:address,amount:u64){
        assert!(amount%2 ==1,ENOT_COD);
        BaseCoin::transfer<MyOdCoin>(from,to,amount);
    }


    /*
    uint tests
    */
    #[test(from = @0x42, to = @0x10)]
    fun test_odd_success(from: signer, to: signer) {
        setup_and_mint(&from, 42);
        setup_and_mint(&to, 10);

        // transfer an odd number of coins so this should succeed.
        transfer(&from, @0x10, 7);

        assert!(BaseCoin::balance_of<MyOdCoin>(@0x42) == 35, 0);
        assert!(BaseCoin::balance_of<MyOdCoin>(@0x10) == 17, 0);
    }

    #[test(from = @0x42, to = @0x10)]
    #[expected_failure]
    fun test_not_odd_failure(from: signer, to: signer) {
        setup_and_mint(&from, 42);
        setup_and_mint(&to, 10);

        // transfer an even number of coins so this should fail.
        transfer(&from, @0x10, 8);
    }

}