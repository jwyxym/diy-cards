--永世之瞬华·仰望绝暗
function c11127183.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcFunFunRep(c,function(c) return c:IsFusionType(TYPE_FUSION) and c:IsFusionSetCard(0xa62) end,aux.FilterBoolFunction(Card.IsRace,RACE_INSECT),1,1,true) 
	aux.AddContactFusionProcedure(c,Card.IsAbleToRemoveAsCost,LOCATION_MZONE,0,Duel.Remove,POS_FACEUP,REASON_COST):SetValue(SUMMON_TYPE_FUSION)
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(function(e,se,sp,st)
	return se:GetHandler():IsSetCard(0xa62) end) 
	c:RegisterEffect(e1)   
	--return to hand
	local e1=Effect.CreateEffect(c) 
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN) 
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER) 
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,11127183)
	e1:SetCondition(c11127183.rthcon)
	e1:SetTarget(c11127183.rthtg)
	e1:SetOperation(c11127183.rthop)
	c:RegisterEffect(e1)
	--negate
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,21127183)
	e2:SetCondition(c11127183.discon)
	e2:SetCost(c11127183.discost)
	e2:SetTarget(c11127183.distg)
	e2:SetOperation(c11127183.disop)
	c:RegisterEffect(e2)
	if not c11127183.global_check then
		c11127183.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_REMOVE)
		ge1:SetOperation(c11127183.checkop)
		Duel.RegisterEffect(ge1,0) 
	end
end
function c11127183.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do 
		if tc:IsRace(RACE_PLANT+RACE_INSECT) then 
		Duel.RegisterFlagEffect(0,11127183,RESET_PHASE+PHASE_END,0,1) 
		Duel.RegisterFlagEffect(1,11127183,RESET_PHASE+PHASE_END,0,1) 
		end 
		tc=eg:GetNext()
	end
end
function c11127183.rthcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,11127183)>=3 
end
function c11127183.rthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_ONFIELD)
end
function c11127183.rthop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
function c11127183.discon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function c11127183.ctfil(c) 
	return c:IsFaceup() and c:IsSetCard(0xa62) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost() 
end
function c11127183.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c11127183.ctfil,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) end
	local g=Duel.SelectMatchingCard(tp,c11127183.ctfil,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil) 
	Duel.Remove(g,POS_FACEUP,REASON_COST) 
end
function c11127183.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function c11127183.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
end





