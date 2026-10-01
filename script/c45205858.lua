--此地无银
local s,id=GetID()
function s.initial_effect(c)
	--① 选择对方场上1张里侧的卡为对象，那张卡加入自己手卡，在对方场上特召衍生物
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

--① 目标过滤：对方场上里侧的卡（里侧怪兽 + 盖放魔陷 + 盖放场地）
function s.filter(c)
	return c:IsFacedown() and c:IsAbleToHand()
end

--① 目标
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_ONFIELD+LOCATION_FZONE,1,nil)
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,45205859,0,TYPES_TOKEN_MONSTER,0,0,4,RACE_FIEND,ATTRIBUTE_EARTH) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_ONFIELD+LOCATION_FZONE,1,1,nil)
	Duel.SetChainLimit(s.chlimit)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,1-tp,LOCATION_MZONE)
end

-- 对方不能对应
function s.chlimit(e,ep,tp)
	return tp==ep
end

--① 处理
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,tp,REASON_EFFECT)
		Duel.ConfirmCards(tp,tc)
	end
	-- 在对方场上特召「无窃衍生物」
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then return end
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,45205859,0,TYPES_TOKEN_MONSTER,0,0,4,RACE_FIEND,ATTRIBUTE_EARTH) then return end
	local token=Duel.CreateToken(tp,45205859)
	Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP)
end

return s
