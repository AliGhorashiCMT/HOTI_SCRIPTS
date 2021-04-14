

interpolation_int = 10 
for plane_group in 1:10
    filenames = Vector{String}()
    for filename in readdir((@__DIR__)*"/input/"*"/plane_group_$(plane_group)")
            push!(filenames, filename)
    end
    for filename in filenames
        kveclist = Vector{Float64}()
        lines = Vector{String}()
        for line in readlines((@__DIR__)*"/input/"*"/plane_group_$(plane_group)/"*filename)
            if contains(line, "kvecs")
                for extraneous_string in [")", "(", "vector3", "list", "kvecs", "="]
                    line = replace(line, extraneous_string => " ")
                end
                all_kvec_coords = (parse.(Ref(Float64), string.(split(line))))
                for coord in all_kvec_coords
                    push!(kveclist, coord)
                end
	    elseif contains(line, "Ws") || contains(line, "ws") || contains(line, "opidxs")

            else
                push!(lines, line)
            end
        end
        num_initial_kvecs = Int(length(kveclist)/2)
        println(filename, "  ", num_initial_kvecs)
        reshaped_kveclist = permutedims(reshape(kveclist, (2, num_initial_kvecs)), (2, 1))
        #println(reshaped_kveclist)
        interpolatedkvecs = Array{Float64, 2}(undef, ((num_initial_kvecs-1)*interpolation_int+1, 2))

        for i in 1:num_initial_kvecs-1
            for j in 1:interpolation_int
                interpolatedkvecs[(i-1)*interpolation_int+j, :] = (reshaped_kveclist[i+1, :]-reshaped_kveclist[i, :])*(j-1)/interpolation_int+reshaped_kveclist[i, :]
            end
        end
        interpolatedkvecs[(num_initial_kvecs-1)*interpolation_int+1, :] = reshaped_kveclist[num_initial_kvecs, :]
        interpolatedkvecs  = round.(interpolatedkvecs, digits = 10)
        kvecstring = "(list "
        for ikvec in eachrow(interpolatedkvecs) 
            kvecstring = kvecstring*string("(vector3 ", [string(ikv, " ") for ikv in ikvec]..., ")")
        end
        kvecstring = "kvecs= "*kvecstring*")"
        #println(kvecstring)
        push!(lines, kvecstring)
        open((@__DIR__)*"/input/"*"/plane_group_$(plane_group)/"*"dispersion"*filename, write=true, create=true) do io
            for line in lines
                write(io, line, "\n")
            end
        end
    end
end



