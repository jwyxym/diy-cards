--阿梅达希尔
local s,id=GetID()
function s.initial_effect(c)
	-- 将此卡标记为“有「伊瑟拉」的卡名记述”
	if aux.AddCodeList then
		aux.AddCodeList(c,44990100)
	end

	-- 永续魔法的发动效果（用于①的处理）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.acttg)
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

	-- ③ 强制诱发：表侧表示从魔陷区送去墓地时，场上的「伊瑟拉」怪兽全部破坏
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

-- ① 发动时的 target
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end

-- ① 检索 filter（有「伊瑟拉」的卡名记述）
function s.thfilter(c)
	if c:IsCode(44990100) then return c:IsAbleToHand() end
	if aux.IsCodeListed then
		return aux.IsCodeListed(c,44990100) and c:IsAbleToHand()
	else
		return c:IsSetCard(0xcf1) and c:IsAbleToHand()
	end
end

-- ① 发动时的处理：可选检索，一回合一次
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)>0 then return end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
	end
end

-- ② 保护对象：自己场上的「伊瑟拉」怪兽（字段0xcf1）
function s.indtg(e,c)
	return c:IsSetCard(0xcf1) and c:IsType(TYPE_MONSTER)
end
function s.tgval(e,re,rp)
	return rp~=e:GetHandlerPlayer()
end

-- ③ 条件：表侧表示从魔陷区送去墓地
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- ③ 不取对象，检查存在
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- ③ 破坏场上所有「伊瑟拉」怪兽
function s.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xcf1) and c:IsType(TYPE_MONSTER)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end