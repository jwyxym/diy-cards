--千年魔京！百鬼夜行！
function c66600026.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,66600026+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c66600026.op)
	c:RegisterEffect(e1)
	--change effect type
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(66600026)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(1,0)
	c:RegisterEffect(e2)
end
function c66600026.filter(c,tp)
	return c:IsSetCard(0x5660) and c:IsType(TYPE_PENDULUM) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function c66600026.op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c66600026.filter,tp,LOCATION_DECK,0,nil,tp)
	if g:CheckSubGroup(aux.dncheck,2) and Duel.SelectYesNo(tp,aux.Stringid(66600026,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
        for tc in aux.Next(sg) do
            Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
			tc:RegisterFlagEffect(66600026,RESET_EVENT+RESETS_STANDARD,0,1)
        end
        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e3:SetCode(EVENT_PHASE+PHASE_END)
        e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        e3:SetCountLimit(1)
        e3:SetOperation(c66600026.retop)
		e3:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e3,tp)
	end
	local tc=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetReset(RESET_PHASE+PHASE_END)
    e1:SetTargetRange(1,0)
    e1:SetTarget(c66600026.splimit)
    Duel.RegisterEffect(e1,tp)
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetDescription(1163)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_SPSUMMON_PROC_G)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_BOTH_SIDE)
    e2:SetRange(LOCATION_PZONE)
    e2:SetCondition(c66600026.pendcon)
    e2:SetOperation(c66600026.pendop)
    e2:SetValue(SUMMON_TYPE_PENDULUM)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e2)
end
function c66600026.splimit(e,c)
    return not c:IsSetCard(0x5660)
end
function c66600026.retop(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
    Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
function c66600026.pendfilter(c)
	return c:GetFlagEffect(66600026)>0
end
function c66600026.pendcon(e,c,og)
	if c==nil then return true end
	local tp=c:GetControler()
	local eset={Duel.IsPlayerAffectedByEffect(tp,EFFECT_EXTRA_PENDULUM_SUMMON)}
	if aux.PendulumChecklist&(0x1<<tp)~=0 and #eset==0 then return false end
	local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	if rpz==nil or c==rpz then return false end
	local loc=0
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_HAND end
	if Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)>0 then loc=loc+LOCATION_EXTRA end
	if loc==0 then return false end
	if Duel.GetMatchingGroupCount(c66600026.pendfilter,tp,LOCATION_PZONE,0,nil)>=2 then
		if c:IsSetCard(0x5660) then
			local lscale=c:GetLeftScale()+2
			local rscale=rpz:GetRightScale()
			if lscale>rscale then lscale,rscale=rscale,lscale end
			if c66600026.pendconcheck(og,loc,e,tp,lscale,rscale,eset) then return true end
		end
		if rpz:IsSetCard(0x5660) then
			local lscale=c:GetLeftScale()
			local rscale=rpz:GetRightScale()+2
			if lscale>rscale then lscale,rscale=rscale,lscale end
			if c66600026.pendconcheck(og,loc,e,tp,lscale,rscale,eset) then return true end
		end
	end
	local lscale=c:GetLeftScale()
	local rscale=rpz:GetRightScale()
	if lscale>rscale then lscale,rscale=rscale,lscale end
	return c66600026.pendconcheck(og,loc,e,tp,lscale,rscale,eset)
end
function c66600026.pendconcheck(og,loc,e,tp,lscale,rscale,eset)
	local g=nil
	if og then
		g=og:Filter(Card.IsLocation,nil,loc)
	else
		g=Duel.GetFieldGroup(tp,loc,0)
	end
	return g:IsExists(aux.PConditionFilter,1,nil,e,tp,lscale,rscale,eset)
end
function c66600026.pendop(e,tp,eg,ep,ev,re,r,rp,c,sg,og)
	local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
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
	local lscale=c:GetLeftScale()
	local rscale=rpz:GetRightScale()
	if Duel.GetMatchingGroupCount(c66600026.pendfilter,tp,LOCATION_PZONE,0,nil)>=2 then
		local l_chk=false
		local r_chk=false
		local other_chk=false
		if c:IsSetCard(0x5660) then
			local lscale_chk=c:GetLeftScale()+2
			local rscale_chk=rpz:GetRightScale()
			if lscale_chk>rscale_chk then lscale_chk,rscale_chk=rscale_chk,lscale_chk end
			if c66600026.pendconcheck(og,loc,e,tp,lscale_chk,rscale_chk,eset) then l_chk=true end
		end
		if rpz:IsSetCard(0x5660) then
			local lscale_chk=c:GetLeftScale()
			local rscale_chk=rpz:GetRightScale()+2
			if lscale_chk>rscale_chk then lscale_chk,rscale_chk=rscale_chk,lscale_chk end
			if c66600026.pendconcheck(og,loc,e,tp,lscale_chk,rscale_chk,eset) then r_chk=true end
		end
		if not other_chk then
			local lscale_chk=c:GetLeftScale()
			local rscale_chk=rpz:GetRightScale()
			if lscale_chk>rscale_chk then lscale_chk,rscale_chk=rscale_chk,lscale_chk end
			if c66600026.pendconcheck(og,loc,e,tp,lscale_chk,rscale_chk,eset) then other_chk=true end
		end
		local chk=false
		if not other_chk then
			chk=true
		else
			chk=Duel.SelectYesNo(tp,aux.Stringid(66600026,1))
		end
		if chk then
			Duel.Hint(HINT_CARD,0,66600026)
			if l_chk and r_chk then
				Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(66600026,2))
				local p_card=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_PZONE,0,1,1,nil):GetFirst()
				if p_card:GetSequence()==6 then lscale=lscale+2
				else rscale=rscale+2 end
			elseif r_chk then rscale=rscale+2
			else lscale=lscale+2
			end
		end
	end
	if lscale>rscale then lscale,rscale=rscale,lscale end
	if og then
		tg=og:Filter(Card.IsLocation,nil,loc):Filter(aux.PConditionFilter,nil,e,tp,lscale,rscale,eset)
	else
		tg=Duel.GetMatchingGroup(aux.PConditionFilter,tp,loc,0,nil,e,tp,lscale,rscale,eset)
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
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	aux.GCheckAdditional=aux.PendOperationCheck(ft1,ft2,ft)
	local g=tg:SelectSubGroup(tp,aux.TRUE,true,1,math.min(#tg,ft))
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