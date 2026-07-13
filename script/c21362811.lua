--魔诞 光骑士 扎甘
function c21362811.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,nil,10,2) 
	--lv change
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_XYZ_LEVEL)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c21362811.lvtg)
	e1:SetValue(c21362811.lvval)
	c:RegisterEffect(e1)	
	--negate
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,21362811)
	e2:SetCondition(c21362811.discon)
	e2:SetCost(c21362811.discost)
	e2:SetTarget(c21362811.distg)
	e2:SetOperation(c21362811.disop)
	c:RegisterEffect(e2) 
	--xx
	local e2=Effect.CreateEffect(c)  
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY) 
	e2:SetCountLimit(1,11362811) 
	e2:SetTarget(c21362811.xxtg)
	e2:SetOperation(c21362811.xxop)
	c:RegisterEffect(e2)
end
function c21362811.lvtg(e,c)
	return c:IsSetCard(0xba38)
end
function c21362811.lvval(e,c,rc)
	local lv=c:GetLevel()
	if rc==e:GetHandler() then return 10
	else return lv end
end
function c21362811.discon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and bit.band(re:GetActivateLocation(),LOCATION_HAND+LOCATION_GRAVE)~=0 and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function c21362811.ctfil(c)  
	return c:IsAbleToGraveAsCost() and c:IsSetCard(0xba38) and c:IsLevelBelow(3)
end 
function c21362811.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c21362811.ctfil,tp,LOCATION_DECK,0,1,nil) end
	local sg=Duel.SelectMatchingCard(tp,c21362811.ctfil,tp,LOCATION_DECK,0,1,1,nil) 
	Duel.SendtoGrave(sg,REASON_COST)
end
function c21362811.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function c21362811.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
function c21362811.xxtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end 
end
function c21362811.xxop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler()
	--damage reduce
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET) 
	e1:SetTargetRange(1,0)
	e1:SetValue(c21362811.damval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end 
function c21362811.damval(e,re,val,r,rp,rc) 
	local tp=e:GetHandlerPlayer()
	if bit.band(r,REASON_BATTLE)~=0 then return Duel.GetLP(tp)/2 
	else return val end
end

