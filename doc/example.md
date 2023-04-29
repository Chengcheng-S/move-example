
<a name="0xcafe_BaseCoin"></a>

# Module `0xcafe::BaseCoin`



-  [Struct `Coin`](#0xcafe_BaseCoin_Coin)
-  [Resource `Balance`](#0xcafe_BaseCoin_Balance)
-  [Constants](#@Constants_0)
-  [Function `publish_balance`](#0xcafe_BaseCoin_publish_balance)
-  [Function `mint`](#0xcafe_BaseCoin_mint)
-  [Function `balance_of`](#0xcafe_BaseCoin_balance_of)
-  [Function `transfer`](#0xcafe_BaseCoin_transfer)
-  [Function `withdraw`](#0xcafe_BaseCoin_withdraw)
-  [Function `deposit`](#0xcafe_BaseCoin_deposit)


<pre><code><b>use</b> <a href="">0x1::signer</a>;
</code></pre>



<a name="0xcafe_BaseCoin_Coin"></a>

## Struct `Coin`



<pre><code><b>struct</b> <a href="example.md#0xcafe_BaseCoin_Coin">Coin</a>&lt;CoinType&gt; <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>value: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0xcafe_BaseCoin_Balance"></a>

## Resource `Balance`



<pre><code><b>struct</b> <a href="example.md#0xcafe_BaseCoin_Balance">Balance</a>&lt;CoinType&gt; <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>coin: <a href="example.md#0xcafe_BaseCoin_Coin">BaseCoin::Coin</a>&lt;CoinType&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0xcafe_BaseCoin_EALREADY_HAS_BALANCE"></a>



<pre><code><b>const</b> <a href="example.md#0xcafe_BaseCoin_EALREADY_HAS_BALANCE">EALREADY_HAS_BALANCE</a>: u64 = 2;
</code></pre>



<a name="0xcafe_BaseCoin_EEQUAL_ADDR"></a>



<pre><code><b>const</b> <a href="example.md#0xcafe_BaseCoin_EEQUAL_ADDR">EEQUAL_ADDR</a>: u64 = 4;
</code></pre>



<a name="0xcafe_BaseCoin_EINSUFFICIENT_BALANCE"></a>



<pre><code><b>const</b> <a href="example.md#0xcafe_BaseCoin_EINSUFFICIENT_BALANCE">EINSUFFICIENT_BALANCE</a>: u64 = 1;
</code></pre>



<a name="0xcafe_BaseCoin_ENOT_MODULE_OWNER"></a>



<pre><code><b>const</b> <a href="example.md#0xcafe_BaseCoin_ENOT_MODULE_OWNER">ENOT_MODULE_OWNER</a>: u64 = 0;
</code></pre>



<a name="0xcafe_BaseCoin_MODULE_OWNER"></a>



<pre><code><b>const</b> <a href="example.md#0xcafe_BaseCoin_MODULE_OWNER">MODULE_OWNER</a>: <b>address</b> = cafe;
</code></pre>



<a name="0xcafe_BaseCoin_publish_balance"></a>

## Function `publish_balance`

Publish an empty balance resource under <code>account</code>'s address. This function must be called before
minting or transferring to the account.


<pre><code><b>public</b> <b>fun</b> <a href="example.md#0xcafe_BaseCoin_publish_balance">publish_balance</a>&lt;CoinType&gt;(account: &<a href="">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="example.md#0xcafe_BaseCoin_publish_balance">publish_balance</a>&lt;CoinType&gt;(account: &<a href="">signer</a>) {
    <b>let</b> empty_coin = <a href="example.md#0xcafe_BaseCoin_Coin">Coin</a>&lt;CoinType&gt; { value: 0 };
    <b>assert</b>!(!<b>exists</b>&lt;<a href="example.md#0xcafe_BaseCoin_Balance">Balance</a>&lt;CoinType&gt;&gt;(<a href="_address_of">signer::address_of</a>(account)), <a href="example.md#0xcafe_BaseCoin_EALREADY_HAS_BALANCE">EALREADY_HAS_BALANCE</a>);
    <b>move_to</b>(account, <a href="example.md#0xcafe_BaseCoin_Balance">Balance</a> { coin: empty_coin });
}
</code></pre>



</details>

<a name="0xcafe_BaseCoin_mint"></a>

## Function `mint`



<pre><code><b>public</b> <b>fun</b> <a href="example.md#0xcafe_BaseCoin_mint">mint</a>&lt;CoinType: drop&gt;(mint_addr: <b>address</b>, amount: u64, _witness: CoinType)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="example.md#0xcafe_BaseCoin_mint">mint</a>&lt;CoinType: drop&gt;(mint_addr: <b>address</b>, amount: u64, _witness: CoinType) <b>acquires</b> <a href="example.md#0xcafe_BaseCoin_Balance">Balance</a> {
    <a href="example.md#0xcafe_BaseCoin_deposit">deposit</a>(mint_addr, <a href="example.md#0xcafe_BaseCoin_Coin">Coin</a>&lt;CoinType&gt; { value: amount });
}
</code></pre>



</details>

<a name="0xcafe_BaseCoin_balance_of"></a>

## Function `balance_of`



<pre><code><b>public</b> <b>fun</b> <a href="example.md#0xcafe_BaseCoin_balance_of">balance_of</a>&lt;CoinType&gt;(account: <b>address</b>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="example.md#0xcafe_BaseCoin_balance_of">balance_of</a>&lt;CoinType&gt;(account: <b>address</b>): u64 <b>acquires</b> <a href="example.md#0xcafe_BaseCoin_Balance">Balance</a> {
    <b>borrow_global</b>&lt;<a href="example.md#0xcafe_BaseCoin_Balance">Balance</a>&lt;CoinType&gt;&gt;(account).coin.value
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>pragma</b> aborts_if_is_strict;
<b>aborts_if</b> !<b>exists</b>&lt;<a href="example.md#0xcafe_BaseCoin_Balance">Balance</a>&lt;CoinType&gt;&gt;(account);
</code></pre>



</details>

<a name="0xcafe_BaseCoin_transfer"></a>

## Function `transfer`

Transfers <code>amount</code> of tokens from <code>from</code> to <code><b>to</b></code>.


<pre><code><b>public</b> <b>fun</b> <a href="example.md#0xcafe_BaseCoin_transfer">transfer</a>&lt;CoinType: drop&gt;(from: &<a href="">signer</a>, <b>to</b>: <b>address</b>, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="example.md#0xcafe_BaseCoin_transfer">transfer</a>&lt;CoinType: drop&gt;(from: &<a href="">signer</a>, <b>to</b>: <b>address</b>, amount: u64) <b>acquires</b> <a href="example.md#0xcafe_BaseCoin_Balance">Balance</a> {
    <b>let</b> from_addr = <a href="_address_of">signer::address_of</a>(from);
    <b>assert</b>!(from_addr != <b>to</b>, <a href="example.md#0xcafe_BaseCoin_EEQUAL_ADDR">EEQUAL_ADDR</a>);
    <b>let</b> check = <a href="example.md#0xcafe_BaseCoin_withdraw">withdraw</a>&lt;CoinType&gt;(from_addr, amount);
    <a href="example.md#0xcafe_BaseCoin_deposit">deposit</a>&lt;CoinType&gt;(<b>to</b>, check);
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>let</b> addr_from = <a href="_address_of">signer::address_of</a>(from);
<b>let</b> balance_from = <b>global</b>&lt;<a href="example.md#0xcafe_BaseCoin_Balance">Balance</a>&lt;CoinType&gt;&gt;(addr_from).coin.value;
<b>let</b> balance_to = <b>global</b>&lt;<a href="example.md#0xcafe_BaseCoin_Balance">Balance</a>&lt;CoinType&gt;&gt;(<b>to</b>).coin.value;
<b>let</b> <b>post</b> balance_from_post = <b>global</b>&lt;<a href="example.md#0xcafe_BaseCoin_Balance">Balance</a>&lt;CoinType&gt;&gt;(addr_from).coin.value;
<b>let</b> <b>post</b> balance_to_post = <b>global</b>&lt;<a href="example.md#0xcafe_BaseCoin_Balance">Balance</a>&lt;CoinType&gt;&gt;(<b>to</b>).coin.value;
<b>ensures</b> balance_from_post == balance_from - amount;
<b>ensures</b> balance_to_post == balance_to + amount;
</code></pre>



</details>

<a name="0xcafe_BaseCoin_withdraw"></a>

## Function `withdraw`

Withdraw <code>amount</code> number of tokens from the balance under <code>addr</code>.


<pre><code><b>fun</b> <a href="example.md#0xcafe_BaseCoin_withdraw">withdraw</a>&lt;CoinType&gt;(addr: <b>address</b>, amount: u64): <a href="example.md#0xcafe_BaseCoin_Coin">BaseCoin::Coin</a>&lt;CoinType&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="example.md#0xcafe_BaseCoin_withdraw">withdraw</a>&lt;CoinType&gt;(addr: <b>address</b>, amount: u64): <a href="example.md#0xcafe_BaseCoin_Coin">Coin</a>&lt;CoinType&gt; <b>acquires</b> <a href="example.md#0xcafe_BaseCoin_Balance">Balance</a> {
    <b>let</b> balance = <a href="example.md#0xcafe_BaseCoin_balance_of">balance_of</a>&lt;CoinType&gt;(addr);
    // balance must be greater than the withdraw amount
    <b>assert</b>!(balance &gt;= amount, <a href="example.md#0xcafe_BaseCoin_EINSUFFICIENT_BALANCE">EINSUFFICIENT_BALANCE</a>);
    <b>let</b> balance_ref = &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="example.md#0xcafe_BaseCoin_Balance">Balance</a>&lt;CoinType&gt;&gt;(addr).coin.value;
    *balance_ref = balance - amount;
    <a href="example.md#0xcafe_BaseCoin_Coin">Coin</a> { value: amount }
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>let</b> balance = <b>global</b>&lt;<a href="example.md#0xcafe_BaseCoin_Balance">Balance</a>&lt;CoinType&gt;&gt;(addr).coin.value;
<b>aborts_if</b> !<b>exists</b>&lt;<a href="example.md#0xcafe_BaseCoin_Balance">Balance</a>&lt;CoinType&gt;&gt;(addr);
<b>aborts_if</b> balance &lt; amount;
<b>let</b> <b>post</b> balance_post = <b>global</b>&lt;<a href="example.md#0xcafe_BaseCoin_Balance">Balance</a>&lt;CoinType&gt;&gt;(addr).coin.value;
<b>ensures</b> balance_post == balance - amount;
<b>ensures</b> result == <a href="example.md#0xcafe_BaseCoin_Coin">Coin</a>&lt;CoinType&gt; { value: amount };
</code></pre>



</details>

<a name="0xcafe_BaseCoin_deposit"></a>

## Function `deposit`

deposit coin into account


<pre><code><b>public</b> <b>fun</b> <a href="example.md#0xcafe_BaseCoin_deposit">deposit</a>&lt;CoinType&gt;(addr: <b>address</b>, check: <a href="example.md#0xcafe_BaseCoin_Coin">BaseCoin::Coin</a>&lt;CoinType&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="example.md#0xcafe_BaseCoin_deposit">deposit</a>&lt;CoinType&gt;(addr: <b>address</b>, check: <a href="example.md#0xcafe_BaseCoin_Coin">Coin</a>&lt;CoinType&gt;) <b>acquires</b> <a href="example.md#0xcafe_BaseCoin_Balance">Balance</a> {
    <b>let</b> balance = <a href="example.md#0xcafe_BaseCoin_balance_of">balance_of</a>&lt;CoinType&gt;(addr);
    <b>let</b> balance_ref = &<b>mut</b> <b>borrow_global_mut</b>&lt;<a href="example.md#0xcafe_BaseCoin_Balance">Balance</a>&lt;CoinType&gt;&gt;(addr).coin.value;

    <b>let</b> <a href="example.md#0xcafe_BaseCoin_Coin">Coin</a> { value } = check; // unpacks the check

    *balance_ref = balance + value;
}
</code></pre>



</details>

<details>
<summary>Specification</summary>



<pre><code><b>let</b> balance = <b>global</b>&lt;<a href="example.md#0xcafe_BaseCoin_Balance">Balance</a>&lt;CoinType&gt;&gt;(addr).coin.value;
<b>let</b> check_value = check.value;
<b>aborts_if</b> !<b>exists</b>&lt;<a href="example.md#0xcafe_BaseCoin_Balance">Balance</a>&lt;CoinType&gt;&gt;(addr);
<b>aborts_if</b> balance + check_value &gt; MAX_U64;
<b>let</b> <b>post</b> balance_post = <b>global</b>&lt;<a href="example.md#0xcafe_BaseCoin_Balance">Balance</a>&lt;CoinType&gt;&gt;(addr).coin.value;
<b>ensures</b> balance_post == balance + check_value;
</code></pre>



</details>
