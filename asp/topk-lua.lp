#script(lua)

function main(prg)
    local count = tonumber(prg.configuration.solve.models)
    local backend = prg:backend()

    local observer = {
        minimize_literals = {}
    }
    function observer:minimize (priority, literals)
        self.minimize_literals = literals
    end

    prg:register_observer(observer)

    prg:ground({{"base", {}}}, self)

    while count > 0 do
        local cost = 0

        prg.configuration.solve.models = count
        local it = prg:solve{yield=true}
        local ret, err = pcall(function()
            if it:get().unsatisfiable then
                count = 0
                return
            end

            for m in it:iter() do
                if m.optimality_proven then
                    cost = m.cost[1]
                    count = count-1
                end
            end
        end)
        it:close()
        if not ret then
            error(err)
        end

        if count > 0 then
            local aux = backend:add_atom()
            backend:add_weight_rule{{aux}, cost+1, observer.minimize_literals}
            backend:add_rule{{aux}, {-aux}}
        end
    end
end
#end.
