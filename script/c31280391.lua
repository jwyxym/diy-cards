--姦淫的狂信者
local s,id,o=GetID()
function s.initial_effect(c)
	--破坏
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCountLimit(1,id)
    e1:SetCondition(s.descon)
	e1:SetCost(s.descost)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--盖放
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o*10000)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
    local e3=e2:Clone()
	e3:SetCode(EVENT_BE_MATERIAL)
    e3:SetCondition(s.actcon)
    e3:SetTarget(s.acttg)
    e3:SetOperation(s.actop)
	c:RegisterEffect(e3)    
    if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetCondition(s.checkcon)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.checkfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsSummonType(SUMMON_TYPE_FUSION)
end    
function s.checkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.checkfilter,1,nil)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.checkfilter,nil)
	local tc=g:GetFirst()
	while tc do
		if Duel.GetFlagEffect(tc:GetSummonPlayer(),id)==0 then
			Duel.RegisterFlagEffect(tc:GetSummonPlayer(),id,RESET_PHASE+PHASE_END,0,1)
		end
		if Duel.GetFlagEffect(0,id)>0 and Duel.GetFlagEffect(1,id)>0 then
			break
		end
		tc=g:GetNext()
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)>0
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	Duel.SendtoGrave(c,REASON_COST)
end
function s.desfilter(c,tp,mc)
	return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_ONFIELD,0,1,Group.FromCards(c,mc))
end    
function s.tgfilter(c)
	return c:IsSetCard(0x5ca1) and c:IsFaceup() and c:IsAbleToGrave()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.desfilter(chkc,tp) end	
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,tp,c) 
    	and Duel.GetLP(tp)>=400 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c,tp,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_ONFIELD)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLP(tp)<400 then return end
    if Duel.PayLPCost(tp,400)~=0 then
    	Duel.BreakEffect()
    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local gc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_ONFIELD,0,1,1,nil):GetFirst()
        if not gc then return end
        Duel.HintSelection(Group.FromCards(gc))
        if Duel.SendtoGrave(gc,REASON_EFFECT)~=0 and gc:IsLocation(LOCATION_GRAVE) then
        	local tc=Duel.GetFirstTarget()
            if tc:IsRelateToEffect(e) then
            	Duel.Destroy(tc,REASON_EFFECT)
            end
		end
	end
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_FUSION)
end
function s.setfilter(c,con)
	return c:IsSetCard(0x5ca1) and (c:IsType(TYPE_SPELL) or (con and c:IsType(TYPE_TRAP))) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,nil)
	if g:GetCount() then 
    	Duel.SSet(tp,g) 
    end
end
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_FUSION and c:IsReason(REASON_EFFECT)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	local con=e:GetLabel()==100
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,con) end
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local con=e:GetLabel()==100
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,con):GetFirst()
	if tc and Duel.SSet(tp,tc)~=0 then
    	local c=e:GetHandler()
        if tc:IsType(TYPE_QUICKPLAY) then
			--速攻        
        	local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
        elseif tc:IsType(TYPE_TRAP) then
			--陷阱        
    		local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
       end     
    end
end