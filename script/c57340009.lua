--篡夺的继承者·辛瑟莱兹
local s,id,o=GetID()
function s.initial_effect(c)
	--①：给人观看手卡的这张卡，丢弃1张「黄金」速攻魔法；本回合首次丢这个卡名的场合，可以从墓地盖放1张「黄金」卡
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(s.cost1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--②：①丢弃过2种以上卡名的决斗中，从手卡特殊召唤这张卡，按种类数破坏对方场上的卡并给伤害
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+10000)
	e2:SetCondition(s.con2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--③：用②特殊召唤成功的回合只有1次，对方发动魔法·陷阱效果时，破坏对方魔法·陷阱区域的卡并给伤害
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+20000)
	e3:SetCondition(s.con3)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
end
--①：可丢弃的手卡（「黄金」速攻魔法）
function s.cfilter(c)
	return c:IsSetCard(0x571) and c:IsType(TYPE_QUICKPLAY)
end
--①：可盖放的墓地卡（「黄金」魔陷）
function s.setfilter(c)
	return c:IsSetCard(0x571) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
--①：本回合丢过同名卡的标记号码（每回合重置）
function s.turnflag(code)
	return id+0x1000+(code-57340000)
end
--①：整局丢过同名卡的标记号码（不重置，②用来数种类）
function s.duelflag(code)
	return id+0x100+(code-57340000)
end
--②：整局用①丢过的「黄金」速攻魔法卡名种类数
function s.namect(tp)
	local ct=0
	for i=0,3 do
		if Duel.GetFlagEffect(tp,s.duelflag(57340000+i))>0 then ct=ct+1 end
	end
	return ct
end
--①：给人观看这张卡，丢弃1张「黄金」速攻魔法
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.ConfirmCards(1-tp,e:GetHandler())
end
--①：本回合首次丢这个卡名的场合，从墓地盖放1张「黄金」卡
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local dg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	local dc=dg:GetFirst()
	if not dc then return end
	local fresh=Duel.GetFlagEffect(tp,s.turnflag(dc:GetCode()))==0
	Duel.RegisterFlagEffect(tp,s.turnflag(dc:GetCode()),RESET_PHASE+PHASE_END,0,1)
	Duel.RegisterFlagEffect(tp,s.duelflag(dc:GetCode()),0,0,1)
	if Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)==0 then return end
	if not fresh then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if not Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) then return end
	if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()==0 then return end
	Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEDOWN,true)
end
--②：整局丢过2种以上卡名，且自己能特殊召唤
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return s.namect(tp)>=2 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
--②：特殊召唤自身，按种类数破坏对方场上的卡并给伤害
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_HAND) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	local n=s.namect(tp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if g:GetCount()==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local sg=g:Select(tp,1,math.min(n,g:GetCount()),nil)
	if sg:GetCount()==0 then return end
	Duel.Destroy(sg,REASON_EFFECT)
	local og=Duel.GetOperatedGroup()
	if og:GetCount()>0 then
		Duel.RegisterFlagEffect(tp,57340011,RESET_PHASE+PHASE_END,0,1)
	end
	local ct=og:FilterCount(Card.IsType,nil,TYPE_MONSTER)
	if ct>0 then Duel.Damage(1-tp,ct*400,REASON_EFFECT) end
end
--③：对方魔陷区的卡（不含场地区）
function s.szfilter(c)
	return c:GetSequence()<5
end
--③：这张卡用②特殊召唤成功的回合，对方发动魔法·陷阱效果时
function s.con3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetFlagEffect(id)==0 then return false end
	local rc=re:GetHandler()
	return rp==1-tp and rc~=nil and rc:IsType(TYPE_SPELL+TYPE_TRAP)
end
--③：破坏对方魔法·陷阱区域的卡并给伤害
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.szfilter,tp,0,LOCATION_SZONE,nil)
	if g:GetCount()==0 then return end
	Duel.Destroy(g,REASON_EFFECT)
	local ct=Duel.GetOperatedGroup():GetCount()
	if ct>0 then
		Duel.Damage(1-tp,ct*400,REASON_EFFECT)
		Duel.RegisterFlagEffect(tp,57340011,RESET_PHASE+PHASE_END,0,1)
	end
end
