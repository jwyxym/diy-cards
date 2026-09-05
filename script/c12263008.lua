--天水：北非之脉
function c12263008.initial_effect(c)
	--装备魔法卡特有
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c12263008.target)
	e1:SetOperation(c12263008.operation)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c12263008.eqlimit)
	c:RegisterEffect(e2)
	--①效果：从卡组把1只天水卡破坏
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,12263008)
	e3:SetTarget(c12263008.destg)
	e3:SetOperation(c12263008.desop)
	c:RegisterEffect(e3)
	
	--②效果：被破坏送墓时发动（修复CAT_SET错误）
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(12263008,0))
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_LEAVE_GRAVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,122630081)
	e4:SetCondition(c12263008.setcon)
	e4:SetTarget(c12263008.settg)
	e4:SetOperation(c12263008.setop)
	c:RegisterEffect(e4)
end
--装备魔法特有
function c12263008.eqlimit(e,c)
	return c:IsFaceup()
end
function c12263008.filter(c)
	return c:IsFaceup()
end
function c12263008.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c12263008.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c12263008.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,c12263008.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function c12263008.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
--①效果：从卡组破坏天水卡【仅此处修改】
function c12263008.desfilter(c)
	return c:IsSetCard(0x5244) and c:IsAbleToGrave()
end
function c12263008.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c12263008.desfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_DECK)
end
function c12263008.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,c12263008.desfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

--===================== ②效果 修复版 =====================
function c12263008.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end

-- 检索天水卡回卡组
function c12263008.tdfilter(c)
	return c:IsSetCard(0x5244) and c:IsAbleToDeck()
end

-- 检索天水魔法·陷阱盖放（排除自身）
function c12263008.stfilter(c)
	return c:IsSetCard(0x5244) and c:IsType(TYPE_SPELL+TYPE_TRAP)
		and not c:IsCode(12263008) and c:IsSSetable()
end

function c12263008.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(c12263008.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
			and Duel.IsExistingMatchingCard(c12263008.stfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end

function c12263008.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 1. 墓地·除外 1张天水回卡组
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,c12263008.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if #g==0 then return end
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end

	-- 2. 墓地把这张卡以外的天水魔陷盖放
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local sg=Duel.SelectMatchingCard(tp,c12263008.stfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #sg>0 then
		Duel.SSet(tp,sg:GetFirst())
	end
end
