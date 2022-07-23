local zaproszenia = {}
local max_people_in_org = 80 ---- MAKSYMALNA LICZBA LUDZI W ORGANIZACJI!
function findPlayer(plr,cel)
	local target=nil
	if (tonumber(cel) ~= nil) then
		for _,thePlayer in ipairs(getElementsByType("player")) do
			if getElementData(thePlayer,"player:sid") == tonumber(cel) then target = thePlayer end
		end
	else -- podano fragment nicku
		for _,thePlayer in ipairs(getElementsByType("player")) do
			if string.find(string.gsub(getPlayerName(thePlayer):lower(),"#%x%x%x%x%x%x", ""), cel:lower(), 0, true) then
				if (target) then
					outputChatBox("* Znaleziono wiecej niz jednego gracza o pasujacym nicku, podaj wiecej liter.", plr)
					return nil
				end
				target=thePlayer
			end
		end
	end
	if target and getElementData(target,"p:inv") then return nil end
	return target
end

addEvent("lidero:editUser", true)
addEventHandler("lidero:editUser", resourceRoot, function(text,rank,faction)
	local result1=exports["pystories-db"]:dbGet("SELECT * FROM pystories_users WHERE id=?", text)
	if not result1 or #result1 < 0 then outputChatBox("* Podany uĹĽytkownik nie istnieje w bazie danych.", client, 255, 0, 0) return end 
    local result2=exports["pystories-db"]:dbGet("SELECT * FROM ms_organizacje WHERE code=? AND uid=? LIMIT 1;", faction, text) -- pobieramy tylko JEDEN rekord
	if not result2 or #result2 < 0 then outputChatBox("* Podany uĹĽytkownik nie znajduje siÄ™ w tej organizacji",client,255,0,0) return end
	local ranke=exports["pystories-db"]:dbGet("SELECT * FROM ms_organizacje WHERE code=? AND uid=? LIMIT 1;", faction, getElementData(client,"player:sid")) -- pobieramy tylko JEDEN rekord
	if not ranke or #ranke < 0 then outputChatBox("* Nie znajdujesz siÄ™ w tej organizacji!",client,255,0,0) return end
	if tonumber(ranke[1].rank) <= 3 and (tonumber(rank) > 2) then outputChatBox("*Posiadasz za maĹ‚Ä… range!",client,255,0,0) return end
	local query1=exports["pystories-db"]:dbSet("UPDATE ms_organizacje SET rank=? WHERE uid=? AND code=?", rank, text, faction)
	if query1 then
	local resulted=exports["pystories-db"]:dbGet("SELECT * FROM ms_organizacje WHERE code=?", faction)
		triggerClientEvent(client,"lidero:refresh",resourceRoot,resulted)
		outputChatBox("* PomyĹ›lnie zmieniono rangÄ™ graczowi "..result1[1].login.." o id: "..faction.." na "..rank.." w organizacji.", client)
	end
	local target = findPlayer(client,text)
	if target then outputChatBox("* Twoja przynaleĹĽnoĹ›Ä‡ w organizacji: "..faction.." zostaĹ‚a zaaktualizowana. Aby odejĹ›Ä‡ wpisz /opusc.organizacje",target) end
end)
addEvent("lidero:addUser", true)
addEventHandler("lidero:addUser", resourceRoot, function(text,faction)
	if string.len(text) <= 0 then return end
	local result1=exports["pystories-db"]:dbGet("SELECT * FROM pystories_users WHERE id=?", text)
	if not result1 or #result1 < 0 then outputChatBox("* Podany uĹĽytkownik nie istnieje w bazie danych.", client, 255, 0, 0) return end
	local result2=exports["pystories-db"]:dbGet("SELECT * FROM ms_organizacje WHERE uid=? and code=?", text, faction)
	if result2 and #result2 > 0 then outputChatBox("* Podany uĹĽytkownik juĹĽ znajduje siÄ™ w tej organizacji.", client, 255, 0, 0) return end
	local result=exports["pystories-db"]:dbGet("SELECT * FROM ms_organizacje WHERE code=?", faction)
	if result and #result >= max_people_in_org then outputChatBox("* Posiadasz juĹĽ maksymalnÄ… liczbe ludzi w organizacji.", client, 255, 0, 0) return end
	local result3=exports["pystories-db"]:dbGet("SELECT * FROM ms_organizacje WHERE uid=?", text)
	if result3 and #result3 > 0 then outputChatBox("* Podany uĹĽytkownik juĹĽ znajduje siÄ™ w innej organizacji.", client, 255, 0, 0) return end
	local target=findPlayer(client,text)
	if target then
		if zaproszenia[target] then outputChatBox("** Gracz juĹĽ dostaĹ‚ zaproszenie !",client) return end
		if zaproszenia[target] and isTimer(zaproszenia[target][3]) then killTimer(zaproszenia[target][3]) end
		zaproszenia[target] = {faction,client,setTimer(function() zaproszenia[target] = nil end ,10000,1)}
		outputChatBox("* ZostaĹ‚eĹ›(aĹ›) zaproszony(a) do organizacji o nazwie :"..faction.." !",target,0,255,0)
		outputChatBox("* Masz 10 sekund na zaakceptowanie zaproszenia! (Wpisz /akceptuj.organizacje)",target,0,255,0)
	end
end)
addEvent("lidero:deleteUser", true)
addEventHandler("lidero:deleteUser", resourceRoot, function(text,faction)
	local result1=exports["pystories-db"]:dbGet("SELECT * FROM pystories_users WHERE id=?", text)
	if not result1 or #result1 < 0 then outputChatBox("* Podany uĹĽytkownik nie istnieje w bazie danych.", client, 255, 0, 0) return end 
    local result2=exports["pystories-db"]:dbGet("SELECT * FROM ms_organizacje WHERE code=? AND uid=? LIMIT 1;", faction, text) -- pobieramy tylko JEDEN rekord
	if not result2 or #result2 < 0 then outputChatBox("*Podany uĹĽytkownik nie znajduje siÄ™ w tej organizacji !",client,255,0,0) return end
	local query1=exports["pystories-db"]:dbSet("DELETE FROM ms_organizacje WHERE uid=? AND code=?",text, faction)
	local resulted=exports["pystories-db"]:dbGet("SELECT * FROM ms_organizacje WHERE code=?", faction)
	triggerClientEvent(client,"lidero:refresh",resourceRoot,resulted)
	outputChatBox("* PomyĹ›lnie usunieto gracza "..result1[1].login.." o SID: "..text.." z organizacji" , client)
	local target = findPlayer(client,text)
	if target then outputChatBox("* Twoja przynaleĹĽnoĹ›Ä‡ w organizacji: "..faction.." zostaĹ‚a zaaktualizowana.",target); setElementData(target,"player:organization",false) end
end)

