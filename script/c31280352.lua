--破壞绝杰·里榭娜
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,31280355)
	--连接召唤
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x3ca1),2,2)
    c:EnableReviveLimit()
	--加手或放置    
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
	e1:SetCondition(s.pthcon)
	e1:SetTarget(s.pthtg)
	e1:SetOperation(s.pthop)
	c:RegisterEffect(e1)
	--效破耐性    
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--选择效果发动    
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
    e3:SetCondition(s.efcon)
	e3:SetTarget(s.eftg)
	e3:SetOperation(s.efop)
	c:RegisterEffect(e3) 
    if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROY)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end   
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(eg) do
    	if tc:IsSetCard(0x3ca1) and tc:IsReason(REASON_BATTLE+REASON_EFFECT) then
			Duel.RegisterFlagEffect(tp,id+o*2,RESET_PHASE+PHASE_END,0,1)
			Duel.RegisterFlagEffect(1-tp,id+o*2,RESET_PHASE+PHASE_END,0,1)
        end    
	end
end
function s.pthcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.pthfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_DECK)) and c:IsSetCard(0x3ca1) and c:IsType(TYPE_PENDULUM)
		and (((Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) and not c:IsForbidden()) or c:IsAbleToHand())
end
function s.pthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.pthfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.pthop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local g=Duel.SelectMatchingCard(tp,s.pthfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
        local b1=tc:IsAbleToHand()
        local b2=(Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) and not tc:IsForbidden()         
		if tc and b1 and (not b2 or Duel.SelectOption(tp,1190,aux.Stringid(id,4))==0) then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		else
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end
end
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id+o*2)>=2 
end    
function s.pfilter(c)
	return c:IsCode(31280355) and not c:IsForbidden()
end
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local b1=Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_EXTRA,0,1,nil) and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
    	and Duel.GetFlagEffect(tp,id)==0 
    local b2=Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) 
    	and Duel.GetFlagEffect(tp,id+o)==0
    if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
    if chk==0 then return (b1 or b2) and Duel.GetFlagEffect(tp,id+o*10000)==0 end
    Duel.RegisterFlagEffect(tp,id+o*10000,RESET_CHAIN,0,1)
    local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,2),1},
		{b2,aux.Stringid(id,3),2})
	e:SetLabel(op)
    if op==1 then
    	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
    	e:SetCategory(0)
        e:SetProperty(0)
    elseif op==2 then
    	Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
        e:SetCategory(CATEGORY_DESTROY)
        e:SetProperty(EFFECT_FLAG_CARD_TARGET)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    end
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.dfilter(c,race)
	return c:IsFaceup() and c:IsRace(race) and c:GetOriginalType()&TYPE_PENDULUM~=0
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
    	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local tc=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
		if tc then 
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true) 
        end    
	elseif op==2 then
    	local tc=Duel.GetFirstTarget()
        if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0
        	and Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_PZONE,0,1,nil,RACE_FAIRY)
			and Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_PZONE,0,1,nil,RACE_FIEND)
        	and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
        	Duel.BreakEffect()
        	local c=e:GetHandler()
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
			e1:SetTarget(s.distg)
			e1:SetLabelObject(tc)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_CHAIN_SOLVING)
			e2:SetCondition(s.discon)
			e2:SetOperation(s.disop)
			e2:SetLabelObject(tc)
			e2:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e2,tp)    
            local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_FIELD)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
			e3:SetTarget(s.distg)
			e3:SetLabelObject(tc)
			e3:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e3,tp)    
        end
    end	
end
function s.distg(e,c)
	local tc=e:GetLabelObject()
	return c:IsOriginalCodeRule(tc:GetOriginalCodeRule()) and (c:IsType(TYPE_EFFECT) or c:GetOriginalType()&TYPE_EFFECT~=0)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsOriginalCodeRule(tc:GetOriginalCodeRule())
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end