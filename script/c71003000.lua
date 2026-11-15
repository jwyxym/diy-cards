--久留美
-- 卡片类型：怪兽卡, 效果
-- 光 1星 战士族 500/500
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- ①：自己主要阶段，自己手卡为3张以上的场合才能发动。宣言1个怪兽·魔法·陷阱卡的种类，随机选对方卡组1张卡确认。确认的卡是宣言的种类的场合，自己从卡组抽1张。不是的场合，自己基本分变成一半，这张卡的控制权转移给对方。那之后，对方卡组洗切。
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_DRAW + CATEGORY_DECKDES + CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1, m)
	e1:SetCondition(cm.con1)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)

	-- ②：这张卡的①效果让自己抽卡的场合才能发动。宣言1个怪兽·魔法·陷阱卡的种类，随机选对方卡组1张卡确认。确认的卡是宣言的种类的场合，自己从卡组抽2张。不是的场合，自己基本分变成一半，选1张手卡回到卡组，这张卡的控制权转移给对方。那之后，对方卡组洗切。
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m, 1))
	e2:SetCategory(CATEGORY_DRAW + CATEGORY_DECKDES + CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CUSTOM + 1)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1, m + 1)
	e2:SetCondition(cm.con2)
	e2:SetTarget(cm.tg2)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)

	-- ③：这张卡的②效果让自己抽卡的场合才能发动。宣言1个怪兽·魔法·陷阱卡的种类，随机选对方卡组1张卡确认。确认的卡是宣言的种类的场合，自己从卡组抽3张。不是的场合，自己基本分变成一半，手卡全部回到卡组，这张卡的控制权转移给对方。那之后，对方卡组洗切。
	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(m, 2))
	e3:SetCategory(CATEGORY_DRAW + CATEGORY_DECKDES + CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CUSTOM + 2)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1, m + 2)
	e3:SetCondition(cm.con3)
	e3:SetTarget(cm.tg3)
	e3:SetOperation(cm.op3)
	c:RegisterEffect(e3)
end

-- ========== 条件与目标 ==========
function cm.con1(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetFieldGroupCount(tp, LOCATION_HAND, 0) >= 3
end
function cm.con2(e, tp, eg, ep, ev, re, r, rp) return true end
function cm.con3(e, tp, eg, ep, ev, re, r, rp) return true end

function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.GetFieldGroupCount(1 - tp, LOCATION_DECK, 0) > 0 end
end
function cm.tg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.GetFieldGroupCount(1 - tp, LOCATION_DECK, 0) > 0 end
end
function cm.tg3(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.GetFieldGroupCount(1 - tp, LOCATION_DECK, 0) > 0 end
end

-- ========== 通用处理逻辑 ==========
function cm.process_effect(e, tp, draw_count, fail_type)
	local c = e:GetHandler()
	local g = Duel.GetFieldGroup(1 - tp, LOCATION_DECK, 0)
	if g:GetCount() == 0 then return end

	-- 调用游戏原生UI，绝对不会显示问号（0=怪兽，1=魔法，2=陷阱）
	local opt = Duel.AnnounceType(tp)
	
	local sg = g:RandomSelect(tp, 1)
	Duel.ConfirmCards(tp, sg)
	local tc = sg:GetFirst()
	
	-- 判断是否猜中
	local match = false
	if opt == 0 and tc:IsType(TYPE_MONSTER) then match = true end
	if opt == 1 and tc:IsType(TYPE_SPELL) then match = true end
	if opt == 2 and tc:IsType(TYPE_TRAP) then match = true end

	if match then
		-- 猜中：抽卡并触发后续效果
		Duel.Draw(tp, draw_count, REASON_EFFECT)
		if draw_count == 1 then
			Duel.RaiseSingleEvent(c, EVENT_CUSTOM + 1, e, REASON_EFFECT, tp, tp, 0)
		elseif draw_count == 2 then
			Duel.RaiseSingleEvent(c, EVENT_CUSTOM + 2, e, REASON_EFFECT, tp, tp, 0)
		end
	else
		-- 猜错：基本分变成一半
		Duel.SetLP(tp, math.ceil(Duel.GetLP(tp) / 2))
		
		-- 各级效果的惩罚处理
		if fail_type == 2 then
			if Duel.GetFieldGroupCount(tp, LOCATION_HAND, 0) > 0 then
				Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
				local hg = Duel.SelectMatchingCard(tp, Card.IsAbleToDeck, tp, LOCATION_HAND, 0, 1, 1, nil)
				if hg:GetCount() > 0 then
					Duel.SendtoDeck(hg, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
				end
			end
		elseif fail_type == 3 then
			local hg = Duel.GetFieldGroup(tp, LOCATION_HAND, 0)
			if hg:GetCount() > 0 then
				Duel.SendtoDeck(hg, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
			end
		end

		-- 猜错把这张卡的控制权转移给对方
		if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_MZONE) then
			Duel.GetControl(c, 1 - tp)
		end
	end

	-- 那之后，对方卡组洗切
	Duel.ShuffleDeck(1 - tp)
end

-- ========== 操作阶段 ==========
function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	cm.process_effect(e, tp, 1, 1)
end
function cm.op2(e, tp, eg, ep, ev, re, r, rp)
	cm.process_effect(e, tp, 2, 2)
end
function cm.op3(e, tp, eg, ep, ev, re, r, rp)
	cm.process_effect(e, tp, 3, 3)
end