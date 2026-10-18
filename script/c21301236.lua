--艾瑞希娅 阿什伍德
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,21301247)
	--同调召唤	
	aux.AddSynchroMixProcedure(c,aux.Tuner(nil),nil,nil,s.mtfilter,1,1)
	c:EnableReviveLimit()
	--卡组检索    
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--特殊召唤    
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.mtfilter(c)
	return c:IsSetCard(0x684) or aux.IsCodeListed(c,21301247)
end
function s.thfilter(c,e,tp,check)
	return (c:IsSetCard(0x684) or aux.IsCodeListed(c,21301247)) and c:IsType(TYPE_MONSTER)
		and (c:IsAbleToHand() or (check and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,check) end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,check):GetFirst()    
	if tc then
    	local c=e:GetHandler()
    	local res=false
		if tc:IsAbleToHand() and (not (check and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)) or Duel.SelectOption(tp,1190,1152)==0) then
			if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
				Duel.ConfirmCards(1-tp,tc)
            	res=true
            end
		else
			res=Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
        if res and c:IsRelateToEffect(e) and c:IsFaceup() and c:GetLevel()>0 and tc:GetLevel()>0
        	and tc:IsLevelBelow(c:GetLevel()-1) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        	Duel.BreakEffect()
            local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetValue(-tc:GetLevel())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
        end
	end
end
function s.spfilter(c,e,tp)
	return (c:IsSetCard(0x684) or aux.IsCodeListed(c,21301247)) and not c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end