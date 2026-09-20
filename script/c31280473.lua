--冥域的烈牙·欧特鲁斯
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,31280102)
	--特殊召唤
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--适用效果    
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DESTROY+CATEGORY_TOGRAVE+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o*10000)
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
function s.confilter(c)
	return aux.IsCodeListed(c,31280102) and c:IsType(TYPE_MONSTER) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,e:GetHandler())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() or Duel.IsBattlePhase()
end
function s.thfilter(c)
	return aux.IsCodeListed(c,31280102) and c:IsType(TYPE_MONSTER) and c:IsLevelAbove(6)
    	and c:IsAbleToHand() and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED))
end
function s.tgfilter(c)
	return c:IsAbleToGrave() and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
end
function s.fselect(g,hg,zg)
	return g:FilterCount(Card.IsLocation,nil,LOCATION_HAND)<=hg:GetCount()
    	and g:FilterCount(Card.IsLocation,nil,LOCATION_ONFIELD)<=zg:GetCount() 
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,c)
    local hg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
    local zg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return g:CheckSubGroup(s.fselect,1,2,hg,zg)
    	and (hg:GetCount()>0 or zg:GetCount()>0) end
    local tg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,c)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,tg,1,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,c)
    local hg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
    local zg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg=g:SelectSubGroup(tp,s.fselect,false,1,2,hg,zg)
	if tg and tg:GetCount()>0 and Duel.SendtoGrave(tg,REASON_EFFECT)~=0 then
    	local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_GRAVE)
        if og:GetCount()<=0 then return end
        local hc=og:FilterCount(Card.IsPreviousLocation,nil,LOCATION_HAND)
        local zc=og:FilterCount(Card.IsPreviousLocation,nil,LOCATION_ONFIELD)
        local res=false
        if hc>0 then
        	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,hc,hc,nil)
			if sg:GetCount()>0 then
				res=Duel.SendtoHand(sg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,sg)
			end
        end
        if zc>0 then
        	if res then Duel.BreakEffect() end
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local dg=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,zc,zc,nil)
			if dg:GetCount()>0 then
				Duel.HintSelection(dg)
                Duel.Destroy(dg,REASON_EFFECT)
			end
        end
    end
end