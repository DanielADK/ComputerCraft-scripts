----------------------------------------------------
--
-- ComputerCraft version: 1.5
-- Modpack: FTB direwolf20 1.4.7 (+ custom mods)
-- Creator: DanielADK
--
----------------------------------------------------
function selectSlot(slot)
	if actualslot ~= slot then
		turtle.select(slot)
		actualslot = slot
	end
end
function checkFuelAndRefill()
	if turtle.getFuelLevel() < 1000 then
		fuelRefill()
	end
end
function fuelRefill()
	for i=(trashCount+1),16 do
		if not (turtle.getItemCount(i) == 0) then
			selectSlot(i)
			turtle.refuel()
		end
	end
	selectSlot(1)
	return
end
function moveDown()
	while not turtle.down() do
		turtle.digDown()
		sleep(0.5)
	end
	consumption = consumption+1
end
function moveUp()
	while not turtle.up() do
		turtle.digUp()
		sleep(0.5)
	end
	consumption = consumption+1
end
function moveForward()
	while not turtle.forward() do
		turtle.dig()
		sleep(0.5)
	end
	consumption = consumption+1
end
function moveBack()
	while not turtle.back() do
		sleep(0.5)
	end
	consumption = consumption+1
end
function emptyTrunk()
	for i=(trashCount+1),16 do
		if not (turtle.getItemCount(i) == 0) then
			selectSlot(i)
			turtle.drop()
		end
	end
end
function countTrashItems()
	local count = 0
	for i=1,16 do
		if turtle.getItemCount(i) ~= 0 then
			count = count+1
		else
			return count
		end
	end
end
function countEmptySlots()
	count = 0
	for i=(trashCount+1),16 do
		if turtle.getItemCount(i) == 0 then
			count = count+1
		end
	end
	return count
end
function emptyTrashFromTrunk()
	for slot=1,trashCount do
		selectSlot(slot)
		for i=(trashCount+1),16 do
			if (turtle.getItemCount(i) ~= 0) and (turtle.compareTo(i)) then
				selectSlot(i)
				turtle.drop()
				selectSlot(slot)
			end
		end
	end
end
function letEmptyAtStart(x, v)
	turtle.turnRight()
	for i=0,x do
		moveForward()
	end
	turtle.turnLeft()
	if v ~= 0 then
		for av=0,(3*v) do
			moveUp()
		end
	end
	emptyTrunk()
	turtle.turnLeft()
	if v ~= 0 then
		for av=0,(3*v) do
			moveDown()
		end
	end
	for i=0,x do
		moveForward()
	end
	turtle.turnRight()
end
function moveToStart(x)
	turtle.turnRight()
	for i=0,x do
		moveForward()
	end
	turtle.turnLeft()
end
function checkUpDown()
	if turtle.detectUp() or turtle.detectDown() then
		down = false
		up = false
		for slot=1,trashCount do
			selectSlot(slot)

			if turtle.compareDown() then
				down = true
			end
			if turtle.compareUp() then
				up = true
			end	

			if turtle.getItemSpace(slot) < 2 then
				turtle.drop(turtle.getItemCount(slot)-1)
			end
		end

		if not down then
			turtle.digDown()
		end
		if not up then
			turtle.digUp()
		end
	end
end
function layer(lenght, width, height, v)
	s = 0
	repeat
		printStatus(lenght, width, height, v, s)

		for d=0,(lenght-2) do
			checkUpDown()
			moveForward()
		end
		checkUpDown()

		emptyTrashFromTrunk()
		if (s%2) == 1 then
			if countEmptySlots() < 2 then
				letEmptyAtStart(s-1, v)
			end
			if (s+1) ~= width then
				turtle.turnLeft()
				moveForward()
				turtle.turnLeft()
			end
		else
			turtle.turnRight()
			moveForward()
			turtle.turnRight()
		end
		s = s+1
	until s == width
	moveToStart(s-2)
	printStatus(lenght, width, height, v, s)
end
function printStatus(lenght, width, height, v, s)
	term.clear()
	term.setCursorPos(2,2)
	local act = v*width+s
	local total = height*width
	local pomer = act/total
	-- send status to ID
	string = "Height: "..v.."/"..height.." ["..(math.floor((pomer*100) * 100) / 100).."%]"
	rednet.send(6, string)
	print(string)
end
function calcFuelConsupmtion(lenght, width, height)
	return (lenght*width*height)+(height*width)*2
end

args = { ... }
if not (#args == 4) then
  print('Pouziti: kopej <lenght> <width> <height> <height-skip>')
  return
elseif not (tonumber(args[2]) % 2 == 0) then
  print('width musi byt sude cislo kvuli uspore paliva v navratove fazi.')
  return
end

trashCount = countTrashItems()
consumption = 0
lenght = tonumber(args[1])
width = tonumber(args[2])
height = tonumber(args[3])

if args[4] == nil then
	startHeight = 0
else
	startHeight = tonumber(args[4])
end
rednet.open("right")
selectSlot(1)

fuelRefill()
if calcFuelConsupmtion(lenght, width, height) > turtle.getFuelLevel() then
	print("Nedostatek paliva pro celý přenos. Stav: "..turtle.getFuelLevel().." / "..calcFuelConsupmtion(lenght, width, height))
	return
end

for v=startHeight,height do
	if v ~= 0 then
		for av=0,(3*v) do
			moveDown()
		end
	end
	layer(lenght, width, height, v)
	print("vrstva: "..v)
	if v ~= 0 then
		for av=0,(3*v) do
			moveUp()
		end
	end
	emptyTrunk()
	turtle.turnLeft()
	turtle.turnLeft()
end
