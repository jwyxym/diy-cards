--惑星兽 泰坦
local this,id,ofs=GetID()
function this.initial_effect(c)
    aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x1380),aux.NonTuner(nil),1,1)
    c:EnableReviveLimit()
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(this.descost)
	e2:SetTarget(this.destg)
	e2:SetOperation(this.desop)
	c:RegisterEffect(e2)
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetCountLimit(1,id)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCondition(this.spcon)
    e2:SetTarget(this.sptg)
    e2:SetOperation(this.spop)
    c:RegisterEffect(e2)
end
function this.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk)
end
function this.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if Duel.IsPlayerAffectedByEffect(tp,38000071) and Duel.GetFlagEffect(tp,38000071)==0 then
	if chk==0 then return Duel.CheckLPCost(1-tp,2000) end
		Duel.PayLPCost(1-tp,2000)
		Duel.RegisterFlagEffect(tp,38000071,RESET_PHASE+PHASE_END,0,1)
	else
		if chk==0 then return Duel.CheckLPCost(tp,2000) end
		Duel.PayLPCost(tp,2000)
	end
end
function this.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(this.desfilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack()) end
	local g=Duel.GetMatchingGroup(this.desfilter,tp,0,LOCATION_MZONE,nil,c:GetAttack())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function this.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local g=Duel.GetMatchingGroup(this.desfilter,tp,0,LOCATION_MZONE,nil,c:GetAttack())
	Duel.Destroy(g,REASON_EFFECT)
end
function this.spfilter(c,e,tp)
    return c:IsSetCard(0x1380) and c:IsLevelBelow(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function this.spcon(e,tp,eg,ep,ev,re,r,rp)
    return bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
function this.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and this.spfilter(chkc,e,tp) end
    if chk==0 then return Duel.IsExistingTarget(this.spfilter,tp,LOCATION_GRAVE,0,2,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local tg=Duel.SelectTarget(tp,this.spfilter,tp,LOCATION_GRAVE,0,2,2,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,2,tp,LOCATION_GRAVE)
end
function this.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
    for tc in aux.Next(tg) do
        if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e1)
            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetValue(RESET_TURN_SET)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e2)
        end
    end
    Duel.SpecialSummonComplete()
end
