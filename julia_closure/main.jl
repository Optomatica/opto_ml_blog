using BenchmarkTools

function fib_loop(n)
    a, b = 0, 1
    for i=2:n
        a, b = b, a+b
    end
    return b
end    


@btime begin
    fib_loop(90)
end

struct FibStruct
    n::Int 
end

function Base.iterate(f::FibStruct)
    return 1, (n=1, a=0, b=1)
end

function Base.iterate(f::FibStruct, state)
    if state.n > f.n
        return nothing
    else
        a, b = state.b, state.a+state.b
        n = state.n + 1
        return b, (n=n, a=a, b=b)
    end
end

answer = nothing
@btime begin 
    for (i, value) in enumerate(FibStruct(10))
        println(i)
        if i == 89
            answer = value
        end
    end
end
answer


using BenchmarkTools


function fib_recursion(n)
    if n == 0 || n == 1
        return n
    else
        return fib_recursion(n-1) + fib_recursion(n-2)
    end
end

@btime begin
    fib_recursion(90)
end

using BenchmarkTools
function fib_recursion_improved(n, history=Dict(0=>0, 1=>1))
    if haskey(history, n)
        return history[n]
    else
        history[n] = fib_recursion_improved(n-1, history) + fib_recursion_improved(n-2, history)
    end
end

@btime begin
    fib_recursion_improved(90)
end

function fib_closure(n)
    a = 0
    b = 1
    function get_next_number()
        a, b = b, a+b
        return b
    end
    return (get_next_number() for i=2:n)
end


@btime begin
    collect(fib_closure(90))[end]    
end
