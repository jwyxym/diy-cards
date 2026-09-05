-- 劫富忍义之投
local s,id,o=GetID()
local SET_NINJA=0x2b        -- 「忍者」字段代码
local SET_NINJITSU=0x61     -- 「忍法」字段代码
local CARD_DAIYUGI=24203749 -- 「天下独步的大义贼」卡号

function s.initial_effect(c)
	-- 规则效果：这张卡在规则上也当作「忍法」卡使用
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(SET_NINJITSU)
	c:RegisterEffect(e0)

	-- ①：把自己手卡·场上任意数量的其他的「忍者」怪兽卡以及「忍法」卡给对方确认才能发动。那些确认的卡回到卡组，自己从卡组抽那个回去的数量-1的数量的卡。那之后，如果自己的手卡比对方多2张以上的场合，对方再从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- ②：把这个回合没有送去墓地的墓地的这张卡除外才能发动。自己场上最多2张「忍者」怪兽卡以及「忍法」卡回到手卡。那之后，自己场上没有怪兽存在的场合，可以再从卡组把1张「天下独步的大义贼」加入手卡。这个回合，自己不是「忍者」怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

-- ①效果：展示卡片过滤
function s.cfilter(c)
	return (c:IsSetCard(SET_NINJA) and c:IsType(TYPE_MONSTER) or c:IsSetCard(SET_NINJITSU))
		and c:IsAbleToDeck()
end

-- ①效果：Cost（确认 2 张及以上）
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,c)
	if chk==0 then return #g>=2 and Duel.IsPlayerCanDraw(tp,1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local sg=g:Select(tp,2,#g,nil)
	Duel.ConfirmCards(1-tp,sg)
	sg:KeepAlive()
	e:SetLabelObject(sg)
end

-- ①效果：Target
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local sg=e:GetLabelObject()
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,#sg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,#sg-1)
end

-- ①效果：Operation
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g then return end
	local ct=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	g:DeleteGroup()
	if ct>1 then
		local draw_ct=ct-1
		if Duel.Draw(tp,draw_ct,REASON_EFFECT)>0 then
			-- 那之后，如果自己的手卡比对方多 2 张以上的场合，对方再从卡组抽 2 张
			local my_hand=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
			local op_hand=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
			if my_hand-op_hand>=2 and Duel.IsPlayerCanDraw(1-tp,2) then
				Duel.BreakEffect()
				Duel.Draw(1-tp,2,REASON_EFFECT)
			end
		end
	end
end

-- ②效果：不是本回合送墓
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.exccon(e)
end

-- ②效果：Cost（自身除外）
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	Duel.Remove(c,POS_FACEUP,REASON_COST)
end

-- ②效果：场上回手卡片过滤
function s.thfilter(c)
	return c:IsFaceup() and (c:IsSetCard(SET_NINJA) and c:IsType(TYPE_MONSTER) or c:IsSetCard(SET_NINJITSU))
		and c:IsAbleToHand()
end

-- ②效果：「天下独步的大义贼」检索过滤
function s.thfilter2(c)
	return c:IsCode(CARD_DAIYUGI) and c:IsAbleToHand()
end

-- ②效果：Target
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_ONFIELD)
end

-- ②效果：Operation
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_ONFIELD,0,1,2,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
		-- 那之后，自己场上没有怪兽存在的场合，可以再从卡组把 1 张「天下独步的大义贼」加入手卡
		if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
			and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
			if #sg>0 then
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,sg)
			end
		end
	end
	-- 额外卡组特召自肃
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.splimit(e,c,sump,sumtype,sumpos,target_p,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(SET_NINJA)
end