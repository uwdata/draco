#script(lua)

require("clingo")

function main(prg)
    local count = tonumber(prg.configuration.solve.models)

    prg:ground({{"base", {}}}, self)

    while count > 0 do
        local m_lits = {}
        local it = prg:solve{yield=true}

        local ret, err = pcall(function()
            if not it:get().satisfiable then
                return
            end

            for m in it:iter() do
                if m.optimality_proven then
                    local lits = {}
                    for i, a in ipairs(m:symbols{atoms=true}) do
                        local s = prg.symbolic_atoms:lookup(clingo.Function(a.name, a.arguments))
                        table.insert(lits, s.literal)
                    end
                    table.insert(m_lits, lits)

                    count = count-1
                    if count == 0 then
                        it:cancel()
                    end
                end
            end
        end)
        it:close()
        if not ret then
            error(err)
        end

        for i, lits in ipairs(m_lits) do
            prg.backend:add_rule{{}, lits}
        end
    end
end
#end.
