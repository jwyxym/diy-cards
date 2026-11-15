--猛鼠过江
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c, 8508055)
	
	--① 自己场上有「格斗鼠 吱助」或记述了它的卡的场合，对方发动卡的效果时无效，战阶可选破坏最多3张
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)

	--② 把这张卡从墓地除外才能发动，从卡组把1张「格斗鼠 吱助」或记述了它的卡加入手卡
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

-- ① 条件：自己场上有「格斗鼠 吱助」或记述了它的卡
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return false end
	if not re then return false end
	return Duel.IsExistingMatchingCard(s.chkfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsChainDisablable(ev)
end

function s.chkfilter(c)
	return c:IsFaceup() and (c:IsCode(8508055) or aux.IsCodeListed(c,8508055))
end

-- ① target
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end

-- ① 处理
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) then
		if re:GetHandler():IsRelateToEffect(re) and re:GetHandler():IsDestructable() then
			Duel.Destroy(eg,REASON_EFFECT)
		end
		
		-- 如果是战斗阶段发动的，可以选择再破坏最多3张卡
		local ph=Duel.GetCurrentPhase()
		if ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE then
			if Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil)
				and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then -- ★ 弹出“是否发动”的选项
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				local dg=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,3,nil)
				if #dg>0 then
					Duel.Destroy(dg,REASON_EFFECT)
				end
			end
		end
	end
end

-- ② 检索过滤：「格斗鼠 吱助」或记述了它的卡
function s.thfilter(c)
	return (c:IsCode(8508055) or aux.IsCodeListed(c,8508055)) and c:IsAbleToHand()
end

-- ② target
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

-- ② 处理
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

return s