function panel(plr,cmd,...)
	local uid=getElementData(plr,"player:sid")
	if not uid then return end
	local code=getElementData(plr,"player:organization")
	if not code then return end
    local result=exports["pystories-db"]:dbGet("SELECT * FROM ms_organizacje WHERE code=? AND uid=? LIMIT 1;", code, uid) -- pobieramy tylko JEDEN rekord
	if result and #result > 0 then
		if result[1].rank <= 2 then outputChatBox("* Brak uprawnieĹ„ do panelu organizacji !",plr) return end
	local resulted=exports["pystories-db"]:dbGet("SELECT * FROM ms_organizacje WHERE code=?", code)
		triggerClientEvent(plr, "lidero:showGUI", resourceRoot,code, resulted)
	end
end

addCommandHandler("panel.organizacji", panel)

addCommandHandler("akceptuj.organizacje",function (plr,cmd)
	local uid=getElementData(plr,"player:sid")
	if not uid then return end
	if not zaproszenia[plr] then outputChatBox("* Nie masz zaproszenia do organizacji lub przedawniĹ‚o siÄ™ !",plr,255,0,0) return end
	local result1=exports["pystories-db"]:dbGet("SELECT * FROM pystories_users WHERE id=?", uid)
	if not result1 or #result1 < 0 then outputChatBox("* Nie wczytano twoich danych !", plr, 255, 0, 0) return end 
	local result=exports["pystories-db"]:dbGet("SELECT * FROM ms_organizacje WHERE uid=? and code=?", uid,  zaproszenia[plr][1])
	if result and #result > 0 then outputChatBox("* Podany uĹĽytkownik juĹĽ znajduje siÄ™ w tej organizacji.", client, 255, 0, 0) return end
	local result=exports["pystories-db"]:dbGet("SELECT * FROM ms_organizacje WHERE uid=?", uid)
	if result and #result > 0 then outputChatBox("* Podany uĹĽytkownik juĹĽ znajduje siÄ™ w innej organizacji.", client, 255, 0, 0) return end
	local query1=exports["pystories-db"]:dbSet("INSERT ms_organizacje (uid,login,code) VALUES (?,?,?)",uid,result1[1].login, zaproszenia[plr][1])
	if isElement(zaproszenia[plr][2]) then
	if isTimer(zaproszenia[plr][3]) then killTimer(zaproszenia[plr][3]) end
	local resulted=exports["pystories-db"]:dbGet("SELECT * FROM ms_organizacje WHERE code=?", zaproszenia[plr][1])
	triggerClientEvent(zaproszenia[plr][2],"lidero:refresh",resourceRoot,resulted)
	outputChatBox("* PomyĹ›lnie dodano gracza "..result1[1].login.." o SID: "..uid.." w organizacji na 1 poziom", zaproszenia[plr][2])
	end
	outputDebugString("ms_organizacje> Organizacja: "..zaproszenia[plr][1].." SID: "..uid)
	outputChatBox("* AkceptowaĹ‚eĹ›(aĹ›) zaproszenie do organizacji o nazwie: "..zaproszenia[plr][1]..". Aby odejĹ›Ä‡ wpisz /opusc.organizacje",plr) 
	setElementData(plr,"player:organization",zaproszenia[plr][1])
	exports['pystories-db']:dbSet("UPDATE ms_organizacje SET actived=curdate() WHERE uid=?", getElementData(plr,"player:sid"))
	zaproszenia[plr] = nil
end)
addCommandHandler("opusc.organizacje",function (plr,cmd)
	local uid=getElementData(plr,"player:sid")
	if not uid then return end
	local code=getElementData(plr,"player:organization")
	if not code then outputChatBox("* Nie posiadasz ĹĽadnej organizacji !",plr) return end
	local query1=exports["pystories-db"]:dbSet("DELETE FROM ms_organizacje WHERE uid=? AND code=?",uid, code)
	outputChatBox("* OpuĹ›ciĹ‚eĹ›(aĹ›) organizacje "..code.." !",plr); setElementData(plr,"player:organization",false)
	
end)


