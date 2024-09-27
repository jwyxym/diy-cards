blue=blue or {}

local m=42699999

----从这里到Duel.GetCrossFieldCard(256行)均为卡片格子转化系列使用函数

---IsLinkMarker转GetLinkMarker
function Card.GetLinkMarker(c)
    if not c:IsType(TYPE_LINK) then return false end
    local lk=0
    for i = 0, 8, 1 do
        local marker=1<<i
        if i~=4 and c:IsLinkMarker(marker) then lk=lk+marker end
    end
    return lk
end

function Card.NonGetLinkMarker(c)
    if not c:IsType(TYPE_LINK) then return false end
    return 0x1ef-c:GetLinkMarker()
end

function Card.NonIsLinkMarker(c,marker)
    if not c:IsType(TYPE_LINK) then return false end
    return c:NonGetLinkMarker()&marker~=0
end

---连接箭头转化斜率，暂时无用
function Card.GetLinkMarkerSlope(c)
    if not c:IsType(TYPE_LINK) then return false end
    local slope=0
    --(k=-A/B)
    if c:IsLinkMarker(0x101) then slope=slope+0x1 end --A=-B
    if c:IsLinkMarker(0x082) then slope=slope+0x2 end --A=0
    if c:IsLinkMarker(0x044) then slope=slope+0x4 end --A=B
    if c:IsLinkMarker(0x028) then slope=slope+0x8 end --B=0
    if slope==0 then return false end
    return slope
end

----以下函数(至256行)均涉及：把决斗区域想象成一个以中央卡为原点的平面直角坐标系，来获取坐标并进行处理

---获取从tp来看的c的坐标
function Card.GetRcSystemPoint(c,tp)
    if not c:IsLocation(0x0c) then return false end
    local point={}
    local cp=c:GetControler()
    if cp==tp then cp=-1 else cp=1 end
    local loc=c:GetLocation()
    local seq=c:GetSequence()
    if loc==LOCATION_MZONE then
        if seq<5 then
            point={(2-seq)*cp,1*cp}
        else
            point={((-2)*seq+11)*cp,0}
        end
    else
        if seq~=5 then
            point={(2-seq)*cp,2*cp}
        else
            point={3*cp,1*cp}
        end
        CheckLocation()
    end
    return point
end

---根据cp,loc,seq来确定根据tp来看的坐标
function Duel.GetRcSystemPoint(tp,cp,loc,seq)
    local point={}
    if cp==tp then cp=-1 else cp=1 end
    if loc==LOCATION_MZONE then
        if seq<5 then
            point={(2-seq)*cp,1*cp}
        else
            point={((-2)*seq+11)*cp,0}
        end
    else
        if seq~=5 then
            point={(2-seq)*cp,2*cp}
        else
            point={3*cp,1*cp}
        end
    end
    return point
end

function Card.afunc()
    local c=e:GetHandler()
    if c:NonGetLinkMarker()~=0 then
        local cpoint=c:GetRcSystemPoint(tp)
        local spzone={}
        if not c:IsLinkMarker(0x001) then table.insert(spzone,{cpoint[1]-1,cpoint[2]-1,0x001}) end
        if not c:IsLinkMarker(0x002) then table.insert(spzone,{cpoint[1],cpoint[2]-1,0x002}) end
        if not c:IsLinkMarker(0x004) then table.insert(spzone,{cpoint[1]+1,cpoint[2]-1,0x004}) end
        if not c:IsLinkMarker(0x008) then table.insert(spzone,{cpoint[1]-1,cpoint[2],0x008}) end
        if not c:IsLinkMarker(0x020) then table.insert(spzone,{cpoint[1]+1,cpoint[2],0x020}) end
        if not c:IsLinkMarker(0x040) then table.insert(spzone,{cpoint[1]-1,cpoint[2]+1,0x040}) end
        if not c:IsLinkMarker(0x080) then table.insert(spzone,{cpoint[1],cpoint[2]+1,0x080}) end
        if not c:IsLinkMarker(0x100) then table.insert(spzone,{cpoint[1]+1,cpoint[2]+1,0x100}) end
        local zone=0
        for i = 0, 1, 1 do
            if Duel.IsPlayerCanSpecialSummonMonster(tp,code,setcode,type,atk,def,level,race,attribute,pos,i) then
                for j = 0, 4, 1 do
                    if Duel.CheckLocation(i,LOCATION_MZONE,j) then
                        local zpoint=Duel.GetRcSystemPoint(tp,i,LOCATION_MZONE,j)
                        for k in ipairs(spzone) do
                            if zpoint[1]==spzone[k][1] and zpoint[2]==spzone[k][2] then
                                zone=zone+spzone[k][3]
                            end
                        end
                    end
                end
            end
        end
        return zone~=0
    end
