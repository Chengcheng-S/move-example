
<a name="0xcafe_OdCoin"></a>

# Module `0xcafe::OdCoin`



-  [Struct `MyOdCoin`](#0xcafe_OdCoin_MyOdCoin)
-  [Constants](#@Constants_0)
-  [Function `setup_and_mint`](#0xcafe_OdCoin_setup_and_mint)
-  [Function `transfer`](#0xcafe_OdCoin_transfer)


<pre><code><b>use</b> <a href="">0x1::signer</a>;
<b>use</b> <a href="example.md#0xcafe_BaseCoin">0xcafe::BaseCoin</a>;
</code></pre>



<a name="0xcafe_OdCoin_MyOdCoin"></a>

## Struct `MyOdCoin`



<pre><code><b>struct</b> <a href="OdCoin.md#0xcafe_OdCoin_MyOdCoin">MyOdCoin</a> <b>has</b> drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>dummy_field: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0xcafe_OdCoin_ENOT_COD"></a>



<pre><code><b>const</b> <a href="OdCoin.md#0xcafe_OdCoin_ENOT_COD">ENOT_COD</a>: u64 = 0;
</code></pre>



<a name="0xcafe_OdCoin_setup_and_mint"></a>

## Function `setup_and_mint`



<pre><code><b>public</b> <b>fun</b> <a href="OdCoin.md#0xcafe_OdCoin_setup_and_mint">setup_and_mint</a>(account: &<a href="">signer</a>, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="OdCoin.md#0xcafe_OdCoin_setup_and_mint">setup_and_mint</a>(account:&<a href="">signer</a>,amount:u64){
    <a href="example.md#0xcafe_BaseCoin_publish_balance">BaseCoin::publish_balance</a>&lt;<a href="OdCoin.md#0xcafe_OdCoin_MyOdCoin">MyOdCoin</a>&gt;(account);
    <a href="example.md#0xcafe_BaseCoin_mint">BaseCoin::mint</a>&lt;<a href="OdCoin.md#0xcafe_OdCoin_MyOdCoin">MyOdCoin</a>&gt;(<a href="_address_of">signer::address_of</a>(account),amount,<a href="OdCoin.md#0xcafe_OdCoin_MyOdCoin">MyOdCoin</a>{});
}
</code></pre>



</details>

<a name="0xcafe_OdCoin_transfer"></a>

## Function `transfer`



<pre><code><b>public</b> <b>fun</b> <a href="OdCoin.md#0xcafe_OdCoin_transfer">transfer</a>(from: &<a href="">signer</a>, <b>to</b>: <b>address</b>, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="OdCoin.md#0xcafe_OdCoin_transfer">transfer</a>(from:&<a href="">signer</a>,<b>to</b>:<b>address</b>,amount:u64){
    <b>assert</b>!(amount%2 ==1,<a href="OdCoin.md#0xcafe_OdCoin_ENOT_COD">ENOT_COD</a>);
    <a href="example.md#0xcafe_BaseCoin_transfer">BaseCoin::transfer</a>&lt;<a href="OdCoin.md#0xcafe_OdCoin_MyOdCoin">MyOdCoin</a>&gt;(from,<b>to</b>,amount);
}
</code></pre>



</details>
