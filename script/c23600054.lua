-- 莫扎特·阿马德乌斯 (ID: 23600054)
local s,id,o=GetID()
function s.initial_effect(c)
	-- 同调召唤手续：风属性调整＋调整以外的魔法师族·风属性同调怪兽1只
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WIND),s.matfilter,1,1)
	c:EnableReviveLimit()

	-- 苏生限制：这张卡不用同调召唤不能特殊召唤
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.synlimit)
	c:RegisterEffect(e0)

	-- ①：自己场上的风属性怪兽攻击力·守备力上升400
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_WIND))
	e1:SetValue(400)
	c:RegisterEffect(e1)
	local e1_2=e1:Clone()
	e1_2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1_2)

	-- ①：自己场上的风属性怪兽不会被战斗破坏
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)

	-- ①：自己场上的风属性怪兽不能用对方的效果除外
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_REMOVE)
	e3:SetValue(s.rmval)
	c:RegisterEffect(e3)

	-- ②：自己·对方回合，选墓地·除外状态最多4只魔法师·风属性怪兽（相同等级最多1只）回到卡组，之后选最多该数量的场上的卡回到卡组
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e4:SetCountLimit(1,id+o*100) -- HOPT 防冲突限制码
	e4:SetTarget(s.tdtg)
	e4:SetOperation(s.tdop)
	c:RegisterEffect(e4)

	-- ③：自己主要阶段，墓地·除外的这张卡回到卡组，选墓地·除外的1只魔法师·风属性怪兽加入手卡
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
	e5:SetCountLimit(1,id+o*200) -- HOPT 防冲突限制码
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	c:RegisterEffect(e5)
end

-- 非调整素材过滤：魔法师族·风属性·同调怪兽
function s.matfilter(c,syncard)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_SYNCHRO)
end

-- ① 效果：不能用对方效果除外（对齐 ocgcore (e, rp) 参数签名）
function s.rmval(e,rp)
	return rp==1-e:GetHandlerPlayer()
end

-- ==================== ② 效果：回收墓地/除外并弹场 ====================
-- 修正：将 EdoPRO 专有的 HasLevel() 彻底替换为原生 ocgcore 通用的 c:GetLevel()>0
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_WIND)
		and c:IsType(TYPE_MONSTER) and c:GetLevel()>0 and c:IsAbleToDeck()
end

-- 校验子集等级互不相同（相同等级最多1只）
function s.dlvcheck(g)
	return g:GetClassCount(Card.GetLevel)==#g
end

function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if chk==0 then
		return g:CheckSubGroup(s.dlvcheck,1,4)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tg=g:SelectSubGroup(tp,s.dlvcheck,false,1,4)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,#tg,0,0)
end

function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 修正：使用原生 ocgcore 的 CHAININFO_TARGET_CARDS 提取对象，根除 GetTargetCards 报错
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g then return end
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if #tg==0 then return end
	local ct=Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	if ct>0 then
		local og=Duel.GetOperatedGroup()
		local sc=og:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
		if sc>0 and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,sc,nil)
			if #sg>0 then
				Duel.HintSelection(sg)
				Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			end
		end
	end
end

-- ==================== ③ 效果：自身洗回卡组并检索 ====================
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_WIND)
		and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToDeck()
			and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,c)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0
		and c:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end