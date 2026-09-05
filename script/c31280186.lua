--械鳞龙魄 待机
local s,id,o=GetID()
function s.initial_effect(c)
	--发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--抽卡
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
    e1:SetCost(s.drcost)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
	--选择效果发动
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(2,id)
	e2:SetCondition(s.efcon)
	e2:SetTarget(s.eftg)
	e2:SetOperation(s.efop)
	c:RegisterEffect(e2)
end
function s.costfilter(c,tp)
	return c:IsSetCard(0x5caa) and c:IsType(TYPE_PENDULUM) and c:IsAbleToGraveAsCost()
    	and Duel.IsExistingMatchingCard(nil,tp,LOCATION_DECK,0,1,c)
end
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rc:GetOriginalType()&(TYPE_PENDULUM|TYPE_MONSTER)==TYPE_PENDULUM|TYPE_MONSTER and not re:IsHasType(EFFECT_TYPE_ACTIVATE) 
    	and re:GetActivateLocation()&LOCATION_ONFIELD~=0
end    
function s.pendvalue(e,c)
	return c:IsRace(RACE_MACHINE)
end
function s.penfilter(c,tp)
	return c:IsSetCard(0x5caa) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden() and c:CheckUniqueOnField(tp) 
    	and (c:IsFaceup() or c:IsLocation(LOCATION_DECK))
end
function s.thfilter(c)
	return c:IsSetCard(0x5caa) and c:IsAbleToHand() and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
    local res=false
	local lpz=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	if lpz~=nil and rpz~=nil then
		local loc=0
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_HAND end
		if Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)>0 then loc=loc+LOCATION_EXTRA end
		if loc~=0 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_EXTRA_PENDULUM_SUMMON)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(1,0)
			e1:SetValue(s.pendvalue)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)            
			local eset={e1}
			local lscale=lpz:GetLeftScale()
			local rscale=rpz:GetRightScale()
			if lscale>rscale then lscale,rscale=rscale,lscale end
			local g=Duel.GetFieldGroup(tp,loc,0)
			res=g:IsExists(aux.PConditionFilter,1,nil,e,tp,lscale,rscale,eset)	
            e1:Reset()
		end            
    end        	
	local b1=res
   	local b2=Duel.IsExistingMatchingCard(s.penfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,tp)
    	and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) 
    local b3=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
	if chk==0 then return (b1 or b2 or b3) end
    local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,2),1},
		{b2,aux.Stringid(id,3),2},
        {b3,aux.Stringid(id,4),3})
    e:SetLabel(op)
    if op==1 then
    	e:SetCategory(CATEGORY_SPECIAL_SUMMON)
    elseif op==3 then
    	e:SetCategory(CATEGORY_TOHAND)
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
    end    
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
    if op==1 then
    	local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_EXTRA_PENDULUM_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.pendvalue)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local eset={e1}
		local lpz=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
		local rpz=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
		local lscale=lpz:GetLeftScale()
		local rscale=rpz:GetRightScale()
		if lscale>rscale then lscale,rscale=rscale,lscale end
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
		local tg=Duel.GetMatchingGroup(aux.PConditionFilter,tp,loc,0,nil,e,tp,lscale,rscale,eset)
		tg=tg:Filter(aux.PConditionExtraFilterSpecific,nil,e,tp,lscale,rscale,e1)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		aux.GCheckAdditional=aux.PendOperationCheck(ft1,ft2,ft)
		local g=tg:SelectSubGroup(tp,aux.TRUE,false,1,math.min(#tg,ft))
		aux.GCheckAdditional=nil
		if not g then
			e1:Reset()
			return
		end
		local sg=Group.CreateGroup()
		sg:Merge(g)
		Duel.HintSelection(Group.FromCards(lpz))
		Duel.HintSelection(Group.FromCards(rpz))
		Duel.RaiseEvent(sg,EVENT_SPSUMMON_SUCCESS_G_P,e,REASON_EFFECT,tp,tp,0)
		Duel.SpecialSummon(sg,SUMMON_TYPE_PENDULUM,tp,tp,true,true,POS_FACEUP)
		e1:Reset()    
    elseif op==2 then
    	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local tc=Duel.SelectMatchingCard(tp,s.penfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,tp):GetFirst()
		if tc then
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
    elseif op==3 then
    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end    
    end
end