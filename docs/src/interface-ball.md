# Ball methods
The following methods are useful for explicitly dealing with the ball
representation of `Arb` and related values.

## Construction
For constructing balls the methods below are useful. Note that there
is no `setinterval` method, this is instead accomplished with `Arb((a,
b))` for constructing a ball containing the interval ``[a, b]``.

``` @docs
setball
add_error
```

## Destruction
For extracting information about the ball representation the following
methods are useful.

``` @docs
radius
midpoint
lbound
ubound
abs_lbound
abs_ubound
getinterval
getball
```

## Union and intersection
The methods `Arblib.union` and `Arblib.intersection` compute the union
and intersection of balls. Note that these methods are not exported
and different from `Base.union` and `Base.intersect`.

``` @docs
Arblib.union
Arblib.intersection
```