end

function Card.loperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsLocation(0x04) and c:IsFaceup() and c:NonGetLinkMarker()~=0 then
		local cpoint=c:GetRcSystemPoint(tp)
		local spzone={}
		if not c:IsLinkMarker(0x001) then table.insert(spzone,{cpoint[1]-1,cpoint[2]-1,0x001}) end
		if not c:IsLinkMarker(0x002) then table.insert(spzone,{cpoint[1],cpoint[2]-1,0x002}) end
		if not c:IsLinkMarker(0x004) then table.insert(spzone,{cpoint[1]+1,cpoint[2]-1,0x004}) end
		if not c:IsLinkMarker(0x008) then table.insert(spzone,{cpoint[1]-1,cpoint[2],0x008}) end
		if not c:IsLinkMarker(0x020) then table.insert(spzone,{cpoint[1]+1,cpoint[2],0x020}) end
		if not c:IsLinkMarker(0x040) then table.insert(spzone,{cpoint[1]-1,cpoint[2]+1,0x040}) end
		if not c:IsLinkMarker(0x080) then table.insert(spzone,{cpoint[1],cpoint[2]+1,0x080}) end
		if not c:IsLinkMarker(0x100) then table.insert(spzone,{cpoint[1]+1,cpoint[2]+1,0x100}) end
		local zoneck=0
		for i = 0, 1, 1 do
			if Duel.IsPlayerCanSpecialSummonMonster(tp,60007131,nil,TYPES_TOKEN_MONSTER,0,3000,10,RACE_CYBERSE,ATTRIBUTE_LIGHT,POS_FACEUP,i) then
				for j = 0, 4, 1 do
					if Duel.CheckLocation(i,LOCATION_MZONE,j) then
						local zpoint=Duel.GetRcSystemPoint(tp,i,LOCATION_MZONE,j)
						for k in ipairs(spzone) do
							if zpoint[1]==spzone[k][1] and zpoint[2]==spzone[k][2] then
								table.insert(spzone[k],i)
								table.insert(spzone[k],j)
								zoneck=zoneck+spzone[k][3]
							end
						end
					end
				end
			end
		end
		if zoneck~=0 then
			local bck={false,false,false,false,false,false,false,false,false}
			for i = 0, 8, 1 do
				local marker=1<<i
				if i~=4 and zoneck&marker~=0 then bck[i+1]=true end
			end
			local op=aux.SelectFromOptions(tp,
			{bck[1],aux.Stringid(m,1)},
			{bck[2],aux.Stringid(m,2)},
			{bck[3],aux.Stringid(m,3)},
			{bck[4],aux.Stringid(m,4)},
			{false,aux.Stringid(m,9)},
			{bck[6],aux.Stringid(m,5)},
			{bck[7],aux.Stringid(m,6)},
			{bck[8],aux.Stringid(m,7)},
			{bck[9],aux.Stringid(m,8)})
			local cmarker=1<<(op-1)
			if not c:IsImmuneToEffect(e) then
				local e1=Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetRange(LOCATION_MZONE)
                e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
                e1:SetCode(EFFECT_LINK_SPELL_KOISHI)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                e1:SetValue(cmarker)
                c:RegisterEffect(e1)
				local mzone={}
				for k in ipairs(spzone) do
					if cmarker==spzone[k][3] then
						table.insert(mzone,spzone[k][4])
						table.insert(mzone,spzone[k][5])
						--break
					end
				end
				local token=Duel.CreateToken(tp,60007131)
				if Duel.SpecialSummon(token,0,tp,mzone[1],false,false,POS_FACEUP,1<<mzone[2]) then
					Duel.AdjustAll()
					if Duel.IsExistingMatchingCard(jiexikaA.exfilter,tp,LOCATION_MZONE,0,1,nil) then
						local g=Duel.GetMatchingGroup(aux.TRUE,tp,0x0c,0x0c,c)
						if #g>0 then
							--获得射线
							local line={}
							if cmarker&0x101~=0 then table.insert(line,{1,-1,(cpoint[1]*(-1)+cpoint[2]*(1)),cpoint[1],cpoint[2]}) end
							if cmarker&0x082~=0 then table.insert(line,{1,0,(cpoint[1]*(-1)),cpoint[1],cpoint[2]}) end
							if cmarker&0x044~=0 then table.insert(line,{1,1,(cpoint[1]*(-1)+cpoint[2]*(-1)),cpoint[1],cpoint[2]}) end
							if cmarker&0x028~=0 then table.insert(line,{0,1,(cpoint[2]*(-1)),cpoint[1],cpoint[2]}) end
							local rg=Group.CreateGroup()
							--判断射线是否包含卡片
							for tc in aux.Next(g) do
								local tpoint=tc:GetRcSystemPoint(tp)
								if line[1][1]*tpoint[1]+line[1][2]*tpoint[2]+line[1][3]==0 then
									if line[1][1]-line[1][2]==1 then
										if cmarker&0x080~=0 and tpoint[2]-line[1][5]>0 then rg:AddCard(tc) end
										if cmarker&0x002~=0 and tpoint[2]-line[1][5]<0 then rg:AddCard(tc) end
									elseif line[1][1]-line[1][2]==-1 then
										if cmarker&0x020~=0 and tpoint[1]-line[1][4]>0 then rg:AddCard(tc) end
										if cmarker&0x008~=0 and tpoint[1]-line[1][4]<0 then rg:AddCard(tc) end
									elseif line[1][1]-line[1][2]==2 then
										if cmarker&0x100~=0 and tpoint[1]-line[1][4]>0 then rg:AddCard(tc) end
										if cmarker&0x001~=0 and tpoint[1]-line[1][4]<0 then rg:AddCard(tc) end
									elseif line[1][1]-line[1][2]==0 then
										if cmarker&0x004~=0 and tpoint[1]-line[1][4]>0 then rg:AddCard(tc) end
										if cmarker&0x040~=0 and tpoint[1]-line[1][4]<0 then rg:AddCard(tc) end
									end
								end
							end
							if #rg>0 and Duel.SelectYesNo(tp,aux.Stringid(m,0)) then
								Duel.Destroy(rg,REASON_EFFECT)
							end
						end
					end
				end
			end
		end
	end
