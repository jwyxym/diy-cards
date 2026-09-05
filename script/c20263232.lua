-- 鬼面忍者-真蛇 (ID: 20263232)
local s,id,o=GetID()
local SET_NINJA=0x2b    -- 「忍者」字段代码
local SET_NINJITSU=0x61 -- 「忍法」字段代码

function s.initial_effect(c)
	-- ①：把手卡这张卡给对手观看才能发动。从自己卡组·墓地把 1 张「忍法」魔法·陷阱卡在自己场上盖放。这个效果盖放的速攻魔法卡·永续陷阱卡在盖放的回合也能发动。那之后，可以从手卡把 1 只「忍者」怪兽在自己场上里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.setcost)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)

	-- ②：这张卡反转的场合才能发动。对方场上 1 张卡回到卡组·额外卡组，给与对方 1000 伤害。那之后，可以把场上这张卡变为里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DAMAGE+CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_FLIP)
	e2:SetCountLimit(1,id+o*100)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
	-- ★ 注册直通效果指针，确保随时可以被其他卡跨区域调用
	s.flip_effect=e2
end

-- ①效果：Cost（手卡公开）
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() end
	Duel.ConfirmCards(1-tp,c)
	Duel.ShuffleHand(tp)
end

-- ①效果：可盖放的「忍法」魔陷过滤
function s.setfilter(c)
	return c:IsSetCard(SET_NINJITSU) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end

-- ①效果：手卡可里侧特召的「忍者」怪兽过滤
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_NINJA) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end

-- ①效果：Target
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end

-- ①效果：Operation
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc and Duel.SSet(tp,tc)>0 then
		-- 盖放的速攻魔法·永续陷阱可以在盖放的回合发动
		if tc:IsType(TYPE_QUICKPLAY) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		elseif tc:IsType(TYPE_CONTINUOUS) and tc:IsType(TYPE_TRAP) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
		-- 那之后：可以从手卡把 1 只「忍者」怪兽里侧守备表示特殊召唤
		local spg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
		if #spg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=spg:Select(tp,1,1,nil):GetFirst()
			if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)>0 then
				Duel.ConfirmCards(1-tp,sc)
			end
		end
	end
end

-- ②效果：Target
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end

-- ②效果：Operation
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		local og=Duel.GetOperatedGroup()
		if og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) then
			Duel.Damage(1-tp,1000,REASON_EFFECT)
			-- 那之后：可以把场上这张卡变为里侧守备表示
			local c=e:GetHandler()
			if c:IsRelateToEffect(e) and c:IsFaceup() and c:IsCanTurnSet()
				and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
				Duel.BreakEffect()
				Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
			end
		end
	end
end