--牧羊的饥肠吠犬
function c35100312.initial_effect(c)
    --atk up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c35100312.atkval)
	c:RegisterEffect(e1)
	--level
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35100312,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,35100312)
	e2:SetCost(c35100312.lvcost)
	e2:SetOperation(c35100312.lvop)
	c:RegisterEffect(e2)
    local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)
    --search thunder dragon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(35100312,3))
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_REMOVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,35100313)
	e4:SetTarget(c35100312.drtg)
	e4:SetOperation(c35100312.drop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCondition(c35100312.drcon)
	c:RegisterEffect(e5)
end
function c35100312.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_COST)
end
function c35100312.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c35100312.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function c35100312.atkval(e,c)
	return c:GetLevel()*100
end
function c35100312.costfilter(c,lv)
	return not c:IsLevel(lv) and c:IsLevelAbove(1) and c:IsLevelBelow(3) and c:IsRace(RACE_BEAST+RACE_WINDBEAST) and c:IsAbleToGraveAsCost()
end
function c35100312.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lv=e:GetHandler():GetLevel()
	if chk==0 then return Duel.IsExistingMatchingCard(c35100312.costfilter,tp,LOCATION_DECK,0,1,nil,lv) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c35100312.costfilter,tp,LOCATION_DECK,0,1,1,nil,lv)
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(g:GetFirst():GetLevel())
end
function c35100312.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv=e:GetLabel()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
    local down=c:IsLevelAbove(2)
	local op=aux.SelectFromOptions(tp,
		{true,aux.Stringid(35100312,1),lv},
		{down,aux.Stringid(35100312,2),-lv})
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	e1:SetValue(op)
	c:RegisterEffect(e1)
end