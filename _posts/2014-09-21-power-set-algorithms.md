---
title: power set algorithms
code: true
math: true
date: 2014-09-21 21:00:00
thumbnail:
  link: power_set.png
  alt: A power set lattice.
tags:
  - math
---

# power sets
The [power set](http://en.wikipedia.org/wiki/Power_set) of a set is the set of all its
[subsets](http://en.wikipedia.org/wiki/Subset), or a collection of all the different combinations of items contained in
that given set: in this write-up, we'll briefly explore the math behind power sets, and derive and compare three
different algorithms used to generate them.

## sets: primer
To refresh our memories: a [set](http://en.wikipedia.org/wiki/Set_(mathematics)), the building block of [set
theory](http://en.wikipedia.org/wiki/Set_theory), is a collection of any number of unique objects where order does not
matter. A set is expressed using bracket notation, like $$\{1, 2, 3\}$$, and an empty, or **null**, set is represented
using either of $$\emptyset$$ and $$\{\}$$. Because sets are order-agnostic, we can say that the $$\{1, 2, 3\}$$ and
$$\{3, 1, 2\}$$ are equal, and, because they contain only distinct members, $$\{1, 1, 2\}$$ is invalid.

## subsets and the power set
The [subset](http://en.wikipedia.org/wiki/Subset) of a set is any combination (the null set included) of its members,
such that it is contained inside the superset; $$\{a, b\}$$, then, is a subset of $$\{a, b, c\}$$, while $$\{a, d\}$$
is not. If a subset contains *all* of the members of the parent set (ie, it's a copy), we call it an **improper**
subset; otherwise, it's **proper**. Finally, the [power set](http://en.wikipedia.org/wiki/Power_set) of a set is the
collection of all of its subsets, so the power set of $$\{a, b, c\}$$ is:

$$
\{
    \{\},
    \{a\},
    \{b\},
    \{c\},
    \{a, b\},
    \{a, c\},
    \{b, c\},
    \{a, b, c\}
\}
$$

## the length of a power set
The length, or [cardinality](http://en.wikipedia.org/wiki/Cardinality), of a power set is $$2^n$$, where $$n$$ is the
cardinality of the original set, so the number of subsets of something like $$\{a, b, c\} (n=3)$$ is 8 $$(2^{n=3})$$.
Two ways of informally proving that property:

  1. when creating a subset of a given set, we iterate over the members of the given set and choose whether each one
     will or will not be in the subset. Since there are 2 possible outcomes of each choice (the member either is or
     isn't chosen) and there are $$n$$ elements, there must be $$2^n$$ subsets.
  2. when adding an element to a set, you must create a copy of each of its existing sets with the new element
     included. We'll use this to implement our succinct second algorithm.

# algorithm 1: recursive walking

# algorithm 2: iterative appending

# algorithm 3: binary representation

# comparison

## practicality

## performance
