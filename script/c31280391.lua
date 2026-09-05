--姦淫的狂信者
local s,id,o=GetID()
function s.initial_effect(c)
	--破坏
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCountLimit(1,id)
    e1:SetCondition(s.tgcon)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
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
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.checkfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsType(TYPE_FUSION) and c:IsFaceup()
end    
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.checkfilter,nil)
	for tc in aux.Next(g) do
		Duel.RegisterFlagEffect(tc:GetSummonPlayer(),id,RESET_PHASE+PHASE_END,0,1)
	end
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)>0
end
function s.bgfilter(c)
	return c:IsSetCard(0x5ca1) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsAbleToGrave()
end    
function s.tgfilter(c,tp)
	return c:IsAbleToGrave() and Duel.IsExistingMatchingCard(s.bgfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,c) 
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc,tp) end	
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) 
    	and Duel.GetLP(tp)>=400 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
    local tg=Duel.GetMatchingGroup(s.bgfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,g:GetFirst())
    g:Merge(tg)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,2,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLP(tp)<400 then return end
    local tc=Duel.GetFirstTarget()
    if Duel.PayLPCost(tp,400)~=0 and tc:IsRelateToEffect(e) then
    	Duel.BreakEffect()
    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local g=Duel.SelectMatchingCard(tp,s.bgfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,tc)
        if g:GetCount()<=0 then return end
        Duel.HintSelection(g)
        g:AddCard(tc)
        Duel.SendtoGrave(g,REASON_EFFECT)		
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
	if tc and Duel.SSet(tp,tc)~=0 and tc:IsType(TYPE_TRAP) then        
    	local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)            
    end
end