--惑星 瀚空之门
local this,id,ofs=GetID()
function this.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(this.ac)
	c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCountLimit(1,id+1)
    e2:SetCost(this.spcost)
    e2:SetTarget(this.sptg)
    e2:SetOperation(this.spop)
    c:RegisterEffect(e2)
end
function this.acfilter(c)
	return c:IsSetCard(0x1380) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function this.ac(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(this.acfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function this.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if Duel.IsPlayerAffectedByEffect(tp,38000071) and Duel.GetFlagEffect(tp,38000071)==0 then
	if chk==0 then return Duel.CheckLPCost(1-tp,2000) end
		Duel.PayLPCost(1-tp,2000)
		Duel.RegisterFlagEffect(tp,38000071,RESET_PHASE+PHASE_END,0,1)
	else
		if chk==0 then return Duel.CheckLPCost(tp,2000) end
		Duel.PayLPCost(tp,2000)
	end
end
function this.sumfilter(c,e,tp)
    local g=Duel.GetMatchingGroup(this.tunerfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,c:GetLevel())
    if #g<1 then return false end
    if g:IsExists(Card.IsOnField,1,nil) then
        return c:IsSetCard(0x380) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
    else
        return c:IsSetCard(0x380) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
            and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
    end
end
function this.tunerfilter(c,lv)
    local g=Duel.GetMatchingGroup(this.filter,c:GetControler(),LOCATION_MZONE+LOCATION_GRAVE,0,nil)
    return c:IsSetCard(0x380) and c:IsType(TYPE_TUNER) and c:IsAbleToRemoveAsCost()
    and g:CheckSubGroup(this.gcheck,1,2,lv-c:GetLevel())
end
function this.filter(c)
    return c:IsSetCard(0x380) and not c:IsType(TYPE_TUNER) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function this.gcheck(g,lv)
    return (g:GetSum(Card.GetLevel))==lv
end
function this.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(this.sumfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,tp,LOCATION_MZONE+LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function this.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sc=Duel.SelectMatchingCard(tp,this.sumfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
    if not sc then return end
    Duel.ConfirmCards(1-tp,sc)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local tc
    if Duel.GetLocationCountFromEx(tp,tp,nil,sc)==0 then
        tc=Duel.SelectMatchingCard(tp,this.tunerfilter,tp,LOCATION_MZONE,0,1,1,nil,sc:GetLevel()):GetFirst()
    else
        tc=Duel.SelectMatchingCard(tp,this.tunerfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,sc:GetLevel()):GetFirst()
    end
    if not tc then return end
    local g=Duel.GetMatchingGroup(this.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,tc)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local mg=g:SelectSubGroup(tp,this.gcheck,false,1,2,sc:GetLevel()-tc:GetLevel())
    if mg then
        mg:AddCard(tc)
        if Duel.Remove(mg,POS_FACEUP,REASON_EFFECT)>0 then
            Duel.BreakEffect()
			sc:SetMaterial(nil)
			if Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
				sc:CompleteProcedure()
			end
        end
    end
end
