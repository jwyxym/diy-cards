-- 奇妙糖果屋 (ID: 20263250)
local s,id,o=GetID()

function s.initial_effect(c)
	-- 头部必须注册：记述自身卡名（实现卡名关联检索闭环）
	aux.AddCodeList(c,id)

	-- ①：作为这张卡的发动的效果处理时，可以从卡组把1张「奇妙糖果屋」以外有「奇妙糖果屋」的卡名记述的卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH) -- 独立 HOPT ①
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- ②：自己场上有「奇妙糖果屋」的卡名记述的怪兽存在，其他卡发动的效果适用之际...
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(s.bancon)
	e2:SetOperation(s.banop)
	c:RegisterEffect(e2)
end

-- ==================== ① 效果：发动处理时检索 ====================
function s.thfilter(c)
	-- 严格静态调用 aux.IsCodeListed，检索自身以外记述「奇妙糖果屋」的卡
	return aux.IsCodeListed(c,id) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end

-- ==================== ② 效果：效果适用之际临时里侧除外双方卡组 ====================
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and aux.IsCodeListed(c,id)
end

function s.get_card_type(c)
	if c:IsType(TYPE_MONSTER) then return TYPE_MONSTER end
	if c:IsType(TYPE_SPELL) then return TYPE_SPELL end
	if c:IsType(TYPE_TRAP) then return TYPE_TRAP end
	return 0
end

function s.bancon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.GetFlagEffect(tp,id+o*100)==0
		and re:GetHandler()~=c
		and re:IsActivated()
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND,0,1,nil)
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,LOCATION_DECK)>0
end

function s.banop(e,tp,eg,ep,ev,re,r,rp)
	if not s.bancon(e,tp,eg,ep,ev,re,r,rp) then return end
	if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end

	-- 注册 ② 效果 HOPT 防撞标记
	Duel.RegisterFlagEffect(tp,id+o*100,RESET_PHASE+PHASE_END,0,1)
	Duel.Hint(HINT_CARD,0,id)

	-- 把手卡 1 张卡给对方确认
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local hg=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_HAND,0,1,1,nil)
	local rc=hg:GetFirst()
	if not rc then return end
	Duel.ConfirmCards(1-tp,rc)
	Duel.ShuffleHand(tp)

	local rtype=s.get_card_type(rc)
	if rtype==0 then return end

	-- 选取双方卡组中种类与展示卡不同的所有卡
	local bg=Duel.GetMatchingGroup(function(c)
		return not c:IsType(rtype) and c:IsAbleToRemove(tp,POS_FACEDOWN)
	end,tp,LOCATION_DECK,LOCATION_DECK,nil)

	if #bg>0 then
		if Duel.Remove(bg,POS_FACEDOWN,REASON_EFFECT+REASON_TEMPORARY)>0 then
			local og=Duel.GetOperatedGroup()
			og:KeepAlive()

			-- 注册在当前效果处理完毕（EVENT_CHAIN_SOLVED）后将除外的卡洗回卡组
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_CHAIN_SOLVED)
			e1:SetLabelObject(og)
			e1:SetOperation(s.retop)
			e1:SetReset(RESET_CHAIN)
			Duel.RegisterEffect(e1,tp)

			-- 连锁被无效时的安全返回保护
			local e2=e1:Clone()
			e2:SetCode(EVENT_CHAIN_NEGATED)
			Duel.RegisterEffect(e2,tp)
		end
	end
end

function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local og=e:GetLabelObject()
	if og then
		Duel.SendtoDeck(og,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		og:DeleteGroup()
	end
	e:Reset()
end