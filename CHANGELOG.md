Latest
------
* Three new doc comment fields, namely `- keyword:`, `- recommended:`
  and `- recommendedover:`, allow Swift users to cooperate with code
  completion engine to deliver more effective code completion results.
  The `- keyword:` field specifies concepts that are not fully manifested in
  declaration names. `- recommended:` indicates other declarations are preferred
  to the one decorated; to the contrary, `- recommendedover:` indicates
  the decorated declaration is preferred to those declarations whose names
  are specified.

* Designated class initializers declared as failable or throwing may now
  return nil or throw an error, respectively, before the object has been
  fully initialized. For example:

    ```swift
    class Widget : Gadget {
      let complexity: Int

      init(complexity: Int, elegance: Int) throws {
        if complexity > 3 { throw WidgetError.TooComplex }
        self.complexity = complexity

        try super.init(elegance: elegance)
      }
    }
    ```

* All slice types now have `removeFirst()` and `removeLast()` methods.

* `ArraySlice.removeFirst()` now preserves element indices.

* Global `anyGenerator()` functions have been changed into initializers on
  `AnyGenerator`, making the API more intuitive and idiomatic.

* Closures appearing inside generic types and generic methods can now be
  converted to C function pointers as long as no generic type parameters
  are referenced in the closure's argument list or body. A conversion of
  a closure that references generic type parameters now produces a
  diagnostic instead of crashing.

  **(rdar://problem/22204968)**

* Anonymously-typed members of C structs and unions can now be accessed
  from Swift. For example, given the following struct 'Pie', the 'crust'
  and 'filling' members are now imported:

    ```swift
    struct Pie {
      struct { bool crispy; } crust;
      union { int fruit; } filling;
    }
    ```

  Since Swift does not support anonymous structs, these fields are
  imported as properties named `crust` and `filling` having nested types
  named `Pie.__Unnamed_crust` and `Pie.__Unnamed_filling`.

  **(rdar://problem/21683348)**

Time warp
---------

  *Changes between Xcode 6.1 (Swift 1.1) through Xcode 7.1  
  (Swift 2.1) have been lost.  Contributions to rectify this would be
  welcome.*


2014-10-09 [Roughly Xcode 6.1, and Swift 1.1]
----------

* `HeapBuffer<Value,Element>`, `HeapBufferStorage<Value,Element>`, and
  `OnHeap<Value>` were never really useful, because their APIs were
  insufficiently public.  They have been replaced with a single class,
  `ManagedBuffer<Value,Element>`.  See also the new function
  `isUniquelyReferenced(x)` which is often useful in conjunction with
  `ManagedBuffer`.

* The `Character` enum has been turned into a struct, to avoid
  exposing its internal implementation details.

* The `countElements` function has been renamed `count`, for better
  consistency with our naming conventions.

* Mixed-sign addition and subtraction operations, that were
  unintentionally allowed in previous versions, now cause a
  compilation error.

* OS X apps can now apply the `@NSApplicationMain` attribute to their app delegate
  class in order to generate an implicit `main` for the app. This works like
  the `@UIApplicationMain` attribute for iOS apps.

* Objective-C `init` and factory methods are now imported as failable
  initializers when they can return `nil`. In the absence of information
  about a potentially-`nil` result, an Objective-C `init` or factory
  method will be imported as `init!`.

  As part of this change, factory methods that have NSError**
  parameters, such as `+[NSString
  stringWithContentsOfFile:encoding:error:]`, will now be imported as
  (failable) initializers, e.g.,

    ```swift
    init?(contentsOfFile path: String,
          encoding: NSStringEncoding,
          error: NSErrorPointer)
    ```

* Nested classes explicitly marked `@objc` will now properly be included in a
  target's generated header as long as the containing context is also
  (implicitly or explicitly) `@objc`. Nested classes not explicitly marked
  `@objc` will never be printed in the generated header, even if they extend an
  Objective-C class.

* All of the `*LiteralConvertible` protocols, as well as
  `StringInterpolationConvertible`, now use initializers for their
  requirements rather than static methods starting with
  `convertFrom`. For example, `IntegerLiteralConvertible` now has the
  following initializer requirement:

    ```swift
    init(integerLiteral value: IntegerLiteralType)
    ```
  Any type that previously conformed to one of these protocols will
  need to replace its `convertFromXXX` static methods with the
  corresponding initializer.

2014-09-15
----------

* Initializers can now fail by returning `nil`. A failable initializer is
  declared with `init?` (to return an explicit optional) or `init!` (to return
  an implicitly-unwrapped optional). For example, you could implement
  `String.toInt` as a failable initializer of `Int` like this:

    ```swift
    extension Int {
      init?(fromString: String) {
        if let i = fromString.toInt() {
          // Initialize
          self = i
        } else {
          // Discard self and return 'nil'.
          return nil
        }
      }
    }
    ```

  The result of constructing a value using a failable initializer then becomes
  optional:

    ```swift
    if let twentytwo = Int(fromString: "22") {
      println("the number is \(twentytwo)")
    } else {
      println("not a number")
    }
    ```

  In the current implementation, struct and enum initializers can return nil
  at any point inside the initializer, but class initializers can only return
  nil after all of the stored properties of the object have been initialized
  and `self.init` or `super.init` has been called. If `self.init` or
  `super.init` is used to delegate to a failable initializer, then the `nil`
  return is implicitly propagated through the current initializer if the
  called initializer fails.

* The `RawRepresentable` protocol that enums with raw types implicitly conform
  to has been redefined to take advantage of failable initializers. The
  `fromRaw(RawValue)` static method has been replaced with an initializer
  `init?(rawValue: RawValue)`, and the `toRaw()` method has been replaced with
  a `rawValue` property. Enums with raw types can now be used like this:

    ```swift
    enum Foo: Int { case A = 0, B = 1, C = 2 }
    let foo = Foo(rawValue: 2)! // formerly 'Foo.fromRaw(2)!'
    println(foo.rawValue)  // formerly 'foo.toRaw()'
    ```

2014-09-02
----------

* Characters can no longer be concatenated using `+`.  Use `String(c1) +
  String(c2)` instead.

2014-08-18
---------

* When force-casting between arrays of class or `@objc` protocol types
  using `a as [C]`, type checking is now deferred until the moment
  each element is accessed.  Because bridging conversions from NSArray
  are equivalent to force-casts from `[NSArray]`, this makes certain
  Array round-trips through Objective-C code `O(1)` instead of `O(N)`.

2014-08-04
----------

* `RawOptionSetType` now implements `BitwiseOperationsType`, so imported
  `NS_OPTIONS` now support the bitwise assignment operators `|=`, `&=`,
  and `^=`. It also no longer implements `BooleanType`; to check if an option
  set is empty, compare it to `nil`.

* Types implementing `BitwiseOperationsType` now automatically support
  the bitwise assignment operators `|=`, `&=`, and `^=`.

* Optionals can now be coalesced with default values using the `??` operator.
  `??` is a short-circuiting operator that takes an optional on the left and
  a non-optional expression on the right. If the optional has a value, its
  value is returned as a non-optional; otherwise, the expression on the right
  is evaluated and returned:

    ```swift
    var sequence: [Int] = []
    sequence.first ?? 0 // produces 0, because sequence.first is nil
    sequence.append(22)
    sequence.first ?? 0 // produces 22, the value of sequence.first
    ```

* The optional chaining `?` operator can now be mutated through, like `!`.
  The assignment and the evaluation of the right-hand side of the operator
  are conditional on the presence of the optional value:

    ```swift
    var sequences = ["fibonacci": [1, 1, 2, 3, 4], "perfect": [6, 28, 496]]
    sequences["fibonacci"]?[4]++ // Increments element 4 of key "fibonacci"
    sequences["perfect"]?.append(8128) // Appends to key "perfect"

    sequences["cubes"]?[3] = 3*3*3 // Does nothing; no "cubes" key
    ```

  Note that optional chaining still flows to the right, so prefix increment
  operators are *not* included in the chain, so this won't type-check:

    ```swift
    ++sequences["fibonacci"]?[4] // Won't type check, can't '++' Int?
    ```

2014-07-28
----------

* The swift command line interface is now divided into an interactive driver
  `swift`, and a batch compiler `swiftc`:

  ```
  swift [options] input-file [program-arguments]
    Runs the script 'input-file' immediately, passing any program-arguments
    to the script. Without any input files, invokes the repl.

  swiftc [options] input-filenames
    The familiar swift compiler interface: compiles the input-files according
    to the mode options like -emit-object, -emit-executable, etc.
  ```

* For greater clarity and explicitness when bypassing the type system,
  `reinterpretCast` has been renamed `unsafeBitCast`, and it has acquired
  a (required) explicit type parameter.  So

    ```swift
    let x: T = reinterpretCast(y)
    ```

  becomes

    ```swift
    let x = unsafeBitCast(y, T.self)
    ```

* Because their semantics were unclear, the methods `asUnsigned` (on
  the signed integer types) and `asSigned` (on the unsigned integer
  types) have been replaced.  The new idiom is explicit construction
  of the target type using the `bitPattern:` argument label.  So,

    ```swift
    myInt.asUnsigned()
    ```

  has become

    ```swift
    UInt(bitPattern: myInt)
    ```

* To better follow Cocoa naming conventions and to encourage
  immutability, The following pointer types were renamed:

  | Old Name                        | New Name                               |
  |---------------------------------|----------------------------------------|
  | `UnsafePointer<T>`              | `UnsafeMutablePointer<T>`              |
  | `ConstUnsafePointer<T>`         | `UnsafePointer<T>`                     |
  | `AutoreleasingUnsafePointer<T>` | `AutoreleasingUnsafeMutablePointer<T>` |

  Note that the meaning of `UnsafePointer` has changed from mutable to
  immutable. As a result, some of your code may fail to compile when
  assigning to an `UnsafePointer`'s `.memory` property.  The fix is to
  change your `UnsafePointer<T>` into an `UnsafeMutablePointer<T>`.

* The optional unwrapping operator `x!` can now be assigned through, and
  mutating methods and operators can be applied through it:

    ```swift
    var x: Int! = 0
    x! = 2
    x!++

    // Nested dictionaries can now be mutated directly:
    var sequences = ["fibonacci": [1, 1, 2, 3, 0]]
    sequences["fibonacci"]![4] = 5
    sequences["fibonacci"]!.append(8)
    ```

* The `@auto_closure` attribute has been renamed to `@autoclosure`.

* There is a new `dynamic` declaration modifier. When applied to a method,
  property, subscript, or initializer, it guarantees that references to the
  declaration are always dynamically dispatched and never inlined or
  devirtualized, and that the method binding can be reliably changed at runtime.
  The implementation currently relies on the Objective-C runtime, so `dynamic`
  can only be applied to `@objc-compatible` declarations for now. `@objc` now
  only makes a declaration visible to Objective-C; the compiler may now use
  vtable lookup or direct access to access (non-dynamic) `@objc` declarations.

    ```swift
    class Foo {
      // Always accessed by objc_msgSend
      dynamic var x: Int

      // Accessed by objc_msgSend from ObjC; may be accessed by vtable
      // or by static reference in Swift
      @objc var y: Int

      // Not exposed to ObjC (unless Foo inherits NSObject)
      var z: Int
    }
    ```

  `dynamic` enables KVO, proxying, and other advanced Cocoa features to work
  reliably with Swift declarations.

* Clang submodules can now be imported:

    ```swift
    import UIKit.UIGestureRecognizerSubclass
    ```

* The numeric optimization levels `-O[0-3]` have been removed in favor of the
  named levels `-Onone` and `-O`.

* The `-Ofast` optimization flag has been renamed to `-Ounchecked`. We will accept
  both names for now and remove `-Ofast` in a later build.

* An initializer that overrides a designated initializer from its
  superclass must be marked with the `override` keyword, so that all
  overrides in the language consistently require the use of
  `override`. For example:

    ```swift
    class A {
      init() { }
    }

    class B : A {
      override init() { super.init() }
    }
    ```

* Required initializers are now more prominent in several ways. First,
  a (non-final) class that conforms to a protocol that contains an
  initializer requirement must provide a required initializer to
  satisfy that requirement. This ensures that subclasses will also
  conform to the protocol, and will be most visible with classes that
  conform to NSCoding:

    ```swift
    class MyClass : NSObject, NSCoding {
      required init(coder aDecoder: NSCoder!) { /*... */ }
      func encodeWithCoder(aCoder: NSCoder!) { /* ... */ }
    }
    ```
  Second, because `required` places a significant requirement on all
  subclasses, the `required` keyword must be placed on overrides of a
  required initializer:

    ```swift
    class MySubClass : MyClass {
      var title: String = "Untitled"

      required init(coder aDecoder: NSCoder!) { /*... */ }
      override func encodeWithCoder(aCoder: NSCoder!) { /* ... */ }
    }
    ```
  Finally, required initializers can now be inherited like any other
  initializer:

    ```swift
    class MySimpleSubClass : MyClass { } // inherits the required init(coder:).
    ```

2014-07-21
----------

* Access control has been implemented.

  - `public` declarations can be accessed from any module.
  - `internal` declarations (the default) can be accessed from within the
    current module.
  - `private` declarations can be accessed only from within the current file.

  There are still details to iron out here, but the model is in place.
  The general principle is that an entity cannot be defined in terms of another
  entity with less accessibility.

  Along with this, the generated header for a framework will only include
  public declarations. Generated headers for applications will include public
  and internal declarations.

* `CGFloat` is now a distinct floating-point type that wraps either a
  `Float` (on 32-bit architectures) or a `Double` (on 64-bit
  architectures). It provides all of the same comparison and
  arithmetic operations of Float and Double, and can be created using
  numeric literals.

* The immediate mode `swift -i` now works for writing `#!` scripts that take
  command line arguments. The `-i` option to the swift driver must now come at
  the end of the compiler arguments, directly before the input filename. Any
  arguments that come after `-i` and the input filename are treated as arguments
  to the interpreted file and forwarded to `Process.arguments`.

* Type inference for `for..in` loops has been improved to consider the
  sequence along with the element pattern. For example, this accepts
  the following loops that were previously rejected:

    ```swift
    for i: Int8 in 0..<10 { }
    for i: Float in 0.0...10.0 { }
    ```

* Introduced the new `BooleanLiteralConvertible` protocol, which allows
  user-defined types to support Boolean literals. `true` and `false`
  are now `Boolean` constants and keywords.

* The `@final`, `@lazy`, `@required` and `@optional` attributes are now
  considered to be declaration modifiers - they no longer require (or allow) an
  `@` sign.

* The `@prefix`, `@infix`, and `@postfix` attributes have been changed to
  declaration modifiers, so they are no longer spelled with an `@` sign.  
  Operator declarations have been rearranged from `operator prefix +` to
  `prefix operator +` for consistency.

2014-07-03
----------

* C function pointer types are now imported as `CFunctionPointer<T>`, where `T`
  is a Swift function type. `CFunctionPointer` and `COpaquePointer` can be
  explicitly constructed from one another, but they do not freely convert, nor
  is `CFunctionPointer` compatible with Swift closures.

  Example: `int (*)(void)` becomes `CFunctionPointer<(Int) -> Void>`.

* The interop model for pointers in C APIs has been simplified. Most code that
  calls C functions by passing arrays, UnsafePointers, or the addresses of
  variables with `&x` does not need to change. However, the `CConstPointer` and
  `CMutablePointer` bridging types have been removed, and functions and methods
  are now imported as and overridden by taking UnsafePointer and
  `ConstUnsafePointer` directly. `Void` pointers are now imported as
  `(Const)UnsafePointer<Void>`; `COpaquePointer` is only imported for opaque
  types now.

* `Array` types are now spelled with the brackets surrounding the
  element type. For example, an array of `Int` is written as:

    ```swift
    var array: [Int]
    ```

* `Dictionary` types can now be spelled with the syntax `[K : V]`, where `K`
  is the key type and `V` is the value type. For example:

    ```swift
    var dict: [String : Int] = ["Hello" : 1, "World" : 2]
    ```

  The type `[K : V]` is syntactic sugar for `Dictionary<K, V>`; nothing
  else has changed.

* The `@IBOutlet` attribute no longer implicitly (and invisibly) changes the type
  of the declaration it is attached to.  It no longer implicitly makes variables
  be an implicitly unwrapped optional and no longer defaults them to weak.

* The `\x`, `\u` and `\U` escape sequences in string literals have been
  consolidated into a single and less error prone `\u{123456}` syntax.


2014-06-23
---------

* The half-open range operator has been renamed from `..` to `..<` to reduce
  confusion.  The `..<` operator is precedented in Groovy (among other languages)
  and makes it much more clear that it doesn't include the endpoint.

* Class objects such as `NSObject.self` can now be converted to `AnyObject` and
  used as object values.

* Objective-C protocol objects such as `NSCopying.self` can now be used as
  instances of the `Protocol` class, such as in APIs such as XPC.

* Arrays now have full value semantics: both assignment and
  initialization create a logically-distinct object

* The `sort` function and array method modify the target in-place.  A
  new `sorted` function and array method are non-mutating, creating
  and returning a new collection.

2014-05-19
----------

* `sort`, `map`, `filter`, and `reduce` methods on `Array`s accept trailing
  closures:

    ```swift
    let a = [5, 6, 1, 3, 9]
    a.sort{ $0 > $1 }
    println(a)                                 // [9, 6, 5, 3, 1]
    println(a.map{ $0 * 2 })                   // [18, 12, 10, 6, 2]
    println(a.map{ $0 * 2 }.filter{ $0 < 10})  // [6, 2]
    println(a.reduce(1000){ $0 + $1 })         // 1024 (no kidding)
    ```

* A lazy `map()` function in the standard library works on any `Sequence`.
  Example:

    ```swift
    class X {
      var value: Int

      init(_ value: Int) {
        self.value = value
        println("created X(\(value))")
      }
    }

    // logically, this sequence is X(0), X(1), X(2), ... X(50)
    let lazyXs = map(0..50){ X($0) }

    // Prints "created X(...)" 4 times
    for x in lazyXs {
      if x.value == 4 {
        break
      }
    }
    ```

* There's a similar lazy `filter()` function:

    ```swift
    // 0, 10, 20, 30, 40
    let tens = filter(0..50) { $0 % 10 == 0 }
    let tenX = map(tens){ X($0) }    // 5 lazy Xs
    let tenXarray = Array(tenX)      // Actually creates those Xs
    ```

* Weak pointers of classbound protocol type work now.

* `IBOutlets` now default to weak pointers with implicit optional type (`T!`).

* `NSArray*` parameters and result types of Objective-C APIs are now
  imported as `AnyObject[]!`, i.e., an implicitly unwrapped optional
  array storing `AnyObject` values. For example, `NSView`'s constraints
  property

    ```objc
    @property (readonly) NSArray *constraints;
    ```

  is now imported as

    ```swift
    var constraints: AnyObject[]!
    ```

  Note that one can implicitly convert between an `AnyObject[]` and an
  `NSArray` (in both directions), so (for example) one can still
  explicitly use `NSArray` if desired:

    ```swift
    var array: NSArray = view.constraints
    ```

  Swift arrays bridge to `NSArray` similarly to the way Swift
  strings bridge to `NSString`.

* `ObjCMutablePointer` has been renamed `AutoreleasingUnsafePointer`.

* `UnsafePointer` (and `AutoreleasingUnsafePointer`)'s `set()` and `get()`
  have been replaced with a property called `memory`.

  - Previously you would write:

    ```swift
    val = p.get()
    p.set(val)
    ```

  - Now you write:

    ```swift
    val = p.memory
    p.memory = val
    ```

* Removed shorthand `x as T!`; instead use `(x as T)!`

  - `x as T!` now means "x as implicitly unwrapped optional".

* Range operators `..` and `...` have been switched.

  - `1..3` now means 1,2
  - `1...3` now means 1,2,3

* The pound sign (`#`) is now used instead of the back-tick (\`) to mark
  an argument name as a keyword argument, e.g.,

    ```swift
    func moveTo(#x: Int, #y: Int) { ... }
    moveTo(x: 5, y: 7)
    ```

* Objective-C factory methods are now imported as initializers. For
  example, `NSColor`'s `+colorWithRed:green:blue:alpha` becomes

    ```swift
    init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
    ```

  which allows an `NSColor` to be created as, e.g.,

    ```swift
    NSColor(red: 0.5, green: 0.25, blue: 0.25, alpha: 0.5)
    ```

  Factory methods are identified by their kind (class methods), name
  (starts with words that match the words that end the class name),
  and result type (`instancetype` or the class type).

* Objective-C properties of some `CF` type are no longer imported as `Unmanaged`.

* REPL mode now uses LLDB, for a greatly-expanded set of features. The colon
  prefix now treats the rest of the line as a command for LLDB, and entering
  a single colon will drop you into the debugging command prompt. Most
  importantly, crashes in the REPL will now drop you into debugging mode to
  see what went wrong.

  If you do have a need for the previous REPL, pass `-integrated-repl`.

* In a UIKit-based application, you can now eliminate your 'main.swift' file
  and instead apply the `@UIApplicationMain` attribute to your
  `UIApplicationDelegate` class. This will cause the `main` entry point to the
  application to be automatically generated as follows:

    ```swift
    UIApplicationMain(argc, argv, nil,
                      NSStringFromClass(YourApplicationDelegate.self))
    ```

  If you need nontrivial logic in your application entry point, you can still
  write out a `main.swift`. Note that `@UIApplicationMain` and `main.swift` are
  mutually exclusive.

2014-05-13
----------

* weak pointers now work with implicitly unchecked optionals, enabling usecases
  where you don't want to `!` every use of a weak pointer.  For example:

     ```swift
     weak var myView : NSView!
     ```

  of course, they still work with explicitly checked optionals like `NSView?`

* Dictionary subscripting now takes/returns an optional type.  This allows
  querying a dictionary via subscripting to gracefully fail.  It also enables
  the idiom of removing values from a dictionary using `dict[key] = nil`.
  As part of this, `deleteKey` is no longer available.

* Stored properties may now be marked with the `@lazy` attribute, which causes
  their initializer to be evaluated the first time the property is touched
  instead of when the enclosing type is initialized.  For example:

    ```swift
    func myInitializer() -> Int { println("hello\n"); return 42 }
    class MyClass {
      @lazy var aProperty = myInitializer()
    }

    var c = MyClass()     // doesn't print hello
    var tmp = c.aProperty // prints hello on first access
    tmp = c.aProperty     // doesn't print on subsequent loads.

    c = MyClass()         // doesn't print hello
    c.aProperty = 57      // overwriting the value prevents it from ever running
    ```

  Because lazy properties inherently rely on mutation of the property, they
  cannot be `let`s.  They are currently also limited to being members of structs
  and classes (they aren't allowed as local or global variables yet) and cannot
  be observed with `willSet`/`didSet` yet.

* Closures can now specify a capture list to indicate with what strength they
  want to capture a value, and to bind a particular field value if they want to.

  Closure capture lists are square-bracket delimited and specified before the
  (optional) argument list in a closure.  Each entry may be specified as `weak`
  or `unowned` to capture the value with a weak or unowned pointer, and may
  contain an explicit expression if desired.  Some examples:

    ```swift
    takeClosure { print(self.title) }                    // strong capture
    takeClosure { [weak self] in print(self!.title) }    // weak capture
    takeClosure { [unowned self] in print(self.title) }  // unowned capture
    ```

  You can also bind arbitrary expression to named values in the capture list.
  The expression is evaluated when the closure is formed, and captured with the
  specified strength.  For example:

    ```swift
    // weak capture of "self.parent"
    takeClosure { [weak tmp = self.parent] in print(tmp!.title) }
    ```

  The full form of a closure can take a signature (an argument list and
  optionally a return type) if needed.  To use either the capture list or the
  signature, you must specify the context sensitive `in` keyword.  Here is a
  (weird because there is no need for `unowned`) example of a closure with both:

    ```swift
    myNSSet.enumerateObjectsUsingBlock { [unowned self] (obj, stop) in
      self.considerWorkingWith(obj)
    }
    ```

* The word `with` is now removed from the first keyword argument name
  if an initialized imported from Objective-C. For example, instead of
  building `UIColor` as:

    ```swift
    UIColor(withRed: r, green: g, blue: b, alpha: a)
    ```

  it will now be:

    ```swift
    UIColor(red: r, green: g, blue: b, alpha: a)
    ```

* `Dictionary` can be bridged to `NSDictionary` and vice versa:

  - `NSDictionary` has an implicit conversion to `Dictionary<NSObject,
    AnyObject>`.  It bridges in O(1), without memory allocation.

  - `Dictionary<K, V>` has an implicit conversion to `NSDictionary`.
    `Dictionary<K, V>` bridges to `NSDictionary` iff both `K` and `V` are
    bridged.  Otherwise, a runtime error is raised.

    Depending on `K` and `V` the operation can be `O(1)` without memory
    allocation, or `O(N)` with memory allocation.

* Single-quoted literals are no longer recognized.  Use double-quoted literals
  and an explicit type annotation to define `Characters` and `UnicodeScalars`:

    ```swift
    var ch: Character = "a"
    var us: UnicodeScalar = "a"
    ```

2014-05-09
----------

* The use of keyword arguments is now strictly enforced at the call
  site. For example, consider this method along with a call to it:

    ```swift
    class MyColor {
      func mixColorWithRed(red: Float, green: Float, blue: Float) { /* ... */ }
    }

    func mix(color: MyColor, r: Float, g: Float, b: Float) {
      color.mixColorWithRed(r, g, b)
    }
    ```

  The compiler will now complain about the missing `green:` and
  `blue:` labels, with a Fix-It to correct the code:

    ```
    color.swift:6:24: error: missing argument labels 'green:blue:' in call
      color.mixColorWithRed(r, g, b)
                           ^
                               green:  blue:
    ```

  The compiler handles missing, extraneous, and incorrectly-typed
  argument labels in the same manner. Recall that one can make a
  parameter a keyword argument with the back-tick or remove a keyword
  argument with the underscore.

    ```swift
    class MyColor {
      func mixColor(`red: Float, green: Float, blue: Float) { /* ... */ }
      func mixColorGuess(red: Float, _ green: Float, _ blue: Float) { /* ... */ }
    }

    func mix(color: MyColor, r: Float, g: Float, b: Float) {
      color.mixColor(red: r, green: g, blue: b) // okay: all keyword arguments
      color.mixColorGuess(r, g, b) // okay: no keyword arguments
    }
    ```

  Arguments cannot be re-ordered unless the corresponding parameters
  have default arguments. For example, given:

    ```swift
    func printNumber(`number: Int, radix: Int = 10, separator: String = ",") { }
    ```

  The following three calls are acceptable because only the arguments for
  defaulted parameters are re-ordered relative to each other:

    ```swift
    printNumber(number: 256, radix: 16, separator: "_")
    printNumber(number: 256, separator: "_")
    printNumber(number: 256, separator: ",", radix: 16)
    ```

  However, this call:

    ```swift
    printNumber(separator: ",", radix: 16, number: 256)
    ```

  results in an error due to the re-ordering:

    ```
    printnum.swift:7:40: error: argument 'number' must precede argument 'separator'
    printNumber(separator: ",", radix: 16, number: 256)
                ~~~~~~~~~~~~~~             ^       ~~~
    ```

* `;` can no longer be used to demarcate an empty case in a switch statement,
  use `break` instead.

2014-05-07
----------

* The compiler's ability to diagnose many common kinds of type check errors has
  improved. (`expression does not type-check` has been retired.)

* Ranges can be formed with floating point numbers, e.g. `0.0 .. 100.0`.

* Convenience initializers are now spelled as `convenience init` instead of with
  the `-> Self` syntax.  For example:

    ```swift
    class Foo {
      init(x : Int) {}  // designated initializer

      convenience init() { self.init(42) } // convenience initializer
    }
    ```

  You still cannot declare designated initializers in extensions, only
  convenience initializers are allowed.

* Reference types using the CoreFoundation runtime are now imported as
  class types.  This means that Swift will automatically manage the
  lifetime of a `CFStringRef` the same way that it manages the lifetime
  of an `NSString`.

  In many common cases, this will just work.  Unfortunately, values
  are returned from `CF`-style APIs in a wide variety of ways, and
  unlike Objective C methods, there simply isn't enough consistency
  for Swift to be able to safely apply the documented conventions
  universally.  The framework teams have already audited many of the
  most important `CF`-style APIs, and those APIs should be imported
  without a hitch into Swift.  For all the APIs which haven't yet
  been audited, we must import return types using the `Unmanaged` type.
  This type allows the programmer to control exactly how the object
  is passed.

  For example:

    ```swift
    // CFBundleGetAllBundles() returns an Unmanaged<CFArrayRef>.
    // From the documentation, we know that it returns a +0 value.
    let bundles = CFBundleGetAllBundles().takeUnretainedValue()

    // CFRunLoopCopyAllModes() returns an Unmanaged<CFArrayRef>.
    // From the documentation, we know that it returns a +1 value.
    let modes = CFRunLoopCopyAllModes(CFRunLoopGetMain()).takeRetainedValue()
    ```

  You can also use `Unmanaged` types to pass and return objects
  indirectly, as well as to generate unbalanced retains and releases
  if you really require them.

  The API of the Unmanaged type is still in flux, and your feedback
  would be greatly appreciated.

2014-05-03
----------

* The `@NSManaged` attribute can be applied to the properties of an
  `NSManagedObject` subclass to indicate that they should be handled by
  CoreData:

    ```swift
    class Employee : NSManagedObject {
      @NSManaged var name: String
      @NSManaged var department: Department
    }
    ```

* The `@weak` and `@unowned` attributes have become context sensitive keywords
  instead of attributes.  To declare a `weak` or `unowned` pointer, use:

    ```swift
    weak var someOtherWindow : NSWindow?
    unowned var someWindow : NSWindow
    ```
  ... with no `@` on the `weak`/`unowned`.

2014-04-30
----------

* Swift now supports a `#elseif` form for build configurations, e.g.:

    ```swift
    #if os(OSX)
      typealias SKColor = NSColor
    #elseif os(iOS)
      typealias SKColor = UIColor
    #else
      typealias SKColor = Green
    #endif
    ```

* You can now use the `true` and `false` constants in build configurations,
  allowing you to emulate the C idioms of `#if 0` (but spelled `#if false`).

* `break` now breaks out of switch statements.

* It is no longer possible to specify `@mutating` as an attribute, you may only
  use it as a keyword, e.g.:

    ```swift
    struct Pair {
      var x, y : Int
      mutating func nuke() { x = 0; y = 0 }
    }
    ```
  The former `@!mutating` syntax used to mark setters as non-mutating is now
  spelled with the `nonmutating` keyword.  Both mutating and nonmutating are
  context sensitive keywords.

* `NSLog` is now available from Swift code.

* The parser now correctly handles expressions like `var x = Int[]()` to
  create an empty array of integers.  Previously you'd have to use syntax like
  `Array<Int>()` to get this.  Now that this is all working, please prefer to
  use `Int[]` consistently instead of `Array<Int>`.

* `Character` is the new character literal type:

    ```swift
    var x = 'a' // Infers 'Character' type
    ```

  You can force inference of `UnicodeScalar` like this:

    ```swift
    var scalar: UnicodeScalar = 'a'
    ```

  `Character` type represents a Unicode extended grapheme cluster (to put it
  simply, a grapheme cluster is what users think of as a character: a base plus
  any combining marks, or other cases explained in
  [Unicode Standard Annex #29](http://unicode.org/reports/tr29/)).

2014-04-22
----------

* Loops and switch statements can now carry labels, and you can
  `break`/`continue` to those labels.  These use conventional C-style label
  syntax, and should be dedented relative to the code they are in.  An example:

    ```swift
    func breakContinue(x : Int) -> Int {
    Outer:
      for a in 0..1000 {

      Switch:
        switch x {
        case 42: break Outer
        case 97: continue Outer
        case 102: break Switch
        case 13: continue // continue always works on loops.
        case 139: break   // break will break out of the switch (but see below)
        }
      }
    }
    ```

* We are changing the behavior of `break` to provide C-style semantics, to allow
  breaking out of a switch statement.  Previously, break completely ignored
  switches so that it would break out of the nearest loop. In the example above,
  `case 139` would break out of the `Outer` loop, not the `Switch`.

  In order to avoid breaking existing code, we're making this a compile time
  error instead of a silent behavior change.  If you need a solution for the
  previous behavior, use labeled break.

  This error will be removed in a week or two.

* Cocoa methods and properties that are annotated with the
  `NS_RETURNS_INNER_POINTER` attribute, including `-[NSData bytes]` and
  `-[{NS,UI}Color CGColor]`, are now safe to use and follow the same lifetime
  extension semantics as ARC.

2014-04-18
----------
* Enabling/disabling of asserts

    ```swift
    assert(condition, msg)
    ```

  is enabled/disabled dependent on the optimization level. In debug mode at
  `-O0` asserts are enabled. At higher optimization levels asserts are disabled
  and no code is generated for them. However, asserts are always type checked
  even at higher optimization levels.

  Alternatively, assertions can be disabled/enabled by using the frontend flag
  `-assert-config Debug`, or `-assert-config Release`.

* Added optimization flag `-Ofast`. It disables all assertions (`assert`), and
  runtime overflow and type checks.

* The "selector-style" function and initializer declaration syntax is
  being phased out. For example, this:

    ```
    init withRed(red: CGFloat) green(CGFloat) blue(CGFloat) alpha(CGFloat)
    ```

  will now be written as:

    ```swift
    init(withRed red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
    ```

  For each parameter, one can have both an argument API name (i.e.,
  `withRed`, which comes first and is used at the call site) and an
  internal parameter name that follows it (i.e. `red`, which comes
  second and is used in the implementation). When the two names are
  the same, one can simply write the name once and it will be used for
  both roles (as with `green`, `blue`, and `alpha` above). The
  underscore (`_`) can be used to mean "no name", as when the
  following function/method:

    ```
    func murderInRoom(room:String) withWeapon(weapon: String)
    ```

  is translated to:

    ```swift
    func murderInRoom(_ room: String, withWeapon weapon: String)
    ```

  The compiler now complains when it sees the selector-style syntax
  and will provide Fix-Its to rewrite to the newer syntax.

  Note that the final form of selector syntax is still being hammered
  out, but only having one declaration syntax, which will be very
  close to this, is a known.

* Stored properties can now be marked with the `@NSCopying` attribute, which
  causes their setter to be synthesized with a copy to `copyWithZone:`.  This may
  only be used with types that conform to the `NSCopying` protocol, or option
  types thereof.  For example:

    ```swift
    @NSCopying var myURL : NSURL
    ```

  This fills the same niche as the (`copy`) attribute on Objective-C properties.


2014-04-16
----------

* Optional variables and properties are now default-initialized to `nil`:

    ```swift
    class MyClass {
      var cachedTitle: String?       // "= nil" is implied
    }
    ```

* `@IBOutlet` has been improved in a few ways:

  - `IBOutlets` can now be `@unchecked` optional.

  - An `IBOutlet` declared as non-optional, i.e.,

      ```swift
      @IBOutlet var button: NSButton
      ```

    will be treated as an `@unchecked` optional.  This is considered to
    be the best practice way to write an outlet, unless you want to explicitly
    handle the null case - in which case, use `NSButton?` as the type. Either
    way, the `= nil` that was formerly required is now implicit.

* The precedence of `is` and `as` is now higher than comparisons, allowing the
  following sorts of things to be written without parens:

    ```swift
    if x is NSButton && y is NSButtonCell { ... }

    if 3/4 as Float == 6/8 as Float { ... }
    ```

* Objective-C blocks are now transparently bridged to Swift closures. You never
  have to write `@objc_block` when writing Objective-C-compatible methods anymore.
  Block parameters are now imported as unchecked optional closure types,
  allowing `nil` to be passed.

2014-04-09
----------

* `Dictionary` changes:

  - `Elements` are now tuples, so you can write

    ```swift
    for (k, v) in d {
      // ...
    }
    ```

  - `keys` and `values` properties, which are `Collections` projecting
    the corresponding aspect of each element.  `Dictionary` indices are
    usable with their `keys` and `values` properties, so:

    ```swift
    for i in indices(d) {
      let (k, v) = d[i]
      assert(k == d.keys[i])
      assert(v == d.values[i])
    }
    ```

* Semicolon can be used as a single no-op statement in otherwise empty cases in
  `switch` statements:

    ```swift
    switch x {
    case 1, 2, 3:
      print("x is 1, 2 or 3")
    default:
      ;
    }
    ```

* `override` is now a context sensitive keyword, instead of an attribute:

    ```swift
    class Base {
      var property: Int { return 0 }
      func instanceFunc() {}
      class func classFunc() {}
    }
    class Derived : Base {
      override var property: Int { return 1 }
      override func instanceFunc() {}
      override class func classFunc() {}
    }
    ```

2014-04-02
----------

* Prefix splitting for imported enums has been revised again due to feedback:
  - If stripping off a prefix would leave an invalid identifier (like `10_4`),
    leave one more word in the result than would otherwise be there
    (`Behavior10_4`).
  - If all enumerators have a `k` prefix (for `constant`) and the enum doesn't,
    the `k` should not be considered when finding the common prefix.
  - If the enum name is a plural (like `NSSomethingOptions`) and the enumerator
    names use the singular form (`NSSomethingOptionMagic`), this is considered
    a matching prefix (but only if nothing follows the plural).

* Cocoa APIs that take pointers to plain C types as arguments now get imported
  as taking the new `CMutablePointer<T>` and `CConstPointer<T>` types instead
  of `UnsafePointer<T>`. These new types allow implicit conversions from
  Swift `inout` parameters and from Swift arrays:

    ```swift
    let rgb = CGColorSpaceCreateDeviceRGB()
    // CGColorRef CGColorCreate(CGColorSpaceRef, const CGFloat*);
    let white = CGColorCreate(rgb, [1.0, 1.0, 1.0])

    var s = 0.0, c = 0.0
    // void sincos(double, double*, double*);
    sincos(M_PI/2, &s, &c)
    ```

  Pointers to pointers to ObjC classes, such as `NSError**`, get imported as
  `ObjCMutablePointer<NSError?>`. This type doesn't work with arrays, but
  accepts inouts or `nil`:

    ```swift
    var error: NSError? = nil
    let words = NSString.stringWithContentsOfFile("/usr/share/dict/words",
      encoding: .UTF8StringEncoding,
      error: &error)
    ```

  `Void` pointer parameters can be passed an array or inout of any type:

    ```swift
    // + (NSData*)dataWithBytes:(const void*)bytes length:(NSUInteger)length;
    let data = NSData.dataWithBytes([1.5, 2.25, 3.125],
                                    length: sizeof(Double.self) * 3)
    var fromData = [0.0, 0.0, 0.0]
    // - (void)getBytes:(void*)bytes length:(NSUInteger)length;
    data.getBytes(&fromData, length: sizeof(Double.self) * 3)
    ```

  Note that we don't know whether an API reads or writes the C pointer, so
  you need to explicitly initialize values (like `s` and `c` above) even if
  you know that the API overwrites them.

  This pointer bridging only applies to arguments, and only works with well-
  behaved C and ObjC APIs that don't keep the pointers they receive as
  arguments around or do other dirty pointer tricks. Nonstandard use of pointer
  arguments still requires `UnsafePointer`.

* Objective-C pointer types now get imported by default as the `@unchecked T?`
  optional type.  Swift class types no longer implicitly include `nil`.

  A value of `@unchecked T?` can be implicitly used as a value of `T`.
  Swift will implicitly cause a reliable failure if the value is `nil`,
  rather than introducing undefined behavior (as in Objective-C ivar
  accesses or everything in C/C++) or silently ignoring the operation
  (as in Objective-C message sends).

  A value of `@unchecked T?` can also be implicitly used as a value of `T?`,
  allowing you explicitly handle the case of a `nil` value.  For example,
  if you would like to just silently ignore a message send a la Objective-C,
  you can use the postfix `?` operator like so:

    ```swift
    fieldsForKeys[kHeroFieldKey]?.setEditable(true)
    ```

  This design allows you to isolate and handle `nil` values in Swift code
  without requiring excessive "bookkeeping" boilerplate to use values that
  you expect to be non-`nil`.

  For now, we will continue to import C pointers as non-optional
  `UnsafePointer` and `C*Pointer` types; that will be evaluated separately.

  We intend to provide attributes for Clang to allow APIs to opt in to
  importing specific parameters, return types, etc. as either the
  explicit optional type `T?` or the simple non-optional type `T`.

* The "separated" call syntax, i.e.,

    ```
    NSColor.colorWithRed(r) green(g) blue(b) alpha(a)
    UIColor.init withRed(r) green(g) blue(b) alpha(a)
    ```

  is being removed. The compiler will now produce an error and provide
  Fix-Its to rewrite calls to the "keyword-argument" syntax:

    ```swift
    NSColor.colorWithRed(r, green: g, blue: b, alpha: a)
    UIColor(withRed: r, green:g, blue:b, alpha: a)
    ```

* The `objc` attribute now optionally accepts a name, which can be
  used to provide the name for an entity as seen in Objective-C. For
  example:

    ```swift
    class MyType {
      var enabled: Bool {
        @objc(isEnabled) get {
          // ...
        }
      }
    }
    ```

  The `@objc` attribute can be used to name initializers, methods,
  getters, setters, classes, and protocols.

* Methods, properties and subscripts in classes can now be marked with the
  `@final` attribute.  This attribute prevents overriding the declaration in any
  subclass, and provides better performance (since dynamic dispatch is avoided
  in many cases).


2014-03-26
----------

* Attributes on declarations are no longer comma separated.

  Old syntax:

    ```
    @_silgen_name("foo"), @objc func bar() {}
    ```

  New syntax:

    ```swift
    @_silgen_name("foo") @objc
    ```

  The `,` was vestigial when the attribute syntax consisted of bracked lists.

* `switch` now always requires a statement after a `case` or `default`.

  Old syntax:

    ```swift
    switch x {
    case .A:
    case .B(1):
      println(".A or .B(1)")
    default:
      // Ignore it.
    }
    ```

  New syntax:

    ```swift
    switch x {
    case .A, .B(1):
      println(".A or .B(1)")
    default:
      () // Ignore it.
    }
    ```

  The following syntax can be used to introduce guard expressions for patterns
  inside the `case`:

    ```swift
    switch x {
    case .A where isFoo(),
         .B(1) where isBar():
      ...
    }
    ```

* Observing properties can now `@override` properties in a base class, so you
  can observe changes that happen to them.

     ```swift
     class MyAwesomeView : SomeBasicView {
      @override
      var enabled : Bool {
        didSet {
          println("Something changed")
        }
      }
      ...
    }
    ```

  Observing properties still invoke the base class getter/setter (or storage)
  when accessed.


* An `as` cast can now be forced using the postfix `!` operator without using
  parens:

    ```swift
    class B {}
    class D {}

    let b: B = D()

    // Before
    let d1: D = (b as D)!
    // After
    let d2: D = b as D!
    ```

  Casts can also be chained without parens:

    ```swift
    // Before
    let b2: B = (((D() as B) as D)!) as B
    // After
    let b3: B = D() as B as D! as B
    ```

* `as` can now be used in `switch` cases to match the result of a checked cast:

    ```swift
    func printHand(hand: Any) {
      switch hand {
      case 1 as Int:
        print("ace")
      case 11 as Int:
        print("jack")
      case 12 as Int:
        print("queen")
      case 13 as Int:
        print("king")
      case let numberCard as Int:
        print("\(numberCard)")
      case let (a, b) as (Int, Int) where a == b:
        print("two ")
        printHand(a)
        print("s")
      case let (a, b) as (Int, Int):
        printHand(a)
        print(" and a ")
        printHand(b)
      case let (a, b, c) as (Int, Int, Int) where a == b && b == c:
        print("three ")
        printHand(a)
        print("s")
      case let (a, b, c) as (Int, Int, Int):
        printHand(a)
        print(", ")
        printHand(b)
        print(", and a ")
        printHand(c)
      default:
        print("unknown hand")
      }
    }
    printHand(1, 1, 1) // prints "three aces"
    printHand(12, 13) // prints "queen and a king"
    ```

* Enums and option sets imported from C/Objective-C still strip common
  prefixes, but the name of the enum itself is now taken into consideration as
  well. This keeps us from dropping important parts of a name that happen to be
  shared by all members.

    ```objc
    // NSFileManager.h
    typedef NS_OPTIONS(NSUInteger, NSDirectoryEnumerationOptions) {
        NSDirectoryEnumerationSkipsSubdirectoryDescendants = 1UL << 0,
        NSDirectoryEnumerationSkipsPackageDescendants      = 1UL << 1,
        NSDirectoryEnumerationSkipsHiddenFiles             = 1UL << 2
    } NS_ENUM_AVAILABLE(10_6, 4_0);
    ```

    ```swift
    // Swift
    let opts: NSDirectoryEnumerationOptions = .SkipsPackageDescendants
    ```

* `init` methods in Objective-C protocols are now imported as
  initializers. To conform to `NSCoding`, you will now need to provide

    ```swift
    init withCoder(aDecoder: NSCoder) { ... }
    ```

  rather than

    ```swift
    func initWithCoder(aDecoder: NSCoder) { ... }
    ```

2014-03-19
----------

* When a class provides no initializers of its own but has default
  values for all of its stored properties, it will automatically
  inherit all of the initializers of its superclass. For example:

    ```swift
    class Document {
      var title: String

      init() -> Self {
        self.init(withTitle: "Default title")
      }

      init withTitle(title: String) {
        self.title = title
      }
    }

    class VersionedDocument : Document {
      var version = 0

      // inherits 'init' and 'init withTitle:' from Document
    }
    ```

  When one does provide a designated initializer in a subclass, as in
  the following example:

    ```swift
    class SecureDocument : Document {
      var key: CryptoKey

      init withKey(key: CryptoKey) -> Self {
        self.init(withKey: key, title: "Default title")        
      }

      init withKey(key: CryptoKey) title(String) {
        self.key = key
        super.init(withTitle: title)        
      }
    }
    ```

  the compiler emits Objective-C method stubs for all of the
  designated initializers of the parent class that will abort at
  runtime if called, and which indicate which initializer needs to be
  implemented. This provides memory safety for cases where an
  Objective-C initializer (such as `-[Document init]` in this example)
  appears to be inherited, but isn't actually implemented.

* `nil` may now be used as a Selector value. This allows calls to Cocoa methods
  that accept `nil` selectors.

* `[]` and `[:]` can now be used as the empty array and dictionary literal,
  respectively.  Because these carry no information about their element types,
  they may only be used in a context that provides this information through type
  inference (e.g. when passing a function argument).

* Properties defined in classes are now dynamically dispatched and can be
  overriden with `@override`.  Currently `@override` only works with computed properties
  overriding other computed properties, but this will be enhanced in coming weeks.


2014-03-12
----------

* The `didSet` accessor of an observing property now gets passed in the old value,
  so you can easily implement an action for when a property changes value.  For
  example:

    ```swift
    class MyAwesomeView : UIView {
      var enabled : Bool = false {
      didSet(oldValue):
        if oldValue != enabled {
          self.needsDisplay = true
        }
      }
      ...
    }
    ```

* The implicit argument name for set and willSet property specifiers has been
  renamed from `(value)` to `(newValue)`.  For example:

    ```swift
    var i : Int {
      get {
        return 42
      }
      set {  // defaults to (newValue) instead of (value)
        print(newValue)
      }
    }
    ```

* The magic identifier `__FUNCTION__` can now be used to get the name of the
  current function as a string. Like `__FILE__` and `__LINE__`, if
  `__FUNCTION__` is used as a default argument, the function name of the caller
  is passed as the argument.

    ```swift
    func malkovich() {
      println(__FUNCTION__)
    }
    malkovich() // prints "malkovich"

    func nameCaller(name: String = __FUNCTION__) -> String {
      return name
    }

    func foo() {
      println(nameCaller()) // prints "foo"
    }

    func foo(x: Int) bar(y: Int) {
      println(nameCaller()) // prints "foo:bar:"
    }
    ```

  At top level, `__FUNCTION__` gives the module name:

    ```swift
    println(nameCaller()) // prints your module name
    ```

* Selector-style methods can now be referenced without applying arguments
  using member syntax `foo.bar:bas:`, for instance, to test for the availability
  of an optional protocol method:

    ```swift
    func getFrameOfObjectValueForColumn(ds: NSTableViewDataSource,
                                        tableView: NSTableView,
                                        column: NSTableColumn,
                                        row: Int) -> AnyObject? {
      if let getObjectValue = ds.tableView:objectValueForTableColumn:row: {
        return getObjectValue(tableView, column, row)
      }
      return nil
    }
    ```

* The compiler now warns about cases where a variable is inferred to have
  `AnyObject`, `AnyClass`, or `()` type, since type inferrence can turn a simple
  mistake (e.g. failing to cast an `AnyObject` when you meant to) into something
  with ripple effects.  Here is a simple example:

    ```
    t.swift:4:5: warning: variable 'fn' inferred to have type '()', which may be unexpected
    var fn = abort()
        ^
    t.swift:4:5: note: add an explicit type annotation to silence this warning
    var fn = abort()
        ^
          : ()
    ```

  If you actually did intend to declare a variable of one of these types, you
  can silence this warning by adding an explicit type (indicated by the Fixit).
  See **rdar://15263687 and rdar://16252090** for more rationale.

* `x.type` has been renamed to `x.dynamicType`, and you can use `type` as a
  regular identifier again.

2014-03-05
----------

* C macros that expand to a single constant string are now imported as global
  constants. Normal string literals are imported as `CString`; `NSString` literals
  are imported as `String`.

* All values now have a `self` property, exactly equivalent to the value
  itself:

    ```swift
    let x = 0
    let x2 = x.self
    ```

  Types also have a `self` property that is the type object for that
  type:

    ```swift
    let theClass = NSObject.self
    let theObj = theClass()
    ```

  References to type names are now disallowed outside of a constructor call
  or member reference; to get a type object as a value, `T.self` is required.
  This prevents the mistake of intending to construct an instance of a
  class but forgetting the parens and ending up with the class object instead:

    ```swift
    let x = MyObject // oops, I meant MyObject()...
    return x.description() // ...and I accidentally called +description
                           //    instead of -description
    ```

* Initializers are now classified as **designated initializers**, which
  are responsible for initializing the current class object and
  chaining via `super.init`, and **convenience initializers**, which
  delegate to another initializer and can be inherited. For example:

    ```swift
    class A {
      var str: String

      init() -> Self { // convenience initializer
        self.init(withString: "hello")
      }

      init withString(str: String) { // designated initializer
        self.str = str
      }
    }
    ```

  When a subclass overrides all of its superclass's designated
  initializers, the convenience initializers are inherited:

    ```swift
    class B {
      init withString(str: String) { // designated initializer
        super.init(withString: str)
      }

      // inherits A.init()
    }
    ```

  Objective-C classes that provide `NS_DESIGNATED_INITIALIZER`
  annotations will have their init methods mapped to designated
  initializers or convenience initializers as appropriate; Objective-C
  classes without `NS_DESIGNATED_INITIALIZER` annotations have all of
  their `init` methods imported as designated initializers, which is
  safe (but can be verbose for subclasses). Note that the syntax and
  terminology is still somewhat in flux.

* Initializers can now be marked as `required` with an attribute,
  meaning that every subclass is required to provide that initializer
  either directly or by inheriting it from a superclass. To construct

    ```swift
    class View {
      @required init withFrame(frame: CGRect) { ... }
    }

    func buildView(subclassObj: View.Type, frame: CGRect) -> View {
      return subclassObj(withFrame: frame)
    }

    class MyView : View {
      @required init withFrame(frame: CGRect) {
        super.init(withFrame: frame)
      }
    }

    class MyOtherView : View {
      // error: must override init withFrame(CGRect).
    }
    ```

* Properties in Objective-C protocols are now correctly imported as properties.
  (Previously the getter and setter were imported as methods.)

* Simple enums with no payloads, including `NS_ENUM`s imported
  from Cocoa, now implicitly conform to the Equatable and Hashable protocols.
  This means they can be compared with the `==` and `!=` operators and can
  be used as `Dictionary` keys:

    ```swift
    enum Flavor {
      case Lemon, Banana, Cherry
    }

    assert(Flavor.Lemon == .Lemon)
    assert(Flavor.Banana != .Lemon)

    struct Profile {
      var sweet, sour: Bool
    }

    let flavorProfiles: Dictionary<Flavor, Profile> = [
      .Lemon:  Profile(sweet: false, sour: true ),
      .Banana: Profile(sweet: true,  sour: false),
      .Cherry: Profile(sweet: true,  sour: true ),
    ]
    assert(flavorProfiles[.Lemon].sour)
    ```

* `val` has been removed.  Long live `let`!

* Values whose names clash with Swift keywords, such as Cocoa methods or
  properties named `class`, `protocol`, `type`, etc., can now be defined and
  accessed by wrapping reserved keywords in backticks to suppress their builtin
  meaning:

    ```swift
    let `class` = 0
    let `type` = 1
    let `protocol` = 2
    println(`class`)
    println(`type`)
    println(`protocol`)

    func foo(Int) `class`(Int) {}
    foo(0, `class`: 1)
    ```

2014-02-26
----------

* The `override` attribute is now required when overriding a method,
  property, or subscript from a superclass. For example:

    ```swift
    class A {
      func foo() { }
    }

    class B : A {
      @override func foo() { } // 'override' is required here
    }
    ```

* We're renaming `val` back to `let`.  The compiler accepts both for this week,
  next week it will just accept `let`.  Please migrate your code this week, sorry
  for the back and forth on this.

* Swift now supports `#if`, `#else` and `#endif` blocks, along with target
  configuration expressions, to allow for conditional compilation within
  declaration and statement contexts.

  Target configurations represent certain static information about the
  compile-time build environment.  They are implicit, hard-wired into the
  compiler, and can only be referenced within the conditional expression of an
  `#if` block.

  Target configurations are tested against their values via a pseudo-function
  invocation expression, taking a single argument expressed as an identitifer.
  The argument represents certain static build-time information.

  There are currently two supported target configurations:
    `os`, which can have the values `OSX` or `iOS`
    `arch`, which can have the values `i386`, `x86_64`, `arm` and `arm64`

  Within the context of an `#if` block's conditional expression, a target
  configuration expression can evaluate to either `true` or `false`.

  For example:

    ```swift
    #if arch(x86_64)
      println("Building for x86_64")
    #else
      println("Not building for x86_64")
    #endif

    class C {
    #if os(OSX)
      func foo() {
        // OSX stuff goes here
      }
    #else
      func foo() {
        // non-OSX stuff goes here
      }
    #endif
    }
    ```

  The conditional expression of an `#if` block can be composed of one or more of
  the following expression types:
    - A unary expression, using `!`
    - A binary expression, using `&&` or `||`
    - A parenthesized expression
    - A target configuration expression

  For example:

    ```swift
    #if os(iOS) && !arch(I386)
    ...
    #endif
    ```

  Note that `#if`/`#else`/`#endif` blocks do not constitute a preprocessor, and
  must form valid and complete expressions or statements. Hence, the following
  produces a parser error:

    ```swift
    class C {

    #if os(iOS)
      func foo() {}
    }
    #else
      func bar() {}
      func baz() {}
    }
    #endif
    ```

  Also note that "active" code will be parsed, typechecked and emitted, while
  "inactive" code will only be parsed.  This is why code in an inactive `#if` or
  `#else` block will produce parser errors for malformed code.  This allows the
  compiler to detect basic errors in inactive regions.

  This is the first step to getting functionality parity with the important
  subset of the C preprocessor.  Further refinements are planned for later.

* Swift now has both fully-closed ranges, which include their endpoint, and
  half-open ranges, which don't.

    ```swift
    (swift) for x in 0...5 { print(x) } ; print('\n') // half-open range
    01234
    (swift) for x in 0..5 { print(x) } ; print('\n')  // fully-closed range
    012345
    ```

* Property accessors have a new brace-based syntax, instead of using the former
  "label like" syntax.  The new syntax is:

  ```swift
  var computedProperty: Int {
    get {
      return _storage
    }
    set {
      _storage = value
    }
  }

  var implicitGet: Int {    // This form still works.
    return 42
  }

  var storedPropertyWithObservingAccessors: Int = 0 {
    willSet { ... }
    didSet { ... }
  }
  ```

* Properties and subscripts now work in protocols, allowing you to do things
  like:

    ```swift
    protocol Subscriptable {
      subscript(idx1: Int, idx2: Int) -> Int { get set }
      var prop: Int { get }
    }

    func foo(s: Subscriptable) {
      return s.prop + s[42, 19]
    }
    ```

  These can be used for generic algorithms now as well.

* The syntax for referring to the type of a type, `T.metatype`, has been
  changed to `T.Type`. The syntax for getting the type of a value, `typeof(x)`,
  has been changed to `x.type`.

* `DynamicSelf` is now called `Self`; the semantics are unchanged.

* `destructor` has been replaced with `deinit`, to emphasize that it
  is related to `init`. We will refer to these as
  `deinitializers`. We've also dropped the parentheses, i.e.:

    ```swift
    class MyClass {
      deinit {
        // release any resources we might have acquired, etc.
      }
    }
    ```

* Class methods defined within extensions of Objective-C classes can
  now refer to `self`, including using `instancetype` methods. As a
  result, `NSMutableString`, `NSMutableArray`, and `NSMutableDictionary`
  objects can now be created with their respective literals, i.e.,

    ```swift
    var dict: NSMutableDictionary = ["a" : 1, "b" : 2]
    ```

2014-02-19
----------

* The `Stream` protocol has been renamed back to `Generator,` which is
  precedented in other languages and causes less confusion with I/O
  streaming.

* The `type` keyword was split into two: `static` and `class`.  One can define
  static functions and static properties in structs and enums like this:

    ```swift
    struct S {
      static func foo() {}
      static var bar: Int = 0
    }
    enum E {
      static func foo() {}
    }
    ```

  `class` keyword allows one to define class properties and class methods in
  classes and protocols:

    ```swift
    class C {
      class func foo() {}
      class var bar: Int = 0
    }
    protocol P {
      class func foo() {}
      class var bar: Int = 0
    }
    ```

  When using `class` and `static` in the extension, the choice of keyword
  depends on the type being extended:

    ```swift
    extension S {
      static func baz() {}
    }
    extension C {
      class func baz() {}
    }
    ```

* The `let` keyword is no longer recognized.  Please move to `val`.

* The standard library has been renamed to `Swift` (instead of `swift`) to be
  more consistent with other modules on our platforms.

* `NSInteger` and other types that are layout-compatible with Swift standard
  library types are now imported directly as those standard library types.

* Optional types now support a convenience method named "cache" to cache the
  result of a closure. For example:

  ```swift
  class Foo {
    var _lazyProperty: Int?
    var property: Int {
      return _lazyProperty.cache { computeLazyProperty() }
    }
  }
  ```

2014-02-12
----------

* We are experimenting with a new message send syntax. For example:

    ```swift
    SKAction.colorizeWithColor(SKColor.whiteColor()) colorBlendFactor(1.0) duration(0.0)
    ```

  When the message send is too long to fit on a single line, subsequent lines
  must be indented from the start of the statement or declaration. For
  example, this is a single message send:

    ```swift
    SKAction.colorizeWithColor(SKColor.whiteColor())
             colorBlendFactor(1.0)
             duration(0.0)
    ```

  while this is a message send to colorizeWithColor: followed by calls
  to `colorBlendFactor` and `duration` (on self or to a global function):

    ```swift
    SKAction.colorizeWithColor(SKColor.whiteColor())
    colorBlendFactor(1.0) // call to 'colorBlendFactor'
    duration(0.0) // call to 'duration'
    ```

* We are renaming the `let` keyword to `val`.  The `let` keyword didn't work
  out primarily because it is not a noun, so "defining a let" never sounded
  right.  We chose `val` over `const` and other options because `var` and `val`
  have similar semantics (making syntactic similarity useful), because `const`
  has varied and sordid connotations in C that we don't want to bring over, and
  because we don't want to punish the "preferred" case with a longer keyword.

  For migration purposes, the compiler now accepts `let` and `val` as synonyms,
  `let` will be removed next week.

* Selector arguments in function arguments with only a type are now implicitly
  named after the selector chunk that contains them.  For example, instead of:

    ```swift
    func addIntsWithFirst(first : Int) second(second : Int) -> Int {
      return first+second
    }
    ```

  you can now write:

    ```swift
    func addIntsWithFirst(first : Int) second(Int) -> Int {
      return first+second
    }
    ```

  if you want to explicitly want to ignore an argument, it is recommended that
  you continue to use the `_` to discard it, as in:

    ```swift
    func addIntsWithFirst(first : Int) second(_ : Int) -> Int {...}
    ```

* The `@inout` attribute in argument lists has been promoted to a
  context-sensitive keyword.  Where before you might have written:

    ```swift
    func swap<T>(a : @inout T, b : @inout T) {
      (a,b) = (b,a)
    }
    ```

  You are now required to write:

    ```swift
    func swap<T>(inout a : T, inout b : T) {
      (a,b) = (b,a)
    }
    ```

  We made this change because `inout` is a fundamental part of the type
  system, which attributes are a poor match for.  The inout keyword is
  also orthogonal to the `var` and `let` keywords (which may be specified in
  the same place), so it fits naturally there.

* The `@mutating` attribute (which can be used on functions in structs,
  enums, and protocols) has been promoted to a context-sensitive keyword.
  Mutating struct methods are now written as:

    ```swift
    struct SomeStruct {
      mutating func f() {}
    }
    ```

* Half-open ranges (those that don't include their endpoint) are now
  spelled with three `.`s instead of two, for consistency with Ruby.

    ```swift
    (swift) for x in 0...5 { print(x) } ; print('\n') // new syntax
    01234
    ```

  Next week, we'll introduce a fully-closed range which does include
  its endpoint.  This will provide:

    ```swift
    (swift) for x in 0..5 { print(x) } ; print('\n')  // coming soon
    012345
    ```

  These changes are being released separately so that users have a
  chance to update their code before its semantics changes.

* Objective-C properties with custom getters/setters are now imported
  into Swift as properties. For example, the Objective-C property

    ```swift
    @property (getter=isEnabled) BOOL enabled;
    ```

  was previously imported as getter (`isEnabled`) and setter
  (`setEnabled`) methods. Now, it is imported as a property (`enabled`).

* `didSet`/`willSet` properties may now have an initial value specified:

    ```swift
    class MyAwesomeView : UIView {
      var enabled : Bool = false {       // Initial value.
      didSet: self.needsDisplay = true
      }
      ...
    }
    ```

  they can also be used as non-member properties now, e.g. as a global
  variable or a local variable in a function.

* Objective-C instancetype methods are now imported as methods that
  return Swift's `DynamicSelf` type. While `DynamicSelf` is not
  generally useful for defining methods in Swift, importing to it
  eliminates the need for casting with the numerous `instancetype` APIs,
  e.g.,

    ```swift
    let tileNode: SKSpriteNode = SKSpriteNode.spriteNodeWithTexture(tileAtlas.textureNamed("tile\(tileNumber).png"))!
    ```

  becomes

    ```swift
    let tileNode = SKSpriteNode.spriteNodeWithTexture(tileAtlas.textureNamed("tile\(tileNumber).png"))
    ```

  `DynamicSelf` will become more interesting in the coming weeks.

2014-02-05
----------

* `if` and `while` statements can now conditionally bind variables. If the
  condition of an `if` or `while` statement is a `let` declaration, then the
  right-hand expression is evaluated as an `Optional` value, and control flow
  proceeds by considering the binding to be `true` if the `Optional` contains a
  value, or `false` if it is empty, and the variables are available in the true
  branch. This allows for elegant testing of dynamic types, methods, nullable
  pointers, and other Optional things:

    ```swift
    class B : NSObject {}
    class D : B {
      func foo() { println("we have a D") }
    }
    var b: B = D()
    if let d = b as D {
      d.foo()
    }
    var id: AnyObject = D()
    if let foo = id.foo {
      foo()
    }
    ```

* When referring to a member of an `AnyObject` (or `AnyClass`) object
  and using it directly (such as calling it, subscripting, or
  accessing a property on it), one no longer has to write the `?` or
  `!`. The run-time check will be performed implicitly. For example:

    ```swift
    func doSomethingOnViews(views: NSArray) {
      for view in views {
          view.updateLayer() // no '!' needed
      }
    }
    ```

  Note that one can still test whether the member is available at
  runtime using `?`, testing the optional result, or conditionally
  binding a variable to the resulting member.

* The `swift` command line tool can now create executables and libraries
  directly, just like Clang. Use `swift main.swift` to create an executable and
  `swift -emit-library -o foo.dylib foo.swift` to create a library.

* Object files emitted by Swift are not debuggable on their own, even if you
  compiled them with the `-g` option. This was already true if you had multiple
  files in your project. To produce a debuggable Swift binary from the command
  line, you must compile and link in a single step with `swift`, or pass object
  files AND swiftmodule files back into `swift` after compilation.
  (Or use Xcode.)

* `import` will no longer import other source files, only built modules.

* The current directory is no longer implicitly an import path. Use `-I .` if
  you have modules in your current directory.


2014-01-29
----------

* Properties in structs and classes may now have `willSet:` and `didSet:`
  observing accessors defined on them:

  For example, where before you may have written something like this in a class:

    ```swift
    class MyAwesomeView : UIView {
      var _enabled : Bool  // storage
      var enabled : Bool { // computed property
      get:
        return _enabled
      set:
        _enabled = value
        self.needDisplay = true
      }
      ...
    }
    ```

  you can now simply write:

    ```swift
    class MyAwesomeView : UIView {
      var enabled : Bool {  // Has storage & observing methods
      didSet: self.needDisplay = true
      }
      ...
    }
    ```

  Similarly, if you want notification before the value is stored, you can use
  `willSet`, which gets the incoming value before it is stored:

    ```swift
    var x : Int {
    willSet(value):  // value is the default and may be elided, as with set:
      println("changing from \(x) to \(value)")
    didSet:
      println("we've got a value of \(x) now.\n")
    }
    ```

  The `willSet`/`didSet` observers are triggered on any store to the property,
  except stores from `init()`, destructors, or from within the observers
  themselves.

  Overall, a property now may either be "stored" (the default), "computed"
  (have a `get:` and optionally a `set:` specifier), or a observed
  (`willSet`/`didSet`) property.  It is not possible to have a custom getter
  or setter on a observed property, since they have storage.

  Two known-missing bits are:
  - **(rdar://problem/15920332) didSet/willSet variables need to allow initializers**
  - **(rdar://problem/15922884) support non-member didset/willset properties**

  Because of the first one, for now, you need to explicitly store an initial
  value to the property in your `init()` method.

* Objective-C properties with custom getter or setter names are (temporarily)
  not imported into Swift; the getter and setter will be imported individually
  as methods instead. Previously, they would appear as properties within the
  Objective-C class, but attempting to use the accessor with the customized
  name would result in a crash.

  The long-term fix is tracked as **(rdar://problem/15877160)**.

* Computed 'type' properties (that is, properties of types, rather
  than of values of the type) are now permitted on classes, on generic
  structs and enums, and in extensions.  Stored 'type' properties in
  these contexts remain unimplemented.

  The implementation of stored 'type' properties is tracked as
  **(rdar://problem/15915785)** (for classes) and **(rdar://problem/15915867)**
  (for generic types).

* The following command-line flags have been deprecated in favor of new
  spellings. The old spellings will be removed in the following week's build:

  | Old Spelling             | New Spelling                  |
  |--------------------------|-------------------------------|
  | `-emit-llvm`             | `-emit-ir`                    |
  | `-triple`                | `-target`                     |
  | `-serialize-diagnostics` | `-serialize-diagnostics-path` |

* Imported `NS_OPTIONS` types now have a default initializer which produces a
  value with no options set. They can also be initialized to the empty set with
  `nil`. These are equivalent:

    ```swift
    var x = NSMatchingOptions()
    var y: NSMatchingOptions = nil
    ```


2014-01-22
----------

* The swift binary no longer has an SDK set by default. Instead, you must do
  one of the following:
    - pass an explicit `-sdk /path/to/sdk`
    - set `SDKROOT` in your environment
    - run `swift` through `xcrun`, which sets `SDKROOT` for you

* `let` declarations can now be used as struct/class properties.  A `let`
  property is mutable within `init()`, and immutable everywhere else.

    ```swift
    class C {
      let x = 42
      let y : Int
      init(y : Int) {
        self.y = y   // ok, self.y is mutable in init()
      }

      func test() {
        y = 42       // error: 'y' isn't mutable
      }
    }
    ```

* The immutability model for structs and enums is complete, and arguments are
  immutable by default.  This allows the compiler to reject mutations of
  temporary objects, catching common bugs.  For example, this is rejected:

    ```swift
    func setTo4(a : Double[]) {
      a[10] = 4.0     // error: 'a' isn't mutable
    }
    ...
    setTo4(someArray)
    ```

  since `a` is semantically a copy of the array passed into the function.  The
  proper fix in this case is to mark the argument is `@inout`, so the effect is
  visible in the caller:

    ```swift
    func setTo4(a : @inout Double[]) {
      a[10] = 4.0     // ok: 'a' is a mutable reference
    }
    ...
    setTo4(&someArray)
    ```

  Alternatively, if you really just want a local copy of the argument, you can
  mark it `var`.  The effects aren't visible in the caller, but this can be
  convenient in some cases:

    ```swift
    func doStringStuff(var s : String) {
      s += "foo"
      print(s)
    }
    ```

* Objective-C instance variables are no longer imported from headers written in
  Objective-C. Previously, they would appear as properties within the
  Objective-C class, but trying to access them would result in a crash.
  Additionally, their names can conflict with property names, which confuses
  the Swift compiler, and there are no patterns in our frameworks that expect
  you to access a parent or other class's instance variables directly. Use
  properties instead.

* The `NSObject` protocol is now imported under the name
  `NSObjectProtocol` (rather than `NSObjectProto`).

2014-01-15
----------

* Improved deallocation of Swift classes that inherit from Objective-C
  classes: Swift destructors are implemented as `-dealloc` methods that
  automatically call the superclass's `-dealloc`. Stored properties are
  released right before the object is deallocated (using the same
  mechanism as ARC), allowing properties to be safely used in
  destructors.

* Subclasses of `NSManagedObject` are now required to provide initial
  values for each of their stored properties. This permits
  initialization of these stored properties directly after +alloc to
  provide memory safety with CoreData's dynamic subclassing scheme.

* `let` declarations are continuing to make slow progress. Curried
  and selector-style arguments are now immutable by default, and
  `let` declarations now get proper debug information.

2014-01-08
----------

* The `static` keyword changed to `type`. One can now define "type
  functions" and "type variables" which are functions and variables
  defined on a type (rather than on an instance of the type), e.g.,

    ```swift
    class X {
      type func factory() -> X { ... }

      type var version: Int
    }
    ```

  The use of `static` was actively misleading, since type methods
  on classes are dynamically dispatched (the same as Objective-C
  `+` methods).

  Note that `type` is a context-sensitive keyword; it can still be
  used as an identifier.

* Strings have a new native UTF-16 representation that can be
  converted back and forth to `NSString` at minimal cost. String
  literals are emitted as UTF-16 for string types that support it
  (including Swift's `String`).

* Initializers can now delegate to other initializers within the same
  class by calling `self.init`. For example:

    ```swift
    class A { }

    class B : A {
      var title: String

      init() {
        // note: cannot access self before delegating
        self.init(withTitle: "My Title")
      }

      init withTitle(title: String) {
        self.title = title
        super.init()
      }
    }
    ```

* Objective-C protocols no longer have the `Proto` suffix unless there
  is a collision with a class name. For example, `UITableViewDelegate` is
  now imported as `UITableViewDelegate` rather than
  `UITableViewDelegateProto`. Where there is a conflict with a class,
  the protocol will be suffixed with `Proto`, as in `NSObject` (the
  class) and `NSObjectProto` (the protocol).

2014-01-01
----------

* Happy New Year

* Division and remainder arithmetic now trap on overflow. Like with the other
  operators, one can use the "masking" alternatives to get non-trapping
  behavior. The behavior of the non-trapping masking operators is defined:

    ```swift
    x &/ 0 == 0
    x &% 0 == 0
    SIGNED_MIN_FOR_TYPE &/ -1 == -1 // i.e. Int8: -0x80 / -1 == -0x80
    SIGNED_MIN_FOR_TYPE &% -1 == 0
    ```

* Protocol conformance checking for `@mutating` methods is now implemented: an
  `@mutating` struct method only fulfills a protocol requirement if the protocol
  method was itself marked `@mutating`:

    ```swift
    protocol P {
      func nonmutating()
      @mutating
      func mutating()
    }

    struct S : P {
      // Error, @mutating method cannot implement non-@mutating requirement.
      @mutating
      func nonmutating() {}

      // Ok, mutating allowed, but not required.
      func mutating() {}
    }
    ```

  As before, class methods never need to be marked `@mutating` (and indeed, they
  aren't allowed to be marked as such).


2013-12-25
----------

* Merry Christmas

* The setters of properties on value types (structs/enums) are now `@mutating` by
  default.  To mark a setter non-mutating, use the `@!mutating` attribute.

* Compiler inserts calls to `super.init()` into the class initializers that do
  not call any initializers explicitly.

* A `map` method with the semantics of Haskell's `fmap` was added to
  `Array<T>`.  Map applies a function `f: T->U` to the values stored in
  the array and returns an Array<U>.  So,

    ```swift
    (swift) func names(x: Int[]) -> String[] {
              return x.map { "<" + String($0) + ">" }
            }
    (swift) names(Array<Int>())
    // r0 : String[] = []
    (swift) names([3, 5, 7, 9])
    // r1 : String[] = ["<3>", "<5>", "<7>", "<9>"]
    ```

2013-12-18
----------

* Global variables and static properties are now lazily initialized on first
  use. Where you would use `dispatch_once` to lazily initialize a singleton
  object in Objective-C, you can simply declare a global variable with an
  initializer in Swift. Like `dispatch_once`, this lazy initialization is thread
  safe.

  Unlike C++ global variable constructors, Swift global variables and
  static properties now never emit static constructors (and thereby don't
  raise build warnings). Also unlike C++, lazy initialization naturally follows
  dependency order, so global variable initializers that cross module
  boundaries don't have undefined behavior or fragile link order dependencies.

* Swift has the start of an immutability model for value types. As part of this,
  you can now declare immutable value bindings with a new `let` declaration,
  which is semantically similar to defining a get-only property:

    ```swift
    let x = foo()
    print(x)        // ok
    x = bar()       // error: cannot modify an immutable value
    swap(&x, &y)    // error: cannot pass an immutable value as @inout parameter
    x.clear()       // error: cannot call mutating method on immutable value
    getX().clear()  // error: cannot mutate a temporary
    ```

  In the case of bindings of class type, the bound object itself is still
  mutable, but you cannot change the binding.

    ```swift
    let r = Rocket()
    r.blastOff()    // Ok, your rocket is mutable.
    r = Rocket()    // error: cannot modify an immutable binding.
    ```

  In addition to the `let` declaration itself, `self` on classes, and a few
  other minor things have switched to immutable bindings.

  A pivotal part of this is that methods of value types (structs and enums) need
  to indicate whether they can mutate self - mutating methods need to be
  disallowed on let values (and get-only property results, temporaries, etc) but
  non-mutating methods need to be allowed.  The default for a method is that it
  does not mutate `self`, though you can opt into mutating behavior with a new
  `@mutating` attribute:

    ```swift
    struct MyWeirdCounter {
      var count : Int

      func empty() -> Bool { return count == 0 }

      @mutating
      func reset() {
        count = 0
      }
      ...
    }

    let x = MyWeirdCounter()
    x.empty()   // ok
    x.reset()   // error, cannot mutate immutable 'let' value
    ```

   One missing piece is that the compiler does not yet reject mutations of self
   in a method that isn't marked `@mutating`.  That will be coming soon.  Related
   to methods are properties.  Getters and setters can be marked mutating as
   well:

   ```swift
   extension MyWeirdCounter {
      var myproperty : Int {
      get:
        return 42

      @mutating
      set:
        count = value*2
      }
    }
    ```

  The intention is for setters to default to mutating, but this has not been
  implemented yet.  There is more to come here.

* A `map` method with the semantics of Haskell's `fmap` was added to
  `Optional<T>`.  Map applies a function `f: T->U` to any value stored in
  an `Optional<T>`, and returns an `Optional<U>`.  So,

    ```swift
   (swift) func nameOf(x: Int?) -> String? {
             return x.map { "<" + String($0) + ">" }
           }
   (swift)
   (swift) var no = nameOf(.None) // Empty optional in...
   // no : String? = <unprintable value>
   (swift) no ? "yes" : "no"      // ...empty optional out
   // r0 : String = "no"
   (swift)
   (swift) nameOf(.Some(42))      // Non-empty in
   // r1 : String? = <unprintable value>
   (swift) nameOf(.Some(42))!     // Non-empty out
   // r2 : String = "<42>"
   ```

* Cocoa types declared with the `NS_OPTIONS` macro are now available in Swift.
  Like `NS_ENUM` types, their values are automatically shortened based
  on the common prefix of the value names in Objective-C, and the name can
  be elided when type context provides it. They can be used in `if` statements
  using the `&`, `|`, `^`, and `~` operators as in C:

    ```swift
    var options: NSJSONWritingOptions = .PrettyPrinted
    if options & .PrettyPrinted {
      println("pretty-printing enabled")
    }
    ```

  We haven't yet designed a convenient way to author `NS_OPTIONS`-like types
  in Swift.

2013-12-11
----------

* Objective-C `id` is now imported as `AnyObject` (formerly known as
 `DynamicLookup`), Objective-C `Class` is imported as `AnyClass`.

* The casting syntax `x as T` now permits both implicit conversions
  (in which case it produces a value of type `T`) and for
  runtime-checked casts (in which case it produces a value of type `T?`
  that will be `.Some(casted x)` on success and `.None` on failure). An
  example:

    ```swift
    func f(x: AnyObject, y: NSControl) {
      var view = y as NSView                  // has type 'NSView'
      var maybeView = x as NSView             // has type NSView?
    }
    ```

* The precedence levels of binary operators has been redefined, with a much
  simpler model than C's.  This is with a goal to define away classes of bugs
  such as those caught by Clang's `-Wparentheses` warnings, and to make it
  actually possible for normal humans to reason about the precedence
  relationships without having to look them up.

  We ended up with 6 levels, from tightest binding to loosest:
    ```
    exponentiative: <<, >>
    multiplicative: *, /, %, &
    additive: +, -, |, ^
    comparative: ==, !=, <, <=, >=, >
    conjunctive: &&
    disjunctive: ||
    ```

* The `Enumerable` protocol has been renamed `Sequence`.

* The `Char` type has been renamed `UnicodeScalar`.  The preferred
  unit of string fragments for users is called `Character`.

* Initialization semantics for classes, structs and enums init methods are now
  properly diagnosed by the compiler.  Instance variables now follow the same
  initialization rules as local variables: they must be defined before use.  The
  initialization model requires that all properties with storage in the current
  class be initialized before `super.init` is called (or, in a root class, before
  any method is called on `self,` and before the final return).

  For example, this will yield an error:

    ```swift
    class SomeClass : SomeBase {
      var x : Int

      init() {
        // error: property 'self.x' not initialized at super.init call
        super.init()
      }
    }
    ```

  A simple fix for this is to change the property definition to `var x = 0`,
  or to explicitly assign to it before calling `super.init()`.

* Relatedly, the compiler now diagnoses incorrect calls to `super.init()`.  It
  validates that any path through an initializer calls `super.init()` exactly once,
  that all ivars are defined before the call to super.init, and that any uses
  which require the entire object to be initialized come after the `super.init`
  call.

* Type checker performance has improved considerably (but we still
  have much work to do here).

2013-12-04
----------

* The "slice" versus "array" subtlety is now dead. `Slice<T>` has been folded
  into `Array<T>` and `T[]` is just sugar for `Array<T>`.


2013-11-20
----------
* Unreachable code warning has been added:

    ```swift
    var y: Int = 1
    if y == 1 { // note: condition always evaluates to true
      return y
    }
    return 1 // warning: will never be executed
    ```

* Overflows on integer type conversions are now detected at runtime and, when
  dealing with constants, at compile time:

    ```swift
    var i: Int = -129
    var i8 = Int8(i)
    // error: integer overflows when converted from 'Int' to 'Int8'

    var si = Int8(-1)
    var ui = UInt8(si)
    // error: negative integer cannot be converted to unsigned type 'UInt8'
    ```

* `def` keyword was changed back to `func`.

2013-11-13
----------

* Objective-C-compatible protocols can now contain optional
  requirements, indicated by the `@optional` attribute:

    ```swift
    @class_protocol @objc protocol NSWobbling {
      @optional def wobble()
    }
    ```

  A class that conforms to the `NSWobbling` protocol above can (but does
  not have to) implement `wobble`. When referring to the `wobble`
  method for a value of type `NSWobbling` (or a value of generic type
  that is bounded by `NSWobbling`), the result is an optional value
  indicating whether the underlying object actually responds to the
  given selector, using the same mechanism as messaging `id`. One can
  use `!` to assume that the method is always there, `?` to chain the
  optional, or conditional branches to handle each case distinctly:

    ```swift
    def tryToWobble(w : NSWobbling) {
      w.wobble()   // error: cannot call a value of optional type
      w.wobble!()  // okay: calls -wobble, but fails at runtime if not there
      w.wobble?()  // okay: calls -wobble only if it's there, otherwise no-op
      if w.wobble {
        // okay: we know -wobble is there
      } else {
        // okay: we know -wobble is not there
      }
    }
    ```

* Enums from Cocoa that are declared with the `NS_ENUM` macro are now imported
  into Swift as Swift enums. Like all Swift enums, the constants of the Cocoa
  enum are scoped as members of the enum type, so the importer strips off the
  common prefix of all of the constant names in the enum when forming the Swift
  interface. For example, this Objective-C declaration:

    ```objc
    typedef NS_ENUM(NSInteger, NSComparisonResult) {
      NSOrderedAscending,
      NSOrderedSame,
      NSOrderedDescending,
    };
    ```

  shows up in Swift as:

    ```swift
    enum NSComparisonResult : Int {
      case Ascending, Same, Descending
    }
    ```

  The `enum` cases can then take advantage of type inference from context.
  In Objective-C, you would write:

    ```objc
    NSNumber *foo = [NSNumber numberWithInt: 1];
    NSNumber *bar = [NSNumber numberWithInt: 2];

    switch ([foo compare: bar]) {
    case NSOrderedAscending:
      NSLog(@"ascending\n");
      break;
    case NSOrderedSame:
      NSLog(@"same\n");
      break;
    case NSOrderedDescending:
      NSLog(@"descending\n");
      break;
    }
    ```

  In Swift, this becomes:

    ```swift
    var foo: NSNumber = 1
    var bar: NSNumber = 2

    switch foo.compare(bar) {
    case .Ascending:
      println("ascending")
    case .Same:
      println("same")
    case .Descending:
      println("descending")
    }
    ```

* Work has begun on implementing static properties. Currently they are supported
  for nongeneric structs and enums.

    ```swift
    struct Foo {
      static var foo: Int = 2
    }
    enum Bar {
      static var bar: Int = 3
    }
    println(Foo.foo)
    println(Bar.bar)
    ```

2013-11-06
----------

* `func` keyword was changed to `def`.

* Implicit conversions are now allowed from an optional type `T?` to another
  optional type `U?` if `T` is implicitly convertible to `U`. For example,
  optional subclasses convert to their optional base classes:

    ```swift
    class Base {}
    class Derived : Base {}

    var d: Derived? = Derived()
    var b: Base? = d
    ```

2013-10-30
----------

* Type inference for variables has been improved, allowing any
  variable to have its type inferred from its initializer, including
  global and instance variables:

    ```swift
    class MyClass {
      var size = 0 // inferred to Int
    }

    var name = "Swift"
    ```

  Additionally, the arguments of a generic type can also be inferred
  from the initializer:

    ```swift
    // infers Dictionary<String, Int>
    var dict: Dictionary = ["Hello": 1, "World": 2]
    ```


2013-10-23
----------

* Missing return statement from a non-`Void` function is diagnosed as an error.

* `Vector<T>` has been replaced with `Array<T>`. This is a complete rewrite to use
  value-semantics and copy-on-write behavior. The former means that you never
  need to defensively copy again (or remember to attribute a property as "copy")
  and the latter yields better performance than defensive copying. `Dictionary<T>`
  is next.

* `switch` can now pattern-match into structs and classes, using the syntax
  `case Type(property1: pattern1, property2: pattern2, ...):`.

    ```swift
    struct Point { var x, y: Double }
    struct Size { var w, h: Double }
    struct Rect { var origin: Point; var size: Size }

    var square = Rect(Point(0, 0), Size(10, 10))

    switch square {
    case Rect(size: Size(w: var w, h: var h)) where w == h:
      println("square")
    case Rect(size: Size(w: var w, h: var h)) where w > h:
      println("long rectangle")
    default:
      println("tall rectangle")
    }
    ```

  Currently only stored properties ("ivars" in ObjC terminology) are
  supported by the implementation.

* Array and dictionary literals allow an optional trailing comma:

    ```swift
    var a = [ 1, 2, ]
    var d = [ "a": 1, "b": 2, ]
    ```

2013-10-16
----------
* Unlike in Objective-C, objects of type `id` in Swift do not
  implicitly convert to any class type. For example, the following
  code is ill-formed:

    ```swift
    func getContentViewBounds(window : NSWindow) -> NSRect {
      var view : NSView = window.contentView() // error: 'id' doesn't implicitly convert to NSView
     return view.bounds()
    }
    ```

  because `contentView()` returns an `id`. One can now use the postfix
  `!` operator to allow an object of type `id` to convert to any class
  type, e.g.,

    ```swift
    func getContentViewBounds(window : NSWindow) -> NSRect {
      var view : NSView = window.contentView()! // ok: checked conversion to NSView
     return view.bounds()
    }
    ```

  The conversion is checked at run-time, and the program will fail if
  the object is not an NSView. This is shorthand for

    ```swift
    var view : NSView = (window.contentView() as NSView)!
    ```

  which checks whether the content view is an `NSView` (via the `as
  NSView`). That operation returns an optional `NSView` (written
  `NSView?`) and the `!` operation assumes that the cast succeeded,
  i.e., that the optional has a value in it.

* The unconditional checked cast syntax `x as! T` has been removed. Many cases
  where conversion from `id` is necessary can now be handled by postfix `!`
  (see above). Fully general unconditional casts can still be expressed using
  `as` and postfix `!` together, `(x as T)!`.

* The old "square bracket" attribute syntax has been removed.

* Overflows on construction of integer and floating point values from integer
  literals that are too large to fit the type are now reported by the compiler.
  Here are some examples:

    ```swift
    var x = Int8(-129)
    // error: integer literal overflows when stored into 'Int8'

    var y : Int = 0xFFFF_FFFF_FFFF_FFFF_F
    // error: integer literal overflows when stored into 'Int'
    ```

  Overflows in constant integer expressions are also reported by the compiler.

    ```swift
    var x : Int8 = 125
    var y : Int8 = x + 125
    // error: arithmetic operation '125 + 125' (on type 'Int8') results in
    //        an overflow
    ```

* Division by zero in constant expressions is now detected by the compiler:

    ```swift
    var z: Int = 0
    var x = 5 / z  // error: division by zero
    ```

* Generic structs with type parameters as field types are now fully supported.

    ```swift
    struct Pair<T, U> {
      var first: T
      var second: U
    }
    ```

2013-10-09
----------
* Autorelease pools can now be created using the `autoreleasepool` function.

    ```swift
    autoreleasepool {
      // code
    }
    ```

  Note that the wrapped code is a closure, so constructs like `break` and
  `continue` and `return` do not behave as they would inside an Objective-C
  `@autoreleasepool` statement.

* Enums can now declare a "raw type", and cases can declare "raw values",
  similar to the integer underlying type of C enums:

    ```swift
    // Declare the underlying type as in Objective-C or C++11, with
    // ': Type'
    enum AreaCode : Int {
      // Assign explicit values to cases with '='
      case SanFrancisco = 415
      case EastBay = 510
      case Peninsula = 650
      case SanJose = 408
      // Values are also assignable by implicit auto-increment
      case Galveston // = 409
      case Baltimore // = 410
    }
    ```

  This introduces `fromRaw` and `toRaw` methods on the enum to perform
  conversions from and to the raw type:

    ```swift
    /* As if declared:
        extension AreaCode {
          // Take a raw value, and produce the corresponding enum value,
          // or None if there is no corresponding enum value
          static func fromRaw(raw:Int) -> AreaCode?


          // Return the corresponding raw value for 'self'
          func toRaw() -> Int
        }
     */

    AreaCode.fromRaw(415) // => .Some(.SanFrancisco)
    AreaCode.fromRaw(111) // => .None
    AreaCode.SanJose.toRaw() // => 408
    ```

  Raw types are not limited to integer types--they can additionally be
  character, floating-point, or string values:

    ```swift
    enum State : String {
      case CA = "California"
      case OR = "Oregon"
      case WA = "Washington"
    }

    enum SquareRootOfInteger : Float {
      case One = 1.0
      case Two = 1.414
      case Three = 1.732
      case Four = 2.0
    }
    ```

  Raw types are currently limited to simple C-like enums with no payload cases.
  The raw values are currently restricted to simple literal values; expressions
  such as `1 + 1` or references to other enum cases are not yet supported.
  Raw values are also currently required to be unique for each case in an enum.

  Enums with raw types implicitly conform to the `RawRepresentable` protocol,
  which exposes the fromRaw and toRaw methods to generics:

    ```swift
    protocol RawRepresentable {
      typealias RawType
      static func fromRaw(raw: RawType) -> Self?
      func toRaw() -> RawType
    }
    ```

* Attribute syntax has been redesigned (see **(rdar://10700853)** and
  **(rdar://14462729)**) so that attributes now preceed the declaration and use
  the `@` character to signify them.  Where before you might have written:

    ```swift
    func [someattribute=42] foo(a : Int) {}
    ```

  you now write:

    ```swift
    @someattribute=42
    func foo(a : Int) {}
    ```

  This flows a lot better (attributes don't push the name for declarations away),
  and means that square brackets are only used for array types, collection
  literals, and subscripting operations.

* The `for` loop now uses the Generator protocol instead of the `Enumerator`
  protocol to iterate a sequence. This protocol looks like this:

    ```swift
    protocol Generator {
      typealias Element
      func next() -> Element?
    }
    ```

  The single method `next()` advances the generator and returns an
  Optional, which is either `.Some(value)`, wrapping the next value out
  of the underlying sequence, or `.None` to signal that there are no
  more elements. This is an improvement over the previous Enumerator
  protocol because it eliminates the separate `isEmpty()` query and
  better reflects the semantics of ephemeral sequences like
  un-buffered input streams.

2013-10-02
----------
* The `[byref]` attribute has been renamed to `[inout]`.  When applied to a logical
  property, the getter is invoked before a call and the setter is applied to
  write back the result.  `inout` conveys this better and aligns with existing
  Objective-C practice better.

* `[inout]` arguments can now be captured into closures. The semantics of a
  inout capture are that the captured variable is an independent local variable
  of the callee, and the inout is updated to contain the value of that local
  variable at function exit.

  In the common case, most closure arguments do not outlive the duration of
  their callee, and the observable behavior is unchanged.  However, if the
  captured variable outlives the function, you can observe this.  For example,
  this code:

    ```swift
    func foo(x : [inout] Int) -> () -> Int {
      func bar() -> Int {
        x += 1
        return x
      }
      // Call 'bar' once while the inout is active.
      bar()
      return bar
    }

    var x = 219
    var f = foo(&x)
    // x is updated to the value of foo's local x at function exit.
    println("global x = \(x)")
    // These calls only update the captured local 'x', which is now independent
    // of the inout parameter.
    println("local x = \(f())")
    println("local x = \(f())")
    println("local x = \(f())")

    println("global x = \(x)")
    ```

  will print:

    ```
    global x = 220
    local x = 221
    local x = 222
    local x = 223
    global x = 220
    ```

  In no case will you end up with a dangling pointer or other unsafe construct.

* `x as T` now performs a checked cast to `T?`, producing `.Some(t)` if the
  cast succeeds, or `.None` if the cast fails.

* The ternary expression (`x ? y : z`) now requires whitespace between the
  first expression and the question mark.  This permits `?` to be used
  as a postfix operator.

* A significant new piece of syntactic sugar has been added to ease working
  with optional values.  The `?` postfix operator is analogous to `!`, but
  instead of asserting on None, it causes all the following postfix
  operators to get skipped and return `None`.

  In a sense, this generalizes (and makes explicit) the Objective-C behavior
  where message sends to `nil` silently produce the zero value of the result.

  For example, this code

    ```swift
    object?.parent.notifyChildEvent?(object!, .didExplode)
    ```

  first checks whether `object` has a value; if so, it drills to its
  parent and checks whether that object implements the `notifyChildEvent`
  method; if so, it calls that method.  (Note that we do not yet have
  generalized optional methods.)

  This code:

    ```swift
    var titleLength = object?.title.length
    ```

  checks whether `object` has a value and, if so, asks for the length of
  its title.  `titleLength` wil have type `Int?`, and if `object` was
  missing, the variable will be initialized to None.

* Objects with type `id` can now be used as the receiver of property
  accesses and subscript operations to get (but not set) values. The
  result is of optional type. For example, for a variable `obj` of
  type `id`, the expression

    ```swift
    obj[0]
    ```

  will produce a value of type `id`, which will either contain the
  result of the message send objectAtIndexedSubscript(0) (wrapped in an
  optional type) or, if the object does not respond to
  `objectAtIndexedSubscript:`, an empty optional. The same approach
  applies to property accesses.

* `_` can now be used not only in `var` bindings, but in assignments as well,
  to ignore elements of a tuple assignment, or to explicitly ignore values.

    ```swift
    var a = (1, 2.0, 3)
    var x = 0, y = 0
    _ = a           // explicitly load and discard 'a'
    (x, _, y) = a   // assign a.0 to x and a.2 to y
    ```

2013-09-24
----------
* The `union` keyword has been replaced with `enum`.  Unions and enums
  are semantically identical in swift (the former just has data
  associated with its discriminators) and `enum` is the vastly more
  common case.  For more rationale, please see
  [docs/proposals/Enums.rst](https://github.com/apple/swift/blob/master/docs/proposals/Enums.rst)

* The Optional type `T?` is now represented as an `enum`:

    ```swift
    enum Optional<T> {
      case None
      case Some(T)
    }
    ```

  This means that, in addition to the existing Optional APIs, it can be
  pattern-matched with switch:

    ```swift
    var x : X?, y : Y?
    switch (x, y) {
    // Both are present
    case (.Some(var a), .Some(var b)):
      println("both")

    // One is present
    case (.Some, .None):
    case (.None, .Some):
      println("one")

    // Neither is present
    case (.None, .None):
      println("neither")
    }
    ```

* Enums now allow multiple cases to be declared in a comma-separated list
  in a single `case` declaration:

    ```swift
    enum Color {
      case Red, Green, Blue
    }
    ```

* The Objective-C `id` and `Class` types now support referring to
  methods declared in any class or protocol without a downcast. For
  example, given a variable `sender` of type `id`, one can refer to
  `-isEqual: with:`

    ```swift
    sender.isEqual
    ```

  The actual object may or may not respond to `-isEqual`, so this
  expression returns result of optional type whose value is determined via a
  compiler-generated `-respondsToSelector` send. When it succeeds, the
  optional contains the method; when it fails, the optional is empty.

  To safely test the optional, one can use, e.g.,

    ```swift
    var senderIsEqual = sender.isEqual
    if senderIsEqual {
      // this will never trigger an "unrecognized selector" failure
      var equal = senderIsEqual!(other)
    } else {
      // sender does not respond to -isEqual:
    }
    ```

  When you *know* that the method is there, you can use postfix `!` to
  force unwrapping of the optional, e.g.,

    ```swift
    sender.isEqual!(other)
    ```

  This will fail at runtime if in fact sender does not respond to `-isEqual:`.
  We have some additional syntactic optimizations planned for testing
  an optional value and handling both the success and failure cases
  concisely. Watch this space.

* Weak references now always have optional type.  If a weak variable
  has an explicit type, it must be an optional type:

    ```swift
    var [weak] x : NSObject?
    ```

  If the variable is not explicitly typed, its type will still be
  inferred to be an optional type.

* There is now an implicit conversion from `T` to `T?`.

2013-09-17
----------
* Constructor syntax has been improved to align better with
  Objective-C's `init` methods. The `constructor` keyword has been
  replaced with `init`, and the selector style of declaration used for
  func declarations is now supported. For example:

    ```swift
    class Y : NSObject {
      init withInt(i : Int) string(s : String) {
        super.init() // call superclass initializer
      }
    }
    ```

  One can use this constructor to create a `Y` object with, e.g.,

    ```swift
    Y(withInt:17, string:"Hello")
    ```

  Additionally, the rules regarding the selector corresponding to such
  a declaration have been revised. The selector for the above
  initializer is `initWithInt:string:`; the specific rules are
  described in the documentation.

  Finally, Swift initializers now introduce Objective-C entry points,
  so a declaration such as:

    ```swift
    class X : NSObject {
      init() {
        super.init()
      }
    }
    ```

  Overrides `NSObject`'s `-init` method (which it calls first) as well
  as introducing the 'allocating' entry point so that one can create a
  new `X` instance with the syntax `X()`.

* Variables in top-level code (i.e. scripts, but not global variables in
  libraries) that lack an initializer now work just like local variables:
  they must be explicitly assigned-to sometime before any use, instead of
  being default constructed.  Instance variables are still on the TODO
  list.

* Generic unions with a single payload case and any number of empty cases
  are now implemented, for example:

    ```swift
    union Maybe<T> {
      case Some(T)
      case None
    }

    union Tristate<T> {
      case Initialized(T)
      case Initializing
      case Uninitialized
    }
    ```

  Generic unions with multiple payload cases are still not yet implemented.

2013-09-11
----------
* The implementation now supports partial application of class and struct
  methods:

    ```swift
    (swift) class B { func foo() { println("B") } }
    (swift) class D : B { func foo() { println("D") } }
    (swift) var foo = B().foo
    // foo : () -> () = <unprintable value>
    (swift) foo()
    B
    (swift) foo = D().foo
    (swift) foo()
    D
    ```

  Support for partial application of Objective-C class methods and methods in
  generic contexts is still incomplete.

2013-09-04
----------
* Local variable declarations without an initializer are no longer implicitly
  constructed.  The compiler now verifies that they are initialized on all
  paths leading to a use of the variable.  This means that constructs like this
  are now allowed:

    ```swift
    var p : SomeProtocol
    if whatever {
      p = foo()
    } else {
      p = bar()
    }
    ```

  where before, the compiler would reject the definition of `p` saying that it
  needed an initializer expression.

  Since all local variables must be initialized before use, simple things like
  this are now rejected as well:

    ```swift
    var x : Int
    print(x)
    ```

  The fix is to initialize the value on all paths, or to explicitly default
  initialize the value in the declaration, e.g. with `var x = 0` or with
  `var x = Int()` (which works for any default-constructible type).

* The implementation now supports unions containing protocol types and weak
  reference types.

* The type annotation syntax, `x as T`, has been removed from the language.
  The checked cast operations `x as! T` and `x is T` still remain.

2013-08-28
----------
* `this` has been renamed to `self`.  Similarly, `This` has been renamed to
  `Self`.

* Swift now supports unions. Unlike C unions, Swift's `union` is type-safe
  and always knows what type it contains at runtime. Union members are labeled
  using `case` declarations; each case may have a different set of
  types or no type:

    ```swift
    union MaybeInt {
      case Some(Int)
      case None
    }

    union HTMLTag {
      case A(href:String)
      case IMG(src:String, alt:String)
      case BR
    }
    ```

  Each `case` with a type defines a static constructor function for the union
  type. `case` declarations without types become static members:

    ```swift
    var br = HTMLTag.BR
    var a = HTMLTag.A(href:"http://www.apple.com/")
    // 'HTMLTag' scope deduced for '.IMG' from context
    var img : HTMLTag = .IMG(src:"http://www.apple.com/mac-pro.png",
                             alt:"The new Mac Pro")
    ```

  Cases can be pattern-matched using `switch`:

    ```swift
    switch tag {
    case .BR:
      println("<br>")
    case .IMG(var src, var alt):
      println("<img src=\"\(escape(src))\" alt=\"\(escape(alt))\">")
    case .A(var href):
      println("<a href=\"\(escape(href))\">")
    }
    ```

  Due to implementation limitations, recursive unions are not yet supported.

* Swift now supports autolinking, so importing frameworks or Swift libraries
  should no longer require adding linker flags or modifying your project file.

2013-08-14
----------
* Swift now supports weak references by applying the `[weak]` attribute to a
  variable declaration.

    ```swift
    (swift) var x = NSObject()
    // x : NSObject = <NSObject: 0x7f95d5804690>
    (swift) var [weak] w = x
    // w : NSObject = <NSObject: 0x7f95d5804690>
    (swift) w == nil
    // r2 : Bool = false
    (swift) x = NSObject()
    (swift) w == nil
    // r3 : Bool = true
    ```

  Swift also supports a special form of weak reference, called `[unowned]`, for
  references that should never be nil but are required to be weak to break
  cycles, such as parent or sibling references. Accessing an `[unowned]`
  reference asserts that the reference is still valid and implicitly promotes
  the loaded reference to a strong reference, so it does not need to be loaded
  and checked for nullness before use like a true `[weak]` reference.

    ```swift
    class Parent {
      var children : Array<Child>

      func addChild(c:Child) {
        c.parent = this
        children.append(c)
      }
    }

    class Child {
      var [unowned] parent : Parent
    }
    ```

2013-07-31
----------
* Numeric literals can now use underscores as separators. For example:

    ```swift
    var billion = 1_000_000_000
    var crore = 1_00_00_000
    var MAXINT = 0x7FFF_FFFF_FFFF_FFFF
    var SMALLEST_DENORM = 0x0.0000_0000_0000_1p-1022
    ```

* Types conforming to protocols now must always declare the conformance in
  their inheritance clause.

* The build process now produces serialized modules for the standard library,
  greatly improving build times.

2013-07-24
----------
* Arithmetic operators `+`, `-`, `*`, and `/` on integer types now do
  overflow checking and trap on overflow. A parallel set of masking operators,
  `&+`, `&-`, `&*`, and `&/`, are defined to perform two's complement wrapping
  arithmetic for all signed and unsigned integer types.

* Debugger support. Swift has a `-g` command line switch that turns on
  debug info for the compiled output. Using the standard lldb debugger
  this will allow single-stepping through Swift programs, printing
  backtraces, and navigating through stack frames; all in sync with
  the corresponding Swift source code. An unmodified lldb cannot
  inspect any variables.

  Example session:

    ```
    $ echo 'println("Hello World")' >hello.swift
    $ swift hello.swift -c -g -o hello.o
    $ ld hello.o "-dynamic" "-arch" "x86_64" "-macosx_version_min" "10.9.0" \
         -framework Foundation lib/swift/libswift_stdlib_core.dylib \
         lib/swift/libswift_stdlib_posix.dylib -lSystem -o hello
    $ lldb hello
    Current executable set to 'hello' (x86_64).
    (lldb) b top_level_code
    Breakpoint 1: where = hello`top_level_code + 26 at hello.swift:1, addre...
    (lldb) r
    Process 38592 launched: 'hello' (x86_64)
    Process 38592 stopped
    * thread #1: tid = 0x1599fb, 0x0000000100000f2a hello`top_level_code + ...
        frame #0: 0x0000000100000f2a hello`top_level_code + 26 at hello.shi...
    -> 1         println("Hello World")
    (lldb) bt
    * thread #1: tid = 0x1599fb, 0x0000000100000f2a hello`top_level_code + ...
        frame #0: 0x0000000100000f2a hello`top_level_code + 26 at hello.shi...
        frame #1: 0x0000000100000f5c hello`main + 28
        frame #2: 0x00007fff918605fd libdyld.dylib`start + 1
        frame #3: 0x00007fff918605fd libdyld.dylib`start + 1
    ```

  Also try `s`, `n`, `up`, `down`.

2013-07-17
----------
* Swift now has a `switch` statement, supporting pattern matching of
  multiple values with variable bindings, guard expressions, and range
  comparisons. For example:

    ```swift
    func classifyPoint(point:(Int, Int)) {
      switch point {
      case (0, 0):
        println("origin")

      case (_, 0):
        println("on the x axis")

      case (0, _):
        println("on the y axis")

      case (var x, var y) where x == y:
        println("on the y = x diagonal")

      case (var x, var y) where -x == y:
        println("on the y = -x diagonal")

      case (-10..10, -10..10):
        println("close to the origin")

      case (var x, var y):
        println("length \(sqrt(x*x + y*y))")
      }
    }
    ```

2013-07-10
----------
* Swift has a new closure syntax. The new syntax eliminates the use of
  pipes. Instead, the closure signature is written the same way as a
  function type and is separated from the body by the `in`
  keyword. For example:

    ```swift
    sort(fruits) { (lhs : String, rhs : String) -> Bool in
      return lhs > rhs
    }
    ```

  When the types are omitted, one can also omit the parentheses, e.g.,

    ```swift
    sort(fruits) { lhs, rhs in lhs > rhs }
    ```

  Closures with no parameters or that use the anonymous parameters
  (`$0`, `$1`, etc.) don't need the `in`, e.g.,

    ```swift
    sort(fruits) { $0 > $1 }
    ```

* `nil` can now be used without explicit casting. Previously, `nil` had
  type `NSObject`, so one would have to write (e.g.) `nil as! NSArray`
  to create a `nil` `NSArray`. Now, `nil` picks up the type of its
  context.

* `POSIX.EnvironmentVariables` and `swift.CommandLineArguments` global variables
  were merged into a `swift.Process` variable.  Now you can access command line
  arguments with `Process.arguments`.  In order to acces environment variables
  add `import POSIX` and use `Process.environmentVariables`.
