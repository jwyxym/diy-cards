--混沌诅咒
function c38030162.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,38030162+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c38030162.target)
	e1:SetOperation(c38030162.activate)
	c:RegisterEffect(e1)
end
function c38030162.spfilter(c,e,tp,chk)
	return c:IsSetCard(0x5616) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (chk==0 or aux.NecroValleyFilter()(c))-- and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsType(TYPE_MONSTER)
end
function c38030162.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsPlayerCanDraw(tp,1)
	local b2=Duel.GetMZoneCount(tp)>0
		and Duel.IsExistingMatchingCard(c38030162.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,0)
	if chk==0 then return b1 or b2 end
	local b3=b1 and b2 and Duel.GetCounter(tp,1,0,0x611)>=10
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(38030162,0)},
		{b2,aux.Stringid(38030162,1)},
		{b3,aux.Stringid(38030162,2)})
	e:SetLabel(op)
	if op~=2 then
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
	if op~=1 then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	end
	local cat=op==1 and CATEGORY_DRAW or CATEGORY_SPECIAL_SUMMON
	if op==3 then cat=CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON end
	e:SetCategory(cat)
end
function c38030162.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local res=0
	if op~=2 then
		res=Duel.Draw(tp,1,REASON_EFFECT)
	end
	if op~=1 then
		if Duel.GetMZoneCount(tp)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,c38030162.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,1):GetFirst()
		if sc then
			if op==3 and res~=0 then Duel.BreakEffect() end
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
