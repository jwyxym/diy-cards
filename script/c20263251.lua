-- 甜蜜与苦涩 (ID: 20263251)
local s,id,o=GetID()
local CARD_WONDER_CANDY_HOUSE=20263250 -- 「奇妙糖果屋」卡号

function s.initial_effect(c)
	-- 记录关联卡名（奇妙糖果屋）
	aux.AddCodeList(c,CARD_WONDER_CANDY_HOUSE)

	-- ①：从以下效果中选择1个发动（这个卡名的以下效果1回合各能选择1次）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- ②：把墓地这张卡除外，将包含原本持有者是对方的卡的自己的3张卡的种类相同的手卡给对方确认才能发动... (1次决斗1次)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o*200,EFFECT_COUNT_CODE_DUEL)
	e2:SetCost(s.gycost)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)
end

-- ==================== ① 效果：三选一分支发动 ====================
function s.fieldfilter(c,tp)
	return c:IsCode(CARD_WONDER_CANDY_HOUSE) and c:IsType(TYPE_FIELD) and c:GetActivateEffect():IsActivatable(tp,true,true)
end

function s.spfilter(c,e,tp)
	return aux.IsCodeListed(c,CARD_WONDER_CANDY_HOUSE) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.cfilter1(c)
	return c:IsFaceup() and c:IsCode(CARD_WONDER_CANDY_HOUSE)
end

function s.cfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and aux.IsCodeListed(c,CARD_WONDER_CANDY_HOUSE)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	local b1=Duel.GetFlagEffect(tp,id+o*100)==0 and Duel.IsExistingMatchingCard(s.fieldfilter,tp,LOCATION_DECK,0,1,nil,tp)
	local b2=Duel.GetFlagEffect(tp,id+o*101)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	local b3=Duel.GetFlagEffect(tp,id+o*102)==0 and Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil)
	if chk==0 then return b1 or b2 or b3 end

	local ops={}
	local opval={}
	if b1 then
		table.insert(ops,aux.Stringid(id,0))
		table.insert(opval,1)
	end
	if b2 then
		table.insert(ops,aux.Stringid(id,1))
		table.insert(opval,2)
	end
	if b3 then
		table.insert(ops,aux.Stringid(id,2))
		table.insert(opval,3)
	end
	local op=Duel.SelectOption(tp,table.unpack(ops))
	local sel=opval[op+1]
	e:SetLabel(sel)

	if sel==1 then
		e:SetCategory(0)
		e:SetProperty(0)
		Duel.RegisterFlagEffect(tp,id+o*100,RESET_PHASE+PHASE_END,0,1)
	elseif sel==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetProperty(0)
		Duel.RegisterFlagEffect(tp,id+o*101,RESET_PHASE+PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	elseif sel==3 then
		e:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.RegisterFlagEffect(tp,id+o*102,RESET_PHASE+PHASE_END,0,1)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	if sel==1 then
		-- ● 从卡组把1张「奇妙糖果屋」在自己场上发动
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local tc=Duel.SelectMatchingCard(tp,s.fieldfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
		if tc then
			local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
			if fc then
				Duel.SendtoGrave(fc,REASON_RULE)
				Duel.BreakEffect()
			end
			Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
			local te=tc:GetActivateEffect()
			local tep=tc:GetControler()
			local cost=te:GetCost()
			if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
			Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
		end
	elseif sel==2 then
		-- ● 从卡组把1张有「奇妙糖果屋」卡名记述的怪兽特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif sel==3 then
		-- ● 无效对方场上1张表侧表示卡并除外（修复：加入 NegateRelatedChain 与完整无效时效）
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
			local c=e:GetHandler()
			-- 核心修复 1：阻断目标在当前连锁串中已经发动的效果
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)

			-- 核心修复 2：施加全回合无效化并增加 PHASE_END 重置条件
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)

			Duel.AdjustInstantly()
			-- 结算除外
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		end
	end
end

-- ==================== ② 效果：墓地除外并暂时除外双方卡组相同种类卡 ====================
function s.ownerfilter(c,tp)
	return c:GetOwner()==1-tp
end

function s.hand_goal(g,tp)
	if #g~=3 or not g:IsExists(s.ownerfilter,1,nil,tp) then return false end
	return g:FilterCount(Card.IsType,nil,TYPE_MONSTER)==3
		or g:FilterCount(Card.IsType,nil,TYPE_SPELL)==3
		or g:FilterCount(Card.IsType,nil,TYPE_TRAP)==3
end

function s.gycost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if chk==0 then
		return c:IsAbleToRemoveAsCost()
			and hg:CheckSubGroup(s.hand_goal,3,3,tp)
	end
	Duel.Remove(c,POS_FACEUP,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local sg=hg:SelectSubGroup(tp,s.hand_goal,false,3,3,tp)
	Duel.ConfirmCards(1-tp,sg)
	Duel.ShuffleHand(tp)

	local rtype=0
	if sg:FilterCount(Card.IsType,nil,TYPE_MONSTER)==3 then rtype=TYPE_MONSTER
	elseif sg:FilterCount(Card.IsType,nil,TYPE_SPELL)==3 then rtype=TYPE_SPELL
	elseif sg:FilterCount(Card.IsType,nil,TYPE_TRAP)==3 then rtype=TYPE_TRAP end
	e:SetLabel(rtype)
end

function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetFieldGroupCount(tp,LOCATION_DECK,LOCATION_DECK)>0
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,PLAYER_ALL,LOCATION_DECK)
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local rtype=e:GetLabel()
	if rtype==0 then return end

	local bg=Duel.GetMatchingGroup(function(c)
		return c:IsType(rtype) and c:IsAbleToRemove(tp,POS_FACEDOWN)
	end,tp,LOCATION_DECK,LOCATION_DECK,nil)

	if #bg>0 then
		if Duel.Remove(bg,POS_FACEDOWN,REASON_EFFECT+REASON_TEMPORARY)>0 then
			local og=Duel.GetOperatedGroup()
			og:KeepAlive()

			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetLabel(0)
			e1:SetLabelObject(og)
			e1:SetOperation(s.retop)
			e1:SetReset(RESET_PHASE+PHASE_END,2)
			Duel.RegisterEffect(e1,tp)
		end
	end
end

function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	ct=ct+1
	e:SetLabel(ct)
	if ct>=2 then
		local og=e:GetLabelObject()
		if og then
			Duel.SendtoDeck(og,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			og:DeleteGroup()
		end
		e:Reset()
	end
end