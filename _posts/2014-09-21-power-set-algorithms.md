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
$$\{3, 1, 2\}$$ are equal, and, because they contain only distinct members, something like $$\{1, 1, 2\}$$ is invalid.

## subsets and the power set
The [subset](http://en.wikipedia.org/wiki/Subset) of a set is any combination (the null set included) of its members,
such that it is contained inside the superset; $$\{a, b\}$$, then, is a subset of $$\{a, b, c\}$$, while $$\{a, d\}$$
is not. If a subset contains *all* of the members of the parent set (ie, it's a copy), we call it an **improper**
subset -- otherwise, it's **proper**. Finally, the [power set](http://en.wikipedia.org/wiki/Power_set) of a set is the
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

## the cardinality of a power set
The length, or [cardinality](http://en.wikipedia.org/wiki/Cardinality), of a power set is $$2^n$$, where $$n$$ is the
cardinality of the original set, so the number of subsets of something like $$\{a, b, c\} (n=3)$$ is 8 $$(2^{n=3})$$.
Two ways of informally proving that property:

  1. when creating a subset of a given set, we iterate over the members of the given set and choose whether each one
     will or will not be in the subset. Since there are 2 possible outcomes of each choice (the member either is or
     isn't chosen) and there are $$n$$ elements, there must be $$2^n$$ subsets.
  2. when adding an element to a set, you must create a copy of each of its existing sets with the new element
     included. We'll use this to implement our succinct second algorithm.

**Note**: the following algorithms are accompanied by Python implementations. To keep things simple, and because
they're language-agnostic, I avoided using strictly Python-specific built-ins (like `yield`) and functions (like
`extend()`) that don't have clear equivalents in most other languages, even though they would've made some code much
cleaner. Also, even though we're dealing with sets, we'll use lists (arrays) under the assumption that they contain
distinct elements.

# algorithm 1: recursive k-subsets
This was my first stab at an algorithm that, given a set, returns its power set, and surprise! It's the least
intuitive and most inelegant of the three. We begin by writing a recursive function `k_subsets()` to find all of a
set's subsets of cardinality $$k$$ (a.k.a., shockingly, its $$k$$-subsets):

  1. Given a set of length $$n$$ and a desired subset of length $$k$$, iterate over the first $$n - k + 1$$ elements.
  2. For each element, make a recursive call to retrieve the $$(k-1)$$-subsets for the remainder of the array.
  3. Append the element to each $$(k-1)$$-subset, and return this new set.

{% highlight python table %}
def k_subsets(k, set_):
    if k == 0:
        return [[]]
    else:
        subsets = []
        for ind in xrange(len(set_) - k + 1):
            for subset in k_subsets(k - 1, set_[ind + 1:]):
                subsets.append(subset + [set_[ind]])
        return subsets
{% endhighlight %}

With the ability to generate any $$k$$-subset, the key to creating a power set is finding the $$k$$-subsets for all
valid $$k$$, which lie in the range $$[0, n]$$ ($$n$$, again, is the cardinality of the superset)!

  1. For any $$k$$ in $$[0, n]$$:
  2. find and return the k-subsets

We'll introduce a wrapper function, `power_set()`, in which we'll nest a slightly modified `k_subsets()` that takes
advantage of closures.

{% highlight python table %}
def power_set(set_):
    def k_subsets(k, start_ind):
        if k == 0:
            return [[]]
        else:
            subsets = []
            for ind in xrange(start_ind, len(set_) - k + 1):
                for subset in k_subsets(k - 1, ind + 1):
                    subsets.append(subset + [set_[ind]])
            return subsets

    subsets = []
    for k in xrange(len(set_) + 1):
        for subset in k_subsets(k, 0):
            subsets.append(subset)
    return subsets
{% endhighlight %}

# algorithm 2: iterative appending

# algorithm 3: binary representation

# comparison

## practicality

## performance
