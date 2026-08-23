--饥饿的光辉
function c31280217.initial_effect(c)
	--发动
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(31280217,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,31280217)
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c31280217.target)
	e1:SetOperation(c31280217.activate)
	c:RegisterEffect(e1)
	--超量召唤    
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31280217,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,31380217)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
    e2:SetCondition(c31280217.condition1)
	e2:SetTarget(c31280217.target1)
	e2:SetOperation(c31280217.operation1)
	c:RegisterEffect(e2)
end    
function c31280217.defilter(c)
	return c:IsFaceup() and c:GetDefense()>0
end
function c31280217.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(c31280217.defilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,c31280217.defilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function c31280217.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
        local preatk=tc:GetDefense()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(2000)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
        local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
        e2:SetValue(-2000)
		tc:RegisterEffect(e2)
       	if preatk~=0 and tc:IsDefense(0) then
       	   Duel.BreakEffect()
           Duel.Destroy(tc,REASON_EFFECT)  
		end           
	end
end
function c31280217.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetOverlayCount()>=3
end
function c31280217.condition1(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.IsExistingMatchingCard(c31280217.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function c31280217.xyzfilter(c)
	return c:IsXyzSummonable(nil)
end
function c31280217.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c31280217.xyzfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c31280217.operation1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(c31280217.xyzfilter,tp,LOCATION_EXTRA,0,nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=g:Select(tp,1,1,nil)		
        if c:IsRelateToEffect(e) and Duel.XyzSummon(tp,tg:GetFirst(),nil)~=0 then
        	if tg:GetFirst():IsSetCard(0x5ca0) and not c:IsImmuneToEffect(e) and c:IsCanOverlay() then	
        		Duel.BreakEffect()
            	local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_SPSUMMON_SUCCESS)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                e1:SetRange(LOCATION_GRAVE)
				e1:SetCondition(c31280217.mtcon)
				e1:SetOperation(c31280217.mtop)
                e1:SetLabelObject(tg:GetFirst())
           	 	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				c:RegisterEffect(e1)        				
    	    else 
				Duel.BreakEffect()
                local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_SPSUMMON_SUCCESS)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                e1:SetRange(LOCATION_GRAVE)
				e1:SetCondition(c31280217.rmcon)
				e1:SetOperation(c31280217.rmop)
                e1:SetLabelObject(tg:GetFirst())
           	 	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				c:RegisterEffect(e1)      
			end                
		end            
	end
end
function c31280217.mtcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return eg:GetFirst()==tc and tc:IsSetCard(0x5ca0)
end
function c31280217.mtop(e,tp,eg,ep,ev,re,r,rp)	
	local tc=e:GetLabelObject()
	Duel.Overlay(tc,e:GetHandler())
end
function c31280217.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return eg:GetFirst()==tc and not tc:IsSetCard(0x5ca0)
end
function c31280217.rmop(e,tp,eg,ep,ev,re,r,rp)	
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end