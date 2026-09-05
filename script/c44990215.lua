--粉碎
local s,id=GetID()
function s.initial_effect(c)
	-- 有「死亡之翼」的卡名记述
	aux.AddCodeList(c,44990201)

	-- ① 对方发动怪兽效果时，无效并破坏，随机丢1手，可选全场破坏
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)

	-- ② 从卡组以外送墓时盖放
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)

	-- 全回合额外自肃计数器
	Duel.AddCustomActivityCounter(id+300,ACTIVITY_SPSUMMON,s.counterfilter)
end

-- 额外自肃计数器过滤：从额外特召且非龙族·暗属性时计入违规
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or (c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK))
end

-- 检查是否已违反额外自肃
function s.CheckBond(tp)
	return Duel.GetCustomActivityCount(id+300,tp,ACTIVITY_SPSUMMON)==0
end

-- 注册全回合额外自肃
function s.RegisterSelfBond(tp,c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
end

-- 额外自肃限制：只允许暗属性龙族从额外特召
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not (c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK))
end

-- ① 条件：对方发动怪兽效果 + 一回合一次 + 未违反额外自肃
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER)
		and Duel.GetFlagEffect(tp,id+100)==0
		and s.CheckBond(tp)
end

-- ① 目标：设置一回合一次标志，注册额外自肃
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE+PHASE_END,0,1)
	s.RegisterSelfBond(tp,e:GetHandler())
end

-- ① 操作：无效发动并破坏，随机丢弃对方1手卡，可选破坏全场怪兽
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效发动并破坏
	if Duel.NegateActivation(ev) then
		local tc=re:GetHandler()
		if tc and tc:IsRelateToEffect(re) then
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end

	-- 对方随机丢弃1张手卡
	local hg=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	if #hg>0 then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DISCARD) -- 仅为提示，实际随机
		local dg=hg:RandomSelect(tp,1)
		Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
	end

	-- 自己场上有「死亡之翼」本体存在的场合，选发破坏场上所有怪兽
	if Duel.IsExistingMatchingCard(s.dwfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		local fg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,LOCATION_MZONE,nil,TYPE_MONSTER)
		if #fg>0 then
			Duel.Destroy(fg,REASON_EFFECT)
		end
	end
end

-- 死亡之翼本体过滤
function s.dwfilter(c)
	return c:IsFaceup() and c:IsCode(44990201) and c:IsType(TYPE_MONSTER)
end

-- ② 条件：从卡组以外送墓 + 一回合一次 + 未违反额外自肃
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsPreviousLocation(LOCATION_DECK)
		and Duel.GetFlagEffect(tp,id+200)==0
		and s.CheckBond(tp)
end

-- ② 目标
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.RegisterFlagEffect(tp,id+200,RESET_PHASE+PHASE_END,0,1)
	s.RegisterSelfBond(tp,e:GetHandler())
end

-- ② 操作：盖放自身
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.SSet(tp,c)
	end
end