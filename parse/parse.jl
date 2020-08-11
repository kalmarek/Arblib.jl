using Arblib

"""
    parse_arbdoc(filename)
Parse a .rst file from the Arb documentation. Returns the title of the
document together with a list of sections with their titles and the
functions documented in them.
"""
function parse_arbdoc(filename)
    return open(filename) do file
        lines = readlines(file)

        title = lines[3]
        @assert startswith(lines[4], "======")

        # Quick and dirty way to find all the sections
        splits = findall(str -> startswith(str, "------"), lines)

        sections = Vector{Tuple{String,Vector{String}}}()
        for n = 1:length(splits)
            section_title = lines[splits[n]-1]
            push!(sections, (section_title, []))

            start = splits[n]
            stop = n == length(splits) ? length(lines) : splits[n+1] - 1

            for line in lines[start:stop]
                if startswith(line, ".. function::")
                    push!(sections[n][2], strip(line[length(".. function::")+1:end]))
                end
            end
        end

        return title, sections
    end
end

"""
    generate_file(title, sections)
    generate_file(filename, title, sections)
Given a title and a list of sections, as returned by
[`parse_arbdoc`](@ref), return a string with the Julia code to load
all of those functions. If a file name is given then also write the
string to that file.

For each function it checks that it is correctly parsed. Those that do
not parse due to unsupported types are commented out in the code. If
they do not parse for some other reason and error is thrown.
"""
function generate_file(filename, title, sections)
    str = generate_file(title, sections)
    open(filename, "w") do file
        write(file, str)
    end
    return str
end

function generate_file(title, sections)
    str = "###\n"
    str *= "### " * title * "\n"
    str *= "###\n"

    for (section_title, functions) in sections
        str *= "\n### " * section_title * "\n"

        for s in functions
            try
                f = Arblib.Arbfunction(s)

                s == Arblib.arbsignature(f) || @warn(
                    "Expected signature: $s\n Obtained signature: $(Arblib.arbsignature(f))")

                str *= "arbcall\"" * s * "\"\n"
            catch e
                if e isa Arblib.UnsupportedArgumentType
                    str *= "# arbcall\"" * s * "\"\n"
                elseif e isa KeyError
                    str *= "# arbcall\"" * s * "\"\n"
                else
                    rethrow(e)
                end
            end
        end
    end
    return str
end
