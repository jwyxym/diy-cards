--大千录 ＋登阶＋
local this,id,ofs=GetID()
function this.initial_effect(c)
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e1:SetOperation(this.thop)
    c:RegisterEffect(e1)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(this.immcon)
	e4:SetValue(this.immval)
	c:RegisterEffect(e4)
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_SZONE,0)
	e2:SetTarget(this.immtarget)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
function this.thfilter(c)
	return (c:IsSetCard(0x3980) and c:IsType(TYPE_MONSTER) or c:IsSetCard(0x3981) and c:IsType(TYPE_SPELL)) and c:IsAbleToHand()
end
function this.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(this.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function this.immfilter(c)
    return c:IsCode(10400010) and c:IsFaceup()
end
function this.immcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(this.immfilter,tp,LOCATION_MZONE,0,1,nil)
end
function this.immval(e,te)
	return te:GetOwner()~=e:GetOwner()
end
function this.immtarget(e,c)
    return c:IsSetCard(0x3981) and c:IsFaceup()
end
