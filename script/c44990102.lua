--阿梅达希尔
local s,id=GetID()
function s.initial_effect(c)
	-- 记述标记
	aux.AddCodeList(c,44990100)

	-- 发动时检索效果（①）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)

	-- ② 永续效果：自己场上的「伊瑟拉」怪兽不会成为对方效果的对象
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.indtg)
	e2:SetValue(s.tgval)
	c:RegisterEffect(e2)

	-- ③ 表侧表示从魔陷区送去墓地时，场上的「伊瑟拉」怪兽全部破坏
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end

-- ① 检索过滤
function s.thfilter(c)
	return aux.IsCodeListed(c,44990100) and c:IsAbleToHand()
end

-- ① 发动操作
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end

-- ② 对象过滤：自己场上的「伊瑟拉」怪兽（字段0xcf1）
function s.indtg(e,c)
	return c:IsSetCard(0xcf1) and c:IsType(TYPE_MONSTER)
end

-- ② 只免疫对方效果的取对象
function s.tgval(e,re,rp)
	return rp~=e:GetHandlerPlayer()
end

-- ③ 条件：从魔法陷阱区表侧表示送去墓地
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEUP)
end

-- ③ 目标：不取对象，确认场上存在伊瑟拉怪兽即可
function s.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xcf1) and c:IsType(TYPE_MONSTER)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

-- ③ 操作：破坏所有场上伊瑟拉怪兽
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end