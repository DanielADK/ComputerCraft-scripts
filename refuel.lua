function fuelRefill()
    for i=1,16 do
        if not (turtle.getItemCount(i) == 0) then
            turtle.select(i)
            turtle.refuel()
        end
    end
end
fuelRefill()
print(turtle.getFuelLevel())
