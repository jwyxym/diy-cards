-- 欢迎来到糖果屋！！！ (ID: 20263249)
local s,id,o=GetID()
local CARD_WONDER_CANDY_HOUSE=20263250 -- 「奇妙糖果屋」卡号

function s.initial_effect(c)
	-- 头部必须注册：本卡记述了「奇妙糖果屋」
	aux.AddCodeList(c,CARD_WONDER_CANDY_HOUSE)

	-- ①：双方各把自身的1张手卡给对方确认...
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SSET+CATEGORY_DRAW+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id) -- 独立 HOPT ①
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- ②：把这个回合没有送去墓地的这张卡除外才能发动。从卡组把1张「欢迎来到糖果屋！！！」加入手卡。那之后，自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o*100) -- 独立 HOPT ② (防撞限制码)
	e2:SetCondition(aux.exccon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

-- ==================== ① 效果：双方展示手卡种类比对 ====================
function s.get_card_type(c)
	if c:IsType(TYPE_MONSTER) then return TYPE_MONSTER end
	if c:IsType(TYPE_SPELL) then return TYPE_SPELL end
	if c:IsType(TYPE_TRAP) then return TYPE_TRAP end
	return 0
end

function s.setfilter(c)
	return c:IsCode(CARD_WONDER_CANDY_HOUSE) and c:IsSSetable()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		-- 发动时必须双方手卡均至少有 1 张卡（排除发动的这张通常魔法自身）
		return Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND,0,1,c)
			and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	local g2=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if #g1==0 or #g2==0 then return end

	-- 双方各选择自身 1 张手卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local sg1=g1:Select(tp,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)
	local sg2=g2:Select(1-tp,1,1,nil)
	if #sg1==0 or #sg2==0 then return end

	local tc1=sg1:GetFirst()
	local tc2=sg2:GetFirst()
	Duel.ConfirmCards(1-tp,tc1)
	Duel.ConfirmCards(tp,tc2)
	Duel.ShuffleHand(tp)
	Duel.ShuffleHand(1-tp)

	local t1=s.get_card_type(tc1)
	local t2=s.get_card_type(tc2)
	local is_same=(t1==t2 and t1~=0)

	if is_same then
		-- 相同：自己可以从卡组把1张「奇妙糖果屋」在自己场上盖放
		if Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
			local sg=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
			if #sg>0 then
				Duel.SSet(tp,sg)
			end
		end
	else
		-- 不相同：对方从卡组抽1张卡
		Duel.Draw(1-tp,1,REASON_EFFECT)
	end
end

-- ==================== ② 效果：墓地除外检索同名卡并抽卡 ====================
function s.thfilter(c)
	return c:IsCode(id) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
			and Duel.IsPlayerCanDraw(tp,1)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end