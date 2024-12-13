--苍炎之爆裂
local this,id,ofs=GetID()
function this.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCondition(this.con)
    e1:SetTarget(this.tg)
    e1:SetOperation(this.op)
    c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(this.sptg)
	e2:SetOperation(this.spop)
	c:RegisterEffect(e2)
	if not this.glocal_check then
        this.glocal_check = true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_LEAVE_FIELD)
		ge1:SetCondition(this.regcon)
		ge1:SetOperation(this.regop)
		Duel.RegisterEffect(ge1,0)
    end
end
function this.regfilter(c)
    return c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_EFFECT)
end
function this.regcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(this.regfilter,1,nil)
end
function this.regop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
function this.filter(c)
    return (c:IsSetCard(0x678) or c:IsSetCard(0x674)) and c:IsFaceup()
end
function this.con(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(this.filter,tp,LOCATION_MZONE,0,1,nil)
    and (Duel.GetTurnPlayer()==tp or Duel.GetFlagEffect(tp,id)>0)
end
function this.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() end
    if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local tc=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
function this.op(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Destroy(tc,REASON_EFFECT) end
end
function this.spfilter(c,e,tp)
	return c:IsRace(RACE_WYRM) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function this.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(this.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function this.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,this.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()<=0 then return end
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
