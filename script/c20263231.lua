-- 次元忍者-幻溯 (ID: 20263231)
local s,id,o=GetID()
local SET_NINJA=0x2b    -- 「忍者」字段代码
local SET_NINJITSU=0x61 -- 「忍法」字段代码

function s.initial_effect(c)
	-- ①：这张卡可以不用解放作通常召唤（表侧召唤与里侧盖放均支持）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.ntcon)
	c:RegisterEffect(e1)
	local e1_set=e1:Clone()
	e1_set:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e1_set)

	-- ②：「忍法」卡的效果发动时，把里侧守备表示的这张卡变为表侧守备表示才能发动。自己抽1张。这个效果把「忍者」怪兽抽到的场合，可以再把那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.chcon)
	e2:SetCost(s.chcost)
	e2:SetTarget(s.chtg)
	e2:SetOperation(s.chop)
	c:RegisterEffect(e2)

	-- ③：这张卡反转的场合才能发动。从自己手卡·场上·墓地把1只「次元忍者-幻溯」以外的「忍者」怪兽除外，那只怪兽的反转的场合发动的效果适用。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_FLIP)
	e3:SetCountLimit(1,id+o*100)
	e3:SetTarget(s.fliptg)
	e3:SetOperation(s.flipop)
	c:RegisterEffect(e3)
	s.flip_effect=e3
end

-- ①效果：不用解放召唤/盖放条件
function s.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end

-- ②效果：响应「忍法」卡的效果发动
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsSetCard(SET_NINJITSU)
end

-- ②效果：Cost（自身里侧守备表示变为表侧守备表示）
function s.chcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsFacedown() and c:IsDefensePos() end
	Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
end

-- ②效果：Target（抽1张卡）
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

-- ②效果：Operation
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)>0 then
		local tc=Duel.GetOperatedGroup():GetFirst()
		if tc and tc:IsLocation(LOCATION_HAND) and tc:IsSetCard(SET_NINJA) and tc:IsType(TYPE_MONSTER)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.ConfirmCards(1-tp,tc)
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

-- ③效果：可除外的「忍者」怪兽过滤
function s.rmfilter(c)
	return c:IsSetCard(SET_NINJA) and c:IsType(TYPE_MONSTER) and not c:IsCode(id)
		and c:IsAbleToRemove() and (c:IsFaceup() or not c:IsOnField())
end

-- ③效果：Target
function s.fliptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,c) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
end

-- ③效果：Operation（全兼容反转效果适用引擎）
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.rmfilter),tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,c)
	local tc=g:GetFirst()
	if not tc then return end

	local code=tc:GetOriginalCode()
	if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
		-- 1. 尝试 95072744 标准方式从对象提取
		local eset={tc:IsHasEffect(EFFECT_TYPE_FLIP)}
		if #eset==0 then
			eset={tc:IsHasEffect(EVENT_FLIP)}
		end
		if #eset>0 then
			local te=eset[1]
			local tg=te:GetTarget()
			local op=te:GetOperation()
			e:SetProperty(te:GetProperty())
			e:SetCategory(te:GetCategory())
			Duel.ClearTargetCard()
			if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
			Duel.BreakEffect()
			local tgcards=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
			if tgcards then
				for etc in aux.Next(tgcards) do
					etc:CreateEffectRelation(e)
				end
			end
			if op then op(e,tp,eg,ep,ev,re,r,rp) end
			if tgcards then
				for etc in aux.Next(tgcards) do
					etc:ReleaseEffectRelation(e)
				end
			end
			return
		end

		-- 2. 直通保障：从 Lua 模块元表直接获取反转 Target 与 Operation（100% 解决非 TYPE_FLIP 怪兽的休眠问题）
		local mt=_G["c"..code] or _G["s"..code]
		if mt then
			if mt.flip_effect then
				local te=mt.flip_effect
				local tg=te:GetTarget()
				local op=te:GetOperation()
				e:SetProperty(te:GetProperty())
				e:SetCategory(te:GetCategory())
				Duel.ClearTargetCard()
				if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
				Duel.BreakEffect()
				local tgcards=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
				if tgcards then
					for etc in aux.Next(tgcards) do
						etc:CreateEffectRelation(e)
					end
				end
				if op then op(e,tp,eg,ep,ev,re,r,rp) end
				if tgcards then
					for etc in aux.Next(tgcards) do
						etc:ReleaseEffectRelation(e)
					end
				end
				return
			end

			-- 自动映射所有「忍者」怪兽的反转处理函数（鬼面:tdop, 雷:rmop, 蝦蟇:ctop, 宙/绿:op, 兽:thop, 枪:spop）
			local op=mt.tdop or mt.flipop or mt.operation or mt.thop or mt.spop or mt.ctop or mt.rmop
			local tg=mt.tdtg or mt.fliptg or mt.target or mt.thtg or mt.sptg or mt.cttg or mt.rmtg
			if op then
				Duel.ClearTargetCard()
				if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
				Duel.BreakEffect()
				local tgcards=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
				if tgcards then
					for etc in aux.Next(tgcards) do
						etc:CreateEffectRelation(e)
					end
				end
				op(e,tp,eg,ep,ev,re,r,rp)
				if tgcards then
					for etc in aux.Next(tgcards) do
						etc:ReleaseEffectRelation(e)
					end
				end
			end
		end
	end
end