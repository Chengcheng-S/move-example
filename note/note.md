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