end

---根据卡片坐标和连接箭头确认：连接箭头的直线函数
--point[1],point[2]分别对应c的x,y参数
function Card.GetLinkedLine(c,tp)
    if not c:IsType(TYPE_LINK) then return false end
    local line={}
    local point=c:GetRcSystemPoint(tp)
    if not point then return false end
    if c:IsLinkMarker(0x101) then table.insert(line,{1,-1,(point[1]*(-1)+point[2]*(1)),point[1],point[2]}) end
    if c:IsLinkMarker(0x082) then table.insert(line,{1,0,(point[1]*(-1)),point[1],point[2]}) end
    if c:IsLinkMarker(0x044) then table.insert(line,{1,1,(point[1]*(-1)+point[2]*(-1)),point[1],point[2]}) end
    if c:IsLinkMarker(0x028) then table.insert(line,{0,1,(point[2]*(-1)),point[1],point[2]}) end
    return line
end

---获取连接怪兽箭头对应射线上的卡片组（包含自身）
function Card.GetLinkedHalfLineGroup(c)
    local rg=Group.CreateGroup()
    if not c:IsType(TYPE_LINK) then return rg end
    local tp=c:GetControler()
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,0x0c,0x0c,c)
    if #g==0 then return rg end
    local line=c:GetLinkedLine(tp)
    if #line==0 then return rg end
    for tc in aux.Next(g) do
        local tpoint=tc:GetRcSystemPoint(tp)
        for i in ipairs(line) do
            if line[i][1]*tpoint[1]+line[i][2]*tpoint[2]+line[i][3]==0 then
                if line[i][1]-line[i][2]==1 then
                    if c:IsLinkMarker(0x080) and tpoint[2]-line[i][5]>0 then rg:AddCard(tc) end
                    if c:IsLinkMarker(0x002) and tpoint[2]-line[i][5]<0 then rg:AddCard(tc) end
                elseif line[i][1]-line[i][2]==-1 then
                    if c:IsLinkMarker(0x020) and tpoint[1]-line[i][4]>0 then rg:AddCard(tc) end
                    if c:IsLinkMarker(0x008) and tpoint[1]-line[i][4]<0 then rg:AddCard(tc) end
                elseif line[i][1]-line[i][2]==2 then
                    if c:IsLinkMarker(0x100) and tpoint[1]-line[i][4]>0 then rg:AddCard(tc) end
                    if c:IsLinkMarker(0x001) and tpoint[1]-line[i][4]<0 then rg:AddCard(tc) end
                elseif line[i][1]-line[i][2]==0 then
                    if c:IsLinkMarker(0x004) and tpoint[1]-line[i][4]>0 then rg:AddCard(tc) end
                    if c:IsLinkMarker(0x040) and tpoint[1]-line[i][4]<0 then rg:AddCard(tc) end
                end
            end
        end
    end
    return rg
