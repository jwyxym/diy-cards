-- 永续魔法（拉法姆字段）
-- 字段: 0xcf0
local s,id=GetID()
function s.initial_effect(c)
	-- 卡的发动（包含①处理）
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH) -- 卡名一回合发动1张
	e0:SetTarget(s.acttg)
	e0:SetOperation(s.actop)
	c:RegisterEffect(e0)

	-- ② 自己场上的「拉法姆」怪兽不会成为对方的效果的对象
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xcf0))
	e2:SetValue(s.tgval)
	c:RegisterEffect(e2)

	-- ③ 授予同纵列的「拉法姆」效果怪兽以下效果（对方回合1次，送墓cost，无效对方1张表侧卡）
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMING_END)
	e3:SetCountLimit(1)
	e3:SetCondition(s.grantcon)
	e3:SetCost(s.grantcost)
	e3:SetTarget(s.granttg)
	e3:SetOperation(s.grantop)

	local e_grant=Effect.CreateEffect(c)
	e_grant:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e_grant:SetRange(LOCATION_SZONE)
	e_grant:SetTargetRange(LOCATION_MZONE,0)
	e_grant:SetTarget(s.grantfilter)
	e_grant:SetLabelObject(e3)
	c:RegisterEffect(e_grant)
end

-- ① 检索目标
function s.thfilter(c)
	return c:IsSetCard(0xcf0) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	-- 发动回合自肃：不是「拉法姆」怪兽不能召唤·特殊召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
	-- 检索
	if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
function s.splimit(e,c)
	return not c:IsSetCard(0xcf0)
end

-- ② 对象抗性
function s.tgval(e,re,rp)
	return rp~=e:GetHandlerPlayer()
end

-- ③ 同纵列条件过滤
function s.grantfilter(e,c)
	local seq=e:GetHandler():GetSequence()
	return c:IsSetCard(0xcf0) and c:IsType(TYPE_EFFECT) and c:IsFaceup()
		and c:IsLocation(LOCATION_MZONE) and c:GetSequence()==seq
end
-- ③ 发动条件：对方回合
function s.grantcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp
end
-- ③ cost：从卡组送墓1只「拉法姆」怪兽
function s.costfilter(c)
	return c:IsSetCard(0xcf0) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function s.grantcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
-- ③ 对象：对方场上1张表侧卡
function s.granttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
end
-- ③ 处理：那张卡的效果无效
function s.grantop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end