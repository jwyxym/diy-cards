--蛇舞·天鸣
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),8,2,nil,nil,99)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(s.intcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(85289965,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.atkcon)
	e3:SetCost(s.atkcost)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o*10000)
	e4:SetCondition(s.negcon)
	e4:SetCost(s.negcost)
	e4:SetTarget(s.negtg)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EFFECT_SPSUMMON_COST)
	e5:SetCost(s.zccost)
	e5:SetOperation(s.zcop)
	c:RegisterEffect(e5)
end
function s.zccost(e,c,tp)
	return true
end
function s.zcop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(24,0,aux.Stringid(id,3))
	Duel.Hint(24,0,aux.Stringid(id,4))
end
function s.intcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayCount()~=0
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	return tc and tc:IsFaceup() and tc:GetAttack()>0
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	Duel.SetTargetCard(e:GetHandler():GetBattleTarget())
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() or tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local atk=tc:GetAttack()
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(math.ceil(atk/2))
		c:RegisterEffect(e2)
	end
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) then return false end
	return re:IsActiveType(TYPE_MONSTER) and (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) and rp==1-tp
end
function s.cfilter(c)
	return c:IsRace(RACE_THUNDER) and c:IsAbleToRemoveAsCost()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.NegateActivation(ev)
		and c:IsRelateToEffect(e) then
		local tg1=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e),e)
		if td>0 and tg1:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.ShuffleHand(tp)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
			local tc1=tg1:Select(tp,1,1,nil):GetFirst()
			if tc1 then
				tc1:CancelToGrave()
				sg:AddCard(tc1)
			end
		end
		if sg:GetCount()>0 then
			Duel.BreakEffect()
			for tc in aux.Next(sg) do
				local og=tc:GetOverlayGroup()
				if og:GetCount()>0 then
					Duel.SendtoGrave(og,REASON_RULE)
				end
			end
			Duel.Overlay(c,sg)
		end
	end
end