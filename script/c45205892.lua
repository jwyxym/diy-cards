--吞噬日月的双头恶龙
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 融合素材：光属性怪兽 + 暗属性怪兽 + 龙族怪兽
	aux.AddFusionProcMix(c,true,true,
		aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),
		aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),
		aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON))

	-- ① 这张卡特殊召唤的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)

	-- ② 对方把光·暗属性怪兽的效果发动时才能发动。那个效果无效。自己场上有「日月潭传说」的情况，这个效果变为「对方把卡的效果发动时才能发动。那个效果无效并破坏」。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)

	-- ③ 这张卡表侧表示存在的场合，这张卡不受对方的光·暗属性怪兽的效果影响。自己场上有「日月潭传说」的情况，这张卡不受对方的魔法·陷阱卡的效果影响。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
end

-- ① 过滤：光·暗属性怪兽 或者 「日月潭」记述的卡（排除自己）
function s.rmfilter(c,e)
	return c~=e:GetHandler() and (c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) or aux.IsCodeListed(c,45205890))
		and c:IsAbleToRemove()
end

-- ① target
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil,e) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

-- ① 处理
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil,e)
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end

-- ② 条件
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return false end
	if not re then return false end
	local rc=re:GetHandler()
	if not rc then return false end
	
	-- 判断是否满足“三色+破坏”条件
	local has_riyuetan = Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD,0,1,nil,45205890)
		or (rc and rc:IsCode(45205890))
		or (re and re:GetHandler():IsCode(45205890))
		
	e:SetLabel(has_riyuetan and 1 or 0)

	if has_riyuetan then 
		return Duel.IsChainDisablable(ev) 
	end
	if rc:IsType(TYPE_MONSTER) and rc:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) then
		return Duel.IsChainDisablable(ev)
	end
	return false
end

-- ② target
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if e:GetLabel()==1 and re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end

-- ② 处理
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) then
		if e:GetLabel()==1 and re:GetHandler():IsRelateToEffect(re) and re:GetHandler():IsDestructable() then
			Duel.Destroy(eg,REASON_EFFECT)
		end
	end
end

-- ③ 免疫判定
function s.efilter(e,te)
	if te:GetOwnerPlayer()==e:GetHandlerPlayer() then return false end
	local tc=te:GetOwner()
	local has_riyuetan = Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil,45205890)
		or (tc and tc:IsCode(45205890))
	if has_riyuetan and te:IsActiveType(TYPE_SPELL+TYPE_TRAP) then return true end
	if te:IsActiveType(TYPE_MONSTER) and tc and tc:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) then return true end
	return false
end

return s
