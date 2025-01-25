--算子械出动！
local this,id,ofs=GetID()
function this.initial_effect(c)
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(this.tg)
    e1:SetOperation(this.op)
    c:RegisterEffect(e1)
end
function this.rmfilter(c,e,tp)
    return c:IsSetCard(0x404) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
    and Duel.IsExistingMatchingCard(this.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetLevel())
end
function this.spfilter1(c,e,tp,lv)
    return c:IsSetCard(0x404) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    and Duel.IsExistingMatchingCard(this.spfilter2,tp,LOCATION_DECK,0,1,c,e,tp,lv,c:GetLevel())
end
function this.spfilter2(c,e,tp,lv,dlv)
    local max=math.max(dlv,c:GetLevel())
    local min=math.min(dlv,c:GetLevel())
    return c:IsSetCard(0x404) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    and (max+min==lv or max-min==lv or max*min==lv or max/min==lv)
end
function this.tg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(this.rmfilter,tp,LOCATION_HAND,0,1,nil,e,tp) and Duel.GetMZoneCount(tp)>=2 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local tc=Duel.SelectMatchingCard(tp,this.rmfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
    e:SetLabel(tc:GetLevel())
    Duel.Remove(tc,POS_FACEUP,REASON_COST)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
function this.op(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc1=Duel.SelectMatchingCard(tp,this.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp,e:GetLabel()):GetFirst()
    if tc1 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local tc2=Duel.SelectMatchingCard(tp,this.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,e:GetLabel(),tc1:GetLevel())
        if tc2 and #tc2==1 then
            tc2:AddCard(tc1)
            Duel.SpecialSummon(tc2,0,tp,tp,false,false,POS_FACEUP)
        end
    end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(this.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function this.splimit(e,c)
	return not c:IsSetCard(0x404)
end
