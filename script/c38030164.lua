--混融的团结者
function c38030164.initial_effect(c)
	--spsummon-self
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38030164,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,38030164+1)
	e1:SetCondition(c38030164.spcon)
	e1:SetTarget(c38030164.sptg)
	e1:SetOperation(c38030164.spop)
	c:RegisterEffect(e1)
	--select
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38030164,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,38030164)
	e2:SetCondition(c38030164.icon)
	e2:SetTarget(c38030164.sltg)
	e2:SetOperation(c38030164.slop)
	c:RegisterEffect(e2)
	local e0=e2:Clone()
	e0:SetHintTiming(TIMING_DAMAGE_STEP,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE+TIMING_DAMAGE_STEP)
	e0:SetType(EFFECT_TYPE_QUICK_O)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e0:SetCondition(c38030164.qcon)
	c:RegisterEffect(e0)
end
function c38030164.cfilter(c)
	return c:IsSetCard(0x5616) and c:IsFaceup()
end
function c38030164.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c38030164.cfilter,tp,LOCATION_MZONE,0,2,nil)
end
function c38030164.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c38030164.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	--if not c:IsRelateToChain() or Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
end
function c38030164.icon(e,tp,eg,ep,ev,re,r,rp)
	return not (Duel.IsPlayerAffectedByEffect(tp,38030153)~=nil and e:GetHandler():IsOriginalSetCard(0x5616))
end
function c38030164.qcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsPlayerAffectedByEffect(tp,38030153)~=nil and e:GetHandler():IsOriginalSetCard(0x5616)
end
function c38030164.spfilter(c,e,tp,pos)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,pos)
end
function c38030164.gcheck(g,e,tp)
	local c1=g:GetFirst()
	local c2=g:GetNext()
	return c38030164.spfilter(c1,e,tp,POS_FACEUP_ATTACK) and c38030164.spfilter(c2,e,tp,POS_FACEUP_DEFENSE) or c38030164.spfilter(c2,e,tp,POS_FACEUP_ATTACK) and c38030164.spfilter(c1,e,tp,POS_FACEUP_DEFENSE) 
end
function c38030164.sltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,38030164)
	local b1=g:IsExists(c38030164.spfilter,1,nil,e,tp,POS_FACEUP_ATTACK) and Duel.GetMZoneCount(tp)>0
	local b2=g:IsExists(c38030164.spfilter,1,nil,e,tp,POS_FACEUP_DEFENSE) and Duel.GetMZoneCount(tp)>0
	local b3=true
	if chk==0 then return b1 or b2 or b3 end
	local cat=0
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(38030164,0),1},
		{b2,aux.Stringid(38030164,1),2},
		{b3,aux.Stringid(38030164,2),4})
	if op==1 then
		cat=cat+CATEGORY_SPECIAL_SUMMON
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
		b1=false
		b2=g:CheckSubGroup(c38030164.gcheck,2,2,e,tp) and Duel.IsPlayerCanSpecialSummonCount(tp,2) and Duel.GetMZoneCount(tp)>=2
	elseif op==2 then
		cat=cat+CATEGORY_SPECIAL_SUMMON
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
		b2=false
		b1=g:CheckSubGroup(c38030164.gcheck,2,2,e,tp) and Duel.IsPlayerCanSpecialSummonCount(tp,2) and Duel.GetMZoneCount(tp)>=2
	elseif op==4 then
		cat=cat+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE
		b3=false
	end
	if Duel.GetCounter(tp,1,0,0x611)>=10 and (b1 or b2 or b3) then
		local b4=true
		local s=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(38030164,0),1},
			{b2,aux.Stringid(38030164,1),2},
			{b3,aux.Stringid(38030164,2),4},
			{b4,aux.Stringid(38030164,3),0})
		if s==1 or s==2 then
			cat=cat+CATEGORY_SPECIAL_SUMMON
			Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
		else
			cat=cat+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE
		end
		op=op+s
	end
	e:SetLabel(op)
	e:SetCategory(cat)
end
function c38030164.slop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local res=0
	if (op&1)~=0 then
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsCode),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,38030164)
		if Duel.GetMZoneCount(tp)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=g:FilterSelect(tp,c38030164.spfilter,1,1,nil,e,tp,POS_FACEUP_ATTACK):GetFirst()
			if sc then
				res=Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP_ATTACK)
			end
		end
	end
	if (op&2)~=0 then
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsCode),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,38030164)
		if Duel.GetMZoneCount(tp)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=g:FilterSelect(tp,c38030164.spfilter,1,1,nil,e,tp,POS_FACEUP_DEFENSE):GetFirst()
			if sc then
				res=Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			end
		end
	end
	if (op&4)~=0 then
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
		if #g==0 then return end
		if res~=0 then Duel.BreakEffect() end
		for tc in aux.Next(g) do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			--e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e1:SetValue(1500)
			--e1:SetRange(LOCATION_MZONE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			tc:RegisterEffect(e2)
		end
	end
end
