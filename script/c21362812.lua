--恶魔神的降临仪式
function c21362812.initial_effect(c)
	c:EnableCounterPermit(0xba38)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN) 
	e1:SetCountLimit(1,21362812)  
	e1:SetOperation(c21362812.activate)
	c:RegisterEffect(e1)
	--counter 
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F) 
	e1:SetCode(EVENT_PHASE+PHASE_END)  
	e1:SetRange(LOCATION_SZONE) 
	e1:SetCountLimit(1,11362812)  
	e1:SetTarget(c21362812.cttg)
	e1:SetOperation(c21362812.ctop)
	c:RegisterEffect(e1)  
	--atk
	local e1=Effect.CreateEffect(c) 
	e1:SetType(EFFECT_TYPE_FIELD) 
	e1:SetCode(EFFECT_UPDATE_ATTACK)  
	e1:SetRange(LOCATION_SZONE) 
	e1:SetTargetRange(0,LOCATION_MZONE) 
	e1:SetValue(function(e) 
	local tp=e:GetHandlerPlayer() 
	return Duel.GetCounter(tp,1,1,0xba38)*-300 end)
	c:RegisterEffect(e1) 
	--damage
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_LEAVE_FIELD_P)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetOperation(c21362812.regop)
	c:RegisterEffect(e0)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21362812,1))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCondition(c21362812.damcon) 
	e2:SetOperation(c21362812.damop)
	e2:SetLabelObject(e0)
	c:RegisterEffect(e2)
end 
function c21362812.filter(c,e,tp)
	return c:IsSetCard(0xba38) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end 
function c21362812.activate(e,tp,eg,ep,ev,re,r,rp) 
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c21362812.filter,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(21362812,0)) then 
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,c21362812.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) 
		end 
	end
end
function c21362812.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0xba38,2) end
end
function c21362812.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(0xba38,2)
	end
end
function c21362812.regop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetHandler():GetCounter(0xba38)
	e:SetLabel(ct)
end
function c21362812.damcon(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabelObject():GetLabel()
	e:SetLabel(ct)
	return ct>0
end 
function c21362812.damop(e,tp,eg,ep,ev,re,r,rp)  
	Duel.Hint(HINT_CARD,0,21362812)
	Duel.Damage(1-tp,e:GetLabel()*400,REASON_EFFECT)
end 


