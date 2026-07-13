--喜悦之夜 埃尔博罗姆·哈皮
function c21362849.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xba38),11,2,nil,nil,2)
	--lv change
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_XYZ_LEVEL)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c21362849.lvtg)
	e1:SetValue(c21362849.lvval)
	c:RegisterEffect(e1)	
	--to grave 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21362849,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetRange(LOCATION_MZONE) 
	e2:SetCountLimit(1,21362849)
	e2:SetCondition(c21362849.tgcon)
	e2:SetCost(c21362849.cost)
	e2:SetTarget(c21362849.tgtg)
	e2:SetOperation(c21362849.tgop)
	c:RegisterEffect(e2)   
	--negate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21362849,2))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,21362850)
	e2:SetCondition(c21362849.discon)
	e2:SetCost(c21362849.cost)
	e2:SetTarget(c21362849.distg)
	e2:SetOperation(c21362849.disop)
	c:RegisterEffect(e2)
	--damage
	local e2=Effect.CreateEffect(c) 
	e2:SetDescription(aux.Stringid(21362849,3))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION) 
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,21362851)
	e2:SetTarget(c21362849.damtg)
	e2:SetOperation(c21362849.damop)
	c:RegisterEffect(e2)
end
function c21362849.lvtg(e,c)
	return c:IsSetCard(0xba38) and c:IsSummonLocation(LOCATION_EXTRA) 
end
function c21362849.lvval(e,c,rc)
	local lv=c:GetLevel()
	if rc==e:GetHandler() then return 11
	else return lv end
end
function c21362849.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
function c21362849.tgcon(e,tp,eg,ep,ev,re,r,rp) 
	return e:GetHandler():IsStatus(STATUS_SPSUMMON_TURN) and e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)  
end 
function c21362849.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c21362849.tgfil,tp,LOCATION_EXTRA,0,1,nil) end 
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
end
function c21362849.tgop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler() 
	local tc=Duel.SelectMatchingCard(tp,c21362849.tgfil,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
	if tc then 
		Duel.SendtoGrave(tc,REASON_EFFECT) 
	end 
end
function c21362849.discon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function c21362849.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end 
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function c21362849.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
function c21362849.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetOverlayCount()>0 end
	local ct=e:GetHandler():GetOverlayCount() 
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,ct*500)
end
function c21362849.damop(e,tp,eg,ep,ev,re,r,rp) 
	local ct=e:GetHandler():GetOverlayCount()
	Duel.Damage(tp,ct*500,REASON_EFFECT)
	Duel.Damage(1-tp,ct*500,REASON_EFFECT)
end



