using BenchmarkTools

function fib_loop(n)
    a, b = 0, 1
    for i = 2:n
        a, b = b, a + b
    end
    return b
end


struct FibStruct
    n::Int 
end


function Base.iterate(f::FibStruct, state=(n = 1, a = 0, b = 1))
    if state.n > f.n
        return nothing
    else
        a, b = state.b, state.a + state.b
        n = state.n + 1
        return b, (n = n, a = a, b = b)
    end
end


function fib_recursion(n)
    if n == 0 || n == 1
        return n
    else
        return fib_recursion(n - 1) + fib_recursion(n - 2)
    end
end


function fib_recursion_improved(n, history=Dict(0 => 0, 1 => 1))
    if haskey(history, n)
        return history[n]
    else
        history[n] = fib_recursion_improved(n - 1, history) + fib_recursion_improved(n - 2, history)
    end
end


function fib_closure(n)
    a = 0
    b = 1
    function get_next_number()
        a, b = b, a + b
        return b
    end
    return (get_next_number() for i = 2:n)
end


@btime begin 
    fib_loop(90) 
end
# 2.029 ns (0 allocations: 0 bytes)


@btime begin 
    fib_struct = FibStruct(90)
    next = iterate(fib_struct)
    while next !== nothing
    (i, state) = next
    next = iterate(fib_struct, state)
end
    # The above code is the same like this
    # for i in FibStruct(90)
    # end        
end
# 1.812 ns (0 allocations: 0 bytes)


@btime begin
    fib_recursion(90)
end
# More than 20 mins

@btime begin
    fib_recursion_improved(90)
end
# 3.481 μs (10 allocations: 6.58 KiB)

@btime begin
    collect(fib_closure(90))[end]    
end
# 2.372 μs (82 allocations: 2.11 KiB)