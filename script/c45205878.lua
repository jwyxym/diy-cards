--杯弓蛇影
local s,id=GetID()
function s.initial_effect(c)
	--① 对方把手卡的卡的效果发动时，展示自己手卡的1只爬虫族怪兽才能发动。
	--   那个效果无效并破坏，给与对方1000点伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.discon)
	e1:SetCost(s.discost)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
end

-- 条件：对方从手卡发动效果
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return false end
	if not re then return false end
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return loc==LOCATION_HAND and Duel.IsChainDisablable(ev)
end

-- cost：展示自己手卡的1只爬虫族怪兽
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
end

-- cost 过滤：爬虫族怪兽
function s.costfilter(c)
	return c:IsRace(RACE_REPTILE)
end

-- target
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsDestructable() and rc:IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,rc,1,0,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end

-- operation：无效效果 + 破坏 + 1000伤害
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) then
		local rc=re:GetHandler()
		if rc:IsRelateToEffect(re) and rc:IsDestructable() then
			Duel.Destroy(rc,REASON_EFFECT)
		end
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	end
end

return s
