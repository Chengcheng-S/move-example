## Move note
move-lang learn note 
The official project link  
- https://github.com/move-language/move/blob/main/language/documentation/book/translations/move-book-zh/src/SUMMARY.md
- https://github.com/move-language/move/tree/main/language/documentation/tutorial
If you have the foundation of Rust-lang, you can directly read the official documentation, if not, it is not very important, but the book will compare some details of Move and Rust.


### structs
struct values as `resources` if it can't be `copied and be dropped`. This struct can't be copied can't be  dropped  and  cannot be stored in global storage by default.This means that all values have to have ownership transferred (linear) and the values must be dealt with by the end of the program's execution (ephemeral).
tip: struct can't be recursive


```move
address 0x40 {
    module A{
        struct A{
            x :u64,
            y : bool,
        }
        struct B{
            value : B // invailed 
        }
    }

}
```

abilities:
- copy: Allows values of types with this ability to be copied. 
- drop: Allows values of types with this ability to be popped/dropped.
- store: Allows values of types with this ability to exist inside a struct in global storage.
- key: Allows the type to serve as a key for global storage operations.

```move
module 0x40::Example {
    
    struct Coin has store{
        value : u64
    }
    
    struct Balnace has key{
        coin: Coin
    }
}
```


### function keywords:
- entry: The entry modifier is designed to allow module functions to be safely and directly invoked much like scripts. This allows module writers to specify which functions can be to begin execution.Essentially, entry functions are the "main" functions of a module, and they specify where Move programs start executing., an entry function can still be called by other Move functions. So while they can serve as the start of a Move program, they aren't restricted to that case.
- public / public(friend) 
-  Acquires: When a function accesses a resource using move_from, borrow_global, or borrow_global_mut, the function must indicate that it acquires that resource. This is then used by Move's type system to ensure the references into global storage are safe, specifically that there are no dangling references into global storage.
- scripts return type : `script` functions must have a return type of uint `()`
- native function: some functions don't have a body, and instead have the body provided by the VM. These functions are marked native.Without modifying the VM source code, a programmer cannot add new native functions. Furthermore, it is the intent that native functions are used for either standard library code or for functionality needed for the given Move environment.

```move
address 0x40 {
    module A {
        public entry fun foo(): u64 { 0 }
    
        fun call_foo(): u64 { foo() }
    
        // internal function can be marked `entry` too
        entry fun bar(): u64 { 0 }
    }
    
    module B {
    
        use std::signer;
    
        fun call_foo(): u64 {
            0x40::A::foo()
        }
    
        struct Balances has key { value: u64 }
    
        public fun add_balance(acc: &signer, value: u64) {
            move_to(acc, Balances { value })
        }
    
        public fun get_value(acc: address): u64 acquires Balances {
            borrow_global<Balances>(address).value
        }
    }
}
script {
    fun do_something(){}
}
```
native function
```move
    module std::vector {
    native public fun empty<Element>(): vector<Element>;
    
    }
```

### Friends
`friend` is used to declare modules that are trusted by the current module. A trusted module is allowed to call any function defined in the current module that have the public(friend) visibility. 

```move
address 0x40{
    module A{
        friend 0x40::B;
    }
    
    module B{
        use 0x40::A;
        friend A;
    }
}
```

Unlike use statements, friend can only be declared in the module scope and not in the expression block scope. 
Tip: 
- A Move script cannot declare friend modules as doing so is considered meaningless: there is no mechanism to call the function defined in a script.
- A Move module cannot declare friend scripts as well because scripts are ephemeral code snippets that are never published to global storage.

#### declaration rule 
- A module can't declare itself as a friend
- Friend modules must be known by complie
- Friend modules must be within the same account address. (Note: this is not a technical requirement but rather a policy decision which may be relaxed later.)
- Friends relationships cannot create cyclic module dependencies.declaring a friend module adds a dependency upon the current module to the friend module (because the purpose is for the friend to call functions in the current module). If that friend module is already used, either directly or transitively, a cycle of dependencies would be created.
- friend list for a module can't contain duplicates.

