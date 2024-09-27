--Sneak·屠戮绞肉机
local m=52500002
local cm=_G["c"..m]
Duel.LoadScript("Sneak.lua")
function cm.initial_effect(c)
	sk.SPSummon(c,m)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DAMAGE+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCountLimit(1,m*2)
	e1:SetCost(sk.fcost)
	e1:SetTarget(cm.tgtg)
	e1:SetOperation(cm.tgop)
	c:RegisterEffect(e1)
end
function cm.tgfi(c)
	return c:IsAbleToGrave() and c:IsSetCard(0x520) and c:IsType(TYPE_MONSTER)
end
function cm.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.tgfi,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function cm.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,cm.tgfi,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT) then
		if Duel.Damage(1-tp,tc:GetBaseAttack(),REASON_EFFECT) and e:GetHandler():IsCanTurnSet() and Duel.SelectYesNo(tp,aux.Stringid(m,0)) then
			Duel.BreakEffect()
			Duel.ChangePosition(e:GetHandler(),POS_FACEDOWN_DEFENSE)
		end
	end
end
