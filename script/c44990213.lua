--疯狂巨龙 死亡之翼
local s,id=GetID()
function s.initial_effect(c)
	-- 有「死亡之翼」的卡名记述
	aux.AddCodeList(c,44990201)

	-- 融合召唤：有「死亡之翼」的卡名记述的怪兽×3
	aux.AddFusionProcFunRep(c,s.ffilter,3,true)
	c:EnableReviveLimit()

	-- ① 对方发动效果时，送墓自己场上2张死亡之翼记述卡，无效并破坏
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.negcon)
	e1:SetCost(s.negcost)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)

	-- ② 被破坏时从卡组盖放大灾变
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end

-- 融合素材条件
function s.ffilter(c)
	return c:IsType(TYPE_MONSTER) and aux.IsCodeListed(c,44990201)
end

-- ① 条件：对方发动效果 + 一回合一次标志检查
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
		and Duel.GetFlagEffect(tp,id+100)==0
end

-- ① cost：送墓自己场上2张有死亡之翼记述的卡
function s.costfilter(c)
	return c:IsFaceup() and aux.IsCodeListed(c,44990201) and c:IsAbleToGraveAsCost()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,0,2,2,nil)
	if #g==2 then
		Duel.SendtoGrave(g,REASON_COST)
	end
end

-- ① 目标：设置一回合一次标志
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE+PHASE_END,0,1)
end

-- ① 操作：无效发动并破坏
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) then
		local tc=re:GetHandler()
		if tc and tc:IsRelateToEffect(re) then
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end

-- ② 条件：一回合一次标志检查
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id+200)==0
end

-- ② 目标：卡组有「大灾变」且魔陷区有空位
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)
			and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	end
	Duel.RegisterFlagEffect(tp,id+200,RESET_PHASE+PHASE_END,0,1)
end

-- ② 大灾变过滤
function s.filter(c)
	return c:IsCode(44990200) and c:IsSSetable()
end

-- ② 操作：盖放大灾变
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g:GetFirst())
	end
end