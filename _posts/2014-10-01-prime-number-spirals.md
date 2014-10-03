---
title: Ulam and Sacks prime number spirals
code: true
math: true
date: 2014-10-01 21:00:00
thumbnail:
  link: prime_number_spiral.png
  alt: An Ulam prime-number spiral.
tags:
  - math
  - visualizations
  - prime number
  - algorithms
  - javascript
---

# prime number spirals
Prime number spirals are visualizations of the distribution of prime numbers that underscore their frequent occurrences
along certain polynomials. They're conceptually simple, yet create order out of the apparent chaos of primes and are
both incredibly elegant and beautiful. We'll explore the Ulam and Sacks spirals, some of their underlying theory,
and algorithms to render each.
abcdefe<1>

# ulam spiral

The story has it that [Stanislaw Ulam](http://en.wikipedia.org/wiki/Stanislaw_Ulam), a Polish-American mathematician of
[thermonuclear](http://en.wikipedia.org/wiki/Teller%E2%80%93Ulam_design) fame, sat in a presentation of a
"long and very boring paper" at a 1963 scientific conference. After some time, he began doodling (the hallmark of great
genius), first wroting out the first few positive integers in a counter-clockwise spiral, and then circling all of
the prime numbers. And he noticed something that he'd later formulate as "a strongly nonrandom appearance." Even on
a small scale -- say, the first 121 integers, which form a 11x11 grid -- it's visible that many primes align along
certain diagonal lines.

![An Ulam spiral consisting of the first 121 natural numbers](/img/prime_number_spirals/small_ulam_spiral.png)

Ulam later used [MANIAC II](http://en.wikipedia.org/wiki/MANIAC_II), a first-generation computer built for
[Los Alamos National Laboratory](http://en.wikipedia.org/wiki/Los_Alamos_Scientific_Laboratory) in 1957, to generate
images of the first 65,000<sup id="link1">[1](#note1)</sup> integers. The following spiral contains the first 360,000
(600x600):

![An Ulam spiral consisting of the first 360,000 natural numbers.](/img/prime_number_spirals/big_ulam_spiral.png)

## prime-generating polynomials

The reason why we see ghostly diagonals is that some quadratic polynomials (or functions of the form $$ax^2 + bx + c$$), informally called
[prime-generating polynomials](http://mathworld.wolfram.com/Prime-GeneratingPolynomial.html), have aberrantly high
occurrences of prime numbers. $$n^2 + n + 41$$, for instance, patented by
[Leonhard Euler](http://en.wikipedia.org/wiki/Leonhard_Euler) in 1772, is prime for all $$n$$ in the range $$[0, 39]$$,
yielding $$43, 47, 53, 61, ..., 1523, 1601$$. A variant is $$n^2 - n + 41$$, proposed by
[Adrien-Marie Legendre](http://en.wikipedia.org/wiki/Adrien-Marie_Legendre) in 1798, which is prime in $$[0, 40]$$.
Here are several others, as taken at random from
[Wolfram Mathworld](http://mathworld.wolfram.com/Prime-GeneratingPolynomial.html):

$$
\frac{1}{4}(n^5 - 133n^4 + 6729n^3 - 158379n^2 + 1720294n - 6823316)\\
\frac{1}{36}(n^6 - 126n^5 + 6217n^4 - 153066n^3 + 1987786n^2 - 13055316n + 34747236)\\
n^4 - 97n^3 + 3294n^2 - 45458n + 213589\\
n^5 - 99n^4 + 3588n^3 - 56822n^2 + 348272n - 286397
$$

In the case of the rectangular Ulam spiral, these polynomials appear as diagonal lines. They were known about since
1772, if not earlier, and a prime-number spiral was hinted at twice before Ulam published his. In 1932 (31 years
earlier before Ulam!), [Laurence M. Klauber](http://en.wikipedia.org/wiki/Laurence_Monroe_Klauber), a herpetologist
primarily focused on the study of rattlesnakes, presented a method of using a spiral grid to identify prime-generating
polynomials to the
[Mathematical Association ofAmerica](http://en.wikipedia.org/wiki/Mathematical_Association_of_America). The second
frequently-cited mention of prime spirals came from [Arthur C. Clarke](http://en.wikipedia.org/wiki/Arthur_C._Clarke),
a British science-fiction writer, whose [*The City and the Stars*](http://en.wikipedia.org/wiki/The_City_and_the_Stars)
(1956) describes a protagonist, Jeserac, as "[setting] up the matrix of all possible integers, and [starting] his
computer stringing the primes across its surface as beads might be arranged at the intersections of a mesh." In my
opinion, the second mention is fairly ambiguous, but the fact stands that, by the time Ulam published his famous
spiral, a general understanding of prime-generating polynomials existed and people were considering ways of visualizing
them. Thus, it's perhaps a little disingenuous to suggest that he stumbled across it when "doodling" (something fairly
intricate) at random -- there may have been some method to it.

## canvas setup

## algorithm

# sacks spiral

Robert Sacks, a software engineer, devised a variant of the Ulam spiral in 1994. Unlike Ulam's, Sacks's spiral
distributes integers along an [Archimedean spiral](http://en.wikipedia.org/wiki/Archimedean_spiral), or a function of
the polar form $$r = a + b\theta$$. Sacks discarded $$a$$ (which just controls the offset of the starting point of the curve
from the pole) and used $$b=\frac{1}{2\pi}$$, leaving $$r = \frac{\theta}{2\pi}$$; he then plotted the squares of all
the natural numbers on the intersections of the spiral and the polar axis, and filled in the points between squares
along the spiral, drawing them equidistant from one another. [^1]

![A Sacks spiral consisting of the first 22,800 natural numbers.](/img/prime_number_spirals/big_sacks_spiral.png)

## algorithm

---

<span id="note1">[1](#link1)</span>: Assuming that Ulam began rendering his spiral with the integer 1 (instead of
something like 41, which is also common), I suspect that the generated images had exactly 65,025 integers. 65,000
integers implies as many pixels, the square root -- the Ulam spiral is inherently square -- of which is 254.95, which
obviously isn't a valid image height/width. Thus, we round to 255, and square for 65,025.

[^1]: Hello, footnote!
