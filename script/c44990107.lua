--伊瑟拉苏醒（修复被吸收后仍发动的bug）
local s,id=GetID()
function s.initial_effect(c)
	-- 标记为有「伊瑟拉」卡名记述
	aux.AddCodeList(c,44990100)

	-- ① 自己场上有「伊瑟拉」，破坏对方场上全部怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.cond1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)

	-- ② 自己结束阶段回收（增加素材检查）
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

-- 检查场上有表侧表示的「伊瑟拉」
function s.IsYsera(c)
	return c:IsFaceup() and c:IsCode(44990100) and c:IsType(TYPE_MONSTER)
end

-- ① 条件：场上有伊瑟拉 + 一回合一次
function s.cond1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.IsYsera,tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetFlagEffect(tp,id)==0
end

-- ① 目标：不取对象，确认对方场上有怪兽即可
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsMonster,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsMonster,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

-- ① 操作：破坏对方场上全部怪兽 + 设置标志
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsMonster,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
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

-- ② 目标：此卡加入手卡
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end

-- ② 操作：加入手卡 + 设置标志
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsAbleToHand() then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE+PHASE_END,0,1)
	end
end