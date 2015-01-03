---
title: "nand2tetris: a book review and recap"
description: A review and recap of the book The Elements of Computing Systems (Nand2Tetris).
date: 2015-01-01 21:00:00
static: nand2tetris_review
thumbnail:
  link: nand2tetris_review.png
  alt: The cover of Nand2Tetris.
code: true
tags:
  - book review
  - computer engineering
---

# what is Nand2Tetris?
[Nand2Tetris](http://www.nand2tetris.org/), or *The Elements of Computing Systems*, is a twelve-part course in
fundamental computer engineering that steps you through the creation of a computer from the ground up, starting with
NAND logic gates and ending with an operating system capable of running a complicated program like Tetris.

The course, architected by [Noam Nisan](http://www.cs.huji.ac.il/~noam/) and
[Shimon Schocken](http://shimonschocken.com/), is available as a
[book](http://www.amazon.com/The-Elements-Computing-Systems-Principles/dp/0262640686) that you can
download for [free](http://www1.idc.ac.il/tecs/plan.html) (though it appears that some chapters are only available in
terse PowerPoint form), and emphasizes a hands-on approach that leads up to some pretty epic struggles and *Aha!*
moments. I just recently finished the course after about two months of hacking on it in my free time -- if you reliably
spend a couple hours a day on it, though, I can easily see you finishing in two weeks -- and wanted to share an
overview of the content and some thoughts.

![The cover of The Elements of Computing Systems.]({% static book.png %})

# content overview

<div class="quote">
	Once upon a time, every computer specialist had a gestalt understanding of how computers worked. The overall
	interactions among hardware, software, compilers, and the operating system were simple and transparent enough to
	produce a coherent picture of the computer’s operations. As modern computer technologies have become increasingly
	more complex, this clarity is all but lost: the most fundamental ideas and techniques in computer science—the very
	essence of the field—are now hidden under many layers of obscure interfaces and proprietary implementations. An
	inevitable consequence of this complexity has been specialization, leading to computer science curricula of many
	courses, each covering a single aspect of the field.

	<div>
		Elements of Computing Systems: Preface
	</div>
</div>

*Nand2Tetris* consists of twelve lectures/chapters, each of which tackles a next logical step in building a computer
called "Hack," and iterates on all of your work up to that point. Note that the book ships with various supplementary
materials (which you can download [here](http://www.nand2tetris.org/software.php)), including emulators for various
components of the computer, like the hardware, stack, and virtual machine. Here's an overview the ground you'll cover:

![An overview of the Nand2Tetris pipeline.]({% static overview.png %})

I'll briefly summarize the contents of each chapter (partly as a review for myself).

## 1: boolean logic
We learn about [boolean logic](http://computer.howstuffworks.com/boolean.htm), or logic with boolean values --
conveniently, `0`s and `1`s -- that facilitate logical/mathematical operations in hardware. We then construct primitive
[logic gates](http://en.wikipedia.org/wiki/Logic_gate), like `AND`, `OR`, and `MUX`, which operate on single-bit
inputs, and chain those together to implement their multi-bit (in this case, the *Hack*
[word](http://en.wikipedia.org/wiki/Word_%28computer_architecture%29), or two bytes) counterparts, like `AND16`.

## 2: boolean arithmetic
We cover binary addition and [two's complement](http://www.cs.cornell.edu/~tomf/notes/cps104/twoscomp.html), a means of
representing *signed* numbers (in other words, negative and positive values instead of positive values only), and
implement *adder* chips to perform addition at the hardware level. Finally, we devise an
[ALU](http://www.computerhope.com/jargon/a/alu.htm) (<b>A</b>rithmetic <b>L</b>ogic <b>U</b>nit), which implements
addition and value comparisons (ie, logic operations), but, unlike industrial-grade hardware, *not* either of
multiplication and division.  We'll implement those operations at the software level -- specifically, in the operating
system's math standard library -- in the interest of simplicity, but at the expense of speed.

## 3: sequential logic
Throughout chapters 1 and 2 we implemented *combinational* chips using **NAND** gates, and got
arithmetic/logic out of the way. This section introduces a new fundamental building block: the
[DFF](http://hyperphysics.phy-astr.gsu.edu/hbase/electronic/dflipflop.html), or <b>D</b>ata <b>F</b>lip <b>F</b>lop,
which will allow us to construct the second crucial component of our *Hack* computer -- memory. Unlike *combinational*
chips, which simply intake arguments via input pins and "immediately" spit out a result to output pins and are thus
*stateless*, the *sequential* circuits that we'll implement with flip-flops are capable of maintaining values across
time. Note that, even though we treat the *DFF* as a fundamental chip, it can be implemented [using NAND
gates](http://en.wikipedia.org/wiki/Flip-flop_%28electronics%29#SR_NAND_latch) and more -- Nand2Tetris just
thoughtfully spares us that gory implementation. We implement a `Bit`, `Register`, and multiple `RAM` chips with
iteratively larger capacities (64-word RAM consists of 8-word RAM, 512 of 64, etc.), and also a *program counter*,
which we'll use to keep track of the next CPU instruction to execute. This *sequential* business is a little
mind-bending (and quite cool) because it effectively makes use of delayed recursion in a hardware context.

## 4: machine language
We're introduced to the *Hack* [machine language](http://en.wikipedia.org/wiki/Machine_code), or the format of the
binary strings that our CPU (to be implemented in the next chapter) will interpret as instructions, and its
correspondent [assembly language](http://en.wikipedia.org/wiki/Assembly_language): this is *the* interface between
hardware and software. Assembly is a human-readable representation of machine code which allows instructions to be
written with mnemonics like `ADD` or `SUB`; those are then compiled down to the appropriate binary by an *assembler*
(to be implemented in chapter 6) -- essentially a glorified preprocessor. Here's an example of *Hack* assembly:

{% highlight text table %}
(LOOP)
	@END
	D;JEQ

	@sum
	M=M+D
	D=D-1

	@LOOP
	0;JMP
{% endhighlight %}

The above code adds all consecutive integers between 0 and some number, storing the sum in a variable `sum`.

## 5: computer architecture
We implement the *Hack* CPU, which abstracts away all hardware operations and exposes an API for executing them -- that
is, the machine language. The CPU integrates chapters 2 (the `ALU`) and 3 (`RAM`) in a classic mold of the
[von Neumann](http://www.teach-ict.com/as_as_computing/ocr/H447/F453/3_3_3/vonn_neuman/miniweb/pg3.htm) architecture:

![A diagram of the von Neumann computer architecture.]({% static von_neumann.png %})

## 6: assembler
Assembly! Everyone loves assembly! This section extends chapter 4, which documented the *Hack* assembly language spec.,
and has you implement the assembler that translates such programs to binary machine instructions.

## 7, 8: virtual machine
We learn about *virtual machines*, or **platform-independent** runtime environments that allow high-level languages to
compile down to a portable [intermediate representation](http://cs.lmu.edu/~ray/notes/ir/), or IR, (in this case, the
virtual machine language) that will run on any chip-set with an implementation of that virtual machine. Basically,
since different CPUs potentially have different machine languages, writing native compilers for high-level languages
would be a nightmare because the output binaries would have to be tweaked on a per-system basis. A virtual machine
handles that concern by itself exposing an interface -- in the form of a virtual machine language, or IR -- for
performing memory, logic, and math operations that target systems can reliably be expected to support.
Platform-specific compilers that convert the IR to assembly *do* have to be written, but that problem is now
centralized in one place; high-level language developers don't have to worry about re-inventing the same compilation
wheel if they build their language around the same virtual machine, instead leaving that problem to the virtual machine
maintainers.

![A simple diagram of a virtual machine.]({% static virtual_machine.png %})

Anyway, the *Hack* virtual machine wraps its assembly language in a simple, stack-based interface. We implement the
IR-to-assembly compiler, which becomes tricky once we involve things like stack frames. Sample code looks like:

{% highlight python table %}
function Point.new 0
	push constant 2
	call Memory.alloc 1
	pop pointer 0
	push argument 0
	pop this 0
	push argument 1
	pop this 1
	push pointer 0
	return
{% endhighlight %}


## 9: high-level language
We're introduced to the spec for a high-level, object-oriented language (without garbage collection) not unlike Java,
called *Jack*. The following *Jack* code defines a class `Point`, which represents a 2D geometric point:

{% highlight java table %}
class Point {
	field int _x, _y;

	constructor Point new(int x, int y){
		let _x = x;
		let _y = y;
		return this;
	}
}
{% endhighlight %}

## 10, 11: compiler
We implement a *Jack* compiler, which converts *Jack* programs to *Hack* virtual machine code. We learn about basic
compilation techniques -- tokenization, recursive-descent parsers -- and features -- symbol tables, parse trees.

## 12: operating system
Finally, we implement the *Hack* operating system (using *Jack*), which only consists of a number of standard system
libraries that govern things like math, memory management, and graphics. The chapter centers heavily on algorithms,
introducing some fascinating optimized approaches to problems including multiplication and heap allocation.

# review and advice
That was a pretty wild ride. I heard about *The Elements of Computing Systems* nearly two years ago and kept it on the
back-burner ever since, and am very glad I finally got around to reading it. Nisan and Schocken succeeded tremendously
in what they set out to accomplish -- creating a course that gives you a universal, if shallow, understanding of
the entire hardware and software stack that computers operate on.

The individual sections are clear and concise, with just enough technical and academic background, examples, and
project walkthroughs, and benefit from a uniform structure. Each project assignment involves a good deal of
steering, as the authors underscore the *suggested* (though probably always the way you'd want to go anyway) approach to
implementing the next stage of the computer, but with nothing in the way of concrete implementations -- this encourages
the reader to wet their feet and, in true hacker fashion, build the thing on their own. The software package that ships
with the course is entirely bug-free, and the emulators are both user-friendly and robust (these things are easy to
take for granted...).

An enormous amount of thought was clearly invested in the structure of the course. The various components of the *Hack*
system have perfectly coupled interrelationships, and your work up to any single point almost magically helps you
bootstrap the next project with incredible ease -- this is mostly true for the hardware sections of the course, where
chip creation is a *highly* iterative process, and lets you create substantially complicated circuits out of nothing in
no time.

Another nice bit about Nand2Tetris is that it has much to offer to people at various skill levels. I entered the
course having never written a line of assembly, nor did I have much knowledge about compilers and virtual machines, but
I *did* have a reasonable amount of software engineering experience and at least a vague understanding of the
aforementioned components: the course ended up perfect, though I suspect that it's mostly aimed at people in my
situation. Still, I can see it being useful even to greybeards with a nuanced knowledge of architectures, compilers,
and operating systems, simply because it does such a good job of tying them all together in a *single coherent
project*. I can imagine myself giving it another pass a couple of years from now, taking each of the projects further
and refreshing myself on the overview it provides.

Finally, the course is lightweight: the book comes in at just under 300 pages, and that's with *twelve* sections that
collectively cover all of the vital components of a rudimentary computer. As a result, it doesn't delve terribly far
into any one of them; you won't implement many elementary chips, the authors intentionally skip over involved
problems like hardware multiplication, the computer won't have a filesystem, you won't come anywhere near hardware
acceleration, networking isn't covered, and the high-level language you develop is highly limited (both in syntax and
functionality). That's the point. *The Elements of Computing Systems* tries to provide a general introduction to each
component and a coherent project that ties them all together -- it's not the place to go for an immersive foray
into any of them. On the upside, it underscore a wealth of questions which you're then encouraged to explore on your
own.

Taking some notes ([I did](https://github.com/sevko/portfolio/tree/develop/books/nand2tetris/notes)) for future
reference might be a good idea while you read.

N2T is, in my opinion, a high quality must-read for software engineers. Can't recommend it enough.

## a note on requisites
This course is *not* for the amateur programmer. While the hardware chapters, the projects for which primarily consist
of implementing chips using an HDL, or hardware description language, don't require any prior experience with anything,
the software sections involve the creation of reasonably complicated software in your programming language of choice. A
solid grasp of recursion is necessary for parsing, tokenization would probably be hell without a knowledge of regex,
and the compilers require some engineering acumen to implement cleanly -- plus, it might be nice to have a vague
understanding of all the various components of a computer's hardware and software going into the course, so that it
clarifies and refines your understanding of the various moving parts instead of simply introducing a bunch of
theretofore unheard-of concepts that, as a result, might be difficult to appreciate. I hope someone proves me wrong,
though!

## vim syntax files
As a complete aside, you'll work with a number of ad-hoc languages throughout the course: *HDL*, *Hack* assembly,
*Hack* virtual machine language, and *Jack*. I'm a Vim user and got a little tired of the lack of syntax highlighting,
so wrote up a [minimalist plugin](https://github.com/sevko/vim-nand2tetris-syntax) to provide it.
