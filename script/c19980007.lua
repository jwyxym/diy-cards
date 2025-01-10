--
function c19980007.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Atk up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_FISH))
	e2:SetValue(c19980007.val)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--inactivatable
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_INACTIVATE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCondition(c19980007.condition)
	e4:SetValue(c19980007.effectfilter)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_DISEFFECT)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCondition(c19980007.condition)
	e5:SetValue(c19980007.effectfilter)
	c:RegisterEffect(e5)
	--remove
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_FZONE)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetCountLimit(1,19980007)
	e6:SetTarget(c19980007.rmtg)
	e6:SetOperation(c19980007.rmop)
	c:RegisterEffect(e6)
end
function c19980007.val(e,c)
	local tp=c:GetControler()
	local v=Duel.GetLP(1-tp)-Duel.GetLP(tp)
	if v>0 then return (v*(2/5)) else return 0 end
end
function c19980007.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(tp)==1
end
function c19980007.effectfilter(e,ct)
	local p=e:GetHandler():GetControler()
	local te,tp,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	return p==tp and te:GetHandler():IsSetCard(0xb34)
end
function c19980007.rmfilter(c)
	return c:IsAttack(0) and c:IsDefense(0) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
function c19980007.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19980007.rmfilter,tp,LOCATION_EXTRA+LOCATION_DECK,0,1,nil) and Duel.IsPlayerCanDraw(tp,1) end
	local g=Duel.GetMatchingGroup(c19980007.rmfilter,tp,LOCATION_EXTRA+LOCATION_DECK,0,nil)
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c19980007.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c19980007.rmfilter,tp,LOCATION_EXTRA+LOCATION_DECK,0,1,1,nil)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if g:GetCount()>0 then
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
	end
	Duel.Draw(p,d,REASON_EFFECT)
end