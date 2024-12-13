
function extended_euler_gcd(a::I, b::I) where {I <: Integer}
    b == 0 && return (gcd=a, x=1, y=0)
    g = extended_euler_gcd(b, a % b)
    return (gcd=g.gcd, x=g.y, y=g.x - g.y * div(a, b))
end

function solve_diophantine(a::I, b::I, c::I) where {I <: Integer}
    g = extended_euler_gcd(a, b)
    c % g.gcd == 0 || return nothing
    f = div(c, g.gcd)
    return (x=g.x * f, y=g.y * f, dx=div(b, g.gcd), dy=-div(a, g.gcd))
end
