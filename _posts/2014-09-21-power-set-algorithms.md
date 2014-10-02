---
title: power set algorithms
description: An overview of the math behind power sets, and three algorithms used to generate them.
code: true
math: true
date: 2014-09-21 21:00:00
thumbnail:
  link: power_set.png
  alt: A power set lattice.
tags:
  - math
  - sets
  - algorithms
  - python
---

# power sets
The power set of a set is the set of all its subsets, or a collection of all the different combinations of items
contained in that given set: in this write-up, we'll briefly explore the math behind power sets, and derive and compare
three different algorithms used to generate them.

## sets: primer
To refresh our memories: a [set](http://en.wikipedia.org/wiki/Set_(mathematics)), the building block of [set
theory](http://en.wikipedia.org/wiki/Set_theory)<sup id="link1">[1](#note1)</sup>, is a collection of any number of
unique objects whose order does not matter. A set is expressed using bracket notation, like $$\{1, 2, 3\}$$, and an
empty, or **null**, set is represented using either of $$\emptyset$$ and $$\{\}$$. Because sets are order-agnostic, we
can say that the $$\{1, 2, 3\}$$ and $$\{3, 1, 2\}$$ are equal, and, because they contain only distinct members,
something like $$\{1, 1, 2\}$$ is invalid.

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
  2. when adding an element to a set, to update its power set, you must create a copy of each of its existing subsets
	 with the new element included. We'll use this to implement our succinct second algorithm.

**Note**: the following algorithms are accompanied by Python implementations. To keep things simple, and because the
algorithms are language-independent, I avoided using Python-specific built-ins (like `yield`) and functions (like
`list.extend()`) that don't have clear equivalents in most other languages, even though they would've made some code
much cleaner. Also, even though we're dealing with sets, we'll use lists (arrays) under the assumption that they
contain distinct elements.

# algorithm 1: recursive k-subsets
This was my first stab at an algorithm that, given a set, returns its power set, and surprise! It's the least
intuitive and most inelegant of the three. We begin by writing a recursive function `k_subsets()` to find all of a
set's subsets of cardinality $$k$$ (a.k.a. its [$$k$$-subsets](http://mathworld.wolfram.com/k-Subset.html)):

## generating k-subsets

  1. Given a set of length $$n$$ and a desired subset of length $$k$$, iterate over the first $$n - k + 1$$ elements.
  2. For each element, make a recursive call to retrieve the $$(k-1)$$-subsets for the remainder of the array (all
     elements after the current one).
  3. Append the element to each $$(k-1)$$-subset, and return these subsets.

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

## from k-subsets to power set

With the ability to generate any $$k$$-subset, the key to creating a power set is finding the $$k$$-subsets for all
valid $$k$$, which lie in the range $$[0, n]$$ ($$n$$, again, is the cardinality of the superset)!

  1. For any $$k$$ in $$[0, n]$$:
  2. find the set's $$k$$-subsets

We'll introduce a wrapper function, `power_set()`, in which we'll nest a slightly modified `k_subsets()` that takes
advantage of closures.

{% highlight python table %}
def power_set_1(set_):
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

The second algorithm relies on our second informal proof of sets' cardinality: whenever an element is added to a set,
it must be added to copies of all the subsets in its current power set to form the new one. Thus:

  1. Start with an empty set, $$\{\}$$, and its power-set, $$\{\{\}\}$$.
  2. For every element inside the superset:
  3. Create a copy of every set in the current power-set
  4. Add the element to each one.
  5. Add the copies to the current power-set.

Like so:

{% highlight python table %}
def power_set_2(set_):
    subsets = [[]]
    for element in set_:
        for ind in xrange(len(subsets)):
            subsets.append(subsets[ind] + [element])
    return subsets
{% endhighlight %}

# algorithm 3: binary representation

The third algorithm is a clever hack, and relies on the binary representation of an incremented number to construct
subsets. In our first proof of the cardinality of a power set, we iterated over each element of an argument set and
made a choice with two possible outcomes (the element either was or wasn't a member of the subset): $$
\underbrace{2 \times 2 \times ... \times 2}_{n} = 2^n$$. Let's consider an integer of $$n$$-bits: it has $$2^n$$
possible values in the range $$[0, 2^n - 1]$$, meaning that we can use it to represent $$2^n$$ distinct arrangements of
$$n$$ bits. Hmm...

  1. Iterate over the range $$[0, 2^n - 1]$$.
  2. For every value, examine each of its $$n$$ bits.
  3. If the $$k$$th bit has a value of 1, add the $$k$$th value of the superset to the current subset.

{% highlight python table %}
def is_bit_flipped(num, bit):
    return (num >> bit) & 1

def power_set_3(set_):
    subsets = []
    for subset in xrange(2 ** len(set_)):
        new_subset = []
        for bit in xrange(len(set_)):
            if is_bit_flipped(subset, bit):
                new_subset.append(set_[bit])
        subsets.append(new_subset)
    return subsets
{% endhighlight %}

---

<span id="note1">[1](#link1)</span>: (completely tangentially) whenever I mention set theory I can't help but think of
the infamous [Principia Mathematica](http://en.wikipedia.org/wiki/Principia_Mathematica): a staggering, three-volume
attempt to axiomatize all of mathematics, published by [Bertrand
Russell](http://en.wikipedia.org/wiki/Bertrand_Russell) and [Alfred North
Whitehead](http://en.wikipedia.org/wiki/Alfred_North_Whitehead) in 1910-'13, that relied heavily on sets. It's
notorious, amongst other things, for proving $$1 + 1 = 2$$ in no less than 379 pages. Check it out.
