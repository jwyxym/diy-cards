-- 天蚀神佑 (ID: 23600078)
local s,id,o=GetID()
local SET_ECLIPSE = 0xd92

function s.initial_effect(c)
	-- ①：对方把怪兽的效果·魔法·陷阱卡发动时，把自己场上的1只昆虫族超量怪兽的1个超量素材取除才能发动。从以下效果选1个适用。这个回合，自己的「天蚀神佑」的效果不能有相同效果适用。
	-- ●这个回合，自己场上的昆虫族怪兽不受对方的效果的影响。
	-- ●自己的墓地·除外状态的最多3只昆虫族·光属性怪兽回到卡组。
	-- ●那个发动无效。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

-- ==================== 发动条件与 Cost ====================
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方把怪兽的效果·魔法·陷阱卡发动时
	return rp==1-tp
end

function s.costfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_INSECT) and c:IsType(TYPE_XYZ)
		and c:CheckRemoveOverlayCard(tp,1,REASON_COST)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	g:GetFirst():RemoveOverlayCard(tp,1,1,REASON_COST)
end

-- ==================== 分支合法性判定与 Target ====================
function s.tdfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToDeck()
		and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 分支 1：本回合尚未适用过分支 1
	local b1=Duel.GetFlagEffect(tp,id+100)==0

	-- 分支 2：本回合尚未适用过分支 2 且 墓地/除外存在合法的昆虫族·光属性怪兽
	local b2=Duel.GetFlagEffect(tp,id+200)==0
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)

	-- 分支 3：本回合尚未适用过分支 3 且 连锁的发动可以被无效
	local b3=Duel.GetFlagEffect(tp,id+300)==0
		and Duel.IsChainNegatable(ev)

	if chk==0 then return b1 or b2 or b3 end

	-- 动态构建可选列表，仅展示本回合未适用过且满足条件的选项
	local ops={}
	local opval={}
	if b1 then
		table.insert(ops,aux.Stringid(id,0))
		table.insert(opval,1)
	end
	if b2 then
		table.insert(ops,aux.Stringid(id,1))
		table.insert(opval,2)
	end
	if b3 then
		table.insert(ops,aux.Stringid(id,2))
		table.insert(opval,3)
	end

	local op=Duel.SelectOption(tp,table.unpack(ops))
	local sel=opval[op+1]
	e:SetLabel(sel)

	-- 根据选择的分支登记分类与操作信息
	if sel==1 then
		e:SetCategory(0)
	elseif sel==2 then
		e:SetCategory(CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	elseif sel==3 then
		e:SetCategory(CATEGORY_NEGATE)
		Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	end
end

-- ==================== Operation 分支执行 ====================
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()

	if sel==1 then
		-- 分支 1 适用：登记标记（本回合自己的「天蚀神佑」不能再次适用分支 1）
		Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE+PHASE_END,0,1)

		-- 这个回合，自己场上的昆虫族怪兽不受对方的效果的影响
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(s.etarget)
		e1:SetValue(s.efilter)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)

		-- 状态提示
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e2:SetDescription(aux.Stringid(id,3))
		e2:SetReset(RESET_PHASE+PHASE_END)
		e2:SetTargetRange(1,0)
		Duel.RegisterEffect(e2,tp)

	elseif sel==2 then
		-- 分支 2 适用：登记标记
		Duel.RegisterFlagEffect(tp,id+200,RESET_PHASE+PHASE_END,0,1)

		-- 自己的墓地·除外状态的最多3只昆虫族·光属性怪兽回到卡组
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local sg=g:Select(tp,1,3,nil)
			if #sg>0 then
				Duel.HintSelection(sg)
				Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end
		end

	elseif sel==3 then
		-- 分支 3 适用：登记标记
		Duel.RegisterFlagEffect(tp,id+300,RESET_PHASE+PHASE_END,0,1)

		-- 那个发动无效（纯无效发动，不带破坏）
		Duel.NegateActivation(ev)
	end
end

-- 全抗性过滤
function s.etarget(e,c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end

function s.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer()
end