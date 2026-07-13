--魔诞 喜悦之光
function c21362806.initial_effect(c)
	aux.AddCodeList(c,21362800)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21362806,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,21362806)
	e1:SetCondition(c21362806.spcon)
	e1:SetTarget(c21362806.sptg)
	e1:SetOperation(c21362806.spop)
	c:RegisterEffect(e1)
	--ctde
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
	e2:SetCountLimit(1,11362806)
	e2:SetCondition(c21362806.ctdcon) 
	e2:SetCost(c21362806.ctdcost)
	e2:SetTarget(c21362806.ctdtg)
	e2:SetOperation(c21362806.ctdop)
	c:RegisterEffect(e2)
end
function c21362806.cfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0xba38)
end
function c21362806.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(c21362806.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c21362806.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c21362806.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_PZONE,0,1,nil,21362800) and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(21362806,0)) then 
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
function c21362806.ctdcon(e,tp,eg,ep,ev,re,r,rp)
	local a,b=Duel.GetBattleMonster(tp)
	if b and b:GetAttack()>0 then
		e:SetLabelObject(b)
		return true
	else return false end
end
function c21362806.ctdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
	Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_COST) 
end
function c21362806.ctdtg(e,tp,eg,ep,ev,re,r,rp,chk) 
	local bc=e:GetLabelObject()
	if chk==0 then return bc end 
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,bc:GetAttack())
end
function c21362806.ctdop(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler()
	local bc=e:GetLabelObject()
	if bc:IsRelateToBattle() then 
		local atk=bc:GetAttack()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetRange(LOCATION_MZONE) 
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		bc:RegisterEffect(e1) 
		Duel.Recover(tp,atk,REASON_EFFECT)
	end 
end

