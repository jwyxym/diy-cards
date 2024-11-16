--魔姬之主 路西菲尔
function c51600170.initial_effect(c)
	  --fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcFunFun(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1516),c51600170.matfilter,5,true)
	aux.AddContactFusionProcedure(c,Card.IsAbleToRemoveAsCost,LOCATION_MZONE+LOCATION_GRAVE,0,Duel.Remove,POS_FACEUP,REASON_COST)
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	--atk up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(3000)
	e2:SetCondition(c51600170.atkcon)
	c:RegisterEffect(e2)
	--negate
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(51600170,0))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,51600170)
	e3:SetCondition(c51600170.discon)
	e3:SetTarget(c51600170.distg)
	e3:SetOperation(c51600170.disop)
	c:RegisterEffect(e3)

	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(51600170,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,51600171)
	e4:SetTarget(c51600170.sptg)
	e4:SetOperation(c51600170.spop)
	c:RegisterEffect(e4)
end

function c51600170.matfilter(c)
	return c:IsSetCard(0x910) and c:IsType(TYPE_MONSTER)
end
function c51600170.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x910) and c:IsType(TYPE_MONSTER)
end
function c51600170.atkcon(e)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(c51600170.atkfilter,tp,LOCATION_REMOVED,0,nil)
	return g:GetClassCount(Card.GetCode)>=6
end

function c51600170.discon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function c51600170.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
   if re:GetHandler():IsDestructable() and Duel.GetMatchingGroup(c51600170.atkfilter,tp,LOCATION_REMOVED,0,nil):GetClassCount(Card.GetCode)>=6 then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,re:GetHandler(),1,0,0)
	end
end
function c51600170.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) 
	and Duel.GetMatchingGroup(c51600170.atkfilter,tp,LOCATION_REMOVED,0,nil):GetClassCount(Card.GetCode)>=6 then
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end

function c51600170.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x910) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c51600170.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c51600170.spfilter,tp,LOCATION_REMOVED,0,3,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_REMOVED)
end
function c51600170.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c51600170.spfilter,tp,LOCATION_REMOVED,0,1,3,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