end

---获取连接怪兽箭头对应直线上的卡片组（包含自身）
function Card.GetLinkedLineGroup(c)
    local rg=Group.CreateGroup()
    if not c:IsType(TYPE_LINK) then return rg end
    local tp=c:GetControler()
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,0x0c,0x0c,c)
    if #g==0 then return rg end
    local line=c:GetLinkedLine(tp)
    if #line==0 then return rg end
    for tc in aux.Next(g) do
        local tpoint=tc:GetRcSystemPoint(tp)
        for i in ipairs(line) do
            if line[i][1]*tpoint[1]+line[i][2]*tpoint[2]+line[i][3]==0 then
                rg:AddCard(tc)
            end
        end
    end
    return rg
end

---获取以tp来看的两张卡连成的直线参数
function Card.GetCardLine(c,tc,tp)
    if c==tc then return false end
    local cpoint,tcpoint=c:GetRcSystemPoint(tp),tc:GetRcSystemPoint(tp)
    local j,k,p,q=cpoint[1],cpoint[2],tcpoint[1],tcpoint[2]
    return {q-k,j-p,k*p-j*q}
end

---获取两张卡连成的直线上经过的卡片（包含自身）
function Card.GetCardLineGroup(c,tc)
    local rg=Group.CreateGroup()
    if not (c:IsLocation(0x0c) and tc:IsLocation(0x0c)) or c==tc then return rg end
    local cg=Group.FromCards(c,tc)
    local tp=c:GetControler()
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,0x0c,0x0c,cg)
    if #g==0 then return rg end
    local line=c:GetCardLine(tc,tp)
    if #line==0 then return rg end
    local j,k,l=line[1],line[2],line[3]
    for rc in aux.Next(g) do
        local tpoint=rc:GetRcSystemPoint(tp)
        local p,q=tpoint[1],tpoint[2]
        if j==0 or k==0 then
            if (j*p+k*q+l)^2<0.25*(j*j+k*k) then rg:AddCard(rc) end
        else
            local spoint={{p-0.5,q-0.5},{p-0.5,q+0.5},{p+0.5,q-0.5},{p+0.5,q+0.5}}
            local zero,posn,negn=0,0,0
            for i in pairs(spoint) do
                local num=j*spoint[i][1]+k*spoint[i][2]+l
                if num==0 then
                    zero=zero+1
                elseif num>0 then
                    posn=posn+1
                else
                    negn=negn+1
                end
            end
            if posn*negn~=0 then rg:AddCard(rc) end
        end
    end
    return rg
