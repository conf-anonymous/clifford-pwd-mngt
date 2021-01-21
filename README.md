# Clifford Password Management

Ruby library for a password management application based on Clifford geometric algebra.

## Requirements

This code requires Ruby installed on your system. There are [several options for downloading and installing Ruby](https://www.ruby-lang.org/en/downloads/ "Download Ruby").

This project uses only Ruby standard libraries, so once you have Ruby installed (version 2.6.3 and greater), you have everything required to run the code. We tested our implementation on Mac OSX version 10.13.6 with ruby 2.6.3p62 (2019-04-16 revision 67580) [x86_64-darwin17].

## Usage

Once Ruby 2.6.3 or higher is installed in your machine, from the project root folder, execute the following on the terminal:

```
$ irb
```

Once in the Ruby interactive console, import the library:

```
> require './boot'
```

In order to initialize a new `password` object, execute the following:

```
> password = Clifford::Password.new
```

This will output somthing similar to

```
=> #<Clifford::Password:0x00007f85bb0a3c30 @counter=0, @order=[7, 13, 8, 5, 6, 10, 11, 12, 14, 1, 4, 0, 3, 15, 2, 9], @x1=53e0 + 83e1 + 67e2 + 101e3 + 12e12 + 74e13 + 101e23 + 80e123, @x2=33e0 + 87e1 + 123e2 + 3e3 + 104e12 + 33e13 + 81e23 + 40e123>
```

Now, let us generate a password of hierichal level 3:

```
> pwd1 = password.generate_password(3)
```

Which, for this particular instance, will output

```
=> "Y\\A'ax-D/7M{=G<W"
```

At this pount, the internal counter is set to 1. Let us consider that the administrador generated two more passwords after that.

Now, let us generate a password of hierichal level 4:

```
> pwd2 = password.generate_password(4)
```

which, for this particular instance, will output

```
=> "G9'0f:1Yv<U<$f^9"
```

We also generate a random password, completely disconnected with our application:

```
> pwd3 = Array.new(16){ rand(33..126) }.map(&:chr).join
```

which outputs

```
=> "]J'ccdO!,?Y8bPV<"
```

In order to verify `pwd1`, we execute

```
> password.verify_password(pwd1)
```

which outputs

```
=> [true, 1, 3]
```

meaning that the password `pwd1` is valid, it belongs to user ID 1, which hierarchical level 3.

Similarly, in order to verify `pwd2`, we execute

```
> password.verify_password(pwd2)
```

which outputs

```
=> [true, 4, 4]
```

meaning that the password `pwd2` is valid, it belongs to user ID 4, which hierarchical level 4.

Finally, in order to verify `pwd3`, we execute

```
> password.verify_password(pwd3)
```

which outputs

```
=> [false, 44, 23]
```

meaning that the password `pwd3` is not valid, which throws off everything. We could just return `false` as the only meaninful answer, however we show what the resulting counter and level is, 44 and 23, respectly, so it is clear to see how off the result is in comparison to the actual instance configuration. The current counter of the instance is 4, and the random password is reporting a 44 counter. However the key here is that these two numbers don't pass the validations in the instance method `verify_password` method from the `Clifford::Password` class.
