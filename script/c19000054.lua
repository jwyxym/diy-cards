--邪魔兽主-绝望显现
function c19000054.initial_effect(c)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,0,19000054)
	--spsummon
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(19000054,0))
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e0:SetProperty(EFFECT_FLAG_DELAY)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCountLimit(1,19000054)
	e0:SetCondition(c19000054.spcon)
	e0:SetTarget(c19000054.sptg)
	e0:SetOperation(c19000054.spop)
	c:RegisterEffect(e0)
	--atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c19000054.atkcon)
	e1:SetValue(2100)
	c:RegisterEffect(e1)
	--indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c19000054.atkcon)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--negate
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O+EFFECT_TYPE_XMATERIAL)
	e3:SetDescription(aux.Stringid(19000054,2))
	e3:SetCode(EVENT_CHAINING)
	e3:SetCountLimit(1)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c19000054.discon)
	e3:SetCost(c19000054.discost)
	e3:SetTarget(c19000054.distg)
	e3:SetOperation(c19000054.disop)
	c:RegisterEffect(e3)
end
function c19000054.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp
end
function c19000054.filter(c,e,tp)
	return c:IsLevel(9) and c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER) and (c:IsLocation(LOCATION_GRAVE+LOCATION_HAND) or c:IsFaceup()) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,true)
end
function c19000054.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c19000054.filter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
end
function c19000054.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c19000054.filter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,true,true,POS_FACEUP) then
		tc:CompleteProcedure()
	end
end
function c19000054.ccfilter(c)
	return c:IsLevel(9) or c:IsRank(9) and c:IsType(TYPE_MONSTER)
end
function c19000054.atkcon(e)
	local g=Duel.GetMatchingGroup(c19000054.ccfilter,e:GetHandler():GetControler(),LOCATION_GRAVE,0,nil)
	return g:GetCount()>=3
end
function c19000054.discon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOriginalRank()==9 and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function c19000054.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function c19000054.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function c19000054.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end