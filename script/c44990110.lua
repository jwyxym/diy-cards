--守护巨龙之拥
local s,id=GetID()
function s.initial_effect(c)
	-- 标记为有「伊瑟拉」的卡名记述（兼容写法）
	if aux.AddCodeList then
		aux.AddCodeList(c,44990100)
	end

	-- ① 自己场上无怪兽，丢1手，从卡组特召4星以下记述伊瑟拉怪兽，附加自肃
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.cond1)
	e1:SetCost(s.cost1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)

	-- ② 结束阶段回收自身（需场上有「伊瑟拉」）
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

	-- ① 发动后自肃：本回合非风属性不能特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetCondition(s.splimcon)
	e3:SetTarget(s.splimit)
	c:RegisterEffect(e3)
end

-- 公共：检查是否为有「伊瑟拉」卡名记述的怪兽（兼容）
function s.IsYseraMonster(c)
	if aux.IsCodeListed then
		return aux.IsCodeListed(c,44990100) and c:IsType(TYPE_MONSTER)
	else
		return c:IsSetCard(0xcf1) and c:IsType(TYPE_MONSTER)
	end
end

-- ① 条件：自己场上无怪兽 + 一回合一次
function s.cond1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		and Duel.GetFlagEffect(tp,id)==0
end

-- ① cost：丢弃1张手卡
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end

-- ① 目标检查：卡组有符合条件的怪兽，且能特召
function s.filter(c,e,tp)
	return s.IsYseraMonster(c) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.GetFlagEffect(tp,id)>0 then return false end
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

-- ① 操作：特召，设置一回合一次标志和自肃标志
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)>0 then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		Duel.RegisterFlagEffect(tp,id+200,RESET_PHASE+PHASE_END,0,1) -- 自肃标志
	end
end

-- ② 条件：自己结束阶段，场上有「伊瑟拉」（卡名），此卡在墓地，一回合一次
function s.cond2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
		and Duel.IsExistingMatchingCard(s.IsYseraOnField,tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetFlagEffect(tp,id+100)==0
end
function s.IsYseraOnField(c)
	return c:IsFaceup() and c:IsCode(44990100) and c:IsType(TYPE_MONSTER)
end

-- ② 目标：此卡能加入手卡
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end

-- ② 操作：回收并设置一回合一次标志
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsAbleToHand() then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE+PHASE_END,0,1)
	end
end

-- 自肃条件
function s.splimcon(e)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id+200)>0
end

-- 禁止非风属性特殊召唤
function s.splimit(e,c,tp,sumtp)
	return not c:IsAttribute(ATTRIBUTE_WIND)
end