function globalMessage(plr, cmd, ...)
	if getElementData(plr,'player:mute') then outputChatBox('Posiadasz karÄ™ wyciszenia! UwaĹĽasz ĹĽe kara jest niesĹ‚uszna? Zaapeluj na forum mta-psrpg.xaa.pl.',plr) return end
	local frakcja=getElementData(plr,'player:organization')
	if not frakcja then
		return
	end
	local msg = table.concat ( { ... }, " " )
	local admins=getElementsByType('player')
	for i,v in pairs(admins) do
	local pfrakcje=getElementData(v,'player:organization')
		if frakcja == pfrakcje then
			outputChatBox("#007aff"..pfrakcje.."> #FFFFFF"..getPlayerName(plr):gsub("#%x%x%x%x%x%x","").."#FFFFFF:#FFFFFF "..msg:gsub("#%x%x%x%x%x%x",""), v,_,_,_,true)
		end
	end
		local desc = "[ORGANIZACJA] ["..getElementData(plr,"id").."]"..getPlayerName(plr):gsub("#%x%x%x%x%x%x","").."("..getElementData(plr,"player:organization").."): "..msg:gsub("#%x%x%x%x%x%x","")..""
		triggerEvent("admin:addText", resourceRoot, desc:gsub("#%x%x%x%x%x%x",""))
		outputServerLog(desc)
end
addCommandHandler("Organizacja", globalMessage)




addEventHandler("onResourceStart", root, function() 
local players=getElementsByType('player')
for _, p in pairs(players) do
bindKey(p, "o", "down", "chatbox", "Organizacja")
end
end)

addEventHandler( "onPlayerSpawn", getRootElement(),
    function (_)
	bindKey(source, "o", "down", "chatbox", "Organizacja")
    end
)

addEventHandler("onPlayerJoin",root,function()
	bindKey(source, "F4","down",panel)
end)
