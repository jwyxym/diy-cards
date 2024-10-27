--惑星兽 石像鬼
local this,id,ofs=GetID()
function this.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(this.sumtg)
	e1:SetOperation(this.sumop)
	c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_ATKCHANGE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,id+1)
    e3:SetCost(this.atkcost)
    e3:SetTarget(this.atktg)
    e3:SetOperation(this.atkop)
    c:RegisterEffect(e3)
end
function this.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsSetCard(0x1380)
end
function this.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(this.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function this.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,this.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function this.atkfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x380) and c:IsType(TYPE_SYNCHRO)
end
function this.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local b=e:GetHandler():IsAbleToRemoveAsCost()
    if Duel.IsPlayerAffectedByEffect(tp,38000071) and Duel.GetFlagEffect(tp,38000071)==0 then
        if chk==0 then return Duel.CheckLPCost(1-tp,500) and b end
        Duel.PayLPCost(1-tp,500)
        Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
    else
        if chk==0 then return Duel.CheckLPCost(tp,500) and b end
        Duel.PayLPCost(tp,500)
        Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
    end
end
function this.atktg(e,tp,eg,ep,ev,rr,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(this.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
end
function this.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(this.atkfilter,tp,LOCATION_MZONE,0,nil)
    for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
    end
end
