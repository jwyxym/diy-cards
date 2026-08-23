--涸绝的甘露
function c31280215.initial_effect(c)
	--发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31280215,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_RECOVER+CATEGORY_DAMAGE+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,31280215+EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(c31280215.condition)
	e1:SetTarget(c31280215.target)
	e1:SetOperation(c31280215.activate)
	c:RegisterEffect(e1)
end
function c31280215.filter(c)
	return c:IsFaceup() and c:GetOverlayCount()>=10 and c:IsSetCard(0x5ca0) and c:IsType(TYPE_XYZ)
end
function c31280215.condition(e)
	return Duel.IsExistingMatchingCard(c31280215.filter,tp,LOCATION_MZONE,0,1,nil)
end
function c31280215.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,5) and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,2000)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,2000)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,5)
    Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,5)
    Duel.SetChainLimit(c31280215.chainlm)     
end
function c31280215.chainlm(e,rp,tp)
	return tp==rp
end
function c31280215.activate(e,tp,eg,ep,ev,re,r,rp)	
	if Duel.Damage(1-tp,2000,REASON_EFFECT) and Duel.Recover(tp,2000,REASON_EFFECT) 
    	and Duel.Draw(tp,5,REASON_EFFECT) then
        local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_SKIP_DP)
		e1:SetTargetRange(1,0)
		if Duel.GetTurnPlayer()==tp then
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetCondition(c31280215.skipcon)
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
		end
		Duel.RegisterEffect(e1,tp) 	             
    	local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetOperation(c31280215.operation)
		e2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2,tp)  
	end             
end
function c31280215.skipcon(e)
	return Duel.GetTurnCount()~=e:GetLabel()
end
function c31280215.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,31280215)
	Duel.DiscardHand(1-tp,nil,5,5,REASON_EFFECT+REASON_DISCARD)
end