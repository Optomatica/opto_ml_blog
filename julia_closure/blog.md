# Julia Iterate, Recursion and Closure.
## Fibonacci Example

Fibonacci sequence is a sequence of numbers such as each number is a result of summing up the previous two numbers.

> 1, 1, 2, 3, 5, 8, 13, 21, ..., etc

In this tutorial we'll be generating fibonacci sequence in different ways. We'll start with a simple `for loop` and then see how we can use julia multiple dispatch with `Base.iterate`. Also we'll be checking recursion and a more efficient version of recursion. Finally we'll talking about closures. 

## 1. Simple Loop
The natural way of approaching this problem is to start with `a=0`, `b=1` and keep adding those variables along the way to the target sequence.

```julia
function fib_loop(n)
    a, b = 0, 1
    for i=2:n
        a, b = b, a+b
    end
    return b
end    
```

## 2. Julia Iterators
One of Julia powerful features is the using of multiple-dispatch. This allows any function to have multiple implementations based on the type of passed arguments. So in our case we'll need have a [`struct`](https://docs.julialang.org/en/v1/manual/types/#Composite-Types) that holds the info of the current iteration and to tell `Base.iterate` that we need to generate a new fibonacci sequence for every iteration. 
In our case the struct will be holding an integer that refers to the current fibonacci index.
```julia
struct FibStruct
    n::Int 
end
```

Now we'll define [iterate](https://docs.julialang.org/en/v1/manual/interfaces/#man-interface-iteration) function that works exclusively for `FibStruct`

```julia
"""
For next iterations, the result will be based on the coming a, b
"""
function Base.iterate(f::FibStruct, state=(n=1, a=0, b=1))
    if state.n > f.n
        return nothing
    else
        a, b = state.b, state.a+state.b
        n = state.n + 1
        return b, (n=n, a=a, b=b)
    end
end
```



## 3. Recursion
The Fibonacci sequence has always been the manifesto example for recursion. You start in a top-down approach from given N until reaching the base case `0`.

```julia
function fib_recursion(n)
    if n == 0 || n == 1
        return n
    else
        return fib_recursion(n-1) + fib_recursion(n-2)
    end
end
```

However this approach is very slow. We may not even be able to compute higher numbers before the end of the day or crashing the memory. 

The problem is that when we are trying to calculate the fifth fibonacci element we'll calculate the fibonacci of `2` twice. Every time you calculate higher number repeated calculations increase. To solve that we can save the values of our calculations so that we won't need to recalculate them. 

![](fib_tree.png)

## 4. Optimized Recursion
Now every time we calculate the fibonacci of a number, we'll save the value of that number in a dictionary or array. That way we won't recalculate values as it's already saved in the dictionary.

```julia
function fib_recursion_improved(n, history=Dict(0=>0, 1=>1))
    if haskey(history, n)
        return history[n]
    else
        history[n] = fib_recursion_improved(n-1, history) + fib_recursion_improved(n-2, history)
    end
end
```



## 5. Julia Closures
[Closure](https://docs.julialang.org/en/v1/devdocs/functions/#Closures) is a combination of  functions binded with its surrounding state such as other outer variables or functions. It provides you with an easier and cleaner way to make stateful function without needing to create a struct or class. 

Now we'll use closures to build a function `get_next_number` that keeps generating fibonacci sequence.
Since we need to save the values of `a` & `b` along the way, we'll be declaring them in the outer function `fib_closure` , Then to calculate nth fibonacci, we'll need to loop n times until reaching the nth fibonacci number.

```julia
function fib_closure(n)
    a = 0
    b = 1
    function get_next_number()
        a, b = b, a+b
        return b
    end
    return (get_next_number() for i=2:n)
end
```

## Conclusion
In this tutorial we've explained ways to calculate fibonacci series. Some ways are identical to other programming language and other ways are exclusively exists in Julia. 
Also we've measured the time of each function using [`BenchmarkTool.jl`](https://github.com/JuliaCI/BenchmarkTools.jl) while calculating the 90s fibonacci number. 
Note: If you try higher number than 93, you'll have an overflow. You may want to use other datatypes like [UInt64, Int128, UInt128](https://docs.julialang.org/en/v1/manual/integers-and-floating-point-numbers/) or [BigInt](https://docs.julialang.org/en/v1/base/numbers/#Base.GMP.BigInt) 

- fib_loop(90) 
    ```julia
    @btime begin
        fib_loop(90)
    end
    # 2.029 ns (0 allocations: 0 bytes)
    ```
- FibStruct(90)
    ```julia
    @btime begin 
        for i in FibStruct(90)
        end        
    end
    # 1.812 ns (0 allocations: 0 bytes)
    ```
- fib_recursion(90)
    ```julia
    @btime begin
        fib_recursion(90)
    end
    # More than 20 mins
    ```
- fib_recursion_improved(90)
    ```julia
    @btime begin
        fib_recursion_improved(90)
    end
    # 3.481 μs (10 allocations: 6.58 KiB)
    ```
- fib_closure(90)
    ```julia
    @btime begin
        collect(fib_closure(90))[end]    
    end
    # 2.372 μs (82 allocations: 2.11 KiB)
    ```

Finally we can conclude that if we want to calculate long sequences you rather use a way that involves loops such as `fib_loop` or iterate over `FibStruct`. Both ways have the best time and least memory allocation. If your problem really needs usage of recursion, Try whether to optimize your code to decrease the function calls or use `Closures`.