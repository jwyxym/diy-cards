--[[
本lua的作者为藜奴儿，如果测试出bug请联系QQ：1502939196

未经允许不支持任何人的任何形式的修改，源数。如有需要请联系作者，而不是私自找人代为修改。
本人对于本lua的任何bug修改、源数和适配后来卡片均为免费，并且追诉期无限。

但是如果使用者私自修改了lua，不论是bug修复还是源数效果，本人对此lua都不会再提供任何形式的支持。
一旦发现任何其他人对本lua进行了任何形式的修改，本人首先自愿放弃此lua除必要署名权以外的所有权利，
同时再也会不承担对此lua的任何维护与后续适配，包括但不限于任何形式的bug修复、效果源数。

如果您想要修改此lua，可以先联系本人，本人会在第一时间进行回复。
并且我承诺，若本人在2天内没有回复您，上述注意事项可作废，您可以直接修改此lua，而后续debug与适配仍然由我来进行。

如果您对本lua有任何疑问，请联系本人，本人会在第一时间进行回复。
如果您对本lua有任何建议，请联系本人，本人会在第一时间进行处理。
]]
--刻界-爆诞
local s,id,o=GetID()
function s.initial_effect(c)
	--①：除外相同纵列并破坏相邻
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	--②：墓地效果，回到卡组
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL)
	e2:SetCost(s.tdcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)

	--记录「刻界」怪兽被战斗破坏
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetOperation(s.regop)
	Duel.RegisterEffect(e3,0)
end

function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSetCard,1,nil,0x346a)
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsSetCard(0x346a) and tc:IsType(TYPE_MONSTER) then
			Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_END,0,1)
			tc:RegisterFlagEffect(id+3,RESET_PHASE+PHASE_END,0,1)
		end
		tc=eg:GetNext()
	end
end

function s.regop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id+2,RESET_PHASE+PHASE_END,0,1)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)>0
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetColumnGroupCount()>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,1-tp,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,0,1-tp,LOCATION_ONFIELD)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	
	local seq=c:GetSequence()
	if seq>=5 then return end --不处理场地区域
	
	--获取相同纵列的对方卡片
	local g=Group.CreateGroup()
	local tc=Duel.GetFieldCard(1-tp,LOCATION_MZONE,seq)
	if tc then g:AddCard(tc) end
	tc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,seq)
	if tc then g:AddCard(tc) end
	
	local removed=Group.CreateGroup()
	if #g>0 then
		local rg=g:Filter(Card.IsAbleToRemove,nil)
		if #rg>0 then
			if Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)>0 then
				removed:Merge(rg)
			end
		end
	end
	
	--检查被除外卡片的相邻区域
	if #removed>0 then
		local dg=Group.CreateGroup()
		local tc=removed:GetFirst()
		while tc do
			local tseq=tc:GetPreviousSequence()
			local tloc=tc:GetPreviousLocation()
			
			--检查左相邻
			if tseq>0 then
				local leftcard=Duel.GetFieldCard(1-tp,tloc,tseq-1)
				if leftcard then dg:AddCard(leftcard) end
			end
			--检查右相邻
			if tseq<4 then
				local rightcard=Duel.GetFieldCard(1-tp,tloc,tseq+1)
				if rightcard then dg:AddCard(rightcard) end
			end
			
			tc=removed:GetNext()
		end
		
		if #dg>0 then
			Duel.BreakEffect()
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end

function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id+2)>0
end

function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() end
	Duel.Remove(c,POS_FACEUP,REASON_COST)
end

function s.tdfilter(c)
	return c:IsSetCard(0x346a) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
		and c:GetFlagEffect(id+3)>0
end

function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end

function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil)
	if #g>0 then
		if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) and (not Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,0,1,nil))
		and Duel.IsPlayerCanDraw(tp,#g) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.Draw(tp,#g,REASON_EFFECT)
		end
		
	end
end

--aux.Stringid对应提示文本:
--aux.Stringid(id,0):除外相同纵列并破坏相邻
--aux.Stringid(id,1):回到卡组
--aux.Stringid(id,2):要抽卡吗？
