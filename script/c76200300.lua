--邪龙使·蕾格蒂维
local this,id,ofs=GetID()
function this.initial_effect(c)
	aux.AddFusionProcFun2(c,this.matfilter1,this.matfilter2,true)
	aux.AddContactFusionProcedure(c,this.matfilter3,LOCATION_ONFIELD,0,Duel.Remove,POS_FACEUP,REASON_COST)
	c:EnableReviveLimit()
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(this.destg)
	e3:SetOperation(this.desop)
	c:RegisterEffect(e3)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(this.atkcon)
	e2:SetValue(this.atkval)
	c:RegisterEffect(e2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id+1)
	e1:SetCost(this.pencost)
	e1:SetTarget(this.pentg)
	e1:SetOperation(this.penop)
	c:RegisterEffect(e1)
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e8:SetCode(EVENT_DESTROYED)
	e8:SetProperty(EFFECT_FLAG_DELAY)
	e8:SetCountLimit(1,id+2)
	e8:SetCondition(this.tpencon)
	e8:SetTarget(this.tpentg)
	e8:SetOperation(this.tpenop)
	c:RegisterEffect(e8)
end
this.has_text_type=TYPE_UNION
function this.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
function this.matfilter1(c)
	return c:IsRace(RACE_DRAGON) and c:IsFusionAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_PENDULUM)
end
function this.matfilter2(c)
	return c:IsRace(RACE_SPELLCASTER)
end
function this.matfilter3(c)
	return c:IsAbleToRemoveAsCost() and c:IsLocation(LOCATION_MZONE)
end
function this.desfilter(c,tp)
	return Duel.IsExistingMatchingCard(this.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetBaseAttack())
end
function this.thfilter(c,atk)
	return c:IsAttackBelow(atk) and c:IsAbleToHand() and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_PENDULUM)
end
function this.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and this.desfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(this.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,this.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function this.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,this.thfilter,tp,LOCATION_DECK,0,1,1,nil,tc:GetBaseAttack())
		if #g>0 then
			Duel.BreakEffect()
			Duel.SendtoHand(g,tp,REASON_EFFECT)
		end
	end
end
function this.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsRace(RACE_DRAGON)
end
function this.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
function this.atkval(e,c)
	local g=Duel.GetMatchingGroup(this.atkfilter,c:GetControler(),LOCATION_MZONE,0,c)
	return math.floor(g:GetSum(Card.GetBaseAttack)/2)
end
function this.pencfilter(c)
	return c:IsAbleToRemoveAsCost()
end
function this.penfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsRace(RACE_DRAGON) and (c:IsFaceup() or c:IsLocation(LOCATION_DECK)) and not c:IsForbidden()
end
function this.pencost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) and Duel.IsExistingMatchingCard(this.pencfilter,tp,LOCATION_PZONE,0,1,nil) end
	Duel.PayLPCost(tp,1000)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,this.pencfilter,tp,LOCATION_PZONE,0,1,1,nil)
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
end
function this.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(this.penfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
end
function this.penop(e,tp,eg,ep,ev,re,r,rp)
	if not (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,this.penfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil):GetFirst()
	Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
end
function this.tpencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
function this.tpentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
function this.tpenop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
