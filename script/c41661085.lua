--罪律进行的推理
local s,id,o=GetID()
function s.initial_effect(c)
	--①：直到出现3张「罪律」卡为止从卡组上面翻卡，之后以下效果全部适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TODECK+CATEGORY_DRAW+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	--②：把墓地的这张卡除外才能发动。手卡1张「罪律」陷阱卡给对方确认，适用那张卡发动时的效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+10000)
	e2:SetCost(s.gycost)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMatchingGroupCount(s.zlchk,tp,LOCATION_DECK,0,nil)>=3 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.zlchk(c)
	--克莱门汀为「罪律」「侦探」双字段卡，部分端对双字段卡的低字段判定失效，显式补判
	return c:IsSetCard(0xe9a) or c:IsCode(41661075)
end
function s.zlhfilter(c)
	return s.zlchk(c) and c:IsAbleToHand()
end
function s.trapfilter(c)
	return c:IsSetCard(0xe9a) and c:IsType(TYPE_TRAP) and not c:IsType(TYPE_CONTINUOUS+TYPE_COUNTER)
end
function s.zlfilter(c)
	--除外状态只能回收表侧的卡
	if c:IsLocation(LOCATION_REMOVED) and not c:IsFaceup() then return false end
	return s.zlchk(c) and c:IsAbleToDeck()
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local dc=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if dc<3 then return end
	--按张数定位：取最小的n，使卡组上方n张里出现3张「罪律」（不依赖组的遍历顺序）
	local g=nil
	local n=1
	while n<=dc do
		local tg=Duel.GetDecktopGroup(tp,n)
		if tg:FilterCount(s.zlchk,nil)>=3 then
			g=tg
			break
		end
		n=n+1
	end
	if not g then return end
	Duel.ConfirmDecktop(tp,n)
	--把1张「罪律」卡加入手卡
	local hg=g:Filter(s.zlhfilter,nil)
	if hg:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=hg:Select(tp,1,1,nil)
		if sg:GetCount()>0 then
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
			g:Sub(sg)
		end
	end
	--把墓地·除外状态的3张「罪律」卡回到卡组，自己抽1张卡
	local rg=Duel.GetMatchingGroup(s.zlfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,nil)
	if rg:GetCount()>=3 and Duel.IsPlayerCanDraw(tp,1) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg=rg:Select(tp,3,3,nil)
		if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
			Duel.ShuffleDeck(tp)
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
	--这个回合，自己不是「罪律」怪兽不能从额外卡组特殊召唤
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetTargetRange(1,0)
	e3:SetTarget(s.exlimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)
	Duel.ShuffleDeck(tp)
end
function s.exlimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not s.zlchk(c)
end
function s.handtrap(c)
	return c:IsSetCard(0xe9a) and c:IsType(TYPE_TRAP) and not c:IsType(TYPE_CONTINUOUS+TYPE_COUNTER)
end
function s.gycost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToRemoveAsCost()
			and Duel.IsExistingMatchingCard(s.handtrap,tp,LOCATION_HAND,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.handtrap,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	Duel.Remove(c,POS_FACEUP,REASON_COST)
	Duel.ConfirmCards(1-tp,g)
	e:SetLabelObject(tc)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc then return end
	local te,ceg,cep,cev,cre,cr,crp=tc:CheckActivateEffect(false,true,true)
	if not te then return end
	Duel.ClearTargetCard()
	tc:CreateEffectRelation(e)
	local t=te:GetTarget()
	if t then t(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	Duel.ClearOperationInfo(0)
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
