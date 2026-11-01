--山水-挥墨 12260011
local s,id,o=GetID()
function s.initial_effect(c)
	--基础激活本体
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)

	--盖放回合发动特权
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,6))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCondition(s.setcon)
	e2:SetCost(s.setcost)
	c:RegisterEffect(e2)

	--②墓地效果
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.ptg)
	e3:SetOperation(s.pop)
	c:RegisterEffect(e3)
end

function s.setcon(e)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SET_TURN) and c:IsLocation(LOCATION_ONFIELD)
end

-- 和寒舍一致的 costfilter：自己场上可改表示形式的怪兽（里侧/表侧都可以）
function s.costfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsCanChangePosition()
end

-- 和寒舍一致的 setcost：用 Duel.SelectMatchingCard
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	if tc:IsFacedown() then
		-- 里侧守备 → 翻表，选攻击/守备
		Duel.ConfirmCards(1-tp,g)
		local sel=Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5))
		if sel==0 then
			Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
		else
			Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
		end
	else
		-- 表侧怪兽 → 盖成里侧守备
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(Card.IsCanTurnSet,tp,LOCATION_MZONE,0,1,nil)
			or Duel.IsExistingMatchingCard(Card.IsCanTurnSet,tp,0,LOCATION_MZONE,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tp1=tp
	local tp2=1-tp
	
	local d1=Duel.SelectYesNo(tp1,aux.Stringid(id,2))
	local d2=Duel.SelectYesNo(tp2,aux.Stringid(id,2))
	
	if d1 then
		Duel.Hint(HINT_SELECTMSG,tp1,HINTMSG_POSCHANGE)
		local g1=Duel.SelectMatchingCard(tp1,Card.IsCanTurnSet,tp1,LOCATION_MZONE,0,1,99,nil)
		if #g1>0 then
			Duel.ChangePosition(g1,POS_FACEDOWN_DEFENSE)
		end
	end
	
	if d2 then
		Duel.Hint(HINT_SELECTMSG,tp2,HINTMSG_POSCHANGE)
		local g2=Duel.SelectMatchingCard(tp2,Card.IsCanTurnSet,tp2,LOCATION_MZONE,0,1,99,nil)
		if #g2>0 then
			Duel.ChangePosition(g2,POS_FACEDOWN_DEFENSE)
		end
	end
	
	local opp=tp2
	local g=Duel.GetMatchingGroup(Card.IsFaceup,opp,LOCATION_ONFIELD,0,nil)
	local ct=#g
	if ct>0 then
		Duel.Damage(opp,ct*500,REASON_EFFECT)
	end
end

function s.filter(c)
	return c:IsFaceup() or c:IsFacedown()
end

function s.ptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		local self_count=Duel.GetMatchingGroupCount(Card.IsCanBeEffectTarget,tp,LOCATION_MZONE,0,nil,e)
		return self_count>0 and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil)
	end
	local g=Duel.GetMatchingGroup(Card.IsCanBeEffectTarget,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local sg=g:Select(tp,1,2,nil)
	if #sg==1 then
		local g2=Duel.SelectMatchingCard(tp,Card.IsCanBeEffectTarget,tp,0,LOCATION_MZONE,1,1,nil,e)
		sg:Merge(g2)
	end
	Duel.SetTargetCard(sg)
end

function s.pop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g then return end
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if #sg==0 then return end
	for tc in aux.Next(sg) do
		if tc:IsFacedown() then
			Duel.ConfirmCards(1-tp,tc)
			local op=Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5))
			if op==0 then
				Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
			else
				Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
			end
		else
			Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		end
	end
end