end

---从这个只有2张卡的组中获取经过这两张卡的直线上所包含的组（包含自身）
function Group.GetGroupLineGroup(cg)
    local rg=Group.CreateGroup()
    if #cg~=2 or cg:FilterCount(Card.IsLocation,nil,LOCATION_ONFIELD)~=2 then return rg end
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,0x0c,0x0c,cg)
    if #g==0 then return rg end
    local c1,c2=cg:GetFirst(),cg:GetNext()
    local tp=c1:GetControler()
    local line=c1:GetCardLine(c2,tp)
    if #line==0 then return rg end
    local j,k,l=line[1],line[2],line[3]
    for rc in aux.Next(g) do
        local tpoint=rc:GetRcSystemPoint(tp)
        local p,q=tpoint[1],tpoint[2]
        if j==0 or k==0 then
            if (j*p+k*q+l)^2<0.25*(j*j+k*k) then rg:AddCard(rc) end
        else
            local spoint={{p-0.5,q-0.5},{p-0.5,q+0.5},{p+0.5,q-0.5},{p+0.5,q+0.5}}
            local zero,posn,negn=0,0,0
            for i in pairs(spoint) do
                local num=j*spoint[i][1]+k*spoint[i][2]+l
                if num==0 then
                    zero=zero+1
                elseif num>0 then
                    posn=posn+1
                else
                    negn=negn+1
                end
            end
            if posn*negn~=0 then rg:AddCard(rc) end
        end
    end
    return rg
end

---获取c的十字区域卡片组（包含自身）
function Card.GetCrossFieldCard(c,tp)
    local rg=Group.CreateGroup()
    if not c:IsLocation(0x0c) then return rg end
    if tp==nil then tp=c:GetControler() end
    local g=Duel.GetFieldGroup(tp,0x0c,0x0c)
    if #g==0 then return rg end
    local point=c:GetRcSystemPoint(tp)
    for tc in aux.Next(g) do
        local tpoint=tc:GetRcSystemPoint(tp)
        if math.abs(tpoint[1]-point[1])+math.abs(tpoint[2]-point[2])<=1 then
            rg:AddCard(tc)
        end
    end
    return rg
end

---获取以cp,loc,seq来看的十字区域卡片组（包含自身）
function Duel.GetCrossFieldCard(tp,cp,loc,seq)
    local g=Duel.GetFieldGroup(tp,0x0c,0x0c)
    local rg=Group.CreateGroup()
    if #g==0 then return rg end
    local point=Duel.GetRcSystemPoint(tp,cp,loc,seq)
    for tc in aux.Next(g) do
        local tpoint=tc:GetRcSystemPoint(tp)
        if math.abs(tpoint[1]-point[1])+math.abs(tpoint[2]-point[2])<=1 then
            rg:AddCard(tc)
        end
    end
    return rg
end

----Chkc简易写法
---if chkc then return chkc:Chkcc(e,tp,loc) and cm.tgcfilter(chkc) end
function Card.Chkcc(c,e,tp,loc)
    if type(tp)==nil then
        return c:IsCanBeEffectTarget(e) and c:IsLocation(loc)
    else
        return c:IsCanBeEffectTarget(e) and c:IsLocation(loc) and c:IsControler(tp)
    end
end

