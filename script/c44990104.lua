--梦境（修复被吸收后送墓的bug）
local s,id=GetID()
function s.initial_effect(c)
	-- 标记为有「伊瑟拉」卡名记述
	aux.AddCodeList(c,44990100)

	-- ① 发动时效果：自己场上有「伊瑟拉」，弹对方场上最多2卡回手
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.cond1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)

	-- ② 墓地效果：自己结束阶段回收（增加素材检查）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.cond2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

-- 检查是否有表侧「伊瑟拉」（卡号44990100）
function s.IsYsera(c)
	return c:IsFaceup() and c:IsCode(44990100) and c:IsType(TYPE_MONSTER)
end

-- ① 条件：场上有伊瑟拉 + 一回合一次
function s.cond1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.IsYsera,tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetFlagEffect(tp,id)==0
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsOnField,tp,0,LOCATION_ONFIELD,1,nil) end
	local ct=Duel.GetMatchingGroupCount(Card.IsOnField,tp,0,LOCATION_ONFIELD,nil)
	local max=math.min(ct,2)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,Card.IsOnField,tp,0,LOCATION_ONFIELD,1,max,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g = Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS)
	if g and #g>0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT)
	end
	Duel.RegisterFlagEffect(tp, id, RESET_PHASE+PHASE_END, 0, 1)
end

-- ② 条件：自己回合结束阶段、场上有伊瑟拉、墓地的此卡、一回合一次、
--         且此卡未成为超量素材（修复被吸收后仍发动的bug）
function s.cond2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果这张卡正在作为超量素材，则不发动
	if c:GetOverlayTarget() then return false end
	return Duel.GetTurnPlayer()==tp
		and Duel.IsExistingMatchingCard(s.IsYsera,tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetFlagEffect(tp,id+100)==0
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsAbleToHand() then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE+PHASE_END,0,1)
	end
end