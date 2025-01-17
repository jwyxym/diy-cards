--333号-新星偶像宣战书
local s,id,o=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,11100110)
	--activate
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
    --set
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_POSITION)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetCountLimit(1,id+o)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetTarget(s.sttg)
	e2:SetOperation(s.stop)
	c:RegisterEffect(e2)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>2 end
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_REPTILE) and c:IsType(TYPE_NORMAL) and c:IsLevel(3) and not c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.cfilter(c,tp)
	return c:IsCode(11100110)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<=3 then return end
    if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>12
    and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil) then
        Duel.ConfirmDecktop(tp,13)
        local g=Duel.GetDecktopGroup(tp,13)
        local ct=g:GetCount()
	    if ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:FilterCount(s.spfilter,nil,e,tp)>0
		    and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		    Duel.DisableShuffleCheck()
		    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		    local sg=g:FilterSelect(tp,s.spfilter,1,1,nil,e,tp)
		    Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		    ct=g:GetCount()-sg:GetCount()
	    end
        if ct>0 then
            Duel.SortDecktop(tp,tp,ct)
            for i=1,ct do
                local mg=Duel.GetDecktopGroup(tp,1)
                Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
            end
        end
    else
        Duel.ConfirmDecktop(tp,3)
        local g=Duel.GetDecktopGroup(tp,3)
        local ct=g:GetCount()
        if ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:FilterCount(s.spfilter,nil,e,tp)>0
            and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
            Duel.DisableShuffleCheck()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local sg=g:FilterSelect(tp,s.spfilter,1,1,nil,e,tp)
            Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
            ct=g:GetCount()-sg:GetCount()
            if ct>0 then
                Duel.SortDecktop(tp,tp,ct)
                for i=1,ct do
                    local mg=Duel.GetDecktopGroup(tp,1)
                    Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
                end
            end
        end
	end
end
function s.filter(c)
	return c:IsFaceup() and c:IsCanTurnSet() and c:IsCode(11100110)
end
function s.sttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) and c:IsSSetable() end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
function s.stop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
    local c=e:GetHandler()
	if tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() then
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
        if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then Duel.SSet(tp,c) end
	end
end