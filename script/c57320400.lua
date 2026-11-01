--约定的荣耀 高文
local s,id,o=GetID()
function s.initial_effect(c)
	--融合召唤
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),2,true)
    aux.AddContactFusionProcedure(c,s.fsmfiler(c),LOCATION_MZONE,0,Duel.Release,REASON_SPSUMMON+REASON_MATERIAL)
	c:EnableReviveLimit()
	--特召限制
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(s.regcon)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)   
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	--适用效果    
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_ATKCHANGE+CATEGORY_HANDES_SELF)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.eftg)
	e2:SetOperation(s.efop)
	c:RegisterEffect(e2)    
end
function s.fsmfiler(ec)
	return	function(c)
				return c:IsReleasable() and Duel.GetFlagEffect(ec:GetControler(),id)==0
			end
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) or re:GetHandler()==c
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
function s.splimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION and Duel.GetFlagEffect(sp,id)==0
end
function s.confilter(c)
	return c:IsRace(RACE_WARRIOR) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(s.confilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
    local b1=ct>=5 and Duel.IsPlayerCanDraw(tp,1)
    local b2=ct>=10
	if chk==0 then return (b1 or b2) end
end    
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=Duel.GetMatchingGroupCount(s.confilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
    local res=false
    if ct>=5 then
    	if Duel.Draw(tp,1,REASON_EFFECT)~=0 then
        	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
			local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil,REASON_EFFECT)
			if dg:GetCount()>0 then
				Duel.BreakEffect()
                Duel.ShuffleHand(tp)
				Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
			end        
        end
        res=true
    end
    if ct>=10 then
    	if res then Duel.BreakEffect() end
        local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
        e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(aux.TargetBoolFunction(Card.IsCode,57320400))
		Duel.RegisterEffect(e1,tp)
        res=true
    end
    if ct>=15 then
    	if res then Duel.BreakEffect() end
        local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
        e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetTargetRange(LOCATION_ONFIELD,0)
		e2:SetTarget(aux.TargetBoolFunction(Card.IsCode,57320400))
		e2:SetValue(s.efilter)
		Duel.RegisterEffect(e2,tp)
        local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
		e3:SetTargetRange(0,LOCATION_MZONE)
		e3:SetValue(s.atlimit)
		Duel.RegisterEffect(e3,tp)        
        res=true
    end
    if ct>=20 then
    	if res then Duel.BreakEffect() end
        if c:IsRelateToEffect(e) and c:IsFaceup() then
        	local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(2000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
        end
    end
end
function s.efilter(e,te)
	return te:IsActivated() and te:IsActiveType(TYPE_MONSTER+TYPE_SPELL) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function s.atlimit(e,c)
	return c:IsCode(57320400) and c:IsFaceup()
end