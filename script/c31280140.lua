--械鳞龙魄 龙威之核
function c31280140.initial_effect(c)
	--发动
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,31280140+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c31280140.activate)
	c:RegisterEffect(e1)
	--仪式召唤 
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(31280140,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,31380140)
    e2:SetCondition(c31280140.condition)
	e2:SetTarget(c31280140.target)
	e2:SetOperation(c31280140.operation)
	c:RegisterEffect(e2)
	--卡组贴p  
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(31280140,2))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c31280140.condition1)
	e3:SetTarget(c31280140.target1)
	e3:SetOperation(c31280140.operation1)
	c:RegisterEffect(e3)  
end
function c31280140.filter(c)
	return c:IsSetCard(0xca4) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c31280140.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c31280140.filter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(31280140,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function c31280140.condition(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rc:GetOriginalType()&TYPE_MONSTER~=0
		and (re:GetActivateLocation()&LOCATION_ONFIELD~=0 or re:IsHasType(EFFECT_TYPE_ACTIVATE)) 
end
function c31280140.dfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_PENDULUM) and c:IsFaceup() and c:IsAbleToDeck()
end
function c31280140.spfilter(c,e,tp)
	return c:IsRace(RACE_MACHINE) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end
function c31280140.rcheck(tp,g,c)
	return g:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)>=0
end
function c31280140.rgcheck(g,ec)
	return g:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)>=0
end
function c31280140.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetRitualMaterial(tp)
		local dg=Duel.GetMatchingGroup(c31280140.dfilter,tp,LOCATION_EXTRA,0,nil)
		aux.RCheckAdditional=c31280140.rcheck
		aux.RGCheckAdditional=c31280140.rgcheck
		local res=Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,nil,c31280140.spfilter,e,tp,mg,dg,Card.GetLevel,"Greater")
		aux.RCheckAdditional=nil
		aux.RGCheckAdditional=nil
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_EXTRA)
end
function c31280140.operation(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	local m=Duel.GetRitualMaterial(tp)
	local dg=Duel.GetMatchingGroup(c31280140.dfilter,tp,LOCATION_EXTRA,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	aux.RCheckAdditional=c31280140.rcheck
	aux.RGCheckAdditional=c31280140.rgcheck
	local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(aux.RitualUltimateFilter),tp,LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil,c31280140.spfilter,e,tp,m,dg,Card.GetLevel,"Greater")
	local tc=tg:GetFirst()
	if tc then
		local mg=m:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		mg:Merge(dg)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Greater")
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Greater")
		aux.GCheckAdditional=nil
		if not mat then
			aux.RCheckAdditional=nil
			aux.RGCheckAdditional=nil
			goto cancel
		end
		tc:SetMaterial(mat)
		local dmat=mat:Filter(Card.IsLocation,nil,LOCATION_EXTRA)
		if dmat:GetCount()>0 then
			mat:Sub(dmat)
			Duel.SendtoDeck(dmat,tp,nil,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		end
		Duel.ReleaseRitualMaterial(mat)	
        Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()	
	end
	aux.RCheckAdditional=nil
	aux.RGCheckAdditional=nil
end
function c31280140.cfilter(c)
	return c:IsSetCard(0xca4) and c:IsFaceup()
end
function c31280140.condition1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(c31280140.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c31280140.penfilter(c)
	return c:IsSetCard(0xca4) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end
function c31280140.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) 
    	and Duel.IsExistingMatchingCard(c31280140.penfilter,tp,LOCATION_DECK,0,1,nil) end
end	
function c31280140.operation1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,c31280140.penfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end