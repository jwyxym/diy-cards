--对峙的四方主
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.zonetg)
	e1:SetOperation(s.zoneop)
	c:RegisterEffect(e1)
	--act in hand
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e3:SetCountLimit(1,id+1000)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE,PLAYER_NONE,0)>0
end
function s.zonetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	local one=0
	for c in aux.Next(g) do
		one=bit.bor(one,c:GetLinkedZone(1-tp))
	end
	local zone=bit.band(one,0x1f)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,0,zone)>0 and Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x597) and c:IsType(TYPE_LINK)
end
function s.zoneop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	local one=0
	for c in aux.Next(g) do
		one=bit.bor(one,c:GetLinkedZone(1-tp))
	end
	local zone=bit.band(one,0x1f)
		if tc:IsControler(1-tp) and Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,0,zone)>0 then
			local z=0
			local flag=bit.bxor(zone,0xff)*0x10000
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
			z=Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,flag)/0x10000
			local nseq=0
			if z==1 then nseq=0
			elseif z==2 then nseq=1
			elseif z==4 then nseq=2
			elseif z==8 then nseq=3
			else nseq=4 end
			Duel.MoveSequence(tc,nseq)
			if Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0,(2^(4-nseq)))>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				if Duel.GetControl(tc,tp,0,0,(2^(4-nseq))) then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e2)
				end
			end
		end
end

function s.hcfilter(c)
	return c:IsFaceup() and c:GetSequence()>4 and c:IsSetCard(0x597)
end
function s.handcon(e)
	return Duel.IsExistingMatchingCard(s.hcfilter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.spfilter(c)
	return c:IsAbleToHand()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_REMOVED,0,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_REMOVED)
end
function s.tdfilter(c)
	return c:IsAbleToDeck()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_REMOVED,0,e:GetHandler())
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,71680410,0,TYPES_TOKEN_MONSTER,0,0,4,RACE_CYBERSE,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE,tp)
	local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,71680410,0,TYPES_TOKEN_MONSTER,0,0,4,RACE_CYBERSE,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE,1-tp)
	if g:GetCount()==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=g:Select(tp,1,4,nil)
	if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~0 and (b1 or b2) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.BreakEffect()
		local op=0
		if b1 and b2 then
			op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
		elseif b1 then
			op=Duel.SelectOption(tp,aux.Stringid(id,3))
		else
			op=Duel.SelectOption(tp,aux.Stringid(id,4))+1
		end
		local p=tp
		if op>0 then p=1-tp end
		local token=Duel.CreateToken(tp,71680410)
		Duel.SpecialSummon(token,0,tp,p,false,false,POS_FACEUP_DEFENSE)
	end
end