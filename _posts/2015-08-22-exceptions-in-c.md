---
title: emulating exceptions in C
description: A practical use-case for emulating exceptions in C with longjmp()/setjmp().
static: exceptions_in_c
code: true
date: 2015-08-22 21:00:00
thumbnail:
  link: exceptions_in_c.png
  alt: A key.
tags:
  - c
  - parsing
  - algorithms
---

# case study: a recursive-descent parser
I recently stumbled across a practical use-case for simulated exceptions in C while writing a recursive-descent JSON
parser for fun and profit. In this quick write-up, I'll give a high-level overview of the problems that I ran into, why
exceptions were ideal for error handling, and how I emulated them in C.

## recursive-descent parsing
I won't dwell on the details of the parser itself because this post is about the error-handling mechanism, but a
minimal understanding of recursive-descent parsing is necessary to appreciate it. As with any kind of parsing, we start
out with the [formal grammar](https://en.wikipedia.org/wiki/Formal_grammar) of our language/data format/whatever. A
simple grammar for common programming language literals might look like:

{% highlight ruby table %}
value: string | number | boolean
string: '"' char* '"'
boolean: 'true' | 'false'
number: '-'? digit+ ('.' digit+)?
array: '[' value ']'
{% endhighlight %}

In fact, the [JSON grammar](http://json.org/) that I used is fairly similar. Writing a [recursive-descent
parser](https://en.wikipedia.org/wiki/Recursive_descent_parser) for a grammar like the above is straightforward,
because you simply map each rule onto a corresponding parse function. In pseudocode, we might have:

{% highlight python table %}
parse()
    # perform setup
    return parseValue()

parseValue()
    if nextIsString()
        return parseString()
    else if nextIsNumber()
        return parseNumber
    else if nextIsBoolean()
        return parseBoolean()
    else if nextIsArray()
        return parseArray()
    else
        throw ParseError()

parseString()
    matchChars('"')
    string = readCharsUntil('"')
    matchChars('"')
    return string

parseBoolean()
    if peekChar() == 't'
        matchChars('true')
        return true
    else
        matchChars('false')
        return false

# and so on
{% endhighlight %}

The gist is that we have a bunch of mutually recursive parsing routines that ultimately rely on very primitive,
low-level functions (like `nextChar()`, `readCharsUntil()`, `matchChars()`, etc. in the above example) that operate
directly on the string being parsed.


# error-handling
Most of the errors that we need to worry about will occur in those primitives: `nextChar()` might fail
to read a character because it hit the end of the input stream and `matchChars()` might find an unexpected character,
for example. We may also want to manually signal an error in one of our high-level parsing routines, like we do in
`parseValue()` when we can't detect any valid values ahead. The key observations to make are that in a recursive-descent
parser, the call stack will grow quite deep, and that errors are fatal; in other words, when one occurs, we need to
`return` through many layers of function calls until we hit the `parse()` that started it all:

{% highlight python table %}
getNextChar()   # Error, hit EOF!
matchChars()
parseBoolean()
parseValue()
parseArray()
parseValue()
parse()         # The top-level parse routine that we need to jump back to.
{% endhighlight %}

How should we
handle errors in C, then?

## error codes
The idiomatic solution is to simply use error codes. If `nextChar()` fails, return `-1` (which is suitable because
character values can't be negative), and make sure to actually *check* that return value every time you call it.

{% highlight c table %}
char chr = nextChar(parserState);
if(chr == -1){
    return -1;
}
{% endhighlight %}

Note that the `parserState` argument passed to `nextChar()` is a (pointer to a) `struct` containing the parser's state:
a pointer to the string being parsed, its length, the current index in that string, etc.

In practice, we'd probably settle for a more sophisticated solution that involves storing error information inside
`parserState`, like a boolean indicating whether a failure occurred and an error message to accompany it, since it's
more flexible:

{% highlight c table %}
char chr = nextChar(parserState);
if(parserState->failed){
    puts(parserState->errMsg); // just an example
    return NULL;
}
{% endhighlight %}

Either way, the result is that we have to remember to manually check some error value after every call to a parse
routine that carried the possibility of failure. It bloats your code with repetitive conditionals and prevents you from
using the return value of a parse routine directly in an expression because, again, you need an explicit conditional.
Can we do better?

## exceptions, exceptions
An exception mechanism would be ideal here, since we want to jump back to an arbitrary point in the call stack (in
our case, `parse()`) from any one function. While C doesn't provide us with real exceptions, we *can* simulate
them...

### `longjmp()`, `setjmp()`
Enter `longjmp()` and `setjmp()`; like `goto`, but nuclear! From the manpage, these functions facilitate
"nonlocal jumps to a saved stack context," or, in other words, allow you to perform jumps across functions. **Use with
extreme caution.** The gist is that `setjmp()` is used to initialize a `jmp_buf`, storing critical information about
the current calling environment -- it's highly system-specific, but generally includes things like the stack pointer
and current register values -- and returns 0 (the **first** time it returns -- this will be explained shortly). You can
then pass that `jmp_buf` to `longjmp()` at any other point, and the program will rewind execution back to the
`setjmp()` call. You'll also need to pass a non-zero `int` to `longjmp()`, which will be the value that `setjmp()`
returns this time around; this allows us to discriminate between the times that `setjmp()` returns a.) initially and
b.) after a jump was performed. An example should set things straight:

{% highlight c table %}
#include <stdio.h>
#include <setjmp.h>

void bar(jmp_buf jmpBuf){
    puts("inside bar()");
    longjmp(jmpBuf, 1);
    puts("this should never run!");
}

void foo(void){
    jmp_buf jmpBuf;
    if(!setjmp(jmpBuf)){
        // This runs after `setjmp()` returns normally.
        puts("calling bar()");
        bar(jmpBuf);
        puts("this should never run!");
    }
    else {
        // This runs after `setjmp()` returns from a `longjmp()`.
        puts("returned from bar()");
    }
}

int main(){
	foo();
	return 0;
}
{% endhighlight %}

When compiled and run, you should see:

{% highlight c %}
calling bar()
inside bar()
returned from bar()
{% endhighlight %}

Notice how we wrap the call to `setjmp()` in a conditional, which allows us to selectively run different code after it
returned regularly (returning 0) and then after a jump occurred (returning whatever argument was passed to `longjmp()`,
or, in our case, 1). Continuing the exceptions analogy, this is similar to a `try {} catch {}`.

Also, note that `jmp_buf` is `typedef`'d as an array of the *actual* `jmp_buf` structs **with only one element** -- in
other words, when you declare `jmp_buf jmpBuf;`, the  struct inside `jmpBuf` lives entirely on the stack but `jmpBuf`
will decay to a pointer if you pass it to a function. In my opinion that's rather misleading and I would've preferred
to manually, explicitly use pointer notation when necessary, but it is what it is.

### integrating them into the parser
The idea is to initialize a `jmp_buf` in the `parse()` function with `setjmp()`, store it inside the `parserState`
struct in a `prevErrorTrap` member (couldn't think of a better name), and then `longjmp()` to it whenever an error
occurs. If that were all, using this solution would be a no-brainer, but alas, there's a complication: some of our
parsing routines might need to perform cleanup before exiting, like `free()`ing temporarily allocated memory. For
instance, the `parseArray()` function in my parser allocates a stretchy array to house all of the values that it
successfully parses; if an error occurs in one of the `parseValue()` calls that it makes, it needs to deallocate all of
the values parsed thus far and then the array itself.  If we jump from the point where the error occurred to the very
beginning of the parse, though, we don't have any means of doing so.

### intermediate cleanup
Two solutions come to mind:

  * storing pointers to all of the blocks of memory allocated by the parse routines inside an array in `parserState`,
    and then `free()`ing them inside the top-level `parse()` if an error occurred
  * setting intermediate jump points in functions that need to perform cleanup; in effect, catching exceptions,
    cleaning up, and reraising them.

I ultimately settled for the latter, and the idea's the same as before: in functions like `parseArray()` and any
others that allocate intermediate memory, create a copy of the current jump buffer (`parserState->prevErrorTrap`),
and then set `parserState->prevErrorTrap` to a **new** jump buffer created with `setjmp()` -- this one will get used
by all of the parse routines called by the current one. If the parse succeeds, just restore
`parserState->prevErrorTrap` to the original jump buffer before returning. If it fails, perform cleanup and jump
directly to the original buffer. Here's an example taken straight from the parser's source, with irrelevant bits
omitted:

{% highlight c table %}
static JsonArray_t JsonParser_parseArray(JsonParser_t *state){
    /**
     * Omitted: perform setup here.
     */

    jmp_buf prevErrorTrap;
    copyJmpBuf(prevErrorTrap, state->errorTrap);

    // The stretchy array used to store parsed values. Read on
    // for why `volatile` is necessary.
    JsonVal_t *volatile values = NULL;

    if(!setjmp(state->errorTrap)){

        /**
         * Omitted: parse values into `values` with repeated calls
         * to `parseValue()`.
         */

        // If we get this far, then no error occurred, so restore the
        // original `prevErrorTrap`.
        copyJmpBuf(state->errorTrap, prevErrorTrap);

        return (JsonArray_t){
            .length = sb_count(values),
            .values = values
        };
    }
    else {
        // An error occurred! Deallocate all intermediate memory,
        // and then jump to the previous `prevErrorTrap`.
        for(int ind = 0; ind < sb_count(values); ind++){
            JsonVal_free(&values[ind]);
        }
        sb_free(values);
        longjmp(prevErrorTrap, 1);
    }
}
{% endhighlight %}

`copyJmpBuf()` is just a convenience wrapper for `memcpy()`:

{% highlight c table %}
static void *copyJmpBuf(jmp_buf dest, const jmp_buf src){
    return memcpy(dest, src, sizeof(jmp_buf));
}
{% endhighlight %}

One other thing to note is that we declared the `values` pointer as `volatile` to prevent the compiler from placing it
into a register. Why? The problem is that we modify `values` after the call to `setjmp()`, namely when we
perform the initial allocation of a stretchy array and then whenever it gets resized and a `realloc()` changes the
location of the items that it contains. When a long jump occurs, register values are restored from whatever they were at the
time of the `setjmp()` call, since those are what it copied into the target `jmp_buf`; if the compiler decided to put
`values` into a register, then after the jump, it would be set to `NULL`.
To prevent that from happening, we use the `volatile` specifier. See [this SO
post](http://stackoverflow.com/questions/7996825/why-volatile-works-for-setjmp-longjmp) for more; this is an example of
the potentially very dangerous subtleties of long jumping. In fact, while writing my parser I forgot to add in the
`volatile` specifier to `values`, and noticed that it was leaking memory (thank you [valgrind](http://valgrind.org/)!)
whenever an error occurred even though the cleanup clause *was* getting run. It turns out that `values` would get put
into a register and then consequently take on a value of `NULL` after the jump -- since that's what it was at the time
of the original `setjmp()` -- meaning that the only reference to the allocated memory was lost and it couldn't possibly
be deallocated. Moreover, when passed to `free()`, it wouldn't blow up, because `free()` ignores NULL pointers[^1]!

To wrap up the above example, all of the other parsing functions that set intermediate breakpoints have virtually the same
layout, so you could even theoretically encapsulate the different statements in macros like `try` and `catch` for a
full blown mimicry of exceptions in other languages -- that's too much magic for me, though.

# in conclusion
`longjmp()` and `setjmp()` are tricky. They're obscure, can give rise to subtle bugs, are highly platform-specific,
and, if abused, will probably lead to awfully confusing code; a footcannon if I ever saw one. That being said, like
`goto`, they *do* have valid uses and can be very powerful when used appropriately. In this case, I think they were
superior to error codes and resulted in a slimmer, more readable implementation than what it otherwise would've been.
If you're interested in more reading, I recommend [this comprehensive
article](http://www.di.unipi.it/~nids/docs/longjump_try_trow_catch.html). Also,
[here]({% static json_parser_c.zip %})'s the thoroughly documented parser source code; check out `src/json_parser.c`.

---

[^1]: From `man -s3 free`: "If ptr is NULL, no operation is performed"
