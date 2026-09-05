-- 万象昭明
local s,id,o=GetID()
local SET_NINJA=0x2b    -- 「忍者」字段代码
local SET_NINJITSU=0x61 -- 「忍法」字段代码

function s.initial_effect(c)
	-- 规则效果：这张卡在规则上也当作「忍法」卡使用
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(SET_NINJITSU)
	c:RegisterEffect(e0)

	-- ①：作为这张卡发动时的效果处理，可以从卡组·墓地把 1 张「忍法」场地魔法卡在自己场上表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- ②：自己在通常召唤外加上只有 1 次，自己主要阶段可以进行 1 次「忍者」怪兽的通常召唤（表侧召唤与里侧盖放均支持）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_NINJA))
	c:RegisterEffect(e2)
	-- 同时注册里侧盖放（Set）权限
	local e2_set=e2:Clone()
	e2_set:SetCode(EFFECT_EXTRA_SET_COUNT)
	c:RegisterEffect(e2_set)

	-- ③：自己主要阶段才能发动。丢弃 1 张手卡，从卡组把 1 张「忍者」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+o*100)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)

	-- ④：只要自己场上有「忍者」怪兽存在，对方不能在战斗阶段把卡的效果发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(0,1)
	e4:SetCondition(s.actcon)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end

-- ①效果：「忍法」场地魔法过滤
function s.fieldfilter(c,tp)
	return c:IsSetCard(SET_NINJITSU) and c:IsType(TYPE_FIELD) and not c:IsForbidden()
end

-- ①效果：发动处理（选发放置场地）
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.fieldfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,tp)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		if tc then
			local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
			if fc then
				Duel.SendtoGrave(fc,REASON_RULE)
				Duel.BreakEffect()
			end
			Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		end
	end
end

-- ③效果：Cost（丢弃 1 张手卡）
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end

-- ③效果：检索过滤
function s.thfilter(c)
	return c:IsSetCard(SET_NINJA) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

-- ③效果：Target
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

-- ③效果：Operation
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- ④效果：场上「忍者」怪兽过滤与战阶条件
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_NINJA)
end

function s.actcon(e)
	local tp=e:GetHandlerPlayer()
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end