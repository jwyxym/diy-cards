--失落武士·景光
local s,id,o=GetID()
function s.initial_effect(c)
	--超量召唤	
	aux.AddXyzProcedure(c,nil,7,2,nil,nil,99)
    c:EnableReviveLimit()
	--不能作为对象    
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.indcon)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	--直接攻击    
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
    e2:SetCondition(s.indcon)
	c:RegisterEffect(e2)
	--适用效果    
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_NEGATE+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.efcon)
	e3:SetTarget(s.eftg)
	e3:SetOperation(s.efop)
	c:RegisterEffect(e3)
	--特殊召唤    
    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetOperation(s.regop)
	c:RegisterEffect(e4)
    local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e5:SetCountLimit(1,id+o*10000)
	e5:SetCondition(s.spcon)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	e5:SetLabelObject(e2)
	c:RegisterEffect(e5)
	--标记    
    local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetCode(id)
	e6:SetRange(LOCATION_MZONE)
    e6:SetCondition(s.indcon)
	c:RegisterEffect(e6)
    local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetCode(EVENT_ADJUST)
	e0:SetRange(0xff)
	e0:SetOperation(s.adjustop)
	c:RegisterEffect(e0)
    if not s.global_check then
		s.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)	
	for tc in aux.Next(eg) do
    	local p=tc:GetSummonPlayer()
    	if tc:IsFaceup() and tc:IsSummonPlayer(p) and tc:IsAttribute(ATTRIBUTE_FIRE) and tc:IsRace(RACE_WARRIOR) then
			Duel.RegisterFlagEffect(p,id,0,0,0)
        end   
	end
end
function s.indcon(e)
	return e:GetHandler():GetOverlayCount()==0
end
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():GetOriginalType()&TYPE_MONSTER~=0
end
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local rc=re:GetHandler()
    local ct=0
	local b1=Duel.IsChainNegatable(ev)
    local b2=rc:IsRelateToEffect(re) and rc:IsDestructable()
    if b1 then ct=ct+1 end
    if b2 then ct=ct+1 end
    if ct>2 then ct=2 end
	if chk==0 then return e:IsCostChecked() and (b1 or b2) and c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
    local rt=c:RemoveOverlayCard(tp,1,ct,REASON_COST)
    if rt>=2 then
    	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
    end
    e:SetLabel(rt)    
end    
function s.efop(e,tp,eg,ep,ev,re,r,rp)        
    local ct=e:GetLabel()    
    if ct<=0 then return end
    local res=false
    local rc=re:GetHandler()
    for i=1,ct do    	
    	local b1=Duel.IsChainNegatable(ev) and rc:GetFlagEffect(31280369)==0
    	local b2=rc:IsRelateToEffect(re) and rc:IsDestructable()
    	if not b1 and not b2 then break end 
        local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},
			{b2,aux.Stringid(id,3),2})
        if i>1 then Duel.BreakEffect() end
        if op==1 then
        	Duel.NegateActivation(ev)
            rc:RegisterFlagEffect(31280369,RESET_CHAIN,0,1)
        elseif op==2 then
        	Duel.Destroy(rc,REASON_EFFECT)
        end
        res=true
    end
    rc:ResetFlagEffect(31280369)
    if res and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,1,nil)
    	and Duel.GetFlagEffect(tp,id)>=7 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
        Duel.BreakEffect()
        local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,nil)
        Duel.SendtoGrave(g,REASON_EFFECT)
    end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsReason(REASON_DESTROY) then return end
	if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then
		e:SetLabel(Duel.GetTurnCount())
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,2)
	else
		e:SetLabel(0)
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1)
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()~=Duel.GetTurnCount() and tp==Duel.GetTurnPlayer() and e:GetHandler():GetFlagEffect(id)>0
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_WARRIOR)
    	and c:IsType(TYPE_XYZ)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.mtfilter(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanOverlay() and not (e and c:IsImmuneToEffect(e))
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 and tc:IsType(TYPE_XYZ)
    	and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.mtfilter),tp,LOCATION_GRAVE,0,1,nil) 
        and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.mtfilter),tp,LOCATION_GRAVE,0,1,1,nil,e)
		if g:GetCount()>0 then
        	Duel.HintSelection(g)
			Duel.Overlay(tc,g)
		end
	end
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(id)
end
function s.adjustop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
    for tc in aux.Next(g) do
    	if tc:IsHasEffect(id) then
        	tc:RegisterFlagEffect(31280369,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,6))
        else
        	tc:ResetFlagEffect(31280369)    
        end       
    end
end