-- 蝦蟇忍者-児雷也
local s,id,o=GetID()
local SET_NINJA=0x2b    -- 「忍者」字段代码
local SET_NINJITSU=0x61 -- 「忍法」字段代码

function s.initial_effect(c)
	-- 融合召唤手续：种族不同的「忍者」怪兽×2
	c:EnableReviveLimit()
	aux.AddFusionProcMix(c,true,true,s.ffilter1,s.ffilter2)
	-- 接触融合：把自己场上的上记卡解放的场合可以从额外卡组特殊召唤
	aux.AddContactFusionProcedure(c,s.cfilter,LOCATION_MZONE,0,Duel.Release,REASON_COST+REASON_MATERIAL)

	-- 特殊召唤限制：只能用融合召唤以及上述方法从额外卡组特殊召唤
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)

	-- ①：这张卡特殊召唤的场合可以发动。自己墓地·除外状态中的 1 只「忍者」怪兽加入手卡。那之后，可以把场上 1 张表侧表示的卡盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	-- ②：只要这张卡在场上表侧表示存在，对方不能对应自己的「忍法」魔法·陷阱卡的发动把卡的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.chainop)
	c:RegisterEffect(e2)

	-- ③：这张卡反转的场合可以发动。获得对方场上 1 只怪兽的控制权，这个效果把里侧守备表示的怪兽控制权获得时，可以再把对方场上 1 张卡返回卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_CONTROL+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_FLIP)
	e3:SetCountLimit(1,id+o*100)
	e3:SetTarget(s.cttg)
	e3:SetOperation(s.ctop)
	c:RegisterEffect(e3)
end

-- 融合素材 1 过滤：第 1 只「忍者」怪兽
function s.ffilter1(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(SET_NINJA)
end

-- 融合素材 2 过滤：第 2 只「忍者」怪兽（种族与第 1 只有别）
function s.ffilter2(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(SET_NINJA) and not c:IsRace(sg:GetFirst():GetRace())
end

-- 接触融合场上素材过滤
function s.cfilter(c)
	return c:IsSetCard(SET_NINJA)
end

-- ①效果：回收怪兽过滤
function s.thfilter(c)
	return c:IsSetCard(SET_NINJA) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

-- ①效果：Target
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

-- ①效果：Operation
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	local tc=g:GetFirst()
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,tc)
		-- 那之后：可以把场上 1 张表侧表示的卡盖放
		local tg=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		if #tg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
			local sg=tg:Select(tp,1,1,nil)
			local sc=sg:GetFirst()
			if sc:IsType(TYPE_MONSTER) then
				Duel.ChangePosition(sc,POS_FACEDOWN_DEFENSE)
			else
				Duel.ChangePosition(sc,POS_FACEDOWN)
			end
		end
	end
end

-- ②效果：连锁封锁监听
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsSetCard(SET_NINJITSU) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and ep==tp then
		Duel.SetChainLimit(s.chainlm)
	end
end
function s.chainlm(e,rp,tp)
	return tp==rp
end

-- ③效果：Target
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,1-tp,LOCATION_MZONE)
end

-- ③效果：Operation
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectMatchingCard(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		local was_facedown=tc:IsFacedown()
		if Duel.GetControl(tc,tp)>0 then
			-- 若夺取的是里侧守备表示怪兽，可以再把对方场上 1 张卡返回卡组
			if was_facedown then
				local tg=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
				if #tg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
					Duel.BreakEffect()
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
					local sg=tg:Select(tp,1,1,nil)
					Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
				end
			end
		end
	end
end