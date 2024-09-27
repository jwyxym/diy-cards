--晨跃 FIGHT！
local this,id,ofs=GetID()
function this.initial_effect(c)
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetCost(this.cost)
    e1:SetTarget(this.tg)
    e1:SetOperation(this.op)
    c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id)
	e2:SetTarget(this.reptg)
	e2:SetValue(this.repval)
	e2:SetOperation(this.repop)
	c:RegisterEffect(e2)
end
function this.filter(c)
    return c:IsSetCard(0x677) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
function this.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(this.filter,tp,LOCATION_DECK,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local tc=Duel.SelectMatchingCard(tp,this.filter,tp,LOCATION_DECK,0,1,1,nil)
    Duel.SendtoGrave(tc,REASON_COST)
end
function this.tg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsPlayerCanSpecialSummonMonster(tp,21300241,0x677,TYPES_TOKEN_MONSTER,1500,1200,3,RACE_CYBERSE,ATTRIBUTE_WIND) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
end
function this.op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,21300241,0x677,TYPES_TOKEN_MONSTER,1500,1200,3,RACE_CYBERSE,ATTRIBUTE_WIND) then return end
	local token=Duel.CreateToken(tp,21300241)
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UNRELEASABLE_SUM)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetValue(1)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    token:RegisterEffect(e1)
end
function this.repfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE) and c:IsLocation(LOCATION_MZONE)
		and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
function this.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(this.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function this.repval(e,c)
	return this.repfilter(c,e:GetHandlerPlayer())
end
function this.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
