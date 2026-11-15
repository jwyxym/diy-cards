--断裂的命运
-- 卡片类型：陷阱卡, 永续
local cm, m, o = GetID()
function cm.initial_effect(c)
	-- 这个卡名的卡1回合只能发动1张。
	-- ①：作为这张卡的发动时的效果处理，双方各掷1次骰子...
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m, 0))
	e1:SetCategory(CATEGORY_DICE + CATEGORY_HANDES + CATEGORY_DESTROY + CATEGORY_DAMAGE + CATEGORY_TOGRAVE + CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1, m)
	e1:SetTarget(cm.tg1)
	e1:SetOperation(cm.op1)
	c:RegisterEffect(e1)
end

function cm.tg1(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return true end
end

-- 核心处理循环
function cm.op1(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	local eff_num = 1 -- 当前适用的效果编号（1, 2, 3）
	
	-- ①②③合计最多适用3次
	for i = 1, 3 do
		local my_roll = Duel.TossDice(tp, 1)
		local opp_roll = Duel.TossDice(1 - tp, 1)
		
		-- 数目相同的场合，直接适用④
		if my_roll == opp_roll then
			cm.op4(e, tp)
			return
		end
		
		local next_eff = 0
		
		if eff_num == 1 then
			if opp_roll > my_roll then
				-- 对方大：对方选1张手卡丢弃，适用②
				Duel.DiscardHand(1 - tp, nil, 1, 1, nil, REASON_EFFECT + REASON_DISCARD)
				next_eff = 2
			else
				-- 自己大：自己选1张手卡丢弃，适用③
				Duel.DiscardHand(tp, nil, 1, 1, nil, REASON_EFFECT + REASON_DISCARD)
				next_eff = 3
			end
		elseif eff_num == 2 then
			if opp_roll > my_roll then
				-- 对方大：选对方场上1只怪兽破坏，适用①
				local g = Duel.GetMatchingGroup(nil, 1 - tp, LOCATION_MZONE, 0, nil)
				if g:GetCount() > 0 then
					Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
					local sg = g:Select(tp, 1, 1, nil)
					Duel.Destroy(sg, REASON_EFFECT)
				end
				next_eff = 1
			else
				-- 自己大：选自己场上1只怪兽破坏，适用③
				local g = Duel.GetMatchingGroup(nil, tp, LOCATION_MZONE, 0, nil)
				if g:GetCount() > 0 then
					Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
					local sg = g:Select(tp, 1, 1, nil)
					Duel.Destroy(sg, REASON_EFFECT)
				end
				next_eff = 3
			end
		elseif eff_num == 3 then
			if opp_roll > my_roll then
				-- 对方大：对方受到差值×1000伤害，适用①
				Duel.Damage(1 - tp, (opp_roll - my_roll) * 1000, REASON_EFFECT)
				next_eff = 1
			else
				-- 自己大：自己受到差值×1000伤害，适用②
				Duel.Damage(tp, (my_roll - opp_roll) * 1000, REASON_EFFECT)
				next_eff = 2
			end
		end
		
		eff_num = next_eff
		
		-- 如果没到第3次，给个短暂停顿（以防连续处理卡画面）
		if i < 3 then
			Duel.BreakEffect()
		end
	end
	
	-- 循环结束（第3次处理完后），强制适用④
	cm.op4(e, tp)
end

-- ④：把场上的这张卡送去墓地，从卡组把1张「曲折的命运」(71003006) 盖放到自己的魔法与陷阱区域。
function cm.op4(e, tp)
	local c = e:GetHandler()
	-- 送墓自身
	if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_SZONE) then
		Duel.SendtoGrave(c, REASON_EFFECT)
	end
	
	-- 从卡组盖放「蜿蜒的命运」(71003006)
	if Duel.GetLocationCount(tp, LOCATION_SZONE) > 0 then
		local g = Duel.GetMatchingGroup(function(tc) return tc:IsCode(71003006) and tc:IsSSetable() end, tp, LOCATION_DECK, 0, nil)
		if g:GetCount() > 0 then
			Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SET)
			local sg = g:Select(tp, 1, 1, nil)
			if #sg > 0 then
				Duel.SSet(tp, sg)
			end
		end
	end
end