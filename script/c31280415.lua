--奏绝的独唱
local s,id,o=GetID()
function s.initial_effect(c)
	--适配
    local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(id)
	e0:SetRange(LOCATION_FZONE)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0:SetTargetRange(1,0)
	c:RegisterEffect(e0)
	--发动
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.pentg)
	e1:SetOperation(s.penop)
	c:RegisterEffect(e1)
	--发动封锁   
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(s.limcon)
	e2:SetOperation(s.limop1)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EVENT_CHAIN_END)
	e3:SetOperation(s.limop2)
	c:RegisterEffect(e3)
	--墓地灵摆    
    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SPSUMMON_PROC_G)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCondition(s.PendGraveCondition())
	e4:SetOperation(s.PendGraveOperation())
	e4:SetValue(SUMMON_TYPE_PENDULUM)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(LOCATION_SZONE,0)
	e5:SetTarget(s.eftg)
	e5:SetLabelObject(e4) 
	c:RegisterEffect(e5)
end
function s.penfilter(c)
	return c:IsSetCard(0x3ca1) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.penfilter,tp,LOCATION_DECK,0,1,nil) 
    	and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) end
end
function s.desfilter(c)
	return c:IsFaceup() and c:GetOriginalType()&TYPE_MONSTER>0
end    
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.penfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		if Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true) 
        	and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil) 
            and Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil)
            and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        	Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local g1=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
            if g1:GetCount()<=0 then return end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local g2=Duel.SelectMatchingCard(tp,s.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
            if g2:GetCount()<=0 then return end
            g1:Merge(g2)
            Duel.HintSelection(g1)
            Duel.Destroy(g1,REASON_EFFECT)
        end
	end
end
function s.limfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:IsFaceup() and c:IsSetCard(0x3ca1)
end
function s.limcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.limfilter,1,nil,tp)
end
function s.limop1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetCurrentChain()==0 then
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	elseif Duel.GetCurrentChain()==1 then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(s.resetop)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.chainlm(e,rp,tp)
	return tp==rp
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(id)
	e:Reset()
end
function s.limop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(id)~=0 then
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	end
	e:GetHandler():ResetFlagEffect(id)
end
function s.eftg(e,c)
	return c:IsType(TYPE_PENDULUM) and c:IsLocation(LOCATION_PZONE)
end
--灵摆召唤
function s.PConditionFilter(c,e,tp,lscale,rscale,eset)
	local lv=0
	if c.pendulum_level then
		lv=c.pendulum_level
	else
		lv=c:GetLevel()
	end
	local bool=aux.PendulumSummonableBool(c)
	return (c:IsLocation(LOCATION_HAND+LOCATION_GRAVE) or (c:IsFaceup() and c:IsType(TYPE_PENDULUM)))
		and lv>lscale and lv<rscale and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_PENDULUM,tp,bool,bool) and not c:IsForbidden()
		and (aux.PendulumChecklist&(0x1<<tp)==0 or aux.PConditionExtraFilter(c,e,tp,lscale,rscale,eset))
end
function s.PConditionExtraFilter(c,e,tp,lscale,rscale,eset)
	local lv=0
	if c.pendulum_level then
		lv=c.pendulum_level
	else
		lv=c:GetLevel()
	end
	local bool=aux.PendulumSummonableBool(c)
	return lv>lscale and lv<rscale and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_PENDULUM,tp,bool,bool) and not c:IsForbidden()
end
function s.PendGraveCondition(tp)
	return  function(e,c,og)
		if c==nil then return true end
		local tp=c:GetControler()
		local eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_EXTRA_PENDULUM_SUMMON)}
		if aux.PendulumChecklist&(0x1<<tp)~=0 and #eset==0 then return false end
		local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
		if rpz==nil or c==rpz then return false end
		local lscale=c:GetLeftScale()
		local rscale=rpz:GetRightScale()
		if lscale>rscale then lscale,rscale=rscale,lscale end
		local loc=0
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_HAND end
		if Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)>0 then loc=loc+LOCATION_EXTRA end
		if loc==0 then return false end
		local g=nil
		if og then
			g=og:Filter(Card.IsLocation,nil,loc)
		else
			g=Duel.GetFieldGroup(tp,loc,0)
		end
		local pg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
		g:Merge(pg)
		return g:IsExists(s.PConditionFilter,1,nil,e,tp,lscale,rscale,eset)
	end
end
function s.PendGraveOperation(tp)
	return  function(e,tp,eg,ep,ev,re,r,rp,c,sg,og)
		local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
		local lscale=c:GetLeftScale()
		local rscale=rpz:GetRightScale()
		if lscale>rscale then lscale,rscale=rscale,lscale end
		local eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_EXTRA_PENDULUM_SUMMON)}
		local tg=nil
		local loc=0
		local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local ft2=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)
		local ft=Duel.GetUsableMZoneCount(tp)
		local ect=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
		if ect and ect<ft2 then ft2=ect end
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then
			if ft1>0 then ft1=1 end
			if ft2>0 then ft2=1 end
			ft=1
		end
		if ft1>0 then loc=loc|LOCATION_HAND end
		if ft2>0 then loc=loc|LOCATION_EXTRA end
		if og then
			tg=og:Filter(Card.IsLocation,nil,loc):Filter(s.PConditionFilter,nil,e,tp,lscale,rscale,eset)
		else
			tg=Duel.GetMatchingGroup(s.PConditionFilter,tp,loc,0,nil,e,tp,lscale,rscale,eset)
		end
		local ce=nil
		local b1=aux.PendulumChecklist&(0x1<<tp)==0
		local b2=#eset>0
		if b1 and b2 then
			local options={1163}
			for _,te in ipairs(eset) do
				table.insert(options,te:GetDescription())
			end
			local op=Duel.SelectOption(tp,table.unpack(options))
			if op>0 then
				ce=eset[op]
			end
		elseif b2 and not b1 then
			local options={}
			for _,te in ipairs(eset) do
				table.insert(options,te:GetDescription())
			end
			local op=Duel.SelectOption(tp,table.unpack(options))
			ce=eset[op+1]
		end
		if ce then
			tg=tg:Filter(aux.PConditionExtraFilterSpecific,nil,e,tp,lscale,rscale,ce)
		end
        local pg=Duel.GetMatchingGroup(s.PConditionExtraFilter,tp,LOCATION_GRAVE,0,nil,e,tp,lscale,rscale,eset)
		tg:Merge(pg)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		aux.GCheckAdditional=aux.PendOperationCheck(ft1,ft2,ft)
		local g=tg:SelectSubGroup(tp,Auxiliary.TRUE,true,1,math.min(#tg,ft))
		aux.GCheckAdditional=nil
		if not g then return end
		if ce then
			Duel.Hint(HINT_CARD,0,ce:GetOwner():GetOriginalCode())
			ce:UseCountLimit(tp)
		else
			aux.PendulumChecklist=aux.PendulumChecklist|(0x1<<tp)
		end
		sg:Merge(g)
		Duel.HintSelection(Group.FromCards(c))
		Duel.HintSelection(Group.FromCards(rpz))
	end
end