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
--天底的再旅者
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--效果1：特殊召唤并进行同调召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.con1)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--效果2：无效幻龙族怪兽和对方表侧表示卡
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(s.con2)
	e3:SetCountLimit(1,id+100)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)==0
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id+1)==0
end
function s.spfilter(c,e,tp)
	return (c:IsSetCard(0x5410)or c:IsCode(96570609,95457011,1984618)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (c:IsFaceup() or not c:IsLocation(LOCATION_EXTRA+LOCATION_REMOVED))
end
function s.synfilter(c)
	return (c:IsSetCard(0x5410)or c:IsCode(96570609,95457011,1984618)) and c:IsType(TYPE_SYNCHRO) and c:IsSynchroSummonable(nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	e:GetHandler():RegisterFlagEffect(id,RESET_PHASE+PHASE_END+RESET_EVENT+RESETS_STANDARD,0,1)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_EXTRA+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		local tc=g:GetFirst()
		--效果无效
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		--离场时回到卡组最下面
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e3:SetValue(LOCATION_DECKBOT)
		tc:RegisterEffect(e3)
		if Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_EXTRA,0,1,nil)and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			--进行同调召唤
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=Duel.SelectMatchingCard(tp,s.synfilter,tp,LOCATION_EXTRA,0,1,1,nil)
			if #sg>0 then
				Duel.SynchroSummon(tp,sg:GetFirst(),nil)
			end
		end
	end
end
function s.disfilter1(c)
	return c:IsFaceup() and c:IsRace(RACE_WYRM) and aux.NegateMonsterFilter(c)
end
function s.disfilter2(c)
	return c:IsFaceup() and aux.NegateMonsterFilter(c)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		local g1=Duel.GetMatchingGroup(s.disfilter1,tp,LOCATION_MZONE,0,nil)
		local g2=Duel.GetMatchingGroup(s.disfilter2,tp,0,LOCATION_ONFIELD,nil)
		return #g1>0 and #g2>0
	end
	e:GetHandler():RegisterFlagEffect(id+1,RESET_PHASE+PHASE_END+RESET_EVENT+RESETS_STANDARD,0,1)
	local g1=Duel.GetMatchingGroup(s.disfilter1,tp,LOCATION_MZONE,0,nil)
	local g2=Duel.GetMatchingGroup(s.disfilter2,tp,0,LOCATION_ONFIELD,nil)
	local ct=math.min(#g1,#g2)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local sg1=g1:Select(tp,1,ct,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local sg2=g2:Select(tp,1,#sg1,nil)
	local tg=Group.CreateGroup()
	tg:Merge(sg1)
	tg:Merge(sg2)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,tg,#tg,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tg=Duel.GetTargetCards(e)
	for tc in aux.Next(tg) do
		if tc:IsRelateToEffect(e) and tc:IsFaceup() then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
	end
end
