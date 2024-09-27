Sneak={}
sk=Sneak
--下级特召自身
function Sneak.SPSummon(c,id)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(Sneak.SPCon)
	e1:SetOperation(Sneak.SPOp)
	e1:SetTargetRange(POS_FACEDOWN_DEFENSE,0)
	c:RegisterEffect(e1)
end
function Sneak.filter(c)
	return c:IsPosition(POS_FACEDOWN) and c:IsCanChangePosition()
end
function Sneak.SPCon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(Sneak.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
function Sneak.SPOp(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local sc=Duel.SelectMatchingCard(tp,Sneak.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.ChangePosition(sc,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE)
	Duel.ConfirmCards(1-tp,c)
end
--下级通用cost
function Sneak.fcostfi(c)
	return c:IsFacedown() and c:IsAbleToGraveAsCost()
end
function Sneak.fcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsFacedown() and c:IsCanChangePosition() and Duel.IsExistingMatchingCard(Sneak.fcostfi,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	Duel.ChangePosition(c,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Sneak.fcostfi,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	Duel.SendtoGrave(g,REASON_COST)
end
--XYZ通用cost
function Sneak.xcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsFacedown() and c:IsCanChangePosition() and c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	Duel.ChangePosition(c,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE)
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
