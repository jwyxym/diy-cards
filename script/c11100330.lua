--欧卡伦-超自然小子
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,11100315,11100333)
    --search to hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
    --xyz
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
--tohand
function s.thfilter(c)
	return aux.IsCodeListed(c,11100315) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
        if Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,11100339,0,TYPES_TOKEN_MONSTER,1100,1100,1,RACE_WARRIOR,ATTRIBUTE_LIGHT) then
		Duel.BreakEffect()
		local token=Duel.CreateToken(tp,11100339)
		Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP)
	end
	end
end
--xyz
function s.xyzfilter(c,e,tp)
    local mc=e:GetHandler()
	return c:IsCode(11100333)
		and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
function s.chkfilter(c)
	return c:IsFaceupEx() and c:IsCode(11100315) and not c:IsForbidden()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) 
        and Duel.IsExistingMatchingCard(s.chkfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local mg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,e)
	local sg=Duel.GetMatchingGroup(s.chkfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE,0,nil,mg)
	if sg:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		Duel.ConfirmCards(1-tp,tc)
        if mg:GetCount()>0 and c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp) 
        and not c:IsImmuneToEffect(e) and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local g=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c)
            local sc=g:GetFirst()
            if sc then
                sc:SetMaterial(Group.FromCards(c))
                Duel.Overlay(sc,Group.FromCards(c))
                if Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)~=0 then
                    sc:CompleteProcedure()
                    if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and sc:IsFaceup() then
                        Duel.BreakEffect()
                        Duel.Equip(tp,tc,sc)
                        local e1=Effect.CreateEffect(c)
                        e1:SetType(EFFECT_TYPE_SINGLE)
                        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
                        e1:SetCode(EFFECT_EQUIP_LIMIT)
                        e1:SetLabelObject(sc)
                        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                        e1:SetValue(s.eqlimit)
                        tc:RegisterEffect(e1)
                        local e2=Effect.CreateEffect(c)
                        e2:SetType(EFFECT_TYPE_EQUIP)
                        e2:SetCode(EFFECT_UPDATE_ATTACK)
                        e2:SetValue(1000)
                        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
                        tc:RegisterEffect(e2)
                    end
                end
            end
        end
	end
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- tc:IsRelateToEffect(e) and