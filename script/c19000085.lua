--
function c19000085.initial_effect(c)
	c:SetUniqueOnField(1,0,19000085)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep2(c,c19000085.ffilter,3,127,true)
	--atk/def
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c19000085.adval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--negate1
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetDescription(aux.Stringid(19000085,0))
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c19000085.discon1)
	e3:SetCost(c19000085.discost1)
	e3:SetTarget(c19000085.distg)
	e3:SetOperation(c19000085.disop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetDescription(aux.Stringid(19000085,1))
	e4:SetCost(c19000085.discost2)
	c:RegisterEffect(e4)
	--negate2
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetDescription(aux.Stringid(19000085,0))
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(c19000085.discon2)
	e5:SetCost(c19000085.discost1)
	e5:SetTarget(c19000085.distg)
	e5:SetOperation(c19000085.disop)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetDescription(aux.Stringid(19000085,1))
	e6:SetCost(c19000085.discost2)
	c:RegisterEffect(e6)
end
function c19000085.ffilter(c,fc)
	return c:IsRace(RACE_ILLUSION)
end
function c19000085.adval(e,c)
	return Duel.GetMatchingGroupCount(c19000085.vfilter,c:GetControler(),LOCATION_GRAVE+LOCATION_REMOVED,0,nil)*530
end
function c19000085.vfilter(c)
	return c:IsRace(RACE_ILLUSION) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
function c19000085.discon1(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) or ep==tp then return false end
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and (tg~=nil or tc>0)
end
function c19000085.discon2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) or ep==tp then return false end
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_REMOVE)
	return ex and (tg~=nil or tc>0)
end
function c19000085.discost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1930) end
	Duel.PayLPCost(tp,1930)
end
function c19000085.discost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,Card.IsRace,1,REASON_COST,true,e:GetHandler(),RACE_ILLUSION) end
	local g=Duel.SelectReleaseGroupEx(tp,Card.IsRace,1,1,REASON_COST,true,e:GetHandler(),RACE_ILLUSION)
	Duel.Release(g,REASON_COST)
end
function c19000085.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function c19000085.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end