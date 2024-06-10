function GrappleCalc()

	local gPointer = memory.readword('WRAM', 0x0D32)
	local gSpeed = memory.readword('WRAM', 0x0D26)
	local gEndAngle = memory.readword('WRAM', 0x0CFA)
	local gVar = 0
	local mult = 0
	local multTwo = 0
	local varThree = 0
	local multThree = 0
	local multFour = 0
	local varFour = 0
	local xVar = 0
	local xVarTwo = 0

	if (gPointer == 0xC79D)	--swinging
	then
		if (gSpeed < 0x8000) --if grapple speed is positive
		then
			gSpeed = (gSpeed << 1) & 0xFFFF	--y index	$05EB
			gEndAngle = (XBA(gEndAngle) & 0x00FF) << 1
			gVar = memory.readword('BUS', 0xA0B443 + gEndAngle)
			if (gVar < 0x8000)	--positive
			then
				----------------calculate y swing-------------------------
				mult = gVar * (gSpeed & 0x00FF)	--$05F1
				multTwo = (XBA(gVar) & 0x00FF) * gSpeed
				varThree = (XBA(mult) & 0x00FF) + multTwo	--$05F2
				multThree = (XBA(gSpeed) & 0x00FF) * (gVar & 0x00FF)	--$4216
				varThree = varThree + multThree
				multFour = (XBA(gVar) & 0x00FF) * (XBA(gSpeed) & 0x00FF)
				varFour = (XBA(varThree) & 0x00FF) + multFour	--$05F3
				mult = (XBA(mult) & 0x00FF) + (XBA(varThree) & 0xFF00)	--$05F1
				gui.text(250, 150, string.format("↓: %d.%d", varFour, mult), 0xFFFFFF)	--print y speed

				----------------calculate x swing-------------------------
				xVar = bit.band(XBA(bit.lrshift(gSpeed, 1, 16)), 0x00FF)	--$12
				xVar = (xVar << 1) & 0xFFFF + xVar	--$12
				xVar = 0x40 - xVar	--$12
				xVarTwo = memory.readword('BUS', 0xA0B443 + (((XBA(memory.readword('WRAM', 0x0CFA)) & 0x00FF) - xVar & 0x00FF) << 1 & 0xFFFF))

				if (xVarTwo < 0x8000)	--if positive
				then
					gVar = xVarTwo	--$05E9
					mult = (gVar & 0x00FF) * (gSpeed & 0x00FF)	--$05F1
					multTwo = (XBA(gSpeed) & 0x00FF) * (gVar & 0x00FF)
					multThree = (XBA(mult) & 0x00FF) + multTwo
					multFour = (XBA(gSpeed) & 0x00FF) * (gVar & 0x00FF)
					varThree = (XBA(mult) & 0x00FF) + multFour--$05F2
					varFour = (XBA(gVar) & 0x00FF) * (XBA(gSpeed) & 0x00FF) + (XBA(varThree) & 0x00FF)	--$05F3
					mult = (XBA(mult) & 0x00FF) + (XBA(varThree) & 0xFF00)	--$05F1
					gui.text(250, 170, string.format("←: %d.%d", varFour, mult), 0xFFFFFF)	--print x-speed
				else	--negative
					gVar = (xVarTwo ^ 0xFFFF) + 1	--$05E9
					mult = (gVar & 0x00FF) * (gSpeed & 0x00FF)	--$05F1
					multTwo = (XBA(gSpeed) & 0x00FF) * (gVar &0x00FF)
					multThree = (XBA(mult) & 0x00FF) + multTwo
					multFour = (XBA(gSpeed) & 0x00FF) * (gVar & 0x00FF)
					varThree = (XBA(mult) & 0x00FF) + multFour--$05F2
					varFour = (XBA(gVar) & 0x00FF) * (XBA(gSpeed) & 0x00FF) + (XBA(varThree) & 0x00FF)	--$05F3
					mult = (XBA(mult) & 0x00FF) + (XBA(varThree) & 0xFF00)	--$05F1
					gui.text(250, 170, string.format("←: %d.%d", varFour, mult), 0xFFFFFF)	--print x-speed
				end
			else	--negative
				----------------calculate y swing-------------------------
				gVar = (gVar ^ 0xFFFF) + 1	--phy	$05E9
				mult = gVar * (gSpeed & 0x00FF)	--$05F1
				multTwo = (XBA(gVar) & 0x00FF) * gSpeed
				varThree = (XBA(mult) & 0x00FF) + multTwo	--$05F2
				multThree = (XBA(gSpeed) & 0x00FF) * (gVar & 0x00FF)	--$4216
				varThree = varThree + multThree
				multFour = (XBA(gVar) & 0x00FF) * (XBA(gSpeed) & 0x00FF)
				varFour = (XBA(varThree) & 0x00FF) + multFour	--$05F3
				mult = (XBA(mult) & 0x00FF) + (XBA(varThree) & 0xFF00)	--$05F1
				gui.text(250, 150, string.format("↑: %d.%d", varFour, mult), 0xFFFFFF)	--print y speed

				----------------calculate x swing-------------------------
				xVar = XBA(bit.lrshift(gSpeed, 1, 16)) && 0x00FF	--$12
				xVar = ((xVar << 1) & 0xFFFF) + xVar	--$12
				xVar = 0x40 - xVar	--$12
				xVarTwo = memory.readword('BUS', 0xA0B443 + (((XBA(memory.readword('WRAM', 0x0CFA)) & 0x00FF) - xVar & 0x00FF << 1) & 0xFFFF))


				if (xVarTwo < 0x8000)	--if positive
				then
					gVar = xVarTwo	--$05E9
					mult = (gVar & 0x00FF) * (gSpeed & 0x00FF)	--$05F1
					multTwo = (XBA(gSpeed) & 0x00FF) * (gVar &0x00FF)
					multThree = (XBA(mult) & 0x00FF) + multTwo
					multFour = (XBA(gSpeed) & 0x00FF) * (gVar & 0x00FF)
					varThree = (XBA(mult) & 0x00FF) + multFour--$05F2
					varFour = (XBA(gVar) & 0x00FF) * (XBA(gSpeed) & 0x00FF) + (XBA(varThree) & 0x00FF)	--$05F3
					mult = (XBA(mult) & 0x00FF) + (XBA(varThree) & 0xFF00)	--$05F1
					gui.text(250, 170, string.format("←: %d.%d", varFour, mult), 0xFFFFFF)	--print x-speed
				else	--negative
					gVar = (xVarTwo ^ 0xFFFF) + 1	--$05E9
					mult = (gVar & 0x00FF) * (gSpeed & 0x00FF)	--$05F1
					multTwo = (XBA(gSpeed) & 0x00FF) * (gVar &0x00FF)
					multThree = (XBA(mult) & 0x00FF) + multTwo
					multFour = (XBA(gSpeed) & 0x00FF) * (gVar & 0x00FF)
					varThree = (XBA(mult) & 0x00FF) + multFour--$05F2
					varFour = (XBA(gVar) & 0x00FF) * (XBA(gSpeed) & 0x00FF) + (XBA(varThree) & 0x00FF)	--$05F3
					mult = (XBA(mult) & 0x00FF) + (XBA(varThree) & 0xFF00)	--$05F1
					gui.text(250, 170, string.format("←: %d.%d", varFour, mult), 0xFFFFFF)	--print x-speed
				end
			end
		else --if grapple speed is negative
			gSpeed = ((gSpeed ^ 0xFFFF) + 1 << 1) & 0xFFFF	--y index	$05EB
			gEndAngle = ((XBA(gEndAngle) & 0x00FF) << 1) & 0xFFFF
			gVar = memory.readword('BUS', 0xA0B443 + gEndAngle)

			if (gVar > 0x8000)	--negative
			then
				----------------calculate y swing-------------------------
				gVar = (gVar ^ 0xFFFF) + 1	--phy	$05E9
				mult = gVar * (gSpeed & 0x00FF)	--$05F1
				multTwo = (XBA(gVar) & 0x00FF) * gSpeed
				varThree = (XBA(mult) & 0x00FF) + multTwo	--$05F2
				multThree = (XBA(gSpeed) & 0x00FF) * (gVar & 0x00FF)	--$4216
				varThree = varThree + multThree
				multFour = (XBA(gVar) & 0x00FF) * (XBA(gSpeed) & 0x00FF)
				varFour = (XBA(varThree) & 0x00FF) + multFour	--$05F3
				mult = (XBA(mult) & 0x00FF) + (XBA(varThree) & 0xFF00)	--$05F1
				gui.text(250, 150, string.format("↓: %d.%d", varFour, mult), 0xFFFFFF)	--print y speed

				----------------calculate x swing-------------------------
				xVar = XBA(bit.lrshift(gSpeed, 1, 16)) & 0x00FF	--$12
				xVar = ((xVar << 1) & 0xFFFF) + xVar	--$12
				xVar = 0x40 - xVar	--$12
				xVarTwo = memory.readword('BUS', 0xA0B443 + bit.lshift(bit.band(bit.band(XBA(memory.readword('WRAM', 0x0CFA)), 0x00FF) - xVar, 0x00FF), 1, 16))


				if (xVarTwo < 0x8000)	--if positive
				then
					gVar = xVarTwo	--$05E9
					mult = bit.band(gVar, 0x00FF) * bit.band(gSpeed, 0x00FF)	--$05F1
					multTwo = bit.band(XBA(gSpeed), 0x00FF) * bit.band(gVar,0x00FF)
					multThree = bit.band(XBA(mult), 0x00FF) + multTwo
					multFour = bit.band(XBA(gSpeed), 0x00FF) * bit.band(gVar, 0x00FF)
					varThree = bit.band(XBA(mult), 0x00FF) + multFour--$05F2
					varFour = bit.band(XBA(gVar), 0x00FF) * bit.band(XBA(gSpeed), 0x00FF) + bit.band(XBA(varThree), 0x00FF)	--$05F3
					mult = bit.band(XBA(mult), 0x00FF) + bit.band(XBA(varThree), 0xFF00)	--$05F1
					gui.text(250, 170, string.format("→: %d.%d", varFour, mult), 0xFFFFFF)	--print x-speed
				else	--negative
					gVar = bit.bxor(xVarTwo, 0xFFFF) + 1	--$05E9
					mult = bit.band(gVar, 0x00FF) * bit.band(gSpeed, 0x00FF)	--$05F1
					multTwo = bit.band(XBA(gSpeed), 0x00FF) * bit.band(gVar,0x00FF)
					multThree = bit.band(XBA(mult), 0x00FF) + multTwo
					multFour = bit.band(XBA(gSpeed), 0x00FF) * bit.band(gVar, 0x00FF)
					varThree = bit.band(XBA(mult), 0x00FF) + multFour--$05F2
					varFour = bit.band(XBA(gVar), 0x00FF) * bit.band(XBA(gSpeed), 0x00FF) + bit.band(XBA(varThree), 0x00FF)	--$05F3
					mult = bit.band(XBA(mult), 0x00FF) + bit.band(XBA(varThree), 0xFF00)	--$05F1
					gui.text(250, 170, string.format("→: %d.%d", varFour, mult), 0xFFFFFF)	--print x-speed
				end
			else	--positive
				----------------calculate y swing-------------------------
				mult = gVar * bit.band(gSpeed, 0x00FF)	--$05F1
				multTwo = bit.band(XBA(gVar), 0x00FF) * gSpeed
				varThree = bit.band(XBA(mult), 0x00FF) + multTwo	--$05F2
				multThree = bit.band(XBA(gSpeed), 0x00FF) * bit.band(gVar, 0x00FF)	--$4216
				varThree = varThree + multThree
				multFour = bit.band(XBA(gVar), 0x00FF) * bit.band(XBA(gSpeed), 0x00FF)
				varFour = bit.band(XBA(varThree), 0x00FF) + multFour	--$05F3
				mult = bit.band(XBA(mult), 0x00FF) + bit.band(XBA(varThree), 0xFF00)	--$05F1
				gui.text(250, 150, string.format("↑: %d.%d", varFour, mult), 0xFFFFFF)	--print y-speed

				----------------calculate x swing-------------------------
				xVar = bit.band(XBA(bit.lrshift(gSpeed, 1, 16)), 0x00FF)	--$12
				xVar = bit.lshift(xVar, 1, 16) + xVar	--$12
				xVar = 0x40 - xVar	--$12
				xVarTwo = memory.readword('BUS', 0xA0B443 + bit.lshift(bit.band(bit.band(XBA(memory.readword('WRAM', 0x0CFA)), 0x00FF) - xVar, 0x00FF), 1, 16))


				if (xVarTwo < 0x8000)	--if positive
				then
					gVar = xVarTwo	--$05E9
					mult = bit.band(gVar, 0x00FF) * bit.band(gSpeed, 0x00FF)	--$05F1
					multTwo = bit.band(XBA(gSpeed), 0x00FF) * bit.band(gVar,0x00FF)
					multThree = bit.band(XBA(mult), 0x00FF) + multTwo
					multFour = bit.band(XBA(gSpeed), 0x00FF) * bit.band(gVar, 0x00FF)
					varThree = bit.band(XBA(mult), 0x00FF) + multFour--$05F2
					varFour = bit.band(XBA(gVar), 0x00FF) * bit.band(XBA(gSpeed), 0x00FF) + bit.band(XBA(varThree), 0x00FF)	--$05F3
					mult = bit.band(XBA(mult), 0x00FF) + bit.band(XBA(varThree), 0xFF00)	--$05F1
					gui.text(250, 170, string.format("→: %d.%d", varFour, mult), 0xFFFFFF)	--print x-speed
				else	--negative
					gVar = bit.bxor(xVarTwo, 0xFFFF) + 1	--$05E9
					mult = bit.band(gVar, 0x00FF) * bit.band(gSpeed, 0x00FF)	--$05F1
					multTwo = bit.band(XBA(gSpeed), 0x00FF) * bit.band(gVar,0x00FF)
					multThree = bit.band(XBA(mult), 0x00FF) + multTwo
					multFour = bit.band(XBA(gSpeed), 0x00FF) * bit.band(gVar, 0x00FF)
					varThree = bit.band(XBA(mult), 0x00FF) + multFour--$05F2
					varFour = bit.band(XBA(gVar), 0x00FF) * bit.band(XBA(gSpeed), 0x00FF) + bit.band(XBA(varThree), 0x00FF)	--$05F3
					mult = bit.band(XBA(mult), 0x00FF) + bit.band(XBA(varThree), 0xFF00)	--$05F1
					gui.text(250, 170, string.format("→: %d.%d", varFour, mult), 0xFFFFFF)	--print x-speed
				end
			end
		end
	end
end

function XBA(twobyte)

	local lowXBA = bit.lshift(bit.band(twobyte, 0x00FF), 8, 16)
	local highXBA = bit.lrshift(bit.band(twobyte, 0xFF00), 8, 16)
	return lowXBA + highXBA

end

function on_paint()

GrappleCalc()
end
