--惑星重启
local this,id,ofs=GetID()
function this.initial_effect(c)
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_POSITION+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCondition(this.acon)
    e1:SetCost(this.acost)
    e1:SetTarget(this.atg)
    e1:SetOperation(this.aop)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(aux.exccon)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(this.sptg)
    e2:SetOperation(this.spop)
    c:RegisterEffect(e2)
end
function this.afilter(c)
    return c:IsSetCard(0x380) and c:IsFaceup()
end
function this.afilter2(c)
    return c:IsFaceup() and c:IsCanTurnSet()
end
function this.acon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(this.afilter,tp,LOCATION_MZONE,0,1,nil)
end
function this.acost(e,tp,eg,ep,ev,re,r,rp,chk)
	if Duel.IsPlayerAffectedByEffect(tp,38000071) and Duel.GetFlagEffect(tp,38000071)==0 then
	if chk==0 then return Duel.CheckLPCost(1-tp,1000) end
		Duel.PayLPCost(1-tp,1000)
		Duel.RegisterFlagEffect(tp,38000071,RESET_PHASE+PHASE_END,0,1)
	else
		if chk==0 then return Duel.CheckLPCost(tp,1000) end
		Duel.PayLPCost(tp,1000)
	end
end
function this.atg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and this.afilter2(chkc) end
    if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,this.afilter2,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,LOCATION_ONFIELD)
end
function this.aop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() and Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)>0 then
		local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
		if g:GetCount()==0 then return end
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=g:Select(tp,1,1,nil)
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
function this.spfilter(c,e,tp)
    return c:IsSetCard(0x1380) and c:IsCanBeSpecialSummoned(e,0,rp,false,false)
end
function this.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(this.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
        and Duel.GetMZoneCount(tp)>0 end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function this.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(this.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
    if tc then
        Duel.SpecialSummon(tc,SUMMON_TYPE_SPECIAL,tp,tp,false,false,POS_FACEUP)
    end
end