----泛用简写标准发动效果生成
function Effect.SetCTCRPC(e,category,typey,code,range,property,countlimit,cardm)
    if type(category)=="number" then
        e:SetCategory(category)
    end
    if type(typey)=="number" then
        e:SetType(typey)
    elseif type(typey)=="string" then
        if typey=="eta" then
            e:SetType(EFFECT_TYPE_ACTIVATE)
        elseif typey=="eti" then
            e:SetType(EFFECT_TYPE_IGNITION)
        elseif typey=="etto+s" then
            e:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
        elseif typey=="etto+f" then
            e:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
        elseif typey=="etqo" then
            e:SetType(EFFECT_TYPE_QUICK_O)
        elseif typey=="ettf+s" then
            e:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
        elseif typey=="ettf+f" then
            e:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
        elseif typey=="etc+s" then
            e:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
        elseif typey=="etc+f" then
            e:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
        elseif typey=="etqf" then
            e:SetType(EFFECT_TYPE_QUICK_F)
        end
    end
    if type(code)=="number" then
        e:SetCode(code)
    end
    if type(range)=="number" then
        e:SetRange(range)
    end
    if type(property)=="number" then
        e:SetProperty(property)
    end
    if type(countlimit)=="number" then
        if type(cardm)==nil then
            e:SetCountLimit(countlimit)
        else
            e:SetCountLimit(countlimit,cardm)
        end
    end
end

function Effect.SetCCTO(e,condition,cost,target,opreation)
    if type(condition)=="function" then
        e:SetCondition(condition)
    end
    if type(cost)=="function" then
        e:SetCost(cost)
    end
    if type(target)=="function" then
        e:SetTarget(target)
    end
    if type(opreation)=="function" then
        e:SetOperation(opreation)
    end
end

----泛用回手处理
function Card.RTOHANDsolve(c,tp)
    if Duel.SendtoHand(c,nil,REASON_EFFECT) then
        if tp==nil then tp=1-c:GetControler() end
        if c:IsLocation(0x02) then
            Duel.ConfirmCards(1-tp,c)
        end
        return true
    end
    return false
end

function Group.RTOHANDsolve(g,tp)
    if Duel.SendtoHand(g,nil,REASON_EFFECT) then
        if g:FilterCount(Card.IsLocation,nil,0x02)>0 then
            Duel.ConfirmCards(1-tp,g:Filter(Card.IsLocation,nil,0x02))
        end
        return true
    end
    return false
end

---SZONE数量确认，pzonecheck=true表示为检测灵摆格子
function Card.getszonechkc(c,tp,i)
    return c:IsControler(tp) and c:IsLocation(0x08) and c:GetSequence()==i
end

function Duel.GetSZoneCount(tp,c,pzonecheck)
    local n,ct=1,0
    if pzonecheck then n=4 end
    for i = 0, 4, n do
        if Duel.CheckLocation(tp,0x08,i) then
            ct=ct+1
        else
            if aux.GetValueType(c)=="Group" then
                if c:IsExists(Card.getszonechkc,1,nil,tp,i) then
                    ct=ct+1
                end
            elseif aux.GetValueType(c)=="Card" then
                if Card.getszonechkc(c,tp,i) then
                    ct=ct+1
                end
            end
        end
    end
    return ct
end

----泛用特招处理
---sfrom对应从哪里特招,sg对应可能要从场上离开的卡
---未知原因暂时无法使用，懒的检查了
-- function Card.SpecialSummonCk(c,e,tp,sfrom,sg,spos,stype,ck1,ck2,zone)
--     if spos==nil then spos=POS_FACEUP end
--     if stype==nil then stype=0 end
--     if ck1==nil then ck1=false end
--     if ck2==nil then ck2=false end
--     if zone==nil then zone=0xff end
--     if sfrom==nil then
--         return c:IsCanBeSpecialSummoned(e,stype,tp,ck1,ck2,spos,zone) and Duel.GetMZoneCount(tp,sg)>0
--     elseif sfrom==0 then
--         return c:IsCanBeSpecialSummoned(e,stype,tp,ck1,ck2,spos,zone)
--     else
--         return c:IsCanBeSpecialSummoned(e,stype,tp,ck1,ck2,spos,zone) and Duel.GetLocationCountFromEx(tp,tp,sg,c)>0
--     end
-- end