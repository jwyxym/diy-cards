if lanp then return end
if not pcall(function() require("expansions/script/c11451919") end) then require("script/c11451919") end
lanc,lang,lane,lans,lanm = {},{},{},{},{}
----------------------------lanp-----------------------------------
function lanp.OP(mat_operation,tg,operation_params)
    for i=1,#operation_params do
        if type(operation_params[i]) == "string" then 
            local az=operation_params[i]
            operation_params[i] = 0
            for _,V in ipairs(lanf.CutString(az,"+")) do
			    operation_params[i] = operation_params[i] + lanp.rea[string.upper(V)]
			end
		end
    end
    return mat_operation(tg,table.unpack(operation_params))
end
function lanp.CC(str,name)
    local offset=self_code<100000000 and 1 or 100
    if type(str) == "string" then
	    self_table.setcard = { }
	    for _,V in ipairs(lanf.CutString(str,"+")) do
            local a=self_table.setcard
            a[#a+1] = V
			lans[self_code] = a
		end  
	end
	if type(name) == "string" then
	    self_table.name = name
	    lanm[self_code] = self_table.name
	end
	return self_table,self_code,offset
end
function lanp.RFE(py,cod,res,pro,ct,lab,desc)
    if type(py) == "Card" then Debug.Message("okk") end
    if not py then py = 0 end
    if not res then res=0 end
    if not pro then pro=0
    elseif type(pro) == "string" then 
        local val = 0
        for _,V in ipairs(lanf.CutString(pro,"+")) do
		    val = val + lanp.pro[string.upper(V)]
        end
        pro=val
    end
    if not ct then ct1 =1 end
    if not lab then lab = 0 end
    if desc and type(desc) == "table" then desc=aux.Stringid(desc[1],desc[2]) end
    if type(py) == "number" then return Duel.RegisterFlagEffect(py,cod,res,pro,ct,lab)
    else return py:RegisterFlagEffect(cod,res,pro,ct,lab,desc) end
end
function lanp.YN(tp,m,desc)
    local az=nil
    if desc then az=aux.Stringid(m,desc) 
    else az=m end
    return Duel.SelectYesNo(tp,az)
end
function lanp.SO(cha,cat,g,ct,py,loc)
    local val=loc
    if type(val) == "string" then
        loc=0
		for _,V in ipairs(lanf.CutString(val,"+")) do
			loc = loc + lanp.ran[string.upper(V)]
		end
	end
    return Duel.SetOperationInfo(cha,lanp.cat[cat],g,ct,py,loc)
end
function lanp.H(typ,py,desc)
    typ= lanf.msg(typ)
    if typ == lanp.msg["S"] then desc = lanf.msg(desc) end
    return Duel.Hint(typ,py,desc)
end
function lanp.SelectOption(a,b,c,d,tp)
    local off=1
    local ops={}
    local opval={}
    if type(c) == "table" then c=aux.Stringid(c[1],c[2]) end
    if type(d) == "table" then d=aux.Stringid(d[1],d[2]) end
    if a then
    ops[off]=c
    opval[off]=0
    off=off+1
    end
    if b then
	    ops[off]=d
	    opval[off]=1
	    off=off+1
	end
	local op=Duel.SelectOption(tp,table.unpack(ops))+1
	local sel=opval[op]
	return sel
end
function lanp.U(v,...)
    local c
    if v=="设置卡" then c={lanp.CC(...)}
    elseif v=="标识" then c={lanp.RFE(...)}
    elseif v=="连锁信息" then c={lanp.SO(...)}
    elseif v=="效果处理" then c={lanp.OP(...)} 
    elseif v=="是否" then c={lanp.YN(...)}
    elseif v=="提示" then c={lanp.H(...)}
    elseif v=="选择" then c={lanp.SelectOption(...)}
    end
    return table.unpack(c)
end
----------------------------lanc-----------------------------------
function lanc.Filter(c,f,...)
	local v = {...}
	v = #v==1 and v[1] or v
	return lang.Filter(Group.FromCards(c),f,v,1)
end
function lanc.Compare(c,f,n,meth,...)
	if type(f) == "string" then f=lanc[f] or Card[f] or aux[f] end
	local v = {...}
	v = type(v[1]) =="table" and #v==1 and v[1] or v
	if meth == "A" then
		return f(c,table.unpack(v))>=n
	elseif meth == "B" then
		return f(c,table.unpack(v))<=n
	end
	return f(c,table.unpack(v))==n
end
function lanc.TgChk(c,e)
	return c:IsCanBeEffectTarget(e)
end
function lanc.GChk(c)
	return not c:IsHasEffect(EFFECT_NECRO_VALLEY)
end
function lanc.Not(c,val)
	if aux.GetValueType(val) == "Card" then
		return c ~= val
	elseif aux.GetValueType(val) == "Group" then
		return not val:IsContains(c)
	elseif aux.GetValueType(val) == "function" then
		return not val(c)
	end
	return false
end
function lanc.IsSet(c,set)
	if type(set) == "number" then return c:IsSetCard(set) end
	for _,Set in ipairs(lanf.CutString(set,"/")) do
		Set=tonumber(Set,16)
		if Set and c:IsSetCard(Set) then return true end
	end
	return false
end
function lanc.GetSeries(mt)
    if aux.GetValueType(mt) == "Card" then mt=lanf.GetMetaTable(mt)
    elseif type(mt)=="number" then mt=_G["c"..mt] end
    local tb={}
    for i=1,#mt do
        local a=mt[i]
        if a.setcard then
            for b=1,#a.setcard do
                tb[#tb+1]=a.setcard[b]
            end
        end
    end
    return tb
end
function lanc.GetName(mt)
    if aux.GetValueType(mt) == "Card" then mt=lanf.GetMetaTable(mt)
    elseif type(mt)=="number" then mt=_G["c"..mt] end
    local nm={}
    for i=1,#mt do
        local a=mt[i]
        if a.name then
            nm[#nm+1]=a.name
        end
    end
    return nm
end
function lanc.IsSeries(c,str,ck)
    local mt=nil
    if type(ck) == "string" and ck == "Original" then 
        mt = lanf.getmetatable(c)
        local ser=lanc.GetSeries(mt)
        for i=1,#ser do
            if ser[i] and ser[i]==str then return true end
        end
    else
        local ser=lanc.GetSeries(c)
        for i=1,#ser do
            if ser[i] and ser[i]==str then return true end
        end
    end
    return false
end
function lanc.IsName(c,str,ck)
    local mt=nil
    local check=false
    if type(ck) == "string" and ck == "Original" then 
        mt = lanf.getmetatable(c)
        if mt.name and mt.name == str then return true end
    else 
        nm=lanc.GetName(c)
        for i=1,#nm do
            if nm[i] and nm[i] == str then return true end
        end
    end
    return false
end
function lanc.AbleTo(c,loc)
	local func = {
		["H"] = "Hand"   ,
		["D"] = "Deck"   ,
		["G"] = "Grave"  ,
		["R"] = "Remove",
		["E"] = "Extra"  ,
	}
	local iscos = string.sub(loc,1,1) == "*"
	if iscos then loc = string.sub(loc,2) end
	func = "IsAbleTo"..func[loc]
	if iscos then func = func.."AsCost" end
	return Card[func](c)
end
function lanc.CanSp(c,e,typ,tp,nochk,nolimit,pos,totp,zone)
	return c:IsCanBeSpecialSummoned(e, typ, tp, nochk or false, nolimit or false, pos or POS_FACEUP, totp or tp,zone or 0xff)
end
function lanc.IsCod(c,cod)
	if type(cod) == "string" then cod = tonumber(cod) end
	return c:IsCode(cod)
end
function lanc.IsLoc(c,loc,ex)
    local az,a,b=nil,"Is","Location"
    if ex then az=a..ex..b else az=a..b end
	return Card[az](c,lanf.Loc(loc))
end
function lanc.CheckConstantValue(func,chktable)
	return function(c,cons)
		if cons and type(cons) ~= "string" then return func(c,cons) end
		local Cons, tStack = lanf.PostFix_Trans(cons), { }
		local CalL, CalR
		for _,val in ipairs(Cons) do
			if string.match(val, "[%-%~]") then
				tStack[#tStack] = not tStack[#tStack]
			elseif string.match(val, "[%+%/]") then
				CalR = table.remove(tStack)
				CalL = table.remove(tStack)
				local tCal = {
					["+"] = CalL and CalR,
					["/"] = CalL or CalR
				}
				table.insert(tStack, tCal[val])
			else
				table.insert(tStack, func(c,chktable[string.upper(val)]))
			end
		end
		return tStack[#tStack]
	end
end
function lanc.GetNumberCardInGroup(g,ct)
    local tc
    for i=1,ct do
        if i==1 then tc=g:GetFirst()
        else tc=g:GetNext() end
    end
    return tc
end
function lanc.IsOnGroup(c,g)
    return g:IsContains(c)
end
function lanc.IsHasVariableInGroup(c,g,f)
    for i=1,#g do
        local tc=lanc.GetNumberCardInGroup(g,i)
        if Group.FromCards(c,tc):GetClassCount(f)<=1 then return false end
    end
    return true
end
lanc.IsRea = lanc.CheckConstantValue(function(c,v) return c:IsReason(v) end,lanp.rea)
lanc.IsTyp = lanc.CheckConstantValue(function(c,v) return c:GetType()&v==v end,lanp.typ)
lanc.IsAtt = lanc.CheckConstantValue(function(c,v) return c:GetAttribute()&v==v end,lanp.att)
lanc.IsRac = lanc.CheckConstantValue(function(c,v) return c:GetRace()&v==v end,lanp.rac)
lanc.IsPos = lanc.CheckConstantValue(function(c,v) return c:IsPosition(v) end,lanp.pos)
lanc.IsNSeries = function(c,v,ck) return not lanc.IsSeries(c,v,ck) end
lanc.IsNName = function(c,v,ck) return not lanc.IsName(c,v,ck) end
----------------------------lang-----------------------------------
function lang.Get(p,loc)
    local locc=nil
    if type(loc)=="string" then locc=0
    elseif type(loc)=="table" then locc=lanf.Loc(loc[2]) loc=loc[1] end
	return Duel.GetFieldGroup(p,lanf.Loc(loc),locc)
end
function lang.Filter(g,f,v,n)
	local func, tStack, index = { }, { }, 1
	v = type(v) == "table" and v or { v }
	func = type(f) == "string" and lanf.PostFix_Trans(f,v) or { f }
	local var = lanf.Value_Trans(v)
	if #func==1 then
		if type(func[1]) == "string" then func[1] = lanc[func[1] ] or Card[func[1] ] or aux[func[1] ] end
		g = g:Filter(func[1],nil,table.unpack(var))
	else
		local CalL, CalR
		for _,val in ipairs(func) do
			if val == "~" then
				CalR = g - table.remove(tStack)
				table.insert(tStack, CalR)
			elseif type(val) == "string" and #val == 1 then
				CalR = table.remove(tStack)
				CalL = table.remove(tStack)
				local tCalc = {
					["+"] = CalL & CalR,
					["-"] = CalL - CalR,
					["/"] = CalL + CalR
				}
				table.insert(tStack, tCalc[val])
			else
				if type(val) == "string" then val = lanc[val] or Card[val] or aux[val] end
				local V = table.remove(var,1)
				V = V and (type(V) =="table" and V or {V}) or { }
				table.insert(tStack, g:Filter(val,nil,table.unpack(V)))
			end
		end
		g = table.remove(tStack)
	end
	if n then return #g>=n end
	return g
end
function lang.GetFilter(p,loc,f,v,n)
	return lang.Filter(lang.Get(p,loc),f,v,n)
end
function lang.SelectFilter(p,loc,f,v,c,min,max,sp)
    c = c or nil
	min=min or 1
	return lang.GetFilter(p,loc,f,v):Select(sp or p,min,max or min,c)
end
function lang.RandomSelectFilter(p,loc,f,v,c,ct,sp)
    ct = ct or 1
	return lang.GetFilter(p,loc,f,v):RandomSelect(sp or p,ct,c)
end
function lang.SelectTg(p,loc,f,v,c,min,max,sp)
	local g=lang.SelectFilter(p,loc,f,v,c,min,max,sp)
	Duel.SetTargetCard(g)
	return g
end
----------------------------lane-----------------------------------
function lane.Creat(owner,handler,...)
	local e = lane.Set(lanp.eff.CRE(lanf.GetCardTable(owner)[1]),...)
	if handler then lane.Register(e,handler) end
	return e
end
function lane.Global(owner,...)
    local ge = lane.Set(lanp.eff.GLE(lanf.GetCardTable(owner)[1]),...)
    lane.Register(ge,0)
    return ge
end
function lane.Clone(effect,handler,...)
	local e = lane.Set(lanp.eff.CLO(effect),...)
	if handler then lane.Register(e,handler) end
	return e
end
function lane.Set(e,...)
	e = type(e) == "table" and e or { e }
	local setlist = {...}
	if #setlist == 0 then return table.unpack(e) end
	if type(setlist[1]) ~= "table" then setlist = {setlist} end
	for _,E in ipairs(e) do
		for _,set in ipairs(setlist) do
			local f = type(set[1]) == "string" and lanp.eff[set[1] ] or set[1]
			table.remove(set,1)
			f(E,table.unpack(set))
		end
	end
	return e
end
function lane.Register(e,handler)
	handler = type(handler) == "table" and handler or { handler }
	local Ignore = handler[2] or false
	local Handler = type(handler[1]) == "number" and handler[1] or lanf.GetCardTable(handler[1])
	for _,E in ipairs(type(e) == "table" and e or {e}) do
		if type(Handler) == "number" then
			Duel.RegisterEffect(E,Handler)
		else
			for _,C in ipairs(Handler) do
				C:RegisterEffect(E,Ignore)
			end
		end
	end
end
--------------------------------------------------------------------------"Effect_Base"
--Action Effect
function lane.Act(typ,dis)
    local typ = lanf.typ(typ)
	return function(c,rc,...)
		local v, var = lanf.Value_Trans({...}), { }
		for i,val in ipairs(lanf.CutDis("DES,CAT,COD,PRO,RAN,CTL,CON,COS,TG,OP,RES,LAB,OBJ",dis)) do
			if val == "COD" then
				var[#var + 1] = { val , lanf.NotNil(v[i]) and v[i] or "FC" }
			elseif lanf.NotNil(v[i]) then
				var[#var + 1] = { val , v[i] }
			end
		end
		return lane.Creat(c,rc,{"TYP",typ},table.unpack(var))
	end
end  
--NoAction Effect
function lane.NoAct(typ,dis)
	return function(c,rc,...)
		local v, var = lanf.Value_Trans({...}), { }
		for i,val in ipairs(lanf.CutDis("DES,COD,PRO,RAN,TRAN,VAL,CTL,CON,TG,OP,RES,LAB,OBJ",dis)) do
			if lanf.NotNil(v[i]) then
				var[#var + 1] = { val , v[i] }
			end
		end
		return lane.Creat(c,rc,{"TYP",typ},table.unpack(var))
	end
end 
--Global Effect
function lane.Glo(typ,dis)
	return function(c,...)
		local v, var = lanf.Value_Trans({...}), { }
		for i,val in ipairs(lanf.CutDis("COD,PRO,CON,TG,OP,LAB,OBJ",dis)) do
			if lanf.NotNil(v[i]) then
				var[#var + 1] = { val , v[i] }
			end
		end
		return lane.Global(c,{"TYP",typ},table.unpack(var))
	end
end
--Cost
function lane.paycost(ct)
    return function(e,tp,eg,ep,ev,re,r,rp,chk)
	    if chk==0 then return Duel.CheckLPCost(tp,ct) end
	    Duel.PayLPCost(tp,ct)
	end
end
function lane.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
--Con
function lane.sptyp_con(sptyp)
    return	function(e,tp,eg,ep,ev,re,r,rp)
        local c=e:GetHandler()
	    return lanc.Filter(c,"IsSummonType",sptyp)
	end
end
lane.B_A = lane.Act(lanf.typ("A"),"RAN")
lane.A   = function(c,rc,cod) return lane.B_A(c,rc or c,",",cod) end
lane.I   = lane.Act(lanf.typ("I"),"")
lane.QO  = lane.Act(lanf.typ("QO"),"")
lane.QF  = lane.Act(lanf.typ("QF"),"")
lane.FTO = lane.Act(lanf.typ("F+TO"),"")
lane.FTF = lane.Act(lanf.typ("F+TF"),"")
lane.STO = lane.Act(lanf.typ("S+TO"),"RAN")
lane.STF = lane.Act(lanf.typ("S+TF"),"RAN")
lane.S   = lane.NoAct(lanf.typ("S"),"TRAN,TG")
lane.SC  = lane.NoAct(lanf.typ("S+C"),"RAN,TRAN,VAL,TG")
lane.F   = lane.NoAct(lanf.typ("F"),"")
lane.FC  = lane.NoAct(lanf.typ("F+C"),"TRAN,VAL,TG")
lane.FG  = lane.NoAct(lanf.typ("F+G"),"DES,COD,PRO,VAL,CTL,TG,OP")
lane.E   = lane.NoAct(lanf.typ("E"),"DES,RAN,TRAN,CTL,TG,OP")
lane.EC  = lane.NoAct(lanf.typ("S+C"),"DES,PRO,RAN,TRAN,VAL,CTL")
lane.GLO1 = lane.Glo(lanf.typ("F+C"),"PRO,TG,LAB,OBJ")
----------------------------lanf-----------------------------------
lanp.loaded_metatable_list=lanp.loaded_metatable_list or {}
function lanf.getmetatable(c)
    local code=c:GetOriginalCode()
	local m1=_G["c"..code]
	if m1 then return m1 end
	local m2=lanp.loaded_metatable_list[code]
	if m2 then return m2 end
	_G["c"..code]={}
	if pcall(function() dofile("expansions/script/c"..code..".lua") end) or pcall(function() dofile("script/c"..code..".lua") end) then
		local mt=_G["c"..code]
		_G["c"..code]=nil
		if mt then
			lanp.loaded_metatable_list[code]=mt
			return mt
		end
	else
		_G["c"..code]=nil
	end
end
function lanf.GetMetaTable(c)
    local code={c:GetCode()}
    local m={ }
    local mt={ }
    for i=1,#code do
	    mt[i]=_G["c"..code[i]]
	    lanp.loaded_metatable_list[code[i]]=mt[i]
	    m[i]=lanp.loaded_metatable_list[code[i]]
	end
	return mt
end