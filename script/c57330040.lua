--表里侦探·诺·莱芙
local s,id,o=GetID()
local SHEN=57330010
local MEITAN=57330050

function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddCodeList(c,SHEN)
	--①：自己·对方回合，把手卡的这张卡给对方观看才能发动。这张卡回到卡组。从卡组把1张「神域的物证」加入手卡。自己场上有「神域的物证」表侧表示存在的场合，也可以作为代替选对手场上1只表侧表示卡的效果无效
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--②：这张卡特殊召唤成功的场合才能发动。从额外卡组把1只「名侦探/大罪犯·诺·莱芙」特殊召唤。那之后，把以下效果依照这场决斗中自己发动过的「神域的物证」的②效果的次数与「名侦探/大罪犯·诺·莱芙」的②效果的次数的合计次数重复适用
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+1000)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
end

--①
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.ConfirmCards(1-tp,e:GetHandler())
end
function s.thfilter(c)
	return c:IsCode(SHEN) and c:IsAbleToHand()
end
function s.shenfilter(c)
	return c:IsFaceup() and c:IsCode(SHEN)
end
function s.disfilter(c)
	return c:IsFaceup()
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
			or (Duel.IsExistingMatchingCard(s.shenfilter,tp,LOCATION_ONFIELD,0,1,nil)
				and Duel.IsExistingMatchingCard(s.disfilter,tp,0,LOCATION_ONFIELD,1,nil))
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local hasbase=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	local hasalt=Duel.IsExistingMatchingCard(s.shenfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingMatchingCard(s.disfilter,tp,0,LOCATION_ONFIELD,1,nil)
	if not hasbase and not hasalt then return end
	local choice=0
	if hasbase and hasalt then
		choice=Duel.SelectOption(tp,aux.Stringid(id,8),aux.Stringid(id,9))
	elseif hasalt then
		choice=1
	end
	if c:IsRelateToEffect(e) then
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
	Duel.BreakEffect()
	if choice==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g=Duel.SelectMatchingCard(tp,s.disfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			local e1=Effect.CreateEffect(tc)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end

--②
function s.spfilter(c,e,tp)
	return c:IsCode(MEITAN) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.mdfilter(c)
	return c:IsCode(MEITAN) and c:IsFaceup()
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		end
	end
	local n=Duel.GetFlagEffect(tp,SHEN)+Duel.GetFlagEffect(tp,MEITAN)
	if n<=0 then return end
	local mg=Duel.GetMatchingGroup(s.mdfilter,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(mg) do
		local atk=tc:GetAttack()
		local def=tc:GetDefense()
		for i=1,n do
			atk,def=def,atk
			atk=atk+500
		end
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk-tc:GetAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetValue(def-tc:GetDefense())
		tc:RegisterEffect(e2)
	end
end
