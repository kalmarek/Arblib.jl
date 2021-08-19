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
    generate_file(title, sections; verbose, manual_overrides)
    generate_file(filename, title, sections; verbose, manual_overrides)
Given a title and a list of sections, as returned by
[`parse_arbdoc`](@ref), return a string with the Julia code to load
all of those functions. If a file name is given then also write the
string to that file.

For each function it checks that it is correctly parsed. Those that do
not parse due to types which are not supported and likely never will
be are commented out in the code with `ns` (not supported). Those that
do not parse due to types that are currently not implemented, though
might be so in the future, are commented out with `ni` (not
implemented). If they do not parse for some other reason an error is
thrown.

If the argument `manual_overrides` is given then comment out functions
which exists as keys in the dictionary. It adds the value of the key
as an extra comment.
"""
function generate_file(
    filename,
    title,
    sections;
    verbose = false,
    manual_overrides = Dict{String,String}(),
)
    str = generate_file(
        title,
        sections,
        verbose = verbose,
        manual_overrides = manual_overrides,
    )
    open(filename, "w") do file
        write(file, str)
    end
    return str
end

function generate_file(
    title,
    sections;
    verbose = false,
    manual_overrides = Dict{String,String}(),
)
    str = "###\n"
    str *= "### " * title * "\n"
    str *= "###\n"

    num_functions = 0
    num_unsupparg = 0
    num_keyerror = 0

    unsuppargs = Set{String}()
    keyerrors = Set{String}()

    for (section_title, functions) in sections
        str *= "\n### " * section_title * "\n"

        for s in functions
            num_functions += 1
            if s in keys(manual_overrides)
                str *= "#mo arbcall\"" * s * "\" # $(manual_overrides[s])\n"
            else
                try

                    f = Arblib.Arbfunction(s)

                    s == Arblib.arbsignature(f) || @warn(
                        "Expected signature: $s\n Obtained signature: $(Arblib.arbsignature(f))"
                    )

                    str *= "arbcall\"" * s * "\"\n"
                catch e
                    if e isa Arblib.UnsupportedArgumentType
                        push!(unsuppargs, e.key)
                        num_unsupparg += 1
                        str *= "#ns arbcall\"" * s * "\"\n"
                    elseif e isa KeyError
                        push!(keyerrors, e.key)
                        num_keyerror += 1
                        str *= "#ni arbcall\"" * s * "\"\n"
                    else
                        rethrow(e)
                    end
                end
            end
        end
    end

    if verbose
        correctly_parsed = num_functions - num_unsupparg - num_keyerror
        @info "Correctly parsed functions: $correctly_parsed/$num_functions"
        @info "Unsupported types: $(collect(unsuppargs))"
        @info "Not implemented types: $(collect(keyerrors))"
    end

    return str
end

"""
    parse_and_generate_arbdoc(arb_doc_dir, out_dir = "src/arbcalls/")
Parses the Arb documentation and generates corresponding Julia files.
The value of `arb_doc_dir` should be a path to the directory
`doc/source/` in the Arb directory.
"""
function parse_and_generate_arbdoc(arb_doc_dir, out_dir = "src/arbcalls/")
    filenames = (
        "mag",
        "arf",
        "arb",
        "acb",
        "arb_poly",
        "acb_poly",
        "arb_mat",
        "acb_mat",
        "acb_hypgeom",
        "arb_hypgeom",
        "acb_elliptic",
        "acb_dirichlet",
    )

    unused_filenames = (
        "arb_fmpz_poly",
        "acb_dft",
        "acb_modular",
        "dirichlet",
        "bernoulli",
        "hypgeom",
        "partitions",
        "arb_calc",
        "acb_calc",
        "fmpz_extras",
        "bool_mat",
        "dlog",
        "fmpr",
    )

    manual_overrides = Dict{String,String}(
        "void mag_print(const mag_t x)" => "clashes with Base.print",
        "double arf_get_d(const arf_t x, arf_rnd_t rnd)" => "clashes with arf_get_si",
        "slong arf_get_si(const arf_t x, arf_rnd_t rnd)" => "clashes with arf_get_d",
        "void arf_print(const arf_t x)" => "clashes with Base.print",
        "int arf_mul(arf_t res, const arf_t x, const arf_t y, slong prec, arf_rnd_t rnd)" => "defined using #DEFINE in C which doesn't work in Julia",
        "arb_ptr _arb_vec_init(slong n)" => "clashes with similar method for acb",
        "double _arb_vec_estimate_allocated_bytes(slong len, slong prec)" => "clashes with similar method for acb",
        "void arb_print(const arb_t x)" => "clashes with Base.print",
        "int arb_can_round_arf(const arb_t x, slong prec, arf_rnd_t rnd)" => "clashes with arb_can_round_mpfr",
        "int arb_can_round_mpfr(const arb_t x, slong prec, mpfr_rnd_t rnd)" => "clashes with arb_can_round_arf",
        "void arb_root(arb_t z, const arb_t x, ulong k, slong prec)" => "alias to arb_root_ui",
        "acb_ptr _acb_vec_init(slong n)" => "clashes with similar method for arb",
        "double _acb_vec_estimate_allocated_bytes(slong len, slong prec)" => "clashes with similar method for arb",
        "void acb_print(const acb_t x)" => "clashes with Base.print",
        "slong arb_poly_length(const arb_poly_t poly)" => "clashes with Base.length",
        "void _arb_poly_add(arb_ptr C, arb_srcptr A, slong lenA, arb_srcptr B, slong lenB, slong prec)" => "clashes with _arb_vec_add",
        "void _arb_poly_sub(arb_ptr C, arb_srcptr A, slong lenA, arb_srcptr B, slong lenB, slong prec)" => "clashes with _arb_vec_sub",
        "slong acb_poly_length(const acb_poly_t poly)" => "clashes with Base.length",
        "void _acb_poly_add(acb_ptr C, acb_srcptr A, slong lenA, acb_srcptr B, slong lenB, slong prec)" => "clashes with _acb_vec_add",
        "void _acb_poly_sub(acb_ptr C, acb_srcptr A, slong lenA, acb_srcptr B, slong lenB, slong prec)" => "clashes with _acb_vec_sub",
        "void _acb_poly_elliptic_k_series(acb_ptr res, acb_srcptr z, slong zlen, slong len, slong prec)" => "alias to _acb_elliptic_k_series",
        "void acb_poly_elliptic_k_series(acb_poly_t res, const acb_poly_t z, slong n, slong prec)" => "alias to acb_elliptic_k_series",
        "void _acb_poly_elliptic_p_series(acb_ptr res, acb_srcptr z, slong zlen, const acb_t tau, slong len, slong prec)" => "alias to _acb_elliptic_p_series",
        "void acb_poly_elliptic_p_series(acb_poly_t res, const acb_poly_t z, const acb_t tau, slong n, slong prec)" => "alias to acb_elliptic_p_series",
    )

    for filename in filenames
        @info "Generating $filename.jl"
        title, sections = parse_arbdoc(joinpath(arb_doc_dir, "$filename.rst"))
        generate_file(
            joinpath(out_dir, "$filename.jl"),
            title,
            sections,
            verbose = true,
            manual_overrides = manual_overrides,
        )
        println("")
    end
end
