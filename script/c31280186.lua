--械鳞龙魄 待机
function c31280186.initial_effect(c)
	--发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--堆墓并抽卡
	local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(31280186,0))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,31280186)
	e2:SetTarget(c31280186.target)
	e2:SetOperation(c31280186.operation)
	c:RegisterEffect(e2)
	--仪式召唤    
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(31280186,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,31380186)
    e3:SetCondition(c31280186.condition1)
	e3:SetTarget(c31280186.target1)
	e3:SetOperation(c31280186.operation1)
	c:RegisterEffect(e3)
end    
function c31280186.tgfilter(c,check)
	return ((c:IsSetCard(0xca4) and c:IsType(TYPE_PENDULUM) and c:IsType(TYPE_MONSTER)) or (check and c:IsCode(31280113))) and c:IsAbleToGrave()
end
function c31280186.checkfilter(c)
	return c:IsFaceup() and (c:IsType(TYPE_RITUAL) or c:IsType(TYPE_LINK)) and c:IsRace(RACE_DRAGON)
end
function c31280186.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
    	local check=Duel.IsExistingMatchingCard(c31280186.checkfilter,tp,LOCATION_MZONE,0,1,nil)
    	return Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingMatchingCard(c31280186.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,check) 
    end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c31280186.operation(e,tp,eg,ep,ev,re,r,rp)
	local check=Duel.IsExistingMatchingCard(c31280186.checkfilter,tp,LOCATION_MZONE,0,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local c=e:GetHandler()
	local g=Duel.SelectMatchingCard(tp,c31280186.tgfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,check)
    local sg=g:GetFirst()
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and sg:IsLocation(LOCATION_GRAVE) then
    	Duel.BreakEffect()    
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
function c31280186.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xca4,0xca6) and c:IsSummonPlayer(tp)
end
function c31280186.condition1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c31280186.cfilter,1,nil,tp)
end
function c31280186.dfilter(c)
	return c:IsSetCard(0xca4,0xca6) and c:IsAbleToDeck()
end
function c31280186.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function c31280186.rcheck(tp,g,c)
	return g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)>=0
end
function c31280186.rgcheck(g,ec)
	return g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)>=0
end
function c31280186.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetRitualMaterial(tp)
		local dg=Duel.GetMatchingGroup(c31280186.dfilter,tp,LOCATION_GRAVE,0,nil)
		aux.RCheckAdditional=c31280186.rcheck
		aux.RGCheckAdditional=c31280186.rgcheck
		local res=Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,c31280186.spfilter,e,tp,mg,dg,Card.GetLevel,"Greater")
		aux.RCheckAdditional=nil
		aux.RGCheckAdditional=nil
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end
function c31280186.operation1(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	local m=Duel.GetRitualMaterial(tp)
	local dg=Duel.GetMatchingGroup(c31280186.dfilter,tp,LOCATION_GRAVE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	aux.RCheckAdditional=c31280186.rcheck
	aux.RGCheckAdditional=c31280186.rgcheck
	local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(aux.RitualUltimateFilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,c31280186.spfilter,e,tp,m,dg,Card.GetLevel,"Greater")
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
		local dmat=mat:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
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