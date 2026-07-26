-- 追忆万花筒
local s,id,o=GetID()
function s.initial_effect(c)
	-- 注册全局特召誓约计数器（用于前置校验）
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)

	-- 规则上也当作「温泉娘」卡使用
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0xd89)
	c:RegisterEffect(e0)

	-- 永续魔法卡基础发动（从手卡发动放置到魔陷区）
	local e_act=Effect.CreateEffect(c)
	e_act:SetType(EFFECT_TYPE_ACTIVATE)
	e_act:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e_act)

	-- ①：自己主要阶段才能发动。从墓地·除外状态回收或特召「温泉娘」怪兽，那之后可翻开 1 只里侧水族怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.eff1cost)
	e1:SetTarget(s.eff1tg)
	e1:SetOperation(s.eff1op)
	c:RegisterEffect(e1)

	-- ②：每次自己把「温泉娘」怪兽的效果发动，回复 200 基本分
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.recop)
	c:RegisterEffect(e2)

	-- ③：自己场上「温泉娘」怪兽反转的场合才能发动。给连接怪兽提供抗性
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_FLIP)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o*100)
	e3:SetCondition(s.eff3con)
	e3:SetCost(s.eff3cost)
	e3:SetOperation(s.eff3op)
	c:RegisterEffect(e3)
end

-- 誓约限制计数器：仅允许从手卡·墓地特召水族·反转怪兽
function s.counterfilter(c)
	return not (c:IsSummonLocation(LOCATION_HAND+LOCATION_GRAVE)
		and not (c:IsRace(RACE_AQUA) and c:IsType(TYPE_FLIP)))
end

function s.splimit(e,c)
	return c:IsLocation(LOCATION_HAND+LOCATION_GRAVE)
		and not (c:IsRace(RACE_AQUA) and c:IsType(TYPE_FLIP))
end

function s.register_splimit(e,tp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

-- ①效果：Cost / Target / Operation (修正：使用原生 GetCustomActivityCount API)
function s.eff1cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	s.register_splimit(e,tp)
end

function s.thspfilter(c,e,tp)
	return c:IsSetCard(0xd89) and c:IsFaceupEx() and c:IsType(TYPE_MONSTER)
		and (c:IsAbleToHand() or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end

function s.eff1tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thspfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.posfilter(c)
	return c:IsFacedown() and c:IsRace(RACE_AQUA)
end

function s.eff1op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thspfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	local res=false
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if tc:IsAbleToHand() and (ft<=0 or not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or Duel.SelectOption(tp,1190,1152)==0) then
		res=Duel.SendtoHand(tc,nil,REASON_EFFECT)>0
		if res then Duel.ConfirmCards(1-tp,tc) end
	else
		res=Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0
	end

	-- 那之后，可以选自己场上1只里侧表示的水族怪兽变成表侧攻击表示或者表侧守备表示
	if res and Duel.IsExistingMatchingCard(s.posfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
		local pg=Duel.SelectMatchingCard(tp,s.posfilter,tp,LOCATION_MZONE,0,1,1,nil)
		if #pg>0 then
			local pc=pg:GetFirst()
			Duel.HintSelection(pg)
			local pos=Duel.SelectPosition(tp,pc,POS_FACEUP_ATTACK+POS_FACEUP_DEFENSE)
			Duel.ChangePosition(pc,pos)
		end
	end
end

-- ②效果：每次「温泉娘」怪兽效果发动回复 200 基本分
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rp==tp and re:IsActiveType(TYPE_MONSTER) and rc:IsSetCard(0xd89) then
		Duel.Hint(HINT_CARD,0,id)
		Duel.Recover(tp,200,REASON_EFFECT)
	end
end

-- ③效果：Condition / Cost / Operation (修正：使用原生 GetCustomActivityCount API)
function s.flipfilter(c,tp)
	return c:IsSetCard(0xd89) and c:IsControler(tp)
end

function s.eff3con(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.flipfilter,1,nil,tp)
end

function s.eff3cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	s.register_splimit(e,tp)
end

function s.immtg(e,c)
	return c:IsSetCard(0xd89) and c:IsType(TYPE_LINK)
end

function s.efilter(e,te,c)
	local tp=e:GetHandlerPlayer()
	-- 必须有里侧怪兽存在
	if not Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_MZONE,0,1,nil) then return false end
	-- 不影响自己的效果，仅对对方发动的效果生效
	if te:GetOwnerPlayer()==tp or not te:IsActivated() then return false end
	-- 不防以该连接怪兽 c 自身为对象的效果
	if te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		if g and g:IsContains(c) then return false end
	end
	return true
end

function s.eff3op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.immtg)
	e1:SetValue(s.efilter)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(e1,tp)
end