--哀伤之夜 辛贝罗姆·卡塔西斯
function c21362846.initial_effect(c)
	c:SetSPSummonOnce(21362846)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,function(c) return c:IsFusionSetCard(0xba38) and c:IsSummonLocation(LOCATION_EXTRA) end,2,true) 
	aux.AddContactFusionProcedure(c,Card.IsReleasable,LOCATION_MZONE,0,Duel.Release,REASON_COST) 
	--defense attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DEFENSE_ATTACK)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--re re 
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_SEND_REPLACE)
	e2:SetRange(LOCATION_MZONE) 
	e2:SetTarget(c21362846.reptg)
	e2:SetValue(c21362846.repval)
	c:RegisterEffect(e2) 
	--lp
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD) 
	e3:SetProperty(EFFECT_FLAG_DELAY) 
	e3:SetCondition(c21362846.lpcon) 
	e3:SetTarget(c21362846.lptg)
	e3:SetOperation(c21362846.lpop)
	c:RegisterEffect(e3)
end  
function c21362846.reptg(e,tp,eg,ep,ev,re,r,rp,chk) 
	local c=e:GetHandler()  
	if chk==0 then return bit.band(r,REASON_EFFECT)~=0 and re and eg:IsContains(c) and (c:GetDestination()==LOCATION_REMOVED or c:IsReason(REASON_DESTROY)) and c:GetAttack()>=500 end 
	if Duel.SelectEffectYesNo(tp,c) then 
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(-500)
		c:RegisterEffect(e1)
		return true 
	else return false end
end
function c21362846.repval(e,c)
	return c==e:GetHandler() 
end
function c21362846.lpcon(e,tp,eg,ep,ev,re,r,rp) 
	return e:GetHandler():GetReasonPlayer()==1-tp and e:GetHandler():IsReason(REASON_EFFECT)  
end 
function c21362846.lptg(e,tp,eg,ep,ev,re,r,rp,chk) 
	if chk==0 then return Duel.GetLP(tp)~=8000 end  
end 
function c21362846.lpop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler() 
	Duel.SetLP(tp,8000)
end 