```move
address 0x40{
    module a{
        friend Self; // error
        friend 0x40::a; // error
    }

    module b{
        friend 0x40::c; // doesn't declare this module C
    }
}


address 0x42{
    module c{
        friend 0x40::A; // can't declare out of this address's module as friends
    }
}

```

```move
address 0x40{
    module A{
        public entry fun foo():u64{0}
        fun call_foo():u64{foo()}
        // internal function can be marked `entry` too
        entry fun bar():u64{0}
    }
}
    
    address 0x40{
    module B{
        friend 0x40::A;
    
        fun call_foo():u64{
            0x40::A::foo()
        }
    }
}
```

```shell
error[E02004]: invalid 'module' declaration
   ┌─ ./sources/example.move:12:9
   │
12 │         friend 0x40::A; 
   │         ^^^^^^^^^^^^^^^ '0x40::A' is a friend of '0x40::B'. This 'friend' relationship creates a dependency cycle.
   ·
15 │            0x40::A::foo()
   │            ------------ '0x40::A' uses '0x40::B'
```
fix this error
reference this link: https://github.com/move-language/move/blob/main/language/changes/1-friend-visibility.md

```move
address 0x40{
    module A{
        friend 0x40::B;
        public entry fun foo():u64{0}
        public(friend) fun call_foo():u64{foo()}
        // internal function can be marked `entry` too
        entry fun bar():u64{0}
    }
}

address 0x40{
        module B{
        use 0x40::A;

        fun set_number():u64{
           2
        }

        fun call_a_foo():u64{
            A::foo()
        }

        fun call_foo():u64{
            A::call_foo()
        }
        
    }
}
```

## move prove
link https://github.com/move-language/move/blob/main/language/move-prover/doc/user/install.md

`move prove`  Automated tool for Moves Lang smart contract validation
work flow ,
`move`--> `move parser` -->`move compiler` --bytecode--> `prover object model` ---> `Boogle Translator` ---> `Boogle` ---> `Z3 SMT solver` ---> `SMT modle`---> `Boogle result analyzer`---> `Diagnosis` 

move porve accepts a Move source file, compiles it, and converts it to the validator object model by specification, The model will be translated into an intermediate language called Boogie. This Boogie code is passed into the Boogie validation system, which performs a "verification condition generation" of the input. This validation condition (VC) is passed into an automated theorem prove called Z3.
After the VC is passed into the Z3 program, the validator checks whether the SMT formula is not satisfied. If so, it means that the specification is valid. Otherwise, a model that satisfies the conditions is generated and converted back to the Boogie format for the publication of a diagnostic report. The diagnostic report then reverts to a source-level error similar to the standard compiler error.


MSL (move specification language) 
```move
address 0x40{
    module A{
        fun xxx(){}

        spec xxx{
            ///verify xxx work
        }
    }
}
```
### aborts_if
`aborts_if` defines a function that should be terminated if a certain condition is met, and an abort in the smart contract causes the entire transaction to be rolled back
```move
...
const P64: u128 = 0x10000000000000000;

spec fun value_of_U256(a: U256): num {
    a.v0 + 
    a.v1 * P64 + 
    a.v2 * P64 * P64 + 
    a.v3 * P64 * P64 * P64
}

spec add {
    aborts_if value_of_U256(a) + value_of_U256(b) >= P64 * P64 * P64 * P64;
}
...
```
Functions can be called in spec code blocks. But the callee must be an MSL function or a `pure Move function.` The pure Move function is one that `does not modify global variables` or uses statements and features that are supported by MSL.

### aborts_if false
aborts_if false can have a function never terminate
```move
spec critical_function {
    aborts_if false;
} 
fun get(addr: address): &Counter acquires Counter {
borrow_global<Counter>(addr)
}
spec get {
aborts_if !exists<Counter>(addr) with EXECUTION_FAILURE;
}

```
### aborts_with
The aborts_with condition allows specifying with which codes a function can abort, independent under which condition.
```move
fun get_one_off(addr: address): u64 {
    aborts(exists<Counter>(addr), 3);
    borrow_global<Counter>(addr).value - 1
}
spec get_one_off {
    aborts_with 3, EXECUTION_FAILURE;
}
```

### requires 
The requires condition is a spec block member which postulates a pre-condition for a function. The prover will produce verification errors for functions which are called with violating pre-conditions.
```move
spec increment {
    requires global<Counter>(a).value < 255;
}
```

### ensure
Ensure that a state is acknowledged at the end of the function run.

```move
fun increment(counter: &mut u64) { *counter = *counter + 1 }
spec increment {
   ensures counter == old(counter) + 1;
}

fun increment_R(addr: address) {
    let r =  borrow_global_mut<R>(addr);
    r.value = r.value + 1;
}
spec increment_R {
    ensures global<R>(addr).value == old(global<R>(addr).value) + 1;
}

```

```move
address 0x40{
    module C{

        struct A has drop{
            a:u64,
            b:u64,
        }

        spec A{
            // b the second elem at A, as a bv type 
            pragma bv = b"1";
        }

        public fun foo_generic<T>(i:T):T{
            i
        }
        
        spec foo_generic{
            pragma bv = b"0";
            pragma bv_ret = b"0";
        }

        public fun test(i:A):u64{
            let x = foo_generic(i.b);
            x^x 
        }

        spec test{
            ensures result ==(0  as u64);
        }

    }
}
```

### modifies
The modifies condition is used to provide permissions to a function to modify global storage.The annotation itself comprises a list of global access expressions. It is specifically used together with opaque function specifications.
```move
address 0x40{
module C{
    struct P has key{
        x:u64
    }

    fun mutate_at(addr:address) acquires P{
        let s = borrow_global_mut<P>(addr);
        s.x = 1
    }
    spec mutate_at{
        modifies global<P>(addr);
    }
}
}

```

In general, a global access expression has the form global<type_expr>(address_expr). The address-valued expression is evaluated in the pre-state of the annotated function.

```move
address 0x40{
    module C{
        struct P has key{
            x:u64
        }

        fun mutate_at(addr:address) acquires P{
            let p = borrow_global_mut<P>(addr);
            p.x = 3
        }
        spec mutate_at{
            pragma verify = true;
            modifies global<P>(addr);
        }

        fun read_at(addr:address):u64 acquires P{
            let p = borrow_global<P>(addr);
            p.x
        }

        fun mutate_test(addr_one:address,addr_two:address):bool acquires P{
            assert!(addr_one!=addr_two,43);
            let x =read_at(addr_two);

            mutate_at(addr_one);

            x == read_at(addr_two)
  
        }
        spec mutate_test{

            pragma verify = true;

            modifies global<P>(addr_one);
            
            ensures addr_one !=addr_two;
        
            ensures result==true;
        }
    }
}
```


### Pragmas and Properties
Pragmas and properties are a generic mechanism to influence interpretation of specifications,
```move
spec xxx{
    pragma <name> = <literal>;
}
```

property
```move
spec xxx{
    <durective> [<name> = <literal>] <content>; // ensure,aborts_if,include  etc ...
}
```

#### pragma Inheritance
A pragma in a module spec block sets a value which applies to all other spec blocks in the module. **A pragma in a function or struct spec block can override this value for the function or struct. Furthermore, the default value of some pragmas can be defined via the prover configuration**.


```move
spec module {
    pragma verify = false; // By default, do not verify specs in this module ...
}

spec increment {
    pragma verify = true; // ... but do verify this function.
    ...
}
```

General Pragmas and Properties
A number of pragmas control general behavior of verification. Those are listed in the table below.
- `verify` : turn on the verification
- `intrinsic` : Marks a function to **skip the Move implementation** and **use a prover native implementation**. This makes a function behave like a native function even if it not so in Move.
- `timeout`: Sets a timeout (in seconds) for function or module. Overrides the timeout provided by command line flags.
- `verify_duration_estimate`: 	Sets an estimate (in seconds) for how long the verification of function takes. If the configured timeout is less than this value, verification will be skipped.
- `seed`: Sets a random seed for function or module. Overrides the seed provided by command line flags
-  [`deactivated`] : **control general behavior of verification**,Excludes the associated condition from verification.

### helper functions
```move
spec fun exists_balance<Currency>(a: address): bool { exists<Balance<Currency>>(a) }
```
helper functions can be generic. Moreover, they can **access global state.**

tip: expression `old(..)` is **not allowed** within the definition of a helper function.


### Axioms and uninterpreted function


```move
spec fun someting(x:num):num;
```

```move
spec xxx{
    axioms forall x:num:sometiong(x) == x+1;
}
```

> Axiom should be used with care as they can introduce unsoundness in the specification logic via contradicting assumptions.
> The Move prover supports a smoke test for detecting unsoundness via the --check-inconsistency flag.


### invariant
The invariant condition can be applied on structs and on global level.

```move
spec increment{
    invariant global<Counter>(a).value <128;
}
```
```move
spec increment {
    requires global<Counter>(a).value < 128;
    ensures global<Counter>(a).value < 128;
}
```

### struct invariant
When the invariant condition is applied to a struct, it expresses a well-formedness property of the struct data. Any instance of this struct which is currently not mutated will satisfy this property
```move
spec Counter{
    invariant value < 128;
}
```

### Schemas
means for structuring specifications by grouping properties together.
```move
spec schema IncrementAborts {
    a: address;
    aborts_if !exists<Counter>(a);
    aborts_if global<Counter>(a).value == 255;
}

spec increment {
    include IncrementAborts;
}
```
Each schema may declare a number of typed variable names and a list of conditions over those variables. All supported condition types can be used in schemas. The schema can then be included in another spec block:

- If that spec block is for a function or a struct, all variable names the schema declares must be matched against existing names of compatible type in the context.
- If a schema is included in another schema, existing names are matched and must have the same type, but non-existing names will be added as new declarations to the inclusion context.

#### schema expressions
- `P==> SchemaExp` all conditions in the schema will be prefixed with P ==> ... Conditions which are not based on boolean expressions will be rejected.
- `if (p) SchemaExp1 else SchemaExp2`
- `SchemaExp1 && SchemaExp2` 

#### apply
`apply Schema to FunctionPattern, .. except FunctionPattern, ...`
>Schema can be a schema name or a schema name plus formal type arguments. 
> FunctionPatterns consists of an optional visibility modifier public or internal (if not provided, both visibilities will match), 
> a name pattern in the style of a shell file pattern ( e.g. *, foo*, foo*bar, etc.) , and finally an optional type argument list. All type arguments provided to Schema must be bound in this list and vice versa.

```move
spec schema Unchanged {
    let resource = global<R>(ADDR):
    ensures resource == old(resource);
}

spec module {
    // Enforce Unchanged for all functions except the initialize function.
    apply Unchanged to * except initialize;
}
```

### opaque 
With the pragma opaque, **a function is declared to be solely defined by its specification at caller sides.** In contrast, if this pragma is not provided, then the function's implementation will be used as the basis to verify the caller.
```move
spec increment{
    pragma opaque;
    ensures global<Counter>(a) == old(global<Counter>(a)) + 1;
}
```
In general, opaque functions enable modular verification, as they abstract from the implementation of functions, resulting in much faster verification.

If an opaque function modifies state, it is advised to use the modifies condition in its specification. If this is omitted, verification of the state changes will fail.

### Abstract
The [abstract] property allow to specify a function such that an abstract semantics is used at the caller side which is different from the actual implementation. 
This is useful if the implementation is too complex for verification, and an abstract semantics is sufficient for verification goals. The [concrete] property, in turn, allows to still specify conditions which are verified against the implementation, but not used at the caller side.

```move
fun hash(v: vector<u8>): u64 {
    <<sum up values>>(v)
}
spec hash {
    pragma opaque;
    aborts_if false;
    ensures [concrete] result == <<sum up values>>(v);
    ensures [abstract] result == spec_hash_abstract(v);
}
spec fun abstract_hash(v: vector<u8>): u64; // uninterpreted function
```
Tip
- the `abstract/concrete` properties should only be used with `opaque` specifications, but the prover will currently not generate an error if not.
- the modifies clause does currently not support abstract/concrete. Also, if no modifies is given, the modified state will be computed from the implementation anyway, possibly conflicting with [abstract] properties.